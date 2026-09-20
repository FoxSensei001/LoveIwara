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
class TranslationsId extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsId({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsId _root = this; // ignore: unused_field

	@override 
	TranslationsId $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsId(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileId personalProfile = _TranslationsPersonalProfileId._(_root);
	@override late final _TranslationsTutorialId tutorial = _TranslationsTutorialId._(_root);
	@override late final _TranslationsCommonId common = _TranslationsCommonId._(_root);
	@override late final _TranslationsAuthId auth = _TranslationsAuthId._(_root);
	@override late final _TranslationsErrorsId errors = _TranslationsErrorsId._(_root);
	@override late final _TranslationsFriendsId friends = _TranslationsFriendsId._(_root);
	@override late final _TranslationsAuthorProfileId authorProfile = _TranslationsAuthorProfileId._(_root);
	@override late final _TranslationsFavoritesId favorites = _TranslationsFavoritesId._(_root);
	@override late final _TranslationsGalleryDetailId galleryDetail = _TranslationsGalleryDetailId._(_root);
	@override late final _TranslationsPlayListId playList = _TranslationsPlayListId._(_root);
	@override late final _TranslationsSearchId search = _TranslationsSearchId._(_root);
	@override late final _TranslationsMediaListId mediaList = _TranslationsMediaListId._(_root);
	@override late final _TranslationsSettingsId settings = _TranslationsSettingsId._(_root);
	@override late final _TranslationsFavoriteTagsId favoriteTags = _TranslationsFavoriteTagsId._(_root);
	@override late final _TranslationsOreno3dId oreno3d = _TranslationsOreno3dId._(_root);
	@override late final _TranslationsSignInId signIn = _TranslationsSignInId._(_root);
	@override late final _TranslationsSubscriptionsId subscriptions = _TranslationsSubscriptionsId._(_root);
	@override late final _TranslationsVideoDetailId videoDetail = _TranslationsVideoDetailId._(_root);
	@override late final _TranslationsShareId share = _TranslationsShareId._(_root);
	@override late final _TranslationsMarkdownId markdown = _TranslationsMarkdownId._(_root);
	@override late final _TranslationsForumId forum = _TranslationsForumId._(_root);
	@override late final _TranslationsNotificationsId notifications = _TranslationsNotificationsId._(_root);
	@override late final _TranslationsConversationId conversation = _TranslationsConversationId._(_root);
	@override late final _TranslationsSplashId splash = _TranslationsSplashId._(_root);
	@override late final _TranslationsDownloadId download = _TranslationsDownloadId._(_root);
	@override late final _TranslationsDownloadNotificationsId downloadNotifications = _TranslationsDownloadNotificationsId._(_root);
	@override late final _TranslationsFavoriteId favorite = _TranslationsFavoriteId._(_root);
	@override late final _TranslationsTranslationId translation = _TranslationsTranslationId._(_root);
	@override late final _TranslationsBottomNavId bottomNav = _TranslationsBottomNavId._(_root);
	@override late final _TranslationsNavigationOrderSettingsId navigationOrderSettings = _TranslationsNavigationOrderSettingsId._(_root);
	@override late final _TranslationsNewsId news = _TranslationsNewsId._(_root);
	@override late final _TranslationsDisplaySettingsId displaySettings = _TranslationsDisplaySettingsId._(_root);
	@override late final _TranslationsLayoutSettingsId layoutSettings = _TranslationsLayoutSettingsId._(_root);
	@override late final _TranslationsMediaPlayerId mediaPlayer = _TranslationsMediaPlayerId._(_root);
	@override late final _TranslationsDiagnosticsId diagnostics = _TranslationsDiagnosticsId._(_root);
	@override late final _TranslationsLogViewerId logViewer = _TranslationsLogViewerId._(_root);
	@override late final _TranslationsCrashRecoveryDialogId crashRecoveryDialog = _TranslationsCrashRecoveryDialogId._(_root);
	@override late final _TranslationsLinkInputDialogId linkInputDialog = _TranslationsLinkInputDialogId._(_root);
	@override late final _TranslationsLogId log = _TranslationsLogId._(_root);
	@override late final _TranslationsEmojiId emoji = _TranslationsEmojiId._(_root);
	@override late final _TranslationsSearchFilterId searchFilter = _TranslationsSearchFilterId._(_root);
	@override late final _TranslationsFirstTimeSetupId firstTimeSetup = _TranslationsFirstTimeSetupId._(_root);
	@override late final _TranslationsProxyHelperId proxyHelper = _TranslationsProxyHelperId._(_root);
	@override late final _TranslationsTagSelectorId tagSelector = _TranslationsTagSelectorId._(_root);
	@override late final _TranslationsAnime4kId anime4k = _TranslationsAnime4kId._(_root);
	@override late final _TranslationsSiteModeId siteMode = _TranslationsSiteModeId._(_root);
	@override late final _TranslationsSavedSearchConfigId savedSearchConfig = _TranslationsSavedSearchConfigId._(_root);
	@override late final _TranslationsSavedSearchId savedSearch = _TranslationsSavedSearchId._(_root);
	@override late final _TranslationsDefaultBlacklistReminderId defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderId._(_root);
	@override late final _TranslationsColorVisionAssistId colorVisionAssist = _TranslationsColorVisionAssistId._(_root);
	@override late final _TranslationsExternalPlayerId externalPlayer = _TranslationsExternalPlayerId._(_root);
	@override late final _TranslationsWatchLaterId watchLater = _TranslationsWatchLaterId._(_root);
	@override late final _TranslationsMediaMenuId mediaMenu = _TranslationsMediaMenuId._(_root);
	@override late final _TranslationsMediaPreviewId mediaPreview = _TranslationsMediaPreviewId._(_root);
	@override late final _TranslationsPlaybackQueueId playbackQueue = _TranslationsPlaybackQueueId._(_root);
	@override late final _TranslationsVrFormatId vrFormat = _TranslationsVrFormatId._(_root);
	@override late final _TranslationsLocalMediaId localMedia = _TranslationsLocalMediaId._(_root);
	@override late final _TranslationsHistoryPageId historyPage = _TranslationsHistoryPageId._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileId extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Profil Pribadi';
	@override String get editPersonalProfile => 'Edit Profil Pribadi';
	@override String get avatar => 'Avatar';
	@override String get background => 'Latar Belakang';
	@override String fetchUserProfileFailed({required Object error}) => 'Gagal mengambil profil pengguna: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Resolusi yang disarankan: ${resolution}, ukuran file < ${size}';
	@override String supportedFormats({required Object formats}) => 'Format yang didukung: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Pengguna premium dapat menggunakan ${type} dinamis (${formats})';
	@override String get homepageBackground => 'Latar Belakang Halaman Utama';
	@override String get basicInfo => 'Informasi Dasar';
	@override String get nickname => 'Nama Panggilan';
	@override String get username => 'Nama Pengguna';
	@override String get copyUsername => 'Salin Nama Pengguna';
	@override String get usernameCopied => 'Nama pengguna disalin';
	@override String get personalIntroduction => 'Perkenalan Pribadi';
	@override String get noPersonalIntroduction => 'Tidak ada perkenalan pribadi';
	@override String get clickToEdit => 'Klik untuk mengedit';
	@override String get privacySettings => 'Pengaturan Privasi';
	@override String get hideSensitiveContent => 'Sembunyikan Konten Sensitif';
	@override String get hideSensitiveContentDesc => 'Sembunyikan video atau gambar yang mengandung tag sensitif.';
	@override String get notificationSettings => 'Pengaturan Notifikasi';
	@override String get contentCommentNotification => 'Notifikasi Komentar Konten';
	@override String get contentCommentNotificationDesc => 'Beri tahu saat seseorang mengomentari konten Anda.';
	@override String get commentReplyNotification => 'Notifikasi Balasan Komentar';
	@override String get commentReplyNotificationDesc => 'Beri tahu saat seseorang membalas komentar Anda.';
	@override String get mentionNotification => 'Notifikasi Sebutan';
	@override String get mentionNotificationDesc => 'Beri tahu saat seseorang menyebut Anda dalam konten.';
	@override String get accountInfo => 'Info Akun';
	@override String get registrationTime => 'Waktu Pendaftaran';
	@override String updateSettingsFailed({required Object error}) => 'Gagal memperbarui pengaturan: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'Gagal memperbarui pengaturan notifikasi: ${error}';
	@override String get editNickname => 'Edit Nama Panggilan';
	@override String get nicknameCannotBeEmpty => 'Nama panggilan tidak boleh kosong';
	@override String get changeSuccess => 'Perubahan berhasil';
	@override String get unsupportedFileFormat => 'Format file tidak didukung';
	@override String fileTooLarge({required Object size}) => 'Ukuran file tidak boleh melebihi ${size}';
	@override String get uploadFailed => 'Unggahan gagal';
	@override String get avatarUpdatedSuccessfully => 'Avatar berhasil diperbarui';
	@override String updateAvatarFailed({required Object error}) => 'Gagal memperbarui avatar: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Latar belakang berhasil diperbarui';
	@override String updateBackgroundFailed({required Object error}) => 'Gagal memperbarui latar belakang: ${error}';
	@override String get editPersonalIntroduction => 'Edit Perkenalan Pribadi';
	@override String get enterPersonalIntroduction => 'Silakan masukkan perkenalan pribadi';
}

// Path: tutorial
class _TranslationsTutorialId extends TranslationsTutorialEn {
	_TranslationsTutorialId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Ikuti Khusus';
	@override String get specialFollowDescription => 'Tandai penulis yang paling sering Anda tonton sebagai ikuti khusus, lalu langsung menuju unggahan terbaru mereka dari sini.';
	@override String get stepsTitle => 'Tiga langkah';
	@override String get stepFollowAuthor => 'Ketuk Ikuti pada video, galeri, atau halaman profil penulis.';
	@override String get stepPickSpecial => 'Ketuk Mengikuti lagi, lalu pilih Ikuti Khusus dari menu.';
	@override String get stepSwitchHere => 'Kembali ke sini dan beralih ke penulis itu menggunakan pemilih avatar di atas.';
	@override String get specialFollowManagementTip => 'Kelola daftar ikuti khusus di Bilah Sisi - Daftar Mengikuti - Ikuti Khusus.';
	@override String get gotIt => 'Mengerti';
}

// Path: common
class _TranslationsCommonId extends TranslationsCommonEn {
	_TranslationsCommonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Urutkan';
	@override String get filter => 'Filter';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'OK';
	@override String get cancel => 'Batal';
	@override String get select => 'Pilih';
	@override String get save => 'Simpan';
	@override String get delete => 'Hapus';
	@override String get visit => 'Kunjungi';
	@override String get loading => 'Memuat...';
	@override String get scrollToTop => 'Gulir ke Atas';
	@override String get privacyHint => 'Mode privasi aktif, konten disembunyikan';
	@override String get latest => 'Terbaru';
	@override String get likesCount => 'Suka';
	@override String get viewsCount => 'Dilihat';
	@override String get popular => 'Populer';
	@override String get trending => 'Sedang Tren';
	@override String get commentList => 'Daftar Komentar';
	@override String get sendComment => 'Kirim Komentar';
	@override String get send => 'Kirim';
	@override String get retry => 'Coba Lagi';
	@override String get premium => 'Premium';
	@override String get follower => 'Pengikut';
	@override String get friend => 'Teman';
	@override String get video => 'Video';
	@override String get following => 'Mengikuti';
	@override String get expand => 'Perluas';
	@override String get collapse => 'Ciutkan';
	@override String get cancelFriendRequest => 'Batalkan Permintaan';
	@override String get cancelSpecialFollow => 'Batalkan Ikuti Spesial';
	@override String get addFriend => 'Tambah Teman';
	@override String get removeFriend => 'Hapus Teman';
	@override String get followed => 'Diikuti';
	@override String get follow => 'Ikuti';
	@override String get unfollow => 'Berhenti Mengikuti';
	@override String get specialFollow => 'Ikuti Spesial';
	@override String get specialFollowed => 'Diikuti Spesial';
	@override String get gallery => 'Galeri';
	@override String get playlist => 'Daftar Putar';
	@override String get commentPostedSuccessfully => 'Komentar Berhasil Dikirim';
	@override String get commentPostedFailed => 'Gagal Mengirim Komentar';
	@override String get success => 'Berhasil';
	@override String get commentDeletedSuccessfully => 'Komentar Berhasil Dihapus';
	@override String get commentUpdatedSuccessfully => 'Komentar Berhasil Diperbarui';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} Komentar',
		other: '${n} Komentar',
	);
	@override String get writeYourCommentHere => 'Tulis komentar Anda di sini...';
	@override String get tmpNoReplies => 'Belum ada balasan';
	@override String get loadMore => 'Muat Lebih Banyak';
	@override String get loadingMore => 'Memuat lebih banyak...';
	@override String get noMoreDatas => 'Tidak ada data lagi';
	@override String get selectTranslationLanguage => 'Pilih Bahasa Terjemahan';
	@override String get translate => 'Terjemahkan';
	@override String get translateFailedPleaseTryAgainLater => 'Terjemahan gagal, silakan coba lagi nanti';
	@override String get translationResult => 'Hasil Terjemahan';
	@override String get justNow => 'Baru Saja';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} menit lalu',
		other: '${n} menit lalu',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} jam lalu',
		other: '${n} jam lalu',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} hari lalu',
		other: '${n} hari lalu',
	);
	@override String editedAt({required Object num}) => '${num} diubah';
	@override String get editComment => 'Ubah Komentar';
	@override String get commentUpdated => 'Komentar Diperbarui';
	@override String get replyComment => 'Balas Komentar';
	@override String get reply => 'Balas';
	@override String get edit => 'Ubah';
	@override String get unknownUser => 'Pengguna Tidak Dikenal';
	@override String get me => 'Saya';
	@override String get author => 'Penulis';
	@override String get admin => 'Administrator';
	@override String viewReplies({required Object num}) => 'Lihat Balasan (${num})';
	@override String get hideReplies => 'Sembunyikan Balasan';
	@override String get confirmDelete => 'Konfirmasi Hapus';
	@override String get areYouSureYouWantToDeleteThisItem => 'Apakah Anda yakin ingin menghapus item ini?';
	@override String get tmpNoComments => 'Belum ada komentar';
	@override String get refresh => 'Segarkan';
	@override String get back => 'Kembali';
	@override String get tips => 'Tips';
	@override String get linkIsEmpty => 'Tautan kosong';
	@override String get linkCopiedToClipboard => 'Tautan disalin ke papan klip';
	@override String get imageCopiedToClipboard => 'Gambar disalin ke papan klip';
	@override String get copyImageFailed => 'Gagal menyalin gambar';
	@override String get mobileSaveImageIsUnderDevelopment => 'Simpan gambar di ponsel masih dalam pengembangan';
	@override String get imageSavedTo => 'Gambar disimpan ke';
	@override String get saveImageFailed => 'Gagal menyimpan gambar';
	@override String get close => 'Tutup';
	@override String get more => 'Lainnya';
	@override String get unknownError => 'Kesalahan Tidak Diketahui';
	@override String get moreFeaturesToBeDeveloped => 'Fitur lainnya akan dikembangkan';
	@override String get all => 'Semua';
	@override String selectedRecords({required Object num}) => 'Terpilih ${num} catatan';
	@override String get cancelSelectAll => 'Batalkan Pilih Semua';
	@override String get selectAll => 'Pilih Semua';
	@override String get invertSelection => 'Balik Pilihan';
	@override String get exitEditMode => 'Keluar dari Mode Edit';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => 'Apakah Anda yakin ingin menghapus ${num} item yang dipilih?';
	@override String get searchHistoryRecords => 'Cari Catatan Riwayat...';
	@override String get settings => 'Pengaturan';
	@override String get subscriptions => 'Langganan';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} video',
		other: '${n} video',
	);
	@override String get share => 'Bagikan';
	@override String get areYouSureYouWantToShareThisPlaylist => 'Apakah Anda yakin ingin membagikan daftar putar ini?';
	@override String get editTitle => 'Ubah Judul';
	@override String get editMode => 'Mode Edit';
	@override String get pleaseEnterNewTitle => 'Silakan masukkan judul baru';
	@override String get createPlayList => 'Buat Daftar Putar';
	@override String get create => 'Buat';
	@override String get checkNetworkSettings => 'Periksa Pengaturan Jaringan';
	@override String get general => 'Umum';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Sensitif';
	@override String get year => 'Tahun';
	@override String get month => 'Bulan';
	@override String get tag => 'Tag';
	@override String get private => 'Privat';
	@override String get noTitle => 'Tanpa Judul';
	@override String get search => 'Cari';
	@override String get noContent => 'Tidak ada konten';
	@override String get recording => 'Merekam';
	@override String get paused => 'Dijeda';
	@override String get clear => 'Bersihkan';
	@override String get clearSelection => 'Bersihkan Pilihan';
	@override String get selectItemsToContinue => 'Pilih item untuk melanjutkan';
	@override String andMoreItems({required Object num}) => 'dan ${num} lainnya';
	@override String get batchDelete => 'Hapus Massal';
	@override String get user => 'Pengguna';
	@override String get post => 'Postingan';
	@override String get seconds => 'Detik';
	@override String get comingSoon => 'Segera Hadir';
	@override String get confirm => 'Konfirmasi';
	@override String get hour => 'Jam';
	@override String get minute => 'Menit';
	@override String get clickToRefresh => 'Klik untuk Menyegarkan';
	@override String get history => 'Riwayat';
	@override String get favorites => 'Favorit';
	@override String get friends => 'Teman';
	@override String get playList => 'Daftar Putar';
	@override String get checkLicense => 'Periksa Lisensi';
	@override String get logout => 'Keluar';
	@override String get fensi => 'Penggemar';
	@override String get accept => 'Terima';
	@override String get reject => 'Tolak';
	@override String get clearAllHistory => 'Bersihkan Semua Riwayat';
	@override String get clearAllHistoryConfirm => 'Apakah Anda yakin ingin membersihkan semua riwayat?';
	@override String get followingList => 'Daftar Mengikuti';
	@override String get followersList => 'Daftar Pengikut';
	@override String get follows => 'Mengikuti';
	@override String get fans => 'Penggemar';
	@override String get followsAndFans => 'Mengikuti dan Penggemar';
	@override String get numViews => 'Dilihat';
	@override String get updatedAt => 'Diperbarui Pada';
	@override String get publishedAt => 'Diterbitkan Pada';
	@override String get externalVideo => 'Video Eksternal';
	@override String get originalText => 'Teks Asli';
	@override String get showOriginalText => 'Tampilkan Teks Asli';
	@override String get showProcessedText => 'Tampilkan Teks Hasil Olahan';
	@override String get preview => 'Pratinjau';
	@override String get rules => 'Aturan';
	@override String get agree => 'Setuju';
	@override String get disagree => 'Tidak Setuju';
	@override String get agreeToRules => 'Setujui Aturan';
	@override String get markdownSyntaxHelp => 'Bantuan Sintaks Markdown';
	@override String get previewContent => 'Pratinjau Konten';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Melebihi batas panjang maksimum (${max})';
	@override String get agreeToCommunityRules => 'Setujui Aturan Komunitas';
	@override String get createPost => 'Buat Postingan';
	@override String get title => 'Judul';
	@override String get enterTitle => 'Silakan masukkan judul';
	@override String get content => 'Konten';
	@override String get enterContent => 'Silakan masukkan konten';
	@override String get writeYourContentHere => 'Silakan masukkan konten...';
	@override String get tagBlacklist => 'Daftar Hitam Tag';
	@override String get noData => 'Tidak ada data';
	@override String get tagLimit => 'Batas Tag';
	@override String get enableFloatingButtons => 'Aktifkan Tombol Melayang';
	@override String get disableFloatingButtons => 'Nonaktifkan Tombol Melayang';
	@override String get enabledFloatingButtons => 'Tombol Melayang Diaktifkan';
	@override String get disabledFloatingButtons => 'Tombol Melayang Dinonaktifkan';
	@override String get pendingCommentCount => 'Jumlah Komentar Tertunda';
	@override String joined({required Object str}) => 'Bergabung pada ${str}';
	@override String lastSeenAt({required Object str}) => 'Terakhir dilihat ${str}';
	@override String get download => 'Unduh';
	@override String get selectQuality => 'Pilih Kualitas';
	@override String get videoQualitySource => 'Sumber';
	@override String get selectImageQuality => 'Pilih kualitas gambar';
	@override String get imageQualityStandard => 'Standar';
	@override String get imageQualityOriginal => 'Asli';
	@override String get selectDateRange => 'Pilih Rentang Tanggal';
	@override String get selectDateRangeHint => 'Pilih rentang tanggal, bawaan adalah 30 hari terakhir';
	@override String get clearDateRange => 'Bersihkan Rentang Tanggal';
	@override String get deleteRecordsInDateRange => 'Hapus Catatan dalam Rentang Ini';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => 'Apakah Anda yakin ingin menghapus ${num} catatan riwayat dalam rentang tanggal ini? Tindakan ini tidak dapat dibatalkan.';
	@override String get noHistoryRecordsInRange => 'Tidak ada catatan riwayat dalam rentang tanggal ini';
	@override String get followSuccessClickAgainToSpecialFollow => 'Berhasil diikuti, klik lagi untuk mengikuti spesial';
	@override String get specialFollowTip => 'Ditambahkan ke ikuti spesial — pilih mereka dari pemilih di kanan atas halaman Langganan untuk akses cepat';
	@override String get exitConfirmTip => 'Apakah Anda yakin ingin keluar?';
	@override String get error => 'Kesalahan';
	@override String get taskRunning => 'Tugas sedang berjalan, mohon tunggu.';
	@override String get operationCancelled => 'Operasi dibatalkan.';
	@override String get unsavedChanges => 'Anda memiliki perubahan yang belum disimpan';
	@override String get specialFollowsManagementTip => 'Seret gagang untuk mengurutkan ulang • Ketuk tombol untuk menghapus';
	@override String get specialFollowsManagement => 'Pengelolaan Ikuti Spesial';
	@override String get removeSpecialFollow => 'Hapus ikuti spesial';
	@override String removeSpecialFollowConfirm({required Object name}) => 'Hapus ${name} dari ikuti spesial?';
	@override String get noSpecialFollows => 'Belum ada ikuti spesial';
	@override String get createTimeDesc => 'Waktu Dibuat Turun';
	@override String get createTimeAsc => 'Waktu Dibuat Naik';
	@override late final _TranslationsCommonPaginationId pagination = _TranslationsCommonPaginationId._(_root);
	@override String get notice => 'Pengumuman';
	@override String get detail => 'Rincian';
	@override String get parseExceptionDestopHint => ' - Pengguna desktop dapat mengonfigurasi proxy di pengaturan';
	@override String get iwaraTags => 'Tag Iwara';
	@override String get tagInfo => 'Info Tag';
	@override String get tagOriginalKey => 'Tag Asli';
	@override String get tagTranslation => 'Terjemahan';
	@override String get copy => 'Salin';
	@override String get selectCopy => 'Pilih & Salin';
	@override String get copiedToClipboard => 'Disalin ke papan klip';
	@override String get showOriginalTag => 'Tampilkan Tag Asli';
	@override String get showTranslatedTag => 'Tampilkan Terjemahan';
	@override String get tagTranslationFeedback => 'Ragu dengan terjemahannya? Beri masukan';
	@override String get tagLocalizationGuideTitle => 'Tentang Lokalisasi Tag';
	@override String get tagLocalizationGuideContent => 'Aplikasi menampilkan tag mentah Iwara (mis. mother) menggunakan nama dalam bahasa Anda saat ini.\n\n• Saat mencari tag, baik terjemahan maupun tag asli akan cocok.\n• Tekan lama / klik kanan pada tag untuk melihat dan menyalin kunci asli serta terjemahannya.\n• Terjemahan dikelola komunitas dan bersifat upaya terbaik — dapat mengandung kesalahan.';
	@override String get likeThisVideo => 'Sukai Video Ini';
	@override String get likeThisGallery => 'Sukai Galeri Ini';
	@override String get operation => 'Operasi';
	@override String get replies => 'Balasan';
	@override String get externalLinkWarning => 'Peringatan Tautan Eksternal';
	@override String get externalLinkWarningMessage => 'Anda akan membuka tautan eksternal yang bukan bagian dari iwara.tv. Harap berhati-hati dan pastikan tautan tersebut aman sebelum melanjutkan.';
	@override String get continueToExternalLink => 'Lanjutkan';
	@override String get cancelExternalLink => 'Batal';
}

// Path: auth
class _TranslationsAuthId extends TranslationsAuthEn {
	_TranslationsAuthId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get login => 'Masuk';
	@override String get logout => 'Keluar';
	@override String get email => 'Alamat Email';
	@override String get password => 'Kata Sandi';
	@override String get loginOrRegister => 'Masuk / Daftar';
	@override String get register => 'Daftar';
	@override String get pleaseEnterEmail => 'Silakan masukkan email';
	@override String get pleaseEnterPassword => 'Silakan masukkan kata sandi';
	@override String get passwordMustBeAtLeast6Characters => 'Kata sandi minimal 6 karakter';
	@override String get pleaseEnterCaptcha => 'Silakan masukkan captcha';
	@override String get captcha => 'Kode Captcha';
	@override String get refreshCaptcha => 'Muat Ulang Captcha';
	@override String get captchaNotLoaded => 'Captcha belum dimuat';
	@override String get loginSuccess => 'Berhasil Masuk';
	@override String get loginSuccessProfilePending => 'Sudah masuk. Memuat profil Anda…';
	@override String get emailVerificationSent => 'Email verifikasi telah dikirim';
	@override String get notLoggedIn => 'Belum Masuk';
	@override String get clickToLogin => 'Klik untuk Masuk';
	@override String get logoutConfirmation => 'Apakah Anda yakin ingin keluar?';
	@override String get logoutSuccess => 'Berhasil Keluar';
	@override String get logoutFailed => 'Gagal Keluar';
	@override String get usernameOrEmail => 'Nama Pengguna atau Email';
	@override String get pleaseEnterUsernameOrEmail => 'Silakan masukkan nama pengguna atau email';
	@override String get rememberMe => 'Ingat Nama Pengguna';
	@override String get registerNoticeTitle => 'Daftar di situs web resmi';
	@override String get registerNoticeDescription => 'Pendaftaran di dalam aplikasi tidak lagi tersedia. Silakan buka situs web resmi Iwara untuk membuat akun, lalu kembali ke sini untuk masuk.';
	@override String get registerNoticeReturnTip => 'Setelah mendaftar, kembali ke sini dan masuk dengan akun Anda.';
	@override String get goToOfficialWebsite => 'Buka situs web resmi';
}

// Path: errors
class _TranslationsErrorsId extends TranslationsErrorsEn {
	_TranslationsErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Kesalahan';
	@override String get required => 'Kolom ini wajib diisi';
	@override String get invalidEmail => 'Alamat email tidak valid';
	@override String get networkError => 'Kesalahan jaringan, silakan coba lagi';
	@override String get errorWhileFetching => 'Kesalahan saat mengambil data';
	@override String get commentCanNotBeEmpty => 'Isi komentar tidak boleh kosong';
	@override String get errorWhileFetchingReplies => 'Kesalahan saat mengambil balasan, silakan periksa koneksi jaringan';
	@override String get canNotFindCommentController => 'Tidak dapat menemukan pengendali komentar';
	@override String get errorWhileLoadingGallery => 'Kesalahan saat memuat galeri';
	@override String get howCouldThereBeNoDataItCantBePossible => 'Bagaimana bisa tidak ada data? Ini tidak mungkin :<';
	@override String unsupportedImageFormat({required Object str}) => 'Format gambar tidak didukung: ${str}';
	@override String get invalidGalleryId => 'ID galeri tidak valid';
	@override String get translationFailedPleaseTryAgainLater => 'Terjemahan gagal, silakan coba lagi nanti';
	@override String get errorOccurred => 'Terjadi kesalahan, silakan coba lagi nanti.';
	@override String get errorOccurredWhileProcessingRequest => 'Terjadi kesalahan saat memproses permintaan';
	@override String get errorWhileFetchingDatas => 'Kesalahan saat mengambil data, silakan coba lagi nanti';
	@override String get serviceNotInitialized => 'Layanan belum diinisialisasi';
	@override String get unknownType => 'Jenis tidak diketahui';
	@override String errorWhileOpeningLink({required Object link}) => 'Kesalahan saat membuka tautan: ${link}';
	@override String get invalidUrl => 'URL tidak valid';
	@override String get failedToOperate => 'Gagal melakukan operasi';
	@override String get permissionDenied => 'Izin Ditolak';
	@override String get youDoNotHavePermissionToAccessThisResource => 'Anda tidak memiliki izin untuk mengakses sumber daya ini';
	@override String get loginFailed => 'Gagal Masuk';
	@override String get unknownError => 'Kesalahan Tidak Diketahui';
	@override String get sessionExpired => 'Sesi Telah Berakhir';
	@override String get failedToFetchCaptcha => 'Gagal mengambil captcha';
	@override String get emailAlreadyExists => 'Email sudah terdaftar';
	@override String get invalidCaptcha => 'Captcha tidak valid';
	@override String get registerFailed => 'Gagal Daftar';
	@override String get failedToFetchComments => 'Gagal mengambil komentar';
	@override String get failedToFetchImageDetail => 'Gagal mengambil rincian gambar';
	@override String get failedToFetchImageList => 'Gagal mengambil daftar gambar';
	@override String get failedToFetchData => 'Gagal mengambil data';
	@override String get invalidParameter => 'Parameter tidak valid';
	@override String get pleaseLoginFirst => 'Silakan masuk terlebih dahulu';
	@override String get errorWhileLoadingPost => 'Kesalahan saat memuat postingan';
	@override String get errorWhileLoadingPostDetail => 'Kesalahan saat memuat rincian postingan';
	@override String get invalidPostId => 'ID postingan tidak valid';
	@override String get forceUpdateNotPermittedToGoBack => 'Saat ini dalam status pembaruan wajib, tidak dapat kembali';
	@override String get pleaseLoginAgain => 'Silakan masuk lagi';
	@override String get invalidLogin => 'Login tidak valid, silakan periksa email dan kata sandi Anda';
	@override String get tooManyRequests => 'Terlalu banyak permintaan, silakan coba lagi nanti';
	@override String exceedsMaxLength({required Object max}) => 'Melebihi panjang maksimum: ${max}';
	@override String get contentCanNotBeEmpty => 'Konten tidak boleh kosong';
	@override String get titleCanNotBeEmpty => 'Judul tidak boleh kosong';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Terlalu banyak permintaan, silakan coba lagi nanti, tersisa';
	@override String remainingHours({required Object num}) => '${num} jam';
	@override String remainingMinutes({required Object num}) => '${num} menit';
	@override String remainingSeconds({required Object num}) => '${num} detik';
	@override String tagLimitExceeded({required Object limit}) => 'Batas tag terlampaui, batas: ${limit}';
	@override String get failedToRefresh => 'Gagal menyegarkan';
	@override String get noPermission => 'Tidak ada izin';
	@override String get resourceNotFound => 'Sumber daya tidak ditemukan';
	@override String get failedToSaveCredentials => 'Gagal menyimpan kredensial login';
	@override String get failedToLoadSavedCredentials => 'Gagal memuat kredensial yang tersimpan';
	@override String get notFound => 'Konten tidak ditemukan atau telah dihapus';
	@override late final _TranslationsErrorsNetworkId network = _TranslationsErrorsNetworkId._(_root);
}

// Path: friends
class _TranslationsFriendsId extends TranslationsFriendsEn {
	_TranslationsFriendsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Klik untuk memulihkan teman';
	@override String get friendsList => 'Daftar Teman';
	@override String get friendRequests => 'Permintaan Pertemanan';
	@override String get friendRequestsList => 'Daftar Permintaan Pertemanan';
	@override String get removingFriend => 'Menghapus teman...';
	@override String get failedToRemoveFriend => 'Gagal menghapus teman';
	@override String get cancelingRequest => 'Membatalkan permintaan pertemanan...';
	@override String get failedToCancelRequest => 'Gagal membatalkan permintaan pertemanan';
}

// Path: authorProfile
class _TranslationsAuthorProfileId extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'Tidak ada data lagi';
	@override String get userProfile => 'Profil Pengguna';
}

// Path: favorites
class _TranslationsFavoritesId extends TranslationsFavoritesEn {
	_TranslationsFavoritesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Klik untuk memulihkan favorit';
	@override String get myFavorites => 'Favorit Saya';
	@override String get batchCancelFavorite => 'Hapus favorit yang dipilih';
	@override String batchCancelFavoriteConfirm({required Object count}) => 'Hapus ${count} item yang dipilih dari favorit? Anda dapat memulihkannya dengan mengetuk kartunya setelah itu.';
	@override String batchCancelFavoriteSuccess({required Object count}) => 'Menghapus ${count} item dari favorit';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => 'Menghapus ${success} item, ${failed} gagal';
}

// Path: galleryDetail
class _TranslationsGalleryDetailId extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Telusuri di ruang';
	@override String get galleryDetail => 'Rincian Galeri';
	@override String get viewGalleryDetail => 'Lihat Rincian Galeri';
	@override String get zoomReset => 'Atur ulang zoom';
	@override String get copyLink => 'Salin Tautan';
	@override String get copyImage => 'Salin Gambar';
	@override String get saveAs => 'Simpan Sebagai';
	@override String get saveToAlbum => 'Simpan ke Album';
	@override String get publishedAt => 'Diterbitkan Pada';
	@override String get viewsCount => 'Jumlah Dilihat';
	@override String get imageLibraryFunctionIntroduction => 'Pengenalan Fungsi Pustaka Gambar';
	@override String get rightClickToSaveSingleImage => 'Klik Kanan untuk Menyimpan Satu Gambar';
	@override String get batchSave => 'Simpan Massal';
	@override String get keyboardLeftAndRightToSwitch => 'Tombol Kiri dan Kanan untuk Berganti';
	@override String get keyboardUpAndDownToZoom => 'Tombol Atas dan Bawah untuk Zoom';
	@override String get mouseWheelToSwitch => 'Roda Mouse untuk Berganti';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + Roda Mouse untuk Zoom';
	@override String get moreFeaturesToBeDiscovered => 'Fitur Lainnya untuk Ditemukan...';
	@override String get authorOtherGalleries => 'Galeri Lain dari Penulis';
	@override String get relatedGalleries => 'Galeri Terkait';
	@override String get authorNoOtherGalleries => 'Tidak ada galeri lain dari penulis ini';
	@override String get noRelatedGalleries => 'Tidak ada galeri terkait';
	@override String get scrollLeft => 'Gulir ke kiri';
	@override String get scrollRight => 'Gulir ke kanan';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Klik Tepi Kiri dan Kanan untuk Berganti Gambar';
	@override String get rotateToLandscape => 'Layar Penuh Lanskap';
	@override String get backToPortrait => 'Kembali ke Potret';
}

// Path: playList
class _TranslationsPlayListId extends TranslationsPlayListEn {
	_TranslationsPlayListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Daftar Putar Saya';
	@override String get friendlyTips => 'Tips Berguna';
	@override String get dearUser => 'Pengguna yang Terhormat';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'sistem daftar putar Iwara belum sempurna';
	@override String get notSupportSetCover => 'Tidak mendukung mengatur sampul';
	@override String get notSupportDeleteList => 'Tidak mendukung menghapus daftar';
	@override String get notSupportSetPrivate => 'Tidak mendukung mengatur privat';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Ya... daftar yang dibuat akan selalu ada dan terlihat oleh semua orang';
	@override String get smallSuggestion => 'Saran Kecil';
	@override String get useLikeToCollectContent => 'Jika Anda lebih mementingkan privasi, disarankan menggunakan fungsi "suka" untuk mengumpulkan konten';
	@override String get welcomeToDiscussOnGitHub => 'Jika Anda memiliki saran atau ide lain, silakan berdiskusi di GitHub!';
	@override String get iUnderstand => 'Saya Mengerti';
	@override String get searchPlaylists => 'Cari Daftar Putar...';
	@override String get newPlaylistName => 'Nama Daftar Putar Baru';
	@override String get createNewPlaylist => 'Buat Daftar Putar Baru';
	@override String get videos => 'Video';
}

// Path: search
class _TranslationsSearchId extends TranslationsSearchEn {
	_TranslationsSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Cakupan Pencarian';
	@override String get searchTags => 'Cari Tag...';
	@override String get contentRating => 'Peringkat Konten';
	@override String get removeTag => 'Hapus Tag';
	@override String get pleaseEnterSearchContent => 'Silakan masukkan konten pencarian';
	@override String get searchHistory => 'Riwayat Pencarian';
	@override String get searchSuggestion => 'Saran Pencarian';
	@override String get usedTimes => 'Jumlah Penggunaan';
	@override String get lastUsed => 'Terakhir Digunakan';
	@override String get noSearchHistoryRecords => 'Tidak ada riwayat pencarian';
	@override String get clearSearchHistoryConfirm => 'Apakah Anda yakin ingin menghapus semua riwayat pencarian? Tindakan ini tidak dapat dibatalkan.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Tidak mendukung jenis pencarian saat ini ${searchType}, silakan tunggu pembaruan';
	@override String get searchResult => 'Hasil Pencarian';
	@override String unsupportedSearchType({required Object searchType}) => 'Jenis pencarian tidak didukung: ${searchType}';
	@override String get googleSearch => 'Penelusuran Google';
	@override String googleSearchHint({required Object webName}) => 'Fungsi pencarian ${webName} kurang mudah digunakan? Coba Penelusuran Google!';
	@override String get googleSearchDescription => 'Gunakan operator pencarian :site dari Penelusuran Google untuk mencari konten di situs. Ini sangat berguna saat mencari video, galeri, daftar putar, dan pengguna.';
	@override String get googleSearchKeywordsHint => 'Masukkan kata kunci untuk mencari';
	@override String get openLinkJump => 'Buka Tautan Eksternal';
	@override String get googleSearchButton => 'Penelusuran Google';
	@override String get pleaseEnterSearchKeywords => 'Silakan masukkan kata kunci pencarian';
	@override String get googleSearchQueryCopied => 'Kueri pencarian disalin ke papan klip';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'Gagal membuka peramban: ${error}';
	@override String get searchRequestTimeout => 'Permintaan habis waktu, silakan coba lagi nanti';
	@override String get searchCannotConnectToServer => 'Tidak dapat terhubung ke server, silakan periksa koneksi jaringan Anda';
	@override String get searchNetworkError => 'Koneksi jaringan gagal, silakan periksa pengaturan jaringan Anda atau coba lagi nanti';
	@override String get searchFailedPleaseRetry => 'Pencarian gagal, silakan coba lagi nanti';
}

// Path: mediaList
class _TranslationsMediaListId extends TranslationsMediaListEn {
	_TranslationsMediaListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Perkenalan';
}

// Path: settings
class _TranslationsSettingsId extends TranslationsSettingsEn {
	_TranslationsSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Mode Tampilan Daftar';
	@override String get previewEffect => 'Efek Pratinjau';
	@override String get useTraditionalPaginationMode => 'Gunakan Mode Penomoran Halaman Tradisional';
	@override String get useTraditionalPaginationModeDesc => 'Aktifkan mode penomoran halaman tradisional, nonaktifkan mode air terjun. Berlaku setelah merender ulang halaman atau memulai ulang aplikasi';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Tampilkan Bilah Kemajuan Video Saat Bilah Alat Disembunyikan';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Konfigurasi ini menentukan apakah bilah kemajuan video bawah akan ditampilkan saat bilah alat disembunyikan.';
	@override String get seekPreviewSize => 'Ukuran Pratinjau Pencarian';
	@override String get seekPreviewSizeDesc => 'Seberapa besar jendela pratinjau di atas bilah kemajuan. Jendela sudah mengikuti ukuran pemutar dan rasio aspek video; ini hanya menyempurnakannya.';
	@override String get seekPreviewSizeSmall => 'Kecil';
	@override String get seekPreviewSizeStandard => 'Standar';
	@override String get seekPreviewSizeLarge => 'Besar';
	@override String get seekPreviewSizeStandardDesc => 'Ukuran yang diturunkan dari pemutar dan video';
	@override String get showFullscreenUpNextHint => 'Tampilkan gagang "Berikutnya"';
	@override String get showFullscreenUpNextHintDesc => 'Menampilkan gagang kecil di tepi kanan pemutar yang membuka laci antrean (sumber / daftar putar / tonton nanti). Tidak ada cara lain untuk masuk setelah ini dinonaktifkan.';
	@override String get basicSettings => 'Pengaturan Dasar';
	@override String get personalizedSettings => 'Pengaturan yang Dipersonalisasi';
	@override String get otherSettings => 'Pengaturan Lain';
	@override String get searchConfig => 'Konfigurasi Pencarian';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Konfigurasi ini menentukan apakah konfigurasi sebelumnya akan digunakan saat memutar video lagi.';
	@override String get playControl => 'Kontrol Pemutaran';
	@override String get playbackSpeedSettings => 'Pemutaran & Kecepatan';
	@override String get playbackBehaviorSettings => 'Perilaku Pemutaran';
	@override String get enhancementSettings => 'Teater & Peningkatan';
	@override String get fastForwardTime => 'Waktu Maju Cepat';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'Waktu maju cepat harus berupa bilangan bulat positif.';
	@override String get rewindTime => 'Waktu Mundur';
	@override String get rewindTimeMustBeAPositiveInteger => 'Waktu mundur harus berupa bilangan bulat positif.';
	@override String get longPressPlaybackSpeed => 'Kecepatan Pemutaran Tekan Lama';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'Kecepatan pemutaran tekan lama harus berupa angka positif.';
	@override String get defaultPlaybackSpeed => 'Kecepatan Pemutaran Bawaan';
	@override String get rememberPlaybackSpeed => 'Ingat Kecepatan Pemutaran';
	@override String get rememberPlaybackSpeedDesc => 'Saat diaktifkan, kecepatan yang Anda atur di pemutar disimpan sebagai bawaan dan diterapkan secara otomatis ke video baru.';
	@override String get repeat => 'Ulangi';
	@override String get renderVerticalVideoInVerticalScreen => 'Tampilkan Video Vertikal di Layar Vertikal';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Konfigurasi ini menentukan apakah video akan ditampilkan di layar vertikal saat diputar dalam layar penuh.';
	@override String get rememberVolume => 'Ingat Volume';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Konfigurasi ini menentukan apakah volume akan dipertahankan saat memutar video lagi.';
	@override String get rememberBrightness => 'Ingat Kecerahan';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Konfigurasi ini menentukan apakah kecerahan akan dipertahankan saat memutar video lagi.';
	@override String get playControlArea => 'Area Kontrol Pemutaran';
	@override String get leftAndRightControlAreaWidth => 'Lebar Area Kontrol Kiri dan Kanan';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Konfigurasi ini menentukan lebar area kontrol di sisi kiri dan kanan pemutar.';
	@override String get proxyAddressCannotBeEmpty => 'Alamat proksi tidak boleh kosong.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Format alamat proksi tidak valid. Gunakan format IP:port atau nama domain:port.';
	@override String get proxyNormalWork => 'Proksi berfungsi normal.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Uji proksi gagal, kode status: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Uji proksi gagal, pengecualian: ${exception}';
	@override String get proxyConfig => 'Konfigurasi Proksi';
	@override String get thisIsHttpProxyAddress => 'Ini adalah alamat proksi http';
	@override String get checkProxy => 'Periksa Proksi';
	@override String get proxyAddress => 'Alamat Proksi';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Silakan masukkan URL server proksi, misalnya 127.0.0.1:8080';
	@override String get enableProxy => 'Aktifkan Proksi';
	@override String get left => 'Kiri';
	@override String get middle => 'Tengah';
	@override String get right => 'Kanan';
	@override String get playerSettings => 'Pengaturan Pemutar';
	@override String get networkSettings => 'Pengaturan Jaringan';
	@override String get customizeYourPlaybackExperience => 'Sesuaikan Pengalaman Pemutaran Anda';
	@override String get chooseYourFavoriteAppAppearance => 'Pilih Tampilan Aplikasi Favorit Anda';
	@override String get configureYourProxyServer => 'Konfigurasikan Server Proksi Anda';
	@override String get settings => 'Pengaturan';
	@override String get themeSettings => 'Pengaturan Tema';
	@override String get followSystem => 'Ikuti Sistem';
	@override String get lightMode => 'Mode Terang';
	@override String get darkMode => 'Mode Gelap';
	@override String get presetTheme => 'Tema Prasetel';
	@override String get basicTheme => 'Tema Dasar';
	@override String get needRestartToApply => 'Perlu memulai ulang aplikasi untuk menerapkan pengaturan';
	@override String get themeNeedRestartDescription => 'Pengaturan tema memerlukan memulai ulang aplikasi untuk menerapkan pengaturan';
	@override String get about => 'Tentang';
	@override String get diagnosticsAndFeedback => 'Diagnostik & Umpan Balik';
	@override String get currentVersion => 'Versi Saat Ini';
	@override String get latestVersion => 'Versi Terbaru';
	@override String get checkForUpdates => 'Periksa Pembaruan';
	@override String get update => 'Perbarui';
	@override String get newVersionAvailable => 'Versi Baru Tersedia';
	@override String get projectHome => 'Beranda Proyek';
	@override String get release => 'Rilis';
	@override String get issueReport => 'Laporan Masalah';
	@override String get openSourceLicense => 'Lisensi Sumber Terbuka';
	@override String get checkForUpdatesFailed => 'Gagal memeriksa pembaruan, silakan coba lagi nanti';
	@override String get autoCheckUpdate => 'Periksa Pembaruan Otomatis';
	@override String get updateContent => 'Konten Pembaruan';
	@override String get releaseDate => 'Tanggal Rilis';
	@override String get ignoreThisVersion => 'Abaikan Versi Ini';
	@override String get forceUpdateTip => 'Ini adalah pembaruan wajib. Harap perbarui ke versi terbaru sesegera mungkin';
	@override String get viewChangelog => 'Lihat Log Perubahan';
	@override String get alreadyLatestVersion => 'Sudah versi terbaru';
	@override String get appSettings => 'Pengaturan Aplikasi';
	@override String get configureYourAppSettings => 'Konfigurasikan Pengaturan Aplikasi Anda';
	@override String get history => 'Riwayat';
	@override String get autoRecordHistory => 'Rekam Riwayat Otomatis';
	@override String get autoRecordHistoryDesc => 'Secara otomatis merekam video dan gambar yang telah Anda tonton';
	@override String get autoDeleteHistory => 'Bersihkan Riwayat Otomatis';
	@override String get autoDeleteHistoryDesc => 'Secara otomatis menghapus riwayat penjelajahan yang lebih lama dari hari retensi saat memulai (nonaktif secara bawaan)';
	@override String get autoDeleteHistoryDays => 'Hari Retensi';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Simpan ${num} hari terakhir';
	@override String get autoDeleteHistoryDaysInvalid => 'Silakan masukkan jumlah hari yang valid (minimal 1)';
	@override String get showUnprocessedMarkdownText => 'Tampilkan Teks Markdown yang Belum Diproses';
	@override String get showUnprocessedMarkdownTextDesc => 'Tampilkan teks asli dari markdown';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Mode Privasi';
	@override String get activeBackgroundPrivacyModeDesc => 'Blokir tangkapan layar dan rekaman layar, serta sembunyikan layar di latar belakang';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Sembunyikan layar saat aplikasi masuk ke latar belakang (platform ini tidak dapat memblokir tangkapan layar)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Blokir tangkapan layar dan rekaman layar';
	@override String get privacy => 'Privasi';
	@override String get appLock => 'Kunci Aplikasi';
	@override String get appLockEnabled => 'Aktifkan kunci aplikasi';
	@override String get appLockEnabledDesc => 'Memerlukan PIN atau biometrik untuk membuka aplikasi; pratinjau latar belakang disembunyikan secara otomatis';
	@override String get appLockEnabledSummary => 'Aktif · Dilindungi PIN';
	@override String get appLockDisabledSummary => 'Nonaktif';
	@override String get appLockTimeout => 'Kunci setelah keluar aplikasi';
	@override String get appLockTimeoutDesc => 'Waktu yang diizinkan di latar belakang sebelum autentikasi diperlukan';
	@override String get appLockAfterScreenOff => 'Kunci setelah kunci layar';
	@override String get appLockAfterScreenOffDesc => 'Memerlukan autentikasi setelah layar perangkat dikunci';
	@override String get appLockTimeoutDisabled => 'Nonaktif';
	@override String get appLockImmediately => 'Segera';
	@override String appLockSeconds({required Object seconds}) => '${seconds} detik';
	@override String appLockMinutes({required Object minutes}) => '${minutes} menit';
	@override String get appLockUseBiometrics => 'Gunakan biometrik';
	@override String get appLockUseBiometricsDesc => 'Buka kunci dengan sidik jari atau pengenalan wajah';
	@override String get appLockBiometricsUnavailable => 'Tidak ada biometrik terdaftar yang tersedia di perangkat ini';
	@override String get appLockSetPin => 'Atur PIN';
	@override String get appLockEnterPin => 'Masukkan PIN';
	@override String get appLockConfirmPin => 'Konfirmasi PIN';
	@override String get appLockCurrentPin => 'Masukkan PIN saat ini';
	@override String get appLockNewPin => 'Masukkan PIN baru';
	@override String get appLockPinRequirements => 'PIN harus berisi 4–8 digit';
	@override String get appLockPinsDoNotMatch => 'PIN tidak cocok';
	@override String get appLockInvalidPin => 'PIN salah';
	@override String get appLockSetupFailed => 'Tidak dapat menyimpan PIN dengan aman';
	@override String get appLockDisable => 'Masukkan PIN untuk menonaktifkan kunci aplikasi';
	@override String get appLockChangePin => 'Ubah PIN';
	@override String get appLockNow => 'Kunci sekarang';
	@override String get appLockUnlock => 'Buka Kunci';
	@override String get appLockLockedTitle => 'Terkunci';
	@override String get appLockLockedDesc => 'Autentikasi untuk melanjutkan';
	@override String get appLockAuthenticateReason => 'Autentikasi untuk membuka kunci';
	@override String get appLockEnableBiometricsReason => 'Autentikasi untuk mengaktifkan buka kunci biometrik';
	@override String get appLockBiometricFailed => 'Autentikasi biometrik tidak diselesaikan';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Terlalu banyak percobaan. Coba lagi dalam ${seconds} dtk';
	@override String get appLockCredentialUnavailableTitle => 'Tidak dapat membaca kredensial kunci aplikasi';
	@override String get appLockCredentialUnavailableDesc => 'Penyimpanan aman sistem sementara tidak tersedia, atau kredensial rusak. Aplikasi tetap terkunci. Coba lagi terlebih dahulu; jika terus gagal, Anda dapat mengatur ulang kunci aplikasi, yang akan mematikannya dan menghapus PIN tersimpan.';
	@override String get appLockRetry => 'Coba Lagi';
	@override String get appLockReset => 'Atur ulang kunci aplikasi';
	@override String get appLockResetAction => 'Atur Ulang';
	@override String get appLockResetConfirmTitle => 'Atur ulang kunci aplikasi?';
	@override String get appLockResetConfirmDesc => 'Ini menonaktifkan kunci aplikasi dan menghapus PIN tersimpan serta pengaturan biometrik. Anda dapat mengaturnya lagi setelahnya.';
	@override String get appLockRetrySucceeded => 'Kredensial berhasil dibaca. Masukkan PIN Anda.';
	@override String get appLockRetryFailed => 'Masih tidak dapat membaca kredensial';
	@override String get forum => 'Forum';
	@override String get news => 'Berita';
	@override String get community => 'Komunitas';
	@override String get disableForumReplyQuote => 'Nonaktifkan Kutipan Balasan Forum';
	@override String get disableForumReplyQuoteDesc => 'Nonaktifkan membawa informasi lantai yang dibalas saat membalas di forum';
	@override String get theaterMode => 'Mode Teater';
	@override String get theaterModeDesc => 'Setelah dibuka, latar belakang pemutar akan diatur ke versi buram dari sampul video';
	@override String get appLinks => 'Tautan Aplikasi';
	@override String get defaultBrowser => 'Peramban Bawaan';
	@override String get defaultBrowserDesc => 'Silakan buka item konfigurasi tautan bawaan di pengaturan sistem dan tambahkan tautan situs iwara.tv';
	@override String get themeMode => 'Mode Tema';
	@override String get themeModeDesc => 'Konfigurasi ini menentukan mode tema aplikasi';
	@override String get glassEffect => 'Material Antarmuka';
	@override String get glassEffectDesc => 'Memilih material yang digunakan di seluruh aplikasi — kapsul header, menu, tombol dialog, dan bilah navigasi bawah';
	@override String get liquidGlassEffect => 'Kaca Cair';
	@override String get liquidGlassEffectDesc => 'Blur dan refraksi nyata. Tampilan terbaik, tetapi dapat menurunkan frame dan memakai sedikit lebih banyak daya pada perangkat kelas bawah';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Permukaan Material 3 standar — opak, tanpa blur, tanpa bayangan. Kinerja dan daya terbaik';
	@override String get glassEffectIntroTitle => 'Pilih material antarmuka Anda';
	@override String get glassEffectIntroContent => 'Header, bilah tab, dan menu menggunakan kaca cair — blur dan refraksi nyata. Jika terasa lambat di perangkat Anda, atau Anda lebih menyukai tampilan yang lebih sederhana, beralihlah ke Material sekarang (permukaan opak, tanpa blur, tanpa bayangan).';
	@override String get glassEffectIntroHint => 'Anda dapat mengubahnya kapan saja di Pengaturan → Tema → Material Antarmuka.';
	@override String get glassEffectIntroDone => 'Pertahankan';
	@override String get dynamicColor => 'Warna Dinamis';
	@override String get dynamicColorDesc => 'Konfigurasi ini menentukan apakah aplikasi menggunakan warna dinamis';
	@override String get useDynamicColor => 'Gunakan Warna Dinamis';
	@override String get useDynamicColorDesc => 'Konfigurasi ini menentukan apakah aplikasi menggunakan warna dinamis';
	@override String get presetColors => 'Warna Prasetel';
	@override String get customColors => 'Warna Kustom';
	@override String get customColorsDisabledByDynamicColor => 'Warna dinamis aktif, sehingga warna prasetel/kustom tidak tersedia. Nonaktifkan warna dinamis terlebih dahulu.';
	@override String get pickColor => 'Pilih Warna';
	@override String get cancel => 'Batal';
	@override String get confirm => 'Konfirmasi';
	@override String get noCustomColors => 'Tidak ada warna kustom';
	@override String get recordAndRestorePlaybackProgress => 'Rekam dan Pulihkan Kemajuan Pemutaran';
	@override String get autoPlayVideoOnFirstEnter => 'Putar Video Otomatis Saat Pertama Masuk';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Pengaturan ini menentukan apakah video mulai diputar secara otomatis saat pertama kali membuka halaman video.';
	@override String get autoEnterFullscreen => 'Masuk Layar Penuh Otomatis';
	@override String get autoEnterFullscreenDesc => 'Kapan pemutar harus masuk layar penuh dengan sendirinya. Video privat, yang dihapus, dan eksternal selalu dibiarkan, begitu juga gambar-dalam-gambar.';
	@override String get autoEnterFullscreenOff => 'Nonaktif';
	@override String get autoEnterFullscreenOffDesc => 'Jangan pernah masuk layar penuh dengan sendirinya';
	@override String get autoEnterFullscreenOnPlaybackStart => 'Saat Pemutaran Dimulai';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Masuk layar penuh tepat saat pemutaran benar-benar dimulai';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'Saat Membuka Video';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Masuk layar penuh segera setelah halaman video terbuka, tanpa menunggu pemutaran';
	@override String get autoEnterFullscreenKind => 'Jenis Layar Penuh';
	@override String get autoEnterFullscreenKindDesc => 'Jenis layar penuh mana yang akan dimasuki secara otomatis. Hanya desktop.';
	@override String get autoEnterFullscreenKindSystem => 'Layar Penuh Sistem';
	@override String get autoEnterFullscreenKindSystemDesc => 'Biarkan pengelola jendela membuat jendela menjadi layar penuh';
	@override String get autoEnterFullscreenKindApp => 'Layar Penuh Aplikasi';
	@override String get autoEnterFullscreenKindAppDesc => 'Pertahankan jendela apa adanya dan ubah seluruh aplikasi menjadi pemutar';
	@override String get signature => 'Tanda Tangan';
	@override String get enableSignature => 'Aktifkan Tanda Tangan';
	@override String get enableSignatureDesc => 'Konfigurasi ini menentukan apakah aplikasi akan menambahkan tanda tangan saat membalas';
	@override String get enterSignature => 'Masukkan Tanda Tangan';
	@override String get editSignature => 'Edit Tanda Tangan';
	@override String get signatureContent => 'Isi Tanda Tangan';
	@override String get exportConfig => 'Ekspor Konfigurasi Aplikasi';
	@override String get exportConfigDesc => 'Ekspor pengaturan dan riwayat (riwayat penjelajahan, kemajuan pemutaran, favorit, dll.) ke file untuk pencadangan atau pemindahan ke perangkat lain. Tugas unduhan tidak disertakan.';
	@override String get importConfig => 'Impor Konfigurasi Aplikasi';
	@override String get importConfigDesc => 'Impor konfigurasi aplikasi dari file';
	@override String get exportConfigSuccess => 'Konfigurasi berhasil diekspor!';
	@override String get exportConfigFailed => 'Gagal mengekspor konfigurasi';
	@override String get importConfigSuccess => 'Konfigurasi berhasil diimpor!';
	@override String get importConfigFailed => 'Gagal mengimpor konfigurasi';
	@override String get exportIncludeSensitive => 'Sertakan info sensitif';
	@override String get exportIncludeSensitiveDesc => 'Menyertakan kunci API, token sesi, dan alamat proksi. Hanya aktifkan saat mencadangkan ke perangkat Anda sendiri.';
	@override String get importConfigOverwriteWarning => 'Mengimpor akan menimpa pengaturan dan riwayat Anda saat ini (riwayat penjelajahan, kemajuan pemutaran, favorit, dll.). Lanjutkan?';
	@override String get importConfigRestartTitle => 'Impor berhasil';
	@override String get importConfigRestartContent => 'Konfigurasi Anda telah diimpor. Harap tutup sepenuhnya dan buka kembali aplikasi agar semua perubahan berlaku.';
	@override String get historyUpdateLogs => 'Log Pembaruan Riwayat';
	@override String get noUpdateLogs => 'Tidak ada log pembaruan yang tersedia';
	@override String get versionLabel => 'Versi: {version}';
	@override String get releaseDateLabel => 'Tanggal Rilis: {date}';
	@override String get noChanges => 'Tidak ada konten pembaruan yang tersedia';
	@override String get interaction => 'Interaksi';
	@override String get enableVibration => 'Aktifkan Getaran';
	@override String get enableVibrationDesc => 'Aktifkan umpan balik getaran saat berinteraksi dengan aplikasi';
	@override String get defaultKeepVideoToolbarVisible => 'Pertahankan Bilah Alat Video Terlihat';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Pengaturan ini menentukan apakah bilah alat video tetap terlihat saat pertama kali membuka halaman video.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Perangkat seluler mengaktifkan mode teater, yang dapat menyebabkan masalah kinerja. Anda dapat memilih untuk mengaktifkannya.';
	@override String get fullscreenOrientation => 'Orientasi Layar Vertikal Setelah Masuk Layar Penuh';
	@override String get fullscreenOrientationDesc => 'Pengaturan ini menentukan orientasi layar bawaan saat masuk layar penuh (khusus seluler)';
	@override String get fullscreenOrientationLeftLandscape => 'Lanskap Kiri';
	@override String get fullscreenOrientationRightLandscape => 'Lanskap Kanan';
	@override String get screenFit => 'Ukuran Layar';
	@override String get screenFitDesc => 'Pilih bagaimana video mengisi area pemutar.';
	@override String get rememberScreenFit => 'Ingat Ukuran Layar';
	@override String get rememberScreenFitDesc => 'Terapkan ukuran yang dipilih ke video yang dibuka nanti.';
	@override String get screenFitFit => 'Sesuaikan';
	@override String get screenFitFitDesc => 'Tampilkan seluruh bingkai dengan mempertahankan rasio aspek';
	@override String get screenFitStretch => 'Regangkan';
	@override String get screenFitStretchDesc => 'Mengisi area pemutar; gambar mungkin terdistorsi';
	@override String get screenFitCover => 'Isi Penuh';
	@override String get screenFitCoverDesc => 'Mengisi area pemutar dengan mempertahankan rasio aspek; bagian berlebih dipotong';
	@override String get screenFitRatioDesc => 'Paksa rasio aspek ini; gambar mungkin terdistorsi';
	@override String get jumpLink => 'Lompat Tautan';
	@override String get language => 'Bahasa';
	@override String get languageNativeName => 'Bahasa Indonesia';
	@override String get followSystemLanguage => 'Ikuti sistem';
	@override String get languageChangedMessage => 'Bahasa berhasil diubah. Beberapa fitur perlu memulai ulang aplikasi agar berlaku.';
	@override String get languageChanged => 'Pengaturan bahasa telah diubah, harap mulai ulang aplikasi agar berlaku.';
	@override late final _TranslationsSettingsKeybindingId keybinding = _TranslationsSettingsKeybindingId._(_root);
	@override String get gestureControl => 'Kontrol Gerakan';
	@override String get leftDoubleTapRewind => 'Ketuk Ganda Kiri untuk Mundur';
	@override String get rightDoubleTapFastForward => 'Ketuk Ganda Kanan untuk Maju Cepat';
	@override String get doubleTapPause => 'Jeda Ketuk Ganda';
	@override String get rightVerticalSwipeVolume => 'Geser Vertikal Kanan untuk Volume (Berlaku saat memasuki halaman baru)';
	@override String get leftVerticalSwipeBrightness => 'Geser Vertikal Kiri untuk Kecerahan (Berlaku saat memasuki halaman baru)';
	@override String get longPressFastForward => 'Tekan Lama untuk Maju Cepat';
	@override String get enableMouseHoverShowToolbar => 'Aktifkan Tampilkan Bilah Alat saat Kursor Melayang';
	@override String get enableMouseHoverShowToolbarInfo => 'Saat diaktifkan, bilah alat video akan ditampilkan saat kursor melayang di atas pemutar. Bilah akan disembunyikan secara otomatis setelah 3 detik tidak ada aktivitas.';
	@override String get enableHorizontalDragSeek => 'Geser Horizontal untuk Mencari';
	@override String get enableVideoGestureZoom => 'Cubit untuk Memperbesar Bingkai Video';
	@override String get enableVideoGestureZoomInfo => 'Cubit dengan dua jari (atau Ctrl + roda mouse di desktop) untuk memperbesar gambar video, lalu seret untuk memindahkannya.';
	@override String get showCenterPlayPauseButton => 'Tombol Putar/Jeda Tengah';
	@override String get showCenterPlayPauseButtonDesc => 'Tampilkan tombol putar/jeda besar di tengah pemutar.';
	@override String get audioVideoConfig => 'Konfigurasi Audio Video';
	@override String get expandBuffer => 'Perluas Buffer';
	@override String get expandBufferInfo => 'Saat diaktifkan, ukuran buffer bertambah, waktu pemuatan menjadi lebih lama tetapi pemutaran lebih lancar';
	@override String get videoSyncMode => 'Mode Sinkron Video';
	@override String get videoSyncModeSubtitle => 'Strategi sinkronisasi audio-video';
	@override String get hardwareDecodingMode => 'Mode Dekode Perangkat Keras';
	@override String get hardwareDecodingModeSubtitle => 'Pengaturan dekode perangkat keras';
	@override String get enableHardwareAcceleration => 'Aktifkan Akselerasi Perangkat Keras';
	@override String get enableHardwareAccelerationInfo => 'Mengaktifkan akselerasi perangkat keras dapat meningkatkan kinerja dekode, tetapi beberapa perangkat mungkin tidak kompatibel';
	@override String get useOpenSLESAudioOutput => 'Gunakan Output Audio OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'Gunakan output audio latensi rendah, dapat meningkatkan kinerja audio';
	@override String get videoSyncAudio => 'Sinkron Audio';
	@override String get videoSyncDisplayResample => 'Tampilkan Resample';
	@override String get videoSyncDisplayResampleVdrop => 'Tampilkan Resample (Jatuhkan Bingkai)';
	@override String get videoSyncDisplayResampleDesync => 'Tampilkan Resample (Desinkron)';
	@override String get videoSyncDisplayTempo => 'Tampilkan Tempo';
	@override String get videoSyncDisplayVdrop => 'Tampilkan Jatuhkan Bingkai Video';
	@override String get videoSyncDisplayAdrop => 'Tampilkan Jatuhkan Bingkai Audio';
	@override String get videoSyncDisplayDesync => 'Tampilkan Desinkron';
	@override String get videoSyncDesync => 'Desinkron';
	@override late final _TranslationsSettingsForumSettingsId forumSettings = _TranslationsSettingsForumSettingsId._(_root);
	@override late final _TranslationsSettingsGallerySettingsId gallerySettings = _TranslationsSettingsGallerySettingsId._(_root);
	@override late final _TranslationsSettingsBlockSettingsId blockSettings = _TranslationsSettingsBlockSettingsId._(_root);
	@override late final _TranslationsSettingsChatSettingsId chatSettings = _TranslationsSettingsChatSettingsId._(_root);
	@override String get hardwareDecodingAuto => 'Otomatis';
	@override String get hardwareDecodingAutoCopy => 'Salin Otomatis';
	@override String get hardwareDecodingAutoSafe => 'Otomatis Aman';
	@override String get hardwareDecodingNo => 'Dinonaktifkan';
	@override String get hardwareDecodingYes => 'Paksa Aktifkan';
	@override String get cdnDistributionStrategy => 'Strategi Distribusi Konten';
	@override String get cdnDistributionStrategyDesc => 'Pilih strategi distribusi server sumber video untuk mengoptimalkan kecepatan pemuatan';
	@override String get cdnDistributionStrategyLabel => 'Strategi Distribusi';
	@override String get cdnDistributionStrategyNoChange => 'Tidak Ada Perubahan (Gunakan Server Asli)';
	@override String get cdnDistributionStrategyAuto => 'Pilih Otomatis (Server Tercepat)';
	@override String get cdnDistributionStrategySpecial => 'Tentukan Server';
	@override String get cdnSpecialServer => 'Tentukan Server';
	@override String get cdnRefreshServerListHint => 'Silakan klik tombol di bawah untuk menyegarkan daftar server';
	@override String get cdnRefreshButton => 'Segarkan';
	@override String get cdnFastRingServers => 'Server Fast Ring';
	@override String get cdnRefreshServerListTooltip => 'Segarkan daftar server';
	@override String get cdnSpeedTestButton => 'Uji Kecepatan';
	@override String cdnSpeedTestingButton({required Object count}) => 'Menguji (${count})';
	@override String get cdnNoServerDataHint => 'Tidak ada data server yang tersedia, silakan klik tombol segarkan';
	@override String get cdnTestingStatus => 'Menguji';
	@override String get cdnUnreachableStatus => 'Tidak Terjangkau';
	@override String get cdnNotTestedStatus => 'Belum Diuji';
	@override late final _TranslationsSettingsDownloadSettingsId downloadSettings = _TranslationsSettingsDownloadSettingsId._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsId extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tag Favorit';
	@override String get emptyIwara => 'Belum ada tag Iwara favorit';
	@override String get emptyOreno3d => 'Belum ada favorit';
	@override String get addIwaraTag => 'Tambah tag Iwara';
	@override String get quickPickHint => 'Item favorit muncul sebagai pilihan cepat di pencarian.';
	@override String get pickerTitle => 'Pilih Oreno3D';
	@override String get searchHint => 'Cari berdasarkan nama atau asli';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n,
		one: '${n} karya',
		other: '${n} karya',
	);
	@override String get browseEntry => 'Telusuri origin / karakter / tag';
	@override String get favoritesSection => 'Favorit';
	@override String get addFavorite => 'Tambah';
	@override String get iwaraTitle => 'Tag Iwara Favorit';
	@override String get oreno3dTitle => 'Tag Oreno3D Favorit';
	@override String get changeTag => 'Ubah tag';
	@override String get switchToText => 'Pencarian teks';
}

// Path: oreno3d
class _TranslationsOreno3dId extends TranslationsOreno3dEn {
	_TranslationsOreno3dId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Tag';
	@override String get characters => 'Karakter';
	@override String get origin => 'Asal';
	@override String get thirdPartyTagsExplanation => 'Informasi **tag**, **karakter**, dan **asal** yang ditampilkan di sini disediakan oleh situs pihak ketiga **Oreno3D** hanya sebagai referensi.\n\nKarena sumber informasi ini hanya tersedia dalam bahasa Jepang, saat ini belum ada penyesuaian internasionalisasi.\n\nJika Anda tertarik untuk berkontribusi pada upaya internasionalisasi, silakan kunjungi repositori untuk membantu meningkatkannya!';
	@override late final _TranslationsOreno3dSortTypesId sortTypes = _TranslationsOreno3dSortTypesId._(_root);
	@override late final _TranslationsOreno3dErrorsId errors = _TranslationsOreno3dErrorsId._(_root);
	@override late final _TranslationsOreno3dLoadingId loading = _TranslationsOreno3dLoadingId._(_root);
	@override late final _TranslationsOreno3dMessagesId messages = _TranslationsOreno3dMessagesId._(_root);
}

// Path: signIn
class _TranslationsSignInId extends TranslationsSignInEn {
	_TranslationsSignInId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Silakan masuk terlebih dahulu';
	@override String get alreadySignedInToday => 'Anda sudah melakukan presensi hari ini!';
	@override String get youDidNotStickToTheSignIn => 'Anda tidak konsisten dalam melakukan presensi.';
	@override String get signInSuccess => 'Presensi berhasil!';
	@override String get signInFailed => 'Presensi gagal, silakan coba lagi nanti';
	@override String get consecutiveSignIns => 'Presensi Berturut-turut';
	@override String get failureReason => 'Alasan Kegagalan';
	@override String get selectDateRange => 'Pilih Rentang Tanggal';
	@override String get startDate => 'Tanggal Mulai';
	@override String get endDate => 'Tanggal Akhir';
	@override String get invalidDate => 'Tanggal Tidak Valid';
	@override String get invalidDateRange => 'Rentang Tanggal Tidak Valid';
	@override String get errorFormatText => 'Kesalahan Format Tanggal';
	@override String get errorInvalidText => 'Rentang Tanggal Tidak Valid';
	@override String get errorInvalidRangeText => 'Rentang Tanggal Tidak Valid';
	@override String get dateRangeCantBeMoreThanOneYear => 'Rentang tanggal tidak boleh lebih dari satu tahun';
	@override String get signIn => 'Presensi';
	@override String get signInRecord => 'Riwayat Presensi';
	@override String get totalSignIns => 'Total Presensi';
	@override String get pleaseSelectSignInStatus => 'Silakan pilih status presensi';
}

// Path: subscriptions
class _TranslationsSubscriptionsId extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Silakan masuk terlebih dahulu untuk melihat langganan Anda.';
	@override String get selectUser => 'Pilih Pengguna';
	@override String get noSubscribedUsers => 'Tidak ada pengguna yang dilanggan';
	@override String get showAllSubscribedUsersContent => 'Tampilkan konten semua pengguna yang dilanggan';
}

// Path: videoDetail
class _TranslationsVideoDetailId extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'Mode PiP';
	@override String resumeFromLastPosition({required Object position}) => 'Lanjutkan dari posisi terakhir: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Dilanjutkan dari ${position}';
	@override String get restartFromBeginning => 'Mulai dari awal';
	@override String get dismissResumeTip => 'Tutup';
	@override late final _TranslationsVideoDetailLocalInfoId localInfo = _TranslationsVideoDetailLocalInfoId._(_root);
	@override String get videoIdIsEmpty => 'ID Video kosong';
	@override String get videoInfoIsEmpty => 'Info video kosong';
	@override String get thisIsAPrivateVideo => 'Ini adalah video privat';
	@override String get getVideoInfoFailed => 'Gagal mendapatkan info video, silakan coba lagi nanti';
	@override String get noVideoSourceFound => 'Tidak ada sumber video yang ditemukan';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Tag "${tagId}" disalin ke papan klip';
	@override String get errorLoadingVideo => 'Kesalahan memuat video';
	@override String get play => 'Putar';
	@override String get pause => 'Jeda';
	@override String get exitAppFullscreen => 'Keluar Layar Penuh Aplikasi';
	@override String get enterAppFullscreen => 'Masuk Layar Penuh Aplikasi';
	@override String get exitSystemFullscreen => 'Keluar Layar Penuh Sistem';
	@override String get enterSystemFullscreen => 'Masuk Layar Penuh Sistem';
	@override String get seekTo => 'Cari Ke';
	@override String get switchResolution => 'Ganti Resolusi';
	@override String get switchPlaybackSpeed => 'Ganti Kecepatan Pemutaran';
	@override String rewindSeconds({required Object num}) => 'Mundur ${num} detik';
	@override String fastForwardSeconds({required Object num}) => 'Maju Cepat ${num} detik';
	@override String playbackSpeedIng({required Object rate}) => 'Memutar pada kecepatan ${rate}x';
	@override String get brightness => 'Kecerahan';
	@override String get brightnessLowest => 'Kecerahan paling rendah';
	@override String get volume => 'Volume';
	@override String get volumeMuted => 'Volume dibisukan';
	@override String get restoreDefaultZoom => 'Pulihkan';
	@override late final _TranslationsVideoDetailGestureGuideId gestureGuide = _TranslationsVideoDetailGestureGuideId._(_root);
	@override String get home => 'Beranda';
	@override String get videoPlayer => 'Pemutar Video';
	@override String get videoPlayerInfo => 'Info Pemutar Video';
	@override String get moreSettings => 'Pengaturan Lainnya';
	@override String get videoPlayerFeatureInfo => 'Info Fitur Pemutar Video';
	@override String get autoRewind => 'Mundur Otomatis';
	@override String get rewindAndFastForward => 'Mundur dan Maju Cepat';
	@override String get volumeAndBrightness => 'Volume dan Kecerahan';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Ketuk Ganda Area Tengah untuk Jeda atau Putar';
	@override String get showVerticalVideoInFullScreen => 'Tampilkan Video Vertikal dalam Layar Penuh';
	@override String get keepLastVolumeAndBrightness => 'Pertahankan Volume dan Kecerahan Terakhir';
	@override String get setProxy => 'Atur Proksi';
	@override String get moreFeaturesToBeDiscovered => 'Lebih Banyak Fitur untuk Ditemukan...';
	@override String get videoPlayerSettings => 'Pengaturan Pemutar Video';
	@override String commentCount({required Object num}) => '${num} komentar';
	@override String get writeYourCommentHere => 'Tulis komentar Anda di sini...';
	@override String get authorOtherVideos => 'Video Lain dari Penulis';
	@override String get relatedVideos => 'Video Terkait';
	@override String get privateVideo => 'Ini adalah video privat';
	@override String get externalVideo => 'Ini adalah video eksternal';
	@override String get openInBrowser => 'Buka di Peramban';
	@override String get resourceDeleted => 'Video ini tampaknya telah dihapus :/';
	@override String get noDownloadUrl => 'Tidak ada URL unduhan';
	@override String get startDownloading => 'Mulai mengunduh';
	@override String get downloadFailed => 'Unduhan gagal, silakan coba lagi nanti';
	@override String get downloadSuccess => 'Unduhan berhasil';
	@override String get download => 'Unduh';
	@override String get downloadManager => 'Pengelola Unduhan';
	@override String get resourceNotFound => 'Sumber daya tidak ditemukan';
	@override String get videoLoadError => 'Kesalahan memuat video';
	@override String get authorNoOtherVideos => 'Penulis tidak memiliki video lain';
	@override String get noRelatedVideos => 'Tidak ada video terkait';
	@override late final _TranslationsVideoDetailPlayerId player = _TranslationsVideoDetailPlayerId._(_root);
	@override late final _TranslationsVideoDetailSkeletonId skeleton = _TranslationsVideoDetailSkeletonId._(_root);
	@override late final _TranslationsVideoDetailCastId cast = _TranslationsVideoDetailCastId._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsId likeAvatars = _TranslationsVideoDetailLikeAvatarsId._(_root);
}

// Path: share
class _TranslationsShareId extends TranslationsShareEn {
	_TranslationsShareId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Bagikan Daftar Putar';
	@override String get wowDidYouSeeThis => 'Wow, apakah Anda melihat ini?';
	@override String get nameIs => 'Nama adalah';
	@override String get clickLinkToView => 'Klik tautan untuk melihat';
	@override String get iReallyLikeThis => 'Saya sangat menyukai ini';
	@override String get shareFailed => 'Gagal membagikan, silakan coba lagi nanti';
	@override String get share => 'Bagikan';
	@override String get shareAsImage => 'Bagikan sebagai Gambar';
	@override String get shareAsText => 'Bagikan sebagai Teks';
	@override String get shareAsImageDesc => 'Bagikan sampul video sebagai gambar';
	@override String get shareAsTextDesc => 'Bagikan detail video sebagai teks';
	@override String get shareAsImageFailed => 'Gagal membagikan sampul video sebagai gambar, silakan coba lagi nanti';
	@override String get shareAsTextFailed => 'Gagal membagikan detail video sebagai teks, silakan coba lagi nanti';
	@override String get shareVideo => 'Bagikan Video';
	@override String get authorIs => 'Penulis adalah';
	@override String get shareGallery => 'Bagikan Galeri';
	@override String get galleryTitleIs => 'Judul galeri adalah';
	@override String get galleryAuthorIs => 'Penulis galeri adalah';
	@override String get shareUser => 'Bagikan Pengguna';
	@override String get userNameIs => 'Nama pengguna adalah';
	@override String get userAuthorIs => 'Penulis pengguna adalah';
	@override String get comments => 'Komentar';
	@override String get shareThread => 'Bagikan Utas';
	@override String get views => 'Tayangan';
	@override String get sharePost => 'Bagikan Postingan';
	@override String get postTitleIs => 'Judul postingan adalah';
	@override String get postAuthorIs => 'Penulis postingan adalah';
}

// Path: markdown
class _TranslationsMarkdownId extends TranslationsMarkdownEn {
	_TranslationsMarkdownId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Sintaks Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'Sintaks Markdown Khusus Iwara';
	@override String get internalLink => 'Tautan Internal';
	@override String get supportAutoConvertLinkBelow => 'Mendukung konversi otomatis tautan berikut:';
	@override String get convertLinkExample => '🎬 Tautan Video\n🖼️ Tautan Gambar\n👤 Tautan Pengguna\n📌 Tautan Forum\n🎵 Tautan Daftar Putar\n💬 Tautan Topik';
	@override String get mentionUser => 'Sebutkan Pengguna';
	@override String get mentionUserDescription => 'Masukkan @ diikuti nama pengguna, akan otomatis diubah menjadi tautan pengguna';
	@override String get markdownBasicSyntax => 'Sintaks Dasar Markdown';
	@override String get paragraphAndLineBreak => 'Paragraf dan Pemisah Baris';
	@override String get paragraphAndLineBreakDescription => 'Paragraf dipisahkan oleh satu baris, dan dua spasi di akhir baris akan diubah menjadi pemisah baris';
	@override String get paragraphAndLineBreakSyntax => 'Ini adalah paragraf pertama\n\nIni adalah paragraf kedua\nBaris ini diakhiri dua spasi  \nakan diubah menjadi pemisah baris';
	@override String get textStyle => 'Gaya Teks';
	@override String get textStyleDescription => 'Gunakan simbol khusus untuk mengapit teks agar mengubah gayanya';
	@override String get textStyleSyntax => '**Teks Tebal**\n*Teks Miring*\n~~Teks Coret~~\n`Teks Kode`';
	@override String get quote => 'Kutipan';
	@override String get quoteDescription => 'Gunakan simbol > untuk membuat kutipan, beberapa > untuk membuat kutipan bertingkat';
	@override String get quoteSyntax => '> Ini kutipan tingkat pertama\n>> Ini kutipan tingkat kedua';
	@override String get list => 'Daftar';
	@override String get listDescription => 'Buat daftar berurut dengan angka+titik, buat daftar tak berurut dengan -';
	@override String get listSyntax => '1. Item pertama\n2. Item kedua\n\n- Item tak berurut\n  - Subitem\n  - Subitem lain';
	@override String get linkAndImage => 'Tautan dan Gambar';
	@override String get linkAndImageDescription => 'Format tautan: [teks](URL)\nFormat gambar: ![deskripsi](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[teks tautan](${link})\n![deskripsi gambar](${imgUrl})';
	@override String get title => 'Judul';
	@override String get titleDescription => 'Gunakan simbol # untuk membuat judul, jumlahnya menunjukkan tingkat';
	@override String get titleSyntax => '# Judul tingkat pertama\n## Judul tingkat kedua\n### Judul tingkat ketiga';
	@override String get separator => 'Pemisah';
	@override String get separatorDescription => 'Buat pemisah dengan tiga simbol - atau lebih';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Sintaks';
}

// Path: forum
class _TranslationsForumId extends TranslationsForumEn {
	_TranslationsForumId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get recent => 'Terkini';
	@override String get category => 'Kategori';
	@override String get lastReply => 'Balasan Terakhir';
	@override late final _TranslationsForumSitewideId sitewide = _TranslationsForumSitewideId._(_root);
	@override late final _TranslationsForumErrorsId errors = _TranslationsForumErrorsId._(_root);
	@override String get createPost => 'Buat Postingan';
	@override String get title => 'Judul';
	@override String get enterTitle => 'Masukkan Judul';
	@override String get content => 'Konten';
	@override String get enterContent => 'Masukkan Konten';
	@override String get writeYourContentHere => 'Tulis konten Anda di sini...';
	@override String get posts => 'Postingan';
	@override String get threads => 'Topik';
	@override String get forum => 'Forum';
	@override String get createThread => 'Buat Topik';
	@override String get selectCategory => 'Pilih Kategori';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Jeda tersisa ${minutes} menit ${seconds} detik';
	@override late final _TranslationsForumGroupsId groups = _TranslationsForumGroupsId._(_root);
	@override late final _TranslationsForumLeafNamesId leafNames = _TranslationsForumLeafNamesId._(_root);
	@override late final _TranslationsForumLeafDescriptionsId leafDescriptions = _TranslationsForumLeafDescriptionsId._(_root);
	@override String get reply => 'Balas';
	@override String get pendingReview => 'Menunggu Tinjauan';
	@override String get editedAt => 'Diubah Pada';
	@override String get copySuccess => 'Disalin ke papan klip';
	@override String copySuccessForMessage({required Object str}) => 'Disalin ke papan klip: ${str}';
	@override String get editReply => 'Ubah Balasan';
	@override String get editTitle => 'Ubah Judul';
	@override String get submit => 'Kirim';
}

// Path: notifications
class _TranslationsNotificationsId extends TranslationsNotificationsEn {
	_TranslationsNotificationsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsId errors = _TranslationsNotificationsErrorsId._(_root);
	@override String get notifications => 'Notifikasi';
	@override String get profile => 'Profil';
	@override String get postedNewComment => 'Memposting komentar baru';
	@override String get inYour => 'Di';
	@override String get video => 'Video';
	@override String get repliedYourVideoComment => 'Membalas komentar video Anda';
	@override String get copyInfoToClipboard => 'Salin info notifikasi ke papan klip';
	@override String get copySuccess => 'Disalin ke papan klip';
	@override String copySuccessForMessage({required Object str}) => 'Disalin ke papan klip: ${str}';
	@override String get markAllAsRead => 'Tandai semua telah dibaca';
	@override String get markAllAsReadSuccess => 'Semua notifikasi telah ditandai sebagai dibaca';
	@override String get markAllAsReadFailed => 'Gagal menandai semua telah dibaca';
	@override String get markSelectedAsRead => 'Tandai yang dipilih sebagai dibaca';
	@override String get markSelectedAsReadSuccess => 'Notifikasi yang dipilih telah ditandai sebagai dibaca';
	@override String get markSelectedAsReadFailed => 'Gagal menandai yang dipilih sebagai dibaca';
	@override String get markAsRead => 'Tandai sebagai dibaca';
	@override String get markAsReadSuccess => 'Notifikasi telah ditandai sebagai dibaca';
	@override String get markAsReadFailed => 'Gagal menandai notifikasi sebagai dibaca';
	@override String get notificationTypeHelp => 'Bantuan Jenis Notifikasi';
	@override String get dueToLackOfNotificationTypeDetails => 'Karena kurangnya detail jenis notifikasi, jenis yang didukung mungkin tidak mencakup pesan yang Anda terima saat ini';
	@override String get helpUsImproveNotificationTypeSupport => 'Jika Anda bersedia membantu kami meningkatkan dukungan jenis notifikasi';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Salin informasi notifikasi\n2. 🐞 Kirim issue ke repositori proyek\n\n⚠️ Catatan: Informasi notifikasi dapat berisi privasi pribadi, jika Anda tidak ingin mempublikasikannya, Anda juga dapat mengirimkannya ke penulis proyek melalui email.';
	@override String get goToRepository => 'Buka Repositori';
	@override String get copy => 'Salin';
	@override String get commentApproved => 'Komentar Disetujui';
	@override String get repliedYourProfileComment => 'Membalas komentar profil Anda';
	@override String get kReplied => 'membalas komentar Anda di';
	@override String get kCommented => 'mengomentari';
	@override String get kVideo => 'video';
	@override String get kGallery => 'galeri';
	@override String get kProfile => 'profil';
	@override String get kThread => 'utas';
	@override String get kPost => 'postingan';
	@override String get kCommentSection => 'bagian komentar';
	@override String get kApprovedComment => 'Komentar disetujui';
	@override String get kApprovedVideo => 'Video disetujui';
	@override String get kApprovedGallery => 'Galeri disetujui';
	@override String get kApprovedThread => 'Utas disetujui';
	@override String get kApprovedPost => 'Postingan disetujui';
	@override String get kApprovedForumPost => 'Postingan forum disetujui';
	@override String get kRejectedContent => 'Peninjauan konten ditolak';
	@override String get kUnknownType => 'Jenis notifikasi tidak dikenal';
}

// Path: conversation
class _TranslationsConversationId extends TranslationsConversationEn {
	_TranslationsConversationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsId errors = _TranslationsConversationErrorsId._(_root);
	@override String get conversation => 'Percakapan';
	@override String get startConversation => 'Mulai Percakapan';
	@override String get noConversation => 'Tidak ada percakapan';
	@override String get selectFromLeftListAndStartConversation => 'Pilih dari daftar kiri dan mulai percakapan';
	@override String get title => 'Judul';
	@override String get body => 'Isi';
	@override String get selectAUser => 'Pilih pengguna';
	@override String get searchUsers => 'Cari pengguna...';
	@override String get tmpNoConversions => 'Tidak ada percakapan';
	@override String get deleteThisMessage => 'Hapus pesan ini';
	@override String get deleteThisMessageSubtitle => 'Tindakan ini tidak dapat dibatalkan';
	@override String get writeMessageHere => 'Tulis pesan di sini...';
	@override String get lastMessageFromMe => 'Anda: ';
	@override String get sendMessage => 'Kirim pesan';
}

// Path: splash
class _TranslationsSplashId extends TranslationsSplashEn {
	_TranslationsSplashId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsId errors = _TranslationsSplashErrorsId._(_root);
	@override String get preparing => 'Mempersiapkan...';
	@override String get initializing => 'Menginisialisasi...';
	@override String get loading => 'Memuat...';
	@override String get ready => 'Siap';
	@override String get initializingMessageService => 'Menginisialisasi layanan pesan...';
}

// Path: download
class _TranslationsDownloadId extends TranslationsDownloadEn {
	_TranslationsDownloadId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsId errors = _TranslationsDownloadErrorsId._(_root);
	@override String get downloadList => 'Daftar Unduhan';
	@override String get viewDownloadList => 'Lihat Daftar Unduhan';
	@override String get download => 'Unduh';
	@override String get selectDownloadTitle => 'Pilih Unduhan';
	@override String get qualitySectionLabel => 'Kualitas';
	@override String get categorySectionLabel => 'Kategori';
	@override String get saveToPreviewLabel => 'Akan disimpan ke';
	@override String saveToPreviewSuggested({required Object name}) => 'Nama file saran: ${name} (bisa diubah di dialog sistem)';
	@override String get lastUsedBadge => 'Terakhir digunakan';
	@override String get pickedBadge => 'Dipilih';
	@override String get startDownloading => 'Mulai Mengunduh';
	@override String get clearAllFailedTasks => 'Bersihkan Semua Tugas Gagal';
	@override String get clearAllFailedTasksConfirmation => 'Apakah Anda yakin ingin membersihkan semua tugas unduhan yang gagal? Berkas dari tugas-tugas ini juga akan dihapus.';
	@override String get clearAllFailedTasksSuccess => 'Semua tugas yang gagal telah dibersihkan';
	@override String get clearAllFailedTasksError => 'Terjadi kesalahan saat membersihkan tugas yang gagal';
	@override String get downloadStatus => 'Status Unduhan';
	@override String get imageList => 'Daftar Gambar';
	@override String get retryDownload => 'Coba Unduh Lagi';
	@override String get notDownloaded => 'Belum Diunduh';
	@override String get downloaded => 'Terunduh';
	@override String get waitingForDownload => 'Menunggu Unduhan';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Mengunduh (${downloaded}/${total} gambar ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Mengunduh (${downloaded} gambar)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Dijeda (${downloaded}/${total} gambar ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'Dijeda (${downloaded} gambar)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Terunduh (Total ${total} gambar)';
	@override String get viewVideoDetail => 'Lihat Rincian Video';
	@override String get viewGalleryDetail => 'Lihat Rincian Galeri';
	@override String get moreOptions => 'Opsi Lainnya';
	@override String get openFile => 'Buka Berkas';
	@override String get playLocally => 'Putar Secara Lokal';
	@override String get pause => 'Jeda';
	@override String get resume => 'Lanjutkan';
	@override String get copyDownloadUrl => 'Salin URL Unduhan';
	@override String get showInFolder => 'Tampilkan di Folder';
	@override String get deleteTask => 'Hapus Tugas';
	@override String get deleteTaskConfirmation => 'Apakah Anda yakin ingin menghapus tugas unduhan ini?\nBerkas tugas juga akan dihapus.';
	@override String get forceDeleteTask => 'Paksa Hapus Tugas';
	@override String get forceDeleteTaskConfirmation => 'Apakah Anda yakin ingin memaksa menghapus tugas unduhan ini?\nBerkas tugas juga akan dihapus, meskipun berkas sedang digunakan.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Mengunduh ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Mengunduh ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'Dijeda ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'Dijeda • Terunduh ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Terunduh • ${size}';
	@override String get copyDownloadUrlSuccess => 'URL unduhan disalin';
	@override String totalImageNums({required Object num}) => '${num} gambar';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Mengunduh ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'Mengunduh';
	@override String get failed => 'Gagal';
	@override String get completed => 'Selesai';
	@override String get downloadDetail => 'Rincian Unduhan';
	@override String get copy => 'Salin';
	@override String get copySuccess => 'Disalin';
	@override String get waiting => 'Menunggu';
	@override String get paused => 'Dijeda';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Mengunduh ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Unduhan Galeri Selesai: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Unduhan Selesai: ${fileName}';
	@override String get searchTasks => 'Cari tugas...';
	@override String statusLabel({required Object label}) => 'Status: ${label}';
	@override String get allStatus => 'Semua Status';
	@override String typeLabel({required Object label}) => 'Jenis: ${label}';
	@override String get allTypes => 'Semua Jenis';
	@override String get taskType => 'Jenis';
	@override String get video => 'Video';
	@override String get gallery => 'Galeri';
	@override String get other => 'Lainnya';
	@override String get clearFilters => 'Bersihkan filter';
	@override String get pauseAll => 'Jeda semua';
	@override String get resumeAll => 'Mulai semua';
	@override String remainingTime({required Object time}) => 'sisa ${time}';
	@override late final _TranslationsDownloadTimelineId timeline = _TranslationsDownloadTimelineId._(_root);
	@override late final _TranslationsDownloadErrorTypesId errorTypes = _TranslationsDownloadErrorTypesId._(_root);
	@override String get errorDetailCopied => 'Rincian kesalahan disalin';
	@override String get errorDetailCopyHint => 'Tekan lama untuk menyalin rincian kesalahan';
	@override late final _TranslationsDownloadRestoredPausedId restoredPaused = _TranslationsDownloadRestoredPausedId._(_root);
	@override late final _TranslationsDownloadActionsId actions = _TranslationsDownloadActionsId._(_root);
	@override late final _TranslationsDownloadNoticeId notice = _TranslationsDownloadNoticeId._(_root);
	@override String get emptyTaskList => 'Belum ada tugas unduhan';
	@override String get noMatchingTasks => 'Tidak ada tugas yang cocok';
	@override late final _TranslationsDownloadDeleteByDateId deleteByDate = _TranslationsDownloadDeleteByDateId._(_root);
	@override late final _TranslationsDownloadRelocationId relocation = _TranslationsDownloadRelocationId._(_root);
	@override late final _TranslationsDownloadCategoryId category = _TranslationsDownloadCategoryId._(_root);
	@override late final _TranslationsDownloadLocationId location = _TranslationsDownloadLocationId._(_root);
	@override String get maxConcurrentDownloads => 'Unduhan bersamaan maksimum';
	@override String get maxConcurrentDownloadsDesc => 'Jumlah tugas yang diunduh pada waktu bersamaan (1-5)';
	@override String get stillInDevelopment => 'Masih dalam pengembangan';
	@override String get saveToAppDirectory => 'Simpan ke direktori aplikasi';
	@override String get alreadyDownloadedWithQuality => 'Sudah diunduh dengan kualitas yang sama, lanjutkan pengunduhan?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Sudah diunduh dengan kualitas: ${qualities}, lanjutkan pengunduhan?';
	@override String get otherQualities => 'Kualitas lain';
	@override late final _TranslationsDownloadBatchDownloadId batchDownload = _TranslationsDownloadBatchDownloadId._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsId extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Unduhan selesai';
	@override String get failedTitle => 'Unduhan gagal';
	@override String completedBody({required Object name}) => '${name} berhasil diunduh';
	@override String failedBody({required Object name}) => '${name} gagal diunduh';
	@override String completedToast({required Object name}) => '${name} telah diunduh';
	@override String failedToast({required Object name}) => 'Unduhan ${name} gagal';
	@override String savedToFolder({required Object dir}) => 'Tersimpan di ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Tersimpan sebagai ${name} (sudah ada file bernama sama)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Tersimpan di folder aplikasi — tidak bisa menulis ${target} (${reason})';
	@override String get viewFolder => 'Lihat folder';
	@override String get fixInSettings => 'Perbaiki di Pengaturan';
	@override String get channelName => 'Status unduhan';
	@override String get channelDescription => 'Notifikasi untuk unduhan yang selesai dan gagal';
}

// Path: favorite
class _TranslationsFavoriteId extends TranslationsFavoriteEn {
	_TranslationsFavoriteId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsId errors = _TranslationsFavoriteErrorsId._(_root);
	@override String get add => 'Tambah';
	@override String get addSuccess => 'Berhasil ditambahkan';
	@override String get addFailed => 'Gagal menambahkan';
	@override String get remove => 'Hapus';
	@override String get removeSuccess => 'Berhasil dihapus';
	@override String get removeFailed => 'Gagal menghapus';
	@override String get removeConfirmation => 'Apakah Anda yakin ingin menghapus item ini dari favorit?';
	@override String get removeConfirmationSuccess => 'Item dihapus dari favorit';
	@override String get removeConfirmationFailed => 'Gagal menghapus item dari favorit';
	@override String get createFolderSuccess => 'Folder berhasil dibuat';
	@override String get createFolderFailed => 'Gagal membuat folder';
	@override String get createFolder => 'Buat Folder';
	@override String get enterFolderName => 'Masukkan nama folder';
	@override String get enterFolderNameHere => 'Masukkan nama folder di sini...';
	@override String get create => 'Buat';
	@override String get items => 'Item';
	@override String get newFolderName => 'Folder Baru';
	@override String get searchFolders => 'Cari folder...';
	@override String get searchItems => 'Cari item...';
	@override String get createdAt => 'Dibuat Pada';
	@override String get myFavorites => 'Favorit Saya';
	@override String get deleteFolderTitle => 'Hapus Folder';
	@override String deleteFolderConfirmWithTitle({required Object title}) => 'Apakah Anda yakin ingin menghapus folder ${title}?';
	@override String get removeItemTitle => 'Hapus Item';
	@override String removeItemConfirmWithTitle({required Object title}) => 'Apakah Anda yakin ingin menghapus item ${title}?';
	@override String get removeItemSuccess => 'Item dihapus dari favorit';
	@override String get removeItemFailed => 'Gagal menghapus item dari favorit';
	@override String get localizeFavorite => 'Favorit Lokal';
	@override String get editFolderTitle => 'Ubah Folder';
	@override String get editFolderSuccess => 'Folder berhasil diperbarui';
	@override String get editFolderFailed => 'Gagal memperbarui folder';
	@override String get searchTags => 'Cari tag';
	@override String get noTagsInFolder => 'Belum ada tag pada item di folder ini';
	@override String get tagFilterMatchAll => 'Hanya menampilkan item yang memiliki semua tag terpilih';
	@override String get clearSelectedTags => 'Bersihkan tag yang dipilih';
	@override String selectedTagCount({required Object count}) => '${count} dipilih';
	@override String get noMatchingTags => 'Tidak ada tag yang cocok';
}

// Path: translation
class _TranslationsTranslationId extends TranslationsTranslationEn {
	_TranslationsTranslationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Layanan Saat Ini';
	@override String get testConnection => 'Uji Koneksi';
	@override String get testConnectionSuccess => 'Uji koneksi berhasil';
	@override String get testConnectionFailed => 'Uji koneksi gagal';
	@override String testConnectionFailedWithMessage({required Object message}) => 'Uji koneksi gagal: ${message}';
	@override String get translation => 'Terjemahan';
	@override String get needVerification => 'Memerlukan Verifikasi';
	@override String get needVerificationContent => 'Silakan uji koneksi terlebih dahulu sebelum mengaktifkan terjemahan AI';
	@override String get confirm => 'Konfirmasi';
	@override String get disclaimer => 'Penafian';
	@override String get riskWarning => 'Peringatan Risiko';
	@override String get dureToRisk1 => 'Karena teks dihasilkan oleh pengguna, teks dapat mengandung konten yang melanggar kebijakan konten penyedia layanan AI';
	@override String get dureToRisk2 => 'Konten yang tidak pantas dapat menyebabkan penangguhan kunci API atau penghentian layanan';
	@override String get operationSuggestion => 'Saran Penggunaan';
	@override String get operationSuggestion1 => '1. Gunakan sebelum meninjau konten yang akan diterjemahkan secara ketat';
	@override String get operationSuggestion2 => '2. Hindari menerjemahkan konten yang melibatkan kekerasan, konten dewasa, dll.';
	@override String get apiConfig => 'Konfigurasi API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Mengubah konfigurasi akan menutup terjemahan AI secara otomatis, perlu diuji lagi setelah diaktifkan';
	@override String get apiAddress => 'Alamat API';
	@override String get modelName => 'Nama Model';
	@override String get modelNameHintText => 'Misalnya: gpt-4-turbo';
	@override String get maxTokens => 'Token Maksimum';
	@override String get maxTokensHintText => 'Misalnya: 32000';
	@override String get temperature => 'Suhu';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Klik tombol uji untuk memverifikasi validitas koneksi API';
	@override String get requestPreview => 'Pratinjau Permintaan';
	@override String get enableAITranslation => 'Aktifkan AI';
	@override String get enabled => 'Diaktifkan';
	@override String get disabled => 'Dinonaktifkan';
	@override String get testing => 'Menguji...';
	@override String get testNow => 'Uji Sekarang';
	@override String get connectionStatus => 'Status Koneksi';
	@override String get success => 'Berhasil';
	@override String get failed => 'Gagal';
	@override String get information => 'Informasi';
	@override String get viewRawResponse => 'Lihat Respons Mentah';
	@override String get pleaseCheckInputParametersFormat => 'Silakan periksa format parameter masukan';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Silakan isi alamat API, nama model, dan kunci';
	@override String get pleaseFillInValidConfigurationParameters => 'Silakan isi parameter konfigurasi yang valid';
	@override String get pleaseCompleteConnectionTest => 'Silakan selesaikan uji koneksi';
	@override String get notConfigured => 'Belum Dikonfigurasi';
	@override String get apiEndpoint => 'Endpoint API';
	@override String get configuredKey => 'Kunci yang Dikonfigurasi';
	@override String get notConfiguredKey => 'Kunci Belum Dikonfigurasi';
	@override String get authenticationStatus => 'Status Autentikasi';
	@override String get thisFieldCannotBeEmpty => 'Kolom ini tidak boleh kosong';
	@override String get apiKey => 'Kunci API';
	@override String get apiKeyCannotBeEmpty => 'Kunci API tidak boleh kosong';
	@override String get pleaseEnterValidNumber => 'Silakan masukkan angka yang valid';
	@override String get range => 'Rentang';
	@override String get mustBeGreaterThan => 'Harus lebih besar dari';
	@override String get invalidAPIResponse => 'Respons API tidak valid';
	@override String connectionFailedForMessage({required Object message}) => 'Koneksi gagal: ${message}';
	@override String get aiTranslationNotEnabledHint => 'Terjemahan AI tidak diaktifkan, silakan aktifkan di pengaturan';
	@override String get goToSettings => 'Buka Pengaturan';
	@override String get disableAITranslation => 'Nonaktifkan Terjemahan AI';
	@override String get currentValue => 'Nilai Saat Ini';
	@override String get configureTranslationStrategy => 'Konfigurasikan Strategi Terjemahan';
	@override String get advancedSettings => 'Pengaturan Lanjutan';
	@override String get translationPrompt => 'Prompt Terjemahan';
	@override String get promptHint => 'Silakan masukkan prompt terjemahan, gunakan [TL] sebagai placeholder untuk bahasa target';
	@override String get promptHelperText => 'Prompt harus berisi [TL] sebagai placeholder untuk bahasa target';
	@override String get promptMustContainTargetLang => 'Prompt harus berisi placeholder [TL]';
	@override String get aiTranslationWillBeDisabled => 'Terjemahan AI akan dinonaktifkan';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'Karena perubahan konfigurasi dasar, terjemahan AI akan dinonaktifkan';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'Karena perubahan prompt terjemahan, terjemahan AI akan dinonaktifkan';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'Karena perubahan konfigurasi parameter, terjemahan AI akan dinonaktifkan';
	@override String get onlyOpenAIAPISupported => 'Saat ini hanya mendukung format API yang kompatibel dengan OpenAI (badan permintaan application/json)';
	@override String get streamingTranslation => 'Terjemahan Streaming';
	@override String get streamingTranslationSupported => 'Terjemahan Streaming Didukung';
	@override String get streamingTranslationNotSupported => 'Terjemahan Streaming Tidak Didukung';
	@override String get streamingTranslationDescription => 'Terjemahan streaming dapat menampilkan hasil secara real-time selama proses terjemahan, memberikan pengalaman pengguna yang lebih baik';
	@override String get usingFullUrlWithHash => 'Menggunakan URL lengkap (diakhiri dengan #)';
	@override String get baseUrlInputHelperText => 'Jika diakhiri dengan #, alamat tersebut akan digunakan sebagai alamat permintaan sebenarnya';
	@override String currentActualUrl({required Object url}) => 'URL sebenarnya saat ini: ${url}';
	@override String get urlEndingWithHashTip => 'URL yang diakhiri dengan # akan digunakan langsung tanpa menambahkan akhiran apa pun';
	@override String get streamingTranslationWarning => 'Catatan: Fitur ini memerlukan dukungan layanan API untuk transmisi streaming, beberapa model mungkin tidak mendukungnya';
	@override String get translationService => 'Layanan Terjemahan';
	@override String get translationServiceDescription => 'Pilih layanan terjemahan yang Anda sukai';
	@override String get googleTranslation => 'Terjemahan Google';
	@override String get googleTranslationDescription => 'Layanan terjemahan online gratis yang mendukung berbagai bahasa';
	@override String get aiTranslation => 'Terjemahan AI';
	@override String get aiTranslationDescription => 'Layanan terjemahan cerdas berbasis model bahasa besar';
	@override String get deeplxTranslation => 'Terjemahan DeepLX';
	@override String get deeplxTranslationDescription => 'Implementasi sumber terbuka dari terjemahan DeepL, menyediakan terjemahan berkualitas tinggi';
	@override String get googleTranslationFeatures => 'Fitur';
	@override String get freeToUse => 'Gratis digunakan';
	@override String get freeToUseDescription => 'Tidak perlu konfigurasi, siap digunakan';
	@override String get fastResponse => 'Respons cepat';
	@override String get fastResponseDescription => 'Kecepatan terjemahan cepat dengan latensi rendah';
	@override String get stableAndReliable => 'Stabil dan andal';
	@override String get stableAndReliableDescription => 'Berbasis API resmi Google';
	@override String get enabledDefaultService => 'Diaktifkan - Layanan terjemahan bawaan';
	@override String get notEnabled => 'Tidak diaktifkan';
	@override String get deeplxTranslationService => 'Layanan Terjemahan DeepLX';
	@override String get deeplxDescription => 'DeepLX adalah implementasi sumber terbuka dari terjemahan DeepL, yang mendukung mode endpoint Free, Pro, dan Official';
	@override String get serverAddress => 'Alamat Server';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Alamat dasar server DeepLX';
	@override String get endpointType => 'Jenis Endpoint';
	@override String get freeEndpoint => 'Free - Endpoint gratis, mungkin memiliki batas laju';
	@override String get proEndpoint => 'Pro - Memerlukan dl_session, lebih stabil';
	@override String get officialEndpoint => 'Official - Format API resmi';
	@override String get finalRequestUrl => 'URL Permintaan Final';
	@override String get apiKeyOptional => 'Kunci API (Opsional)';
	@override String get apiKeyOptionalHint => 'Untuk mengakses layanan DeepLX yang dilindungi';
	@override String get apiKeyOptionalHelperText => 'Beberapa layanan DeepLX memerlukan Kunci API untuk autentikasi';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'Parameter dl_session diperlukan untuk mode Pro';
	@override String get dlSessionHelperText => 'Parameter sesi diperlukan untuk endpoint Pro, diperoleh dari akun DeepL Pro';
	@override String get proModeRequiresDlSession => 'Mode Pro memerlukan dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Klik tombol uji untuk memverifikasi koneksi API DeepLX';
	@override String get enableDeepLXTranslation => 'Aktifkan Terjemahan DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'Terjemahan DeepLX akan dinonaktifkan karena perubahan konfigurasi';
	@override String get translatedResult => 'Hasil Terjemahan';
	@override String get testSuccess => 'Uji berhasil';
	@override String get pleaseFillInDeepLXServerAddress => 'Silakan isi alamat server DeepLX';
	@override String get invalidAPIResponseFormat => 'Format respons API tidak valid';
	@override String get translationServiceReturnedError => 'Layanan terjemahan mengembalikan kesalahan atau hasil kosong';
	@override String get connectionFailed => 'Koneksi gagal';
	@override String get translationFailed => 'Terjemahan gagal';
	@override String get aiTranslationFailed => 'Terjemahan AI gagal';
	@override String get deeplxTranslationFailed => 'Terjemahan DeepLX gagal';
	@override String get aiTranslationTestFailed => 'Uji terjemahan AI gagal';
	@override String get deeplxTranslationTestFailed => 'Uji terjemahan DeepLX gagal';
	@override String get streamingTranslationTimeout => 'Waktu habis terjemahan streaming, memaksa pembersihan sumber daya';
	@override String get translationRequestTimeout => 'Waktu habis permintaan terjemahan';
	@override String get streamingTranslationDataTimeout => 'Waktu habis penerimaan data terjemahan streaming';
	@override String get dataReceptionTimeout => 'Waktu habis penerimaan data';
	@override String get streamDataParseError => 'Kesalahan saat mengurai data aliran';
	@override String get streamingTranslationFailed => 'Terjemahan streaming gagal';
	@override String get fallbackTranslationFailed => 'Terjemahan cadangan ke terjemahan normal juga gagal';
	@override String get translationSettings => 'Pengaturan Terjemahan';
	@override String get enableGoogleTranslation => 'Aktifkan Terjemahan Google';
	@override String get thinking => 'Berpikir...';
	@override String get thoughtProcess => 'Proses Pemikiran';
	@override String get modelCompatibility => 'Kompatibilitas Model';
	@override String get modelCompatibilityDescription => 'Sesuaikan parameter permintaan untuk model modern seperti model penalaran (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'Model Penalaran';
	@override String get reasoningModelDescription => 'Untuk o1/o3, DeepSeek-R1, QwQ, dll. Melipat prompt ke dalam pesan pengguna, menghilangkan temperature, dan menggunakan max_completion_tokens';
	@override String get useMaxCompletionTokens => 'Gunakan max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'Endpoint OpenAI yang lebih baru memerlukan max_completion_tokens alih-alih max_tokens yang sudah usang';
	@override String get sendTemperature => 'Kirim temperature';
	@override String get sendTemperatureDescription => 'Nonaktifkan untuk model yang menolak parameter temperature (sebagian besar model penalaran)';
	@override String get showReasoningProcess => 'Tampilkan proses pemikiran';
	@override String get showReasoningProcessDescription => 'Tampilkan penalaran yang dapat dilipat dari model penalaran di dialog terjemahan';
	@override String get provider => 'Penyedia';
	@override String get providerOpenAI => 'OpenAI (dan yang kompatibel)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Mendukung OpenAI (dan endpoint apa pun yang kompatibel dengan OpenAI), Anthropic, dan Google melalui SDK dartantic_ai';
	@override String get baseUrlOptionalHelperText => 'Opsional. Biarkan kosong untuk menggunakan endpoint bawaan penyedia; isi untuk endpoint yang kompatibel dengan OpenAI/relai';
	@override String get defaultEndpoint => 'Endpoint bawaan';
	@override String get providerPreset => 'Prasetel Penyedia';
	@override String get selectProviderPreset => 'Pilih prasetel';
	@override String get presetCustom => 'Kustom';
	@override String presetApplied({required Object name}) => 'Prasetel diterapkan: ${name}';
	@override late final _TranslationsTranslationPresetNamesId presetNames = _TranslationsTranslationPresetNamesId._(_root);
	@override String get fetchModelList => 'Ambil daftar model';
	@override String get fetchingModels => 'Mengambil...';
	@override String get selectModel => 'Pilih Model';
	@override String get searchModel => 'Cari model';
	@override String get noModelsFound => 'Tidak ada model ditemukan';
}

// Path: bottomNav
class _TranslationsBottomNavId extends TranslationsBottomNavEn {
	_TranslationsBottomNavId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get video => 'Video';
	@override String get gallery => 'Galeri';
	@override String get subscription => 'Feed';
	@override String get community => 'Forum';
	@override String get localMedia => 'Lokal';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsId extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Urutan Navigasi';
	@override String get customNavigationOrder => 'Urutan Navigasi Kustom';
	@override String get customNavigationOrderDesc => 'Seret untuk menyesuaikan urutan tampilan halaman pada bilah navigasi bawah dan bilah samping';
	@override String get restartRequired => 'Perlu memulai ulang aplikasi';
	@override String get navigationItemSorting => 'Pengurutan Item Navigasi';
	@override String get done => 'Selesai';
	@override String get edit => 'Ubah';
	@override String get reset => 'Atur Ulang';
	@override String get previewEffect => 'Pratinjau Efek';
	@override String get bottomNavigationPreview => 'Pratinjau Navigasi Bawah:';
	@override String get sidebarPreview => 'Pratinjau Bilah Samping:';
	@override String get confirmResetNavigationOrder => 'Konfirmasi Atur Ulang Urutan Navigasi';
	@override String get confirmResetNavigationOrderDesc => 'Apakah Anda yakin ingin mengatur ulang urutan navigasi ke pengaturan bawaan?';
	@override String get cancel => 'Batal';
	@override String get show => 'Tampilkan';
	@override String get hide => 'Sembunyikan';
	@override String get hidden => 'Tersembunyi';
	@override String get hideHint => 'Ketuk ikon mata untuk menampilkan atau menyembunyikan Komunitas dan berkas lokal';
	@override String get videoDescription => 'Telusuri konten video populer';
	@override String get galleryDescription => 'Telusuri gambar dan galeri';
	@override String get subscriptionDescription => 'Lihat konten terbaru dari pengguna yang Anda ikuti';
	@override String get forumDescription => 'Ikut serta dalam diskusi komunitas';
	@override String get newsDescription => 'Telusuri berita, artikel, dan siaran resmi';
	@override String get communityDescription => 'Diskusi forum serta berita, artikel, dan siaran resmi';
	@override String get localMediaDescription => 'Telusuri video dan gambar yang tersimpan di perangkat ini';
}

// Path: news
class _TranslationsNewsId extends TranslationsNewsEn {
	_TranslationsNewsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Berita';
	@override String get newsUpdates => 'Pembaruan Berita';
	@override String get articles => 'Artikel';
	@override String get broadcast => 'Siaran';
	@override String get openInBrowser => 'Buka di Peramban';
}

// Path: displaySettings
class _TranslationsDisplaySettingsId extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Tampilan';
	@override String get layoutSettings => 'Pengaturan Tata Letak';
	@override String get layoutSettingsDesc => 'Sesuaikan jumlah kolom dan konfigurasi titik henti';
	@override String get gridLayout => 'Tata Letak Kisi';
	@override String get navigationOrderSettings => 'Pengaturan Urutan Navigasi';
	@override String get customNavigationOrder => 'Urutan Navigasi Kustom';
	@override String get customNavigationOrderDesc => 'Sesuaikan urutan tampilan halaman pada bilah navigasi bawah dan bilah samping';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsId extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Tata Letak';
	@override String get descriptionTitle => 'Penjelasan Konfigurasi Tata Letak';
	@override String get descriptionContent => 'Konfigurasi di sini akan menentukan jumlah kolom yang ditampilkan pada halaman daftar video dan galeri. Anda dapat memilih mode otomatis agar sistem menyesuaikan secara otomatis berdasarkan lebar layar, atau memilih mode manual untuk menetapkan jumlah kolom.';
	@override String get layoutMode => 'Mode Tata Letak';
	@override String get reset => 'Atur Ulang';
	@override String get autoMode => 'Mode Otomatis';
	@override String get autoModeDesc => 'Menyesuaikan secara otomatis berdasarkan lebar layar';
	@override String get manualMode => 'Mode Manual';
	@override String get manualModeDesc => 'Gunakan jumlah kolom tetap';
	@override String get manualSettings => 'Pengaturan Manual';
	@override String get fixedColumns => 'Kolom Tetap';
	@override String get columns => 'kolom';
	@override String get breakpointConfig => 'Konfigurasi Titik Henti';
	@override String get add => 'Tambah';
	@override String get defaultColumns => 'Kolom Bawaan';
	@override String get defaultColumnsDesc => 'Tampilan bawaan untuk layar besar';
	@override String get previewEffect => 'Pratinjau Efek';
	@override String get screenWidth => 'Lebar Layar';
	@override String get addBreakpoint => 'Tambah Titik Henti';
	@override String get editBreakpoint => 'Ubah Titik Henti';
	@override String get deleteBreakpoint => 'Hapus Titik Henti';
	@override String get screenWidthLabel => 'Lebar Layar';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Kolom';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Silakan masukkan lebar';
	@override String get enterValidWidth => 'Silakan masukkan lebar yang valid';
	@override String get widthCannotExceed9999 => 'Lebar tidak boleh melebihi 9999';
	@override String get breakpointAlreadyExists => 'Titik henti sudah ada';
	@override String get enterColumns => 'Silakan masukkan jumlah kolom';
	@override String get enterValidColumns => 'Silakan masukkan jumlah kolom yang valid';
	@override String get columnsCannotExceed12 => 'Kolom tidak boleh melebihi 12';
	@override String get breakpointConflict => 'Titik henti sudah ada';
	@override String get confirmResetLayoutSettings => 'Atur Ulang Pengaturan Tata Letak';
	@override String get confirmResetLayoutSettingsDesc => 'Apakah Anda yakin ingin mengatur ulang semua pengaturan tata letak ke nilai bawaan?\n\nAkan dikembalikan ke:\n• Mode otomatis\n• Konfigurasi titik henti bawaan';
	@override String get resetToDefaults => 'Atur Ulang ke Bawaan';
	@override String get confirmDeleteBreakpoint => 'Hapus Titik Henti';
	@override String confirmDeleteBreakpointDesc({required Object width}) => 'Apakah Anda yakin ingin menghapus titik henti ${width}px?';
	@override String get noCustomBreakpoints => 'Tidak ada titik henti kustom, menggunakan kolom bawaan';
	@override String get breakpointRange => 'Rentang Titik Henti';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Ubah';
	@override String get delete => 'Hapus';
	@override String get cancel => 'Batal';
	@override String get save => 'Simpan';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerId extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Kesalahan Pemutar Video';
	@override String get videoLoadFailed => 'Gagal Memuat Video';
	@override String get videoCodecNotSupported => 'Codec Video Tidak Didukung';
	@override String get networkConnectionIssue => 'Masalah Koneksi Jaringan';
	@override String get insufficientPermission => 'Izin Tidak Cukup';
	@override String get unsupportedVideoFormat => 'Format Video Tidak Didukung';
	@override String get retry => 'Coba Lagi';
	@override String get externalPlayer => 'Pemutar Eksternal';
	@override String get detailedErrorInfo => 'Informasi Kesalahan Terperinci';
	@override String get format => 'Format';
	@override String get suggestion => 'Saran';
	@override String get androidWebmCompatibilityIssue => 'Perangkat Android memiliki dukungan terbatas untuk format WEBM. Disarankan menggunakan pemutar eksternal atau mengunduh aplikasi pemutar yang mendukung WEBM';
	@override String get currentDeviceCodecNotSupported => 'Perangkat saat ini tidak mendukung codec untuk format video ini';
	@override String get checkNetworkConnection => 'Silakan periksa koneksi jaringan Anda dan coba lagi';
	@override String get appMayLackMediaPermission => 'Aplikasi mungkin kekurangan izin pemutaran media yang diperlukan';
	@override String get tryOtherVideoPlayer => 'Silakan coba gunakan pemutar video lain';
	@override String get unrecognizedVideoFormat => 'Berkas video tidak dikenali';
	@override String get unrecognizedVideoFormatSuggestion => 'Tautan mungkin sudah kedaluwarsa, atau responsnya bukan video. Coba lagi, atau buka dengan aplikasi lain.';
	@override String get accessDenied => 'Server menolak permintaan ini (403)';
	@override String get accessDeniedSuggestion => 'Tautan pemutaran kemungkinan besar sudah kedaluwarsa. Ketuk Coba Lagi untuk mengambilnya kembali, atau buka dengan aplikasi lain.';
	@override String get mute => 'Bisukan';
	@override String get unmute => 'Bunyikan';
	@override String get video => 'VIDEO';
	@override String get serverSelector => 'Pilihan Server CDN';
	@override String get serverSelectorDescription => 'Pilih server dengan latensi terendah untuk pengalaman pemutaran terbaik';
	@override String get retestSpeed => 'Uji Ulang Kecepatan';
	@override String get waitingForSpeedTest => 'Menunggu uji kecepatan';
	@override String get testingSpeed => 'Menguji kecepatan...';
	@override String get testFailed => 'Uji gagal';
	@override String get loadingServerList => 'Memuat daftar server...';
	@override String get noAvailableServers => 'Tidak ada server yang tersedia';
	@override String get refreshServerList => 'Segarkan Daftar Server';
	@override String get cannotGetSource => 'Tidak dapat mendapatkan sumber video saat ini';
	@override String switchedToServer({required Object serverName}) => 'Beralih ke server: ${serverName}';
	@override String serverCount({required Object count}) => 'Total ${count} server';
	@override String statusCode({required Object code}) => 'Kode status: ${code}';
	@override String get connectionFailed => 'Koneksi gagal';
	@override String get connectionTimeout => 'Koneksi habis waktu';
	@override String get networkError => 'Kesalahan jaringan';
	@override String get sslError => 'Kesalahan sertifikat SSL';
	@override String get testCompleted => 'Uji selesai';
	@override String get local => 'Lokal';
	@override String get unknown => 'Tidak diketahui';
	@override String get localVideoPathEmpty => 'Jalur video lokal kosong';
	@override String localVideoFileNotExists({required Object path}) => 'Berkas video lokal tidak ada: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'Tidak dapat memutar video lokal: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Jatuhkan berkas video di sini untuk memutar';
	@override String get supportedFormats => 'Format yang didukung: MP4, MKV, AVI, MOV, WEBM, dll.';
	@override String get noSupportedVideoFile => 'Tidak ditemukan berkas video yang didukung';
	@override String get retryingOpenVideoLink => 'Gagal membuka tautan video, mencoba lagi';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'Tidak dapat memuat dekoder: ${event}. Coba beralih ke dekode perangkat lunak di pengaturan pemutar lalu masuk kembali ke halaman';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Kesalahan pemuatan video: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Terdeteksi kegagalan pemutaran berulang. Buka Pengaturan > Diagnostik & Umpan Balik untuk mengekspor log.';
	@override String get openSettingsAction => 'Lihat';
	@override late final _TranslationsMediaPlayerNoticeId notice = _TranslationsMediaPlayerNoticeId._(_root);
	@override String get imageLoadFailed => 'Gagal Memuat Gambar';
	@override String get unsupportedImageFormat => 'Format Gambar Tidak Didukung';
	@override String get tryOtherViewer => 'Silakan coba gunakan penampil lain';
}

// Path: diagnostics
class _TranslationsDiagnosticsId extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Info Diagnostik';
	@override String get appVersionLabel => 'Versi Aplikasi';
	@override String memoryUsage({required Object memMB}) => 'Penggunaan memori: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'Tidak dapat mengambil info perangkat';
	@override String get secureStorageLabel => 'Penyimpanan aman';
	@override String get secureStorageHealthy => 'Tersedia';
	@override String get secureStorageRecovered => 'Pulih sendiri melalui reset (data sebelumnya dihapus)';
	@override String get secureStorageUnavailable => 'Tidak tersedia (login disimpan dengan enkripsi cadangan)';
	@override String get secureStoragePlatformOptOut => 'Enkripsi lokal sesuai kebijakan platform (keychain sistem tidak digunakan di macOS)';
	@override String get secureStorageDualWrite => ' (perlindungan penulisan ganda aktif)';
	@override String get schemaHealthLabel => 'Skema basis data';
	@override String get schemaHealthOk => 'OK';
	@override String get schemaHealthRepairedNow => 'Diperbaiki oleh jaring pengaman pada peluncuran ini (migrasi tidak berhasil)';
	@override String get schemaHealthRepairedBefore => 'Sebelumnya pernah diperbaiki oleh jaring pengaman';
	@override String get logPolicySectionTitle => 'Kebijakan Log';
	@override String get configServiceUnavailable => 'Layanan konfigurasi belum diinisialisasi. Kebijakan log tidak dapat disesuaikan.';
	@override String get enableLoggingTitle => 'Aktifkan pencatatan log';
	@override String get enableLoggingSubtitle => 'Nonaktifkan untuk menghentikan penulisan log baru';
	@override String get enableLogPersistenceTitle => 'Aktifkan persistensi log';
	@override String get enableLogPersistenceSubtitle => 'Nonaktifkan agar log hanya disimpan di memori dan menghentikan penulisan ke disk';
	@override String get minLogLevelTitle => 'Level log minimum';
	@override String get minLogLevelSubtitle => 'Log di bawah level ini akan disaring';
	@override String get maxFileSizeTitle => 'Batas ukuran satu berkas';
	@override String get maxFileSizeSubtitle => 'Rotasi saat ambang tercapai';
	@override String get rotatedFileCountTitle => 'Jumlah berkas rotasi log utama';
	@override String get rotatedFileCountSubtitle => 'Jumlah berkas yang disimpan di luar berkas saat ini';
	@override String get hangFileSizeTitle => 'Batas ukuran log hang';
	@override String get hangFileSizeSubtitle => 'Kendalikan pertumbuhan berkas hang_events';
	@override String get hangRotatedFileCountTitle => 'Jumlah berkas rotasi log hang';
	@override String get hangRotatedFileCountSubtitle => 'Kendalikan riwayat yang disimpan untuk hang_events';
	@override String get healthSectionTitle => 'Kesehatan Log';
	@override String get refreshMetrics => 'Segarkan Metrik';
	@override String get toolsSectionTitle => 'Alat';
	@override String get privacyNotice => 'Log dapat berisi informasi sensitif seperti data akun dan parameter permintaan. Jangan memposting log lengkap secara publik di issue; tinjau terlebih dahulu lalu kirim melalui email.';
	@override String get exportLogsTitle => 'Ekspor Log';
	@override String get exportLogsSubtitle => 'Tinjau data privasi sebelum mengirim ke pengembang';
	@override String get viewLogsTitle => 'Lihat Log';
	@override String get viewLogsSubtitle => 'Lihat log runtime secara real-time';
	@override String get copySupportEmailTitle => 'Salin Email Dukungan';
	@override String get reportIssueTitle => 'Laporkan Masalah';
	@override String get reportIssueSubtitle => 'Berikan langkah reproduksi di GitHub (jangan lampirkan log lengkap)';
	@override String get healthSummaryUnavailable => 'Belum ada data kesehatan log';
	@override String get healthMetricsUnavailable => 'Metrik kesehatan belum dikumpulkan';
	@override String get healthNoRiskIndicators => 'Tidak ada indikator risiko yang terdeteksi';
	@override late final _TranslationsDiagnosticsHealthAlertId healthAlert = _TranslationsDiagnosticsHealthAlertId._(_root);
	@override late final _TranslationsDiagnosticsToastId toast = _TranslationsDiagnosticsToastId._(_root);
	@override String get shareSubject => 'Log diagnostik LoveIwara (berisi data sensitif, bagikan dengan hati-hati)';
}

// Path: logViewer
class _TranslationsLogViewerId extends TranslationsLogViewerEn {
	_TranslationsLogViewerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Penampil Log';
	@override String get searchHint => 'Cari log...';
	@override String get emptyState => 'Tidak ada log';
	@override String get copiedToClipboard => 'Disalin ke papan klip';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogId extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aplikasi keluar secara tak terduga';
	@override String get description => 'Kami mendeteksi penutupan tidak wajar pada sesi terakhir. Silakan ekspor log diagnostik dan kirimkan melalui email kepada pengembang untuk membantu kami memperbaiki masalah ini.';
	@override String previousVersion({required Object version}) => 'Versi terakhir: ${version}';
	@override String previousStart({required Object time}) => 'Peluncuran terakhir: ${time}';
	@override String lastException({required Object message}) => 'Pengecualian terakhir: ${message}';
	@override String get lastHangRecovered => 'UI sempat macet terakhir kali dan pulih secara otomatis';
	@override String lastHangStalled({required Object stalledMs}) => 'Kemungkinan pembekuan UI terdeteksi terakhir kali, berlangsung sekitar ${stalledMs}ms';
	@override String get exportGuide => 'Buka Pengaturan > Diagnostik & Umpan Balik > Ekspor Log.';
	@override String get privacyHint => 'Log dapat berisi data pribadi. Harap tinjau sebelum mengirim email ke:';
	@override String get issueWarning => 'Jangan lampirkan log lengkap secara publik di issue GitHub';
	@override String get acknowledge => 'Mengerti';
	@override String get supportEmailCopied => 'Email disalin';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogId extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Masukkan Tautan';
	@override String supportedLinksHint({required Object webName}) => 'Mendukung pengenalan cerdas beberapa tautan ${webName} dan melompat dengan cepat ke halaman terkait di aplikasi (pisahkan tautan dari teks lain dengan spasi)';
	@override String inputHint({required Object webName}) => 'Silakan masukkan tautan ${webName}';
	@override String get validatorEmptyLink => 'Silakan masukkan tautan';
	@override String validatorNoIwaraLink({required Object webName}) => 'Tidak terdeteksi tautan ${webName} yang valid';
	@override String get multipleLinksDetected => 'Terdeteksi beberapa tautan, silakan pilih satu:';
	@override String notIwaraLink({required Object webName}) => 'Bukan tautan ${webName} yang valid';
	@override String linkParseError({required Object error}) => 'Kesalahan penguraian tautan: ${error}';
	@override String get unsupportedLinkDialogTitle => 'Tautan Tidak Didukung';
	@override String get unsupportedLinkDialogContent => 'Jenis tautan ini tidak dapat dibuka langsung di aplikasi dan perlu diakses menggunakan peramban eksternal.\n\nApakah Anda ingin membuka tautan ini di peramban?';
	@override String get openInBrowser => 'Buka di Peramban';
	@override String get confirmOpenBrowserDialogTitle => 'Konfirmasi Buka Peramban';
	@override String get confirmOpenBrowserDialogContent => 'Tautan berikut akan dibuka di peramban eksternal:';
	@override String get confirmContinueBrowserOpen => 'Apakah Anda yakin ingin melanjutkan?';
	@override String get browserOpenFailed => 'Gagal membuka tautan';
	@override String get unsupportedLink => 'Tautan Tidak Didukung';
	@override String get cancel => 'Batal';
	@override String get confirm => 'Buka di Peramban';
}

// Path: log
class _TranslationsLogId extends TranslationsLogEn {
	_TranslationsLogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Pengelolaan Log';
	@override String get enableLogPersistence => 'Aktifkan Persistensi Log';
	@override String get enableLogPersistenceDesc => 'Simpan log ke basis data untuk analisis';
	@override String get logDatabaseSizeLimit => 'Batas Ukuran Basis Data Log';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Saat ini: ${size}';
	@override String get exportCurrentLogs => 'Ekspor Log Saat Ini';
	@override String get exportCurrentLogsDesc => 'Ekspor log aplikasi saat ini untuk membantu pengembang mendiagnosis masalah';
	@override String get exportHistoryLogs => 'Ekspor Log Riwayat';
	@override String get exportHistoryLogsDesc => 'Ekspor log dalam rentang tanggal tertentu';
	@override String get exportMergedLogs => 'Ekspor Log Gabungan';
	@override String get exportMergedLogsDesc => 'Ekspor log gabungan dalam rentang tanggal tertentu';
	@override String get showLogStats => 'Tampilkan Statistik Log';
	@override String get logExportSuccess => 'Ekspor log berhasil';
	@override String logExportFailed({required Object error}) => 'Ekspor log gagal: ${error}';
	@override String get showLogStatsDesc => 'Lihat statistik berbagai jenis log';
	@override String logExtractFailed({required Object error}) => 'Gagal mendapatkan statistik log: ${error}';
	@override String get clearAllLogs => 'Bersihkan Semua Log';
	@override String get clearAllLogsDesc => 'Hapus semua data log';
	@override String get confirmClearAllLogs => 'Konfirmasi Bersihkan';
	@override String get confirmClearAllLogsDesc => 'Apakah Anda yakin ingin membersihkan semua data log? Tindakan ini tidak dapat dibatalkan.';
	@override String get clearAllLogsSuccess => 'Log berhasil dibersihkan';
	@override String clearAllLogsFailed({required Object error}) => 'Gagal membersihkan log: ${error}';
	@override String get unableToGetLogSizeInfo => 'Tidak dapat mendapatkan informasi ukuran log';
	@override String get currentLogSize => 'Ukuran Log Saat Ini:';
	@override String get logCount => 'Jumlah Log:';
	@override String get logCountUnit => 'log';
	@override String get logSizeLimit => 'Batas Ukuran Log:';
	@override String get usageRate => 'Tingkat Penggunaan:';
	@override String get exceedLimit => 'Melebihi Batas';
	@override String get remaining => 'Tersisa';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Ukuran log saat ini telah terlampaui, silakan bersihkan log lama atau tingkatkan batas ukuran log';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'Ukuran log saat ini hampir terlampaui, silakan bersihkan log lama';
	@override String get cleaningOldLogs => 'Membersihkan log lama...';
	@override String get logCleaningCompleted => 'Pembersihan log selesai';
	@override String get logCleaningProcessMayNotBeCompleted => 'Proses pembersihan log mungkin belum selesai';
	@override String get cleanExceededLogs => 'Bersihkan log berlebih';
	@override String get noLogsToExport => 'Tidak ada log untuk diekspor';
	@override String get exportingLogs => 'Mengekspor log...';
	@override String get noHistoryLogsToExport => 'Tidak ada log riwayat untuk diekspor, silakan gunakan aplikasi terlebih dahulu untuk beberapa saat';
	@override String get selectLogDate => 'Pilih Tanggal Log';
	@override String get today => 'Hari Ini';
	@override String get selectMergeRange => 'Pilih Rentang Gabungan';
	@override String get selectMergeRangeHint => 'Silakan pilih rentang waktu log yang akan digabungkan';
	@override String selectMergeRangeDays({required Object days}) => '${days} hari terakhir';
	@override String get logStats => 'Statistik Log';
	@override String todayLogs({required Object count}) => 'Log Hari Ini: ${count} log';
	@override String recent7DaysLogs({required Object count}) => 'Log 7 Hari Terakhir: ${count} log';
	@override String totalLogs({required Object count}) => 'Total Log: ${count} log';
	@override String get setLogDatabaseSizeLimit => 'Atur Batas Ukuran Basis Data Log';
	@override String currentLogSizeWithSize({required Object size}) => 'Ukuran Log Saat Ini: ${size}';
	@override String get warning => 'Peringatan';
	@override String newSizeLimit({required Object size}) => 'Batas ukuran baru: ${size}';
	@override String get confirmToContinue => 'Konfirmasi untuk melanjutkan';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Batas ukuran log diatur ke ${size}';
}

// Path: emoji
class _TranslationsEmojiId extends TranslationsEmojiEn {
	_TranslationsEmojiId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Emoji';
	@override String get size => 'Ukuran';
	@override String get small => 'Kecil';
	@override String get medium => 'Sedang';
	@override String get large => 'Besar';
	@override String get extraLarge => 'Sangat Besar';
	@override String get copyEmojiLinkSuccess => 'Tautan emoji disalin';
	@override String get preview => 'Pratinjau Emoji';
	@override String get library => 'Pustaka Emoji';
	@override String get noEmojis => 'Tidak ada emoji';
	@override String get clickToAddEmojis => 'Klik tombol di kanan atas untuk menambahkan emoji';
	@override String get addEmojis => 'Tambah Emoji';
	@override String get imagePreview => 'Pratinjau Gambar';
	@override String get imageLoadFailed => 'Gagal memuat gambar';
	@override String get loading => 'Memuat...';
	@override String get delete => 'Hapus';
	@override String get close => 'Tutup';
	@override String get deleteImage => 'Hapus Gambar';
	@override String get confirmDeleteImage => 'Apakah Anda yakin ingin menghapus gambar ini?';
	@override String get cancel => 'Batal';
	@override String get batchDelete => 'Hapus Massal';
	@override String confirmBatchDelete({required Object count}) => 'Apakah Anda yakin ingin menghapus ${count} gambar yang dipilih? Tindakan ini tidak dapat dibatalkan.';
	@override String get deleteSuccess => 'Berhasil dihapus';
	@override String get addImage => 'Tambah Gambar';
	@override String get addImageByUrl => 'Tambah lewat URL';
	@override String get addImageUrl => 'Tambah URL Gambar';
	@override String get imageUrl => 'URL Gambar';
	@override String get enterImageUrl => 'Silakan masukkan URL gambar';
	@override String get add => 'Tambah';
	@override String get batchImport => 'Impor Massal';
	@override String get enterJsonUrlArray => 'Silakan masukkan larik URL dalam format JSON:';
	@override String get formatExample => 'Contoh format:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Silakan tempel larik URL dalam format JSON';
	@override String get import => 'Impor';
	@override String importSuccess({required Object count}) => 'Berhasil mengimpor ${count} gambar';
	@override String get jsonFormatError => 'Kesalahan format JSON, silakan periksa masukan';
	@override String get createGroup => 'Buat Grup Emoji';
	@override String get groupName => 'Nama Grup';
	@override String get enterGroupName => 'Silakan masukkan nama grup';
	@override String get create => 'Buat';
	@override String get editGroupName => 'Ubah Nama Grup';
	@override String get save => 'Simpan';
	@override String get deleteGroup => 'Hapus Grup';
	@override String get confirmDeleteGroup => 'Apakah Anda yakin ingin menghapus grup emoji ini? Semua gambar dalam grup juga akan dihapus.';
	@override String imageCount({required Object count}) => '${count} gambar';
	@override String get selectEmoji => 'Pilih Emoji';
	@override String get noEmojisInGroup => 'Tidak ada emoji di grup ini';
	@override String get goToSettingsToAddEmojis => 'Buka pengaturan untuk menambahkan emoji';
	@override String get emojiManagement => 'Pengelolaan Emoji';
	@override String get manageEmojiGroupsAndImages => 'Kelola grup dan gambar emoji';
	@override String get uploadLocalImages => 'Unggah Gambar Lokal';
	@override String get uploadingImages => 'Mengunggah Gambar';
	@override String uploadingImagesProgress({required Object count}) => 'Mengunggah ${count} gambar, mohon tunggu...';
	@override String get doNotCloseDialog => 'Harap jangan tutup dialog ini';
	@override String uploadSuccess({required Object count}) => 'Berhasil mengunggah ${count} gambar';
	@override String uploadFailed({required Object count}) => 'Gagal ${count}';
	@override String get uploadFailedMessage => 'Gagal mengunggah gambar, silakan periksa koneksi jaringan atau format berkas';
	@override String uploadErrorMessage({required Object error}) => 'Terjadi kesalahan saat mengunggah: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterId extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Pilih Bidang';
	@override String get add => 'Tambah';
	@override String get clear => 'Bersihkan';
	@override String get clearAll => 'Bersihkan Semua';
	@override String get generatedQuery => 'Kueri yang Dihasilkan';
	@override String get copyToClipboard => 'Salin ke Papan Klip';
	@override String get copied => 'Disalin';
	@override String filterCount({required Object count}) => '${count} filter';
	@override String get filterSettings => 'Pengaturan Filter';
	@override String get field => 'Bidang';
	@override String get operator => 'Operator';
	@override String get language => 'Bahasa';
	@override String get value => 'Nilai';
	@override String get dateRange => 'Rentang Tanggal';
	@override String get numberRange => 'Rentang Angka';
	@override String get from => 'Dari';
	@override String get to => 'Sampai';
	@override String get date => 'Tanggal';
	@override String get number => 'Angka';
	@override String get boolean => 'Boolean';
	@override String get tags => 'Tag';
	@override String get select => 'Pilih';
	@override String get clickToSelectDate => 'Klik untuk memilih tanggal';
	@override String get pleaseEnterValidNumber => 'Silakan masukkan angka yang valid';
	@override String get pleaseEnterValidDate => 'Silakan masukkan format tanggal yang valid (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => 'Nilai awal harus kurang dari nilai akhir';
	@override String get startDateMustBeBeforeEndDate => 'Tanggal mulai harus sebelum tanggal akhir';
	@override String get pleaseFillStartValue => 'Silakan isi nilai awal';
	@override String get pleaseFillEndValue => 'Silakan isi nilai akhir';
	@override String get rangeValueFormatError => 'Kesalahan format nilai rentang';
	@override String get contains => 'Mengandung';
	@override String get equals => 'Sama dengan';
	@override String get notEquals => 'Tidak Sama dengan';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Rentang';
	@override String get kIn => 'Mengandung Salah Satu';
	@override String get notIn => 'Tidak Mengandung Salah Satu';
	@override String get username => 'Nama Pengguna';
	@override String get nickname => 'Nama Panggilan';
	@override String get registrationDate => 'Tanggal Pendaftaran';
	@override String get description => 'Deskripsi';
	@override String get title => 'Judul';
	@override String get body => 'Isi';
	@override String get author => 'Penulis';
	@override String get publishDate => 'Tanggal Publikasi';
	@override String get private => 'Privat';
	@override String get duration => 'Durasi (detik)';
	@override String get likes => 'Suka';
	@override String get views => 'Tayangan';
	@override String get comments => 'Komentar';
	@override String get rating => 'Peringkat';
	@override String get imageCount => 'Jumlah Gambar';
	@override String get videoCount => 'Jumlah Video';
	@override String get createDate => 'Tanggal Dibuat';
	@override String get content => 'Konten';
	@override String get all => 'Semua';
	@override String get adult => 'Dewasa';
	@override String get general => 'Umum';
	@override String get yes => 'Ya';
	@override String get no => 'Tidak';
	@override String get users => 'Pengguna';
	@override String get videos => 'Video';
	@override String get images => 'Gambar';
	@override String get posts => 'Postingan';
	@override String get forumThreads => 'Utas Forum';
	@override String get forumPosts => 'Postingan Forum';
	@override String get playlists => 'Daftar Putar';
	@override late final _TranslationsSearchFilterSortTypesId sortTypes = _TranslationsSearchFilterSortTypesId._(_root);
	@override String get drawerSubtitle => 'Perubahan berlaku seketika';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupId extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeId welcome = _TranslationsFirstTimeSetupWelcomeId._(_root);
	@override late final _TranslationsFirstTimeSetupBasicId basic = _TranslationsFirstTimeSetupBasicId._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkId network = _TranslationsFirstTimeSetupNetworkId._(_root);
	@override late final _TranslationsFirstTimeSetupThemeId theme = _TranslationsFirstTimeSetupThemeId._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerId player = _TranslationsFirstTimeSetupPlayerId._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialId spatial = _TranslationsFirstTimeSetupSpatialId._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionId completion = _TranslationsFirstTimeSetupCompletionId._(_root);
	@override late final _TranslationsFirstTimeSetupCommonId common = _TranslationsFirstTimeSetupCommonId._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperId extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Proksi sistem terdeteksi';
	@override String get copied => 'Disalin';
	@override String get copy => 'Salin';
}

// Path: tagSelector
class _TranslationsTagSelectorId extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Pilih Tag';
	@override String get clickToSelectTags => 'Klik untuk memilih tag';
	@override String get addTag => 'Tambah Tag';
	@override String get removeTag => 'Hapus Tag';
	@override String get deleteTag => 'Hapus Tag';
	@override String get usageInstructions => 'Tambahkan tag terlebih dahulu, lalu klik untuk memilih dari tag yang ada';
	@override String get usageInstructionsTooltip => 'Petunjuk Penggunaan';
	@override String get addTagTooltip => 'Tambah Tag';
	@override String get removeTagTooltip => 'Hapus Tag';
	@override String get cancelSelection => 'Batalkan Pilihan';
	@override String get selectAll => 'Pilih Semua';
	@override String get cancelSelectAll => 'Batalkan Pilih Semua';
	@override String get delete => 'Hapus';
}

// Path: anime4k
class _TranslationsAnime4kId extends TranslationsAnime4kEn {
	_TranslationsAnime4kId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Peningkatan resolusi dan penghilangan noise video secara real-time, meningkatkan kualitas video animasi';
	@override String get settings => 'Pengaturan Anime4K';
	@override String get preset => 'Preset Anime4K';
	@override String get disable => 'Nonaktifkan Anime4K';
	@override String get disableDescription => 'Nonaktifkan efek peningkatan video';
	@override String get highQualityPresets => 'Preset Kualitas Tinggi';
	@override String get fastPresets => 'Preset Cepat';
	@override String get litePresets => 'Preset Ringan';
	@override String get moreLitePresets => 'Preset Lebih Ringan';
	@override String get customPresets => 'Preset Kustom';
	@override late final _TranslationsAnime4kPresetGroupsId presetGroups = _TranslationsAnime4kPresetGroupsId._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsId presetDescriptions = _TranslationsAnime4kPresetDescriptionsId._(_root);
	@override late final _TranslationsAnime4kPresetNamesId presetNames = _TranslationsAnime4kPresetNamesId._(_root);
	@override String get performanceTip => '💡 Tips: Pilih preset yang sesuai dengan performa perangkat. Perangkat kelas bawah disarankan menggunakan preset ringan.';
	@override String get compatibilityTip => '⚠️ Sebagian GPU seluler (mis. Kirin 980 / Mali-G76) tidak dapat merender shader kustom apa pun. Jika gambar menjadi hitam sementara audio tetap berjalan, nonaktifkan Anime4K di sini.';
	@override String get autoDisabledOnRenderFailure => 'GPU perangkat Anda gagal merender shader Anime4K, sehingga dinonaktifkan secara otomatis.';
}

// Path: siteMode
class _TranslationsSiteModeId extends TranslationsSiteModeEn {
	_TranslationsSiteModeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mode Situs';
	@override String get mainSite => 'Main';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Saat ini ${currentSite} · Ketuk untuk beralih ke ${nextSite}';
	@override String get dialogTitle => 'Beralih Mode Situs';
	@override String get dialogDescription => 'Beralih akan menyegarkan seluruh aplikasi dan mengatur ulang daftar serta status halaman yang dimuat sebelumnya.';
	@override String get chooseLinkTargetTitle => 'Pilih Situs Tujuan';
	@override String get chooseLinkTargetDescription => 'Tautan ini tidak menyertakan domain. Silakan pilih apakah akan membukanya di Main atau AI.';
	@override String get chooseLinkTargetHint => 'Setelah dibuka, halaman ini dan permintaan detail lanjutannya akan terus menggunakan situs yang dipilih.';
	@override String get alreadyUsing => 'Anda sudah menggunakan mode situs ini.';
	@override String openInSite({required Object site}) => 'Buka di ${site}';
	@override String confirmUsing({required Object site}) => 'Setelah dikonfirmasi, permintaan mendatang akan menggunakan mode ${site}.';
	@override String switched({required Object site}) => 'Beralih ke ${site}. Aplikasi telah disegarkan.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigId extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filter Tersimpan';
	@override String get empty => 'Belum ada filter tersimpan';
	@override String get saveTooltip => 'Simpan filter saat ini';
	@override String get namePromptTitle => 'Simpan Filter';
	@override String get nameLabel => 'Nama';
	@override String get nameHint => 'Masukkan nama';
	@override String get saveSuccess => 'Filter disimpan';
	@override String get deleteSuccess => 'Filter dihapus';
	@override String get addCurrent => 'Simpan filter saat ini';
	@override String get reorderHint => 'Tekan lama dan seret untuk mengurutkan';
	@override String get rename => 'Ganti Nama';
	@override String get unnamed => 'Tanpa Nama';
	@override String get noConditions => 'Semua konten (tanpa filter)';
	@override String tagsCount({required Object count}) => '${count} tag';
}

// Path: savedSearch
class _TranslationsSavedSearchId extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pencarian Tersimpan';
	@override String get empty => 'Belum ada pencarian tersimpan';
	@override String get saveTooltip => 'Simpan pencarian saat ini';
	@override String get namePromptTitle => 'Simpan Pencarian';
	@override String get nameLabel => 'Nama';
	@override String get nameHint => 'Masukkan nama';
	@override String get saveSuccess => 'Pencarian disimpan';
	@override String get deleteSuccess => 'Pencarian dihapus';
	@override String get addCurrent => 'Simpan pencarian saat ini';
	@override String get reorderHint => 'Tekan lama dan seret untuk mengurutkan';
	@override String get rename => 'Ganti Nama';
	@override String get noKeyword => '(Tanpa kata kunci)';
	@override String filtersCount({required Object count}) => '${count} filter';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderId extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Daftar Hitam Tag Bawaan Terdeteksi';
	@override String get content => 'Akun Anda masih menggunakan daftar hitam tag yang diterapkan situs web secara otomatis ke setiap akun baru. Ingin meninjau dan mengelolanya?';
	@override String get goManage => 'Kelola';
	@override String get dismiss => 'Nanti saja';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistId extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bantuan Penglihatan Warna';
	@override String get description => 'Mengoreksi warna video bagi penonton dengan defisiensi penglihatan warna, dapat digunakan bersama Anime4K';
	@override String get galleryDescription => 'Mengoreksi warna gambar galeri bagi penonton dengan defisiensi penglihatan warna (terlepas dari sakelar pemutar)';
	@override String get galleryDescriptionSpatial => 'Mengoreksi warna gambar galeri bagi penonton dengan defisiensi penglihatan warna. Hanya berlaku untuk penampil 2D di panel ini — gambar pada layar spasial dirender secara native dan tidak melewati filter ini';
	@override String get disable => 'Nonaktif';
	@override String get disableDescription => 'Tanpa koreksi warna';
	@override String get protanopia => 'Bantuan Merah (Protanopia)';
	@override String get protanopiaDescription => 'Untuk protanopia — sulit membedakan warna merah';
	@override String get deuteranopia => 'Bantuan Hijau (Deuteranopia)';
	@override String get deuteranopiaDescription => 'Untuk deuteranopia — sulit membedakan warna hijau';
	@override String get tritanopia => 'Bantuan Biru (Tritanopia)';
	@override String get tritanopiaDescription => 'Untuk tritanopia — sulit membedakan warna biru dan kuning';
	@override String appliedToast({required Object filterName}) => '${filterName} diterapkan, langsung berlaku';
	@override String get disabledToast => 'Bantuan penglihatan warna dinonaktifkan';
}

// Path: externalPlayer
class _TranslationsExternalPlayerId extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Buka dengan aplikasi lain';
	@override String get description => 'Serahkan video saat ini ke pemutar lain di perangkat ini, seperti Skybox atau Pigasus pada headset VR, atau MX Player dan VLC di ponsel';
	@override String get openWithOtherApp => 'Pilih aplikasi lain';
	@override String get openWithOtherAppDescription => 'Tampilkan pemilih sistem dan pilih pemutar untuk mengambil alih';
	@override String get openWithSystemPlayer => 'Buka di pemutar bawaan';
	@override String get openWithSystemPlayerDescription => 'Serahkan ke aplikasi video bawaan sistem';
	@override String get copyLink => 'Salin tautan video';
	@override String get copyLinkDescription => 'Untuk pemutar yang hanya dapat menempel URL, seperti Skybox atau DeoVR';
	@override String get linkCopied => 'Tautan video disalin';
	@override String get sourceLocal => 'Berkas lokal';
	@override String get sourceOnline => 'Tautan langsung';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Tautan langsung · ${quality}';
	@override String get onlineLinkExpiryHint => 'Tautan langsung dapat kedaluwarsa, sehingga pemutar eksternal mungkin berhenti di tengah jalan. Mengunduh terlebih dahulu adalah cara yang andal.';
	@override String get vrPlayerHint => 'Jika pemutar VR Anda tidak ada di pemilih, gunakan Salin tautan video lalu tempelkan di dalam pemutar tersebut.';
	@override String get noHandler => 'Tidak ada aplikasi di perangkat ini yang dapat membuka video';
	@override String handoffFailed({required Object message}) => 'Penyerahan gagal: ${message}';
	@override String get handoffFailedUnknown => 'Penyerahan gagal';
	@override String get sourceUnavailable => 'Tidak dapat mendapatkan alamat video saat ini, silakan coba lagi';
	@override String get localFileMissing => 'Berkas lokal sudah tidak ada';
	@override String get handedOff => 'Diserahkan ke pemutar eksternal';
	@override String get desktopSectionTitle => 'Pemutar eksternal';
	@override String get managePlayers => 'Kelola pemutar eksternal';
	@override String get managePlayersDescWindows => 'Pemutar PCVR seperti HereSphere, DeoVR, dan Whirligig bukan aplikasi bawaan sistem. Arahkan ini ke berkas .exe mereka dan Anda dapat menyerahkan video saat ini langsung dari pemutar.';
	@override String get managePlayersDescMac => 'Arahkan ini ke pemutar seperti IINA, VLC, atau mpv dan Anda dapat menyerahkan video saat ini langsung dari pemutar.';
	@override String get managePlayersDescLinux => 'Arahkan ini ke pemutar seperti mpv, VLC, atau Celluloid dan Anda dapat menyerahkan video saat ini langsung dari pemutar.';
	@override String get pickExecutableHintWindows => 'Pilih berkas .exe utama di dalam folder pemasangan pemutar, mis. HereSphere.exe atau vlc.exe. Pintasan desktop (.lnk) tidak akan berfungsi.';
	@override String get pickExecutableHintMac => 'Pilih berkas .app pemutar di Applications, mis. IINA.app — berkas eksekusi sebenarnya di dalamnya akan ditemukan untuk Anda.';
	@override String get pickExecutableHintLinux => 'Pilih berkas eksekusi pemutar, mis. /usr/bin/mpv. Menjalankan which mpv akan memberi tahu lokasinya.';
	@override String emptyStateGuide({required Object examples}) => 'Setelah dikonfigurasi, ia muncul sebagai entri tersendiri di bawah Buka dengan aplikasi lain pada halaman pemutar. Yang umum: ${examples}';
	@override String get detectNothingFoundGuide => 'Tidak ada pemutar terpasang yang ditemukan. Folder pemasangan kustom dan versi portabel tidak dapat dideteksi — gunakan Tambah pemutar untuk menunjuk pemutar sendiri.';
	@override String get detectNothingNew => 'Tidak ada pemutar baru yang ditemukan; semua yang terpasang sudah ada dalam daftar';
	@override String get detectFailed => 'Deteksi gagal — gunakan Tambah pemutar untuk menunjuk pemutar sendiri';
	@override String get advancedOptions => 'Lanjutan';
	@override String get playerNameHint => 'Biarkan kosong untuk menggunakan nama berkas';
	@override String get executablePathRequired => 'Pilih berkas eksekusi pemutar terlebih dahulu';
	@override String playerCount({required Object count}) => '${count} dikonfigurasi';
	@override String get noPlayerConfigured => 'Belum ada pemutar eksternal yang dikonfigurasi';
	@override String get autoDetect => 'Deteksi otomatis';
	@override String get detecting => 'Mendeteksi…';
	@override String detectFound({required Object count}) => 'Menemukan ${count} pemutar';
	@override String get detectNothingFound => 'Tidak ada pemutar baru yang ditemukan, tambahkan secara manual';
	@override String get autoDetectedTag => 'terdeteksi';
	@override String get addPlayer => 'Tambah pemutar';
	@override String get editPlayer => 'Ubah pemutar';
	@override String get playerName => 'Nama';
	@override String get executablePath => 'Berkas eksekusi';
	@override String get browse => 'Telusuri';
	@override String get argumentTemplate => 'Argumen peluncuran';
	@override String get argumentTemplateHint => 'Gunakan {input} untuk jalur atau URL video. Biarkan kosong untuk meneruskannya sebagai satu-satunya argumen.';
	@override String get nameAndPathRequired => 'Nama dan berkas eksekusi keduanya wajib diisi';
	@override String get testLaunch => 'Uji peluncuran';
	@override String get testLaunched => 'Pemutar diluncurkan';
	@override String get testFailed => 'Peluncuran gagal, periksa jalur berkas eksekusi';
	@override String get executableMissing => 'Berkas eksekusi tidak ditemukan';
	@override String openWithNamed({required Object name}) => 'Buka di ${name}';
	@override String get managePlayersEntry => 'Kelola pemutar eksternal…';
}

// Path: watchLater
class _TranslationsWatchLaterId extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Tonton Nanti';
	@override String get addToWatchLater => 'Tonton nanti';
	@override String get removeFromWatchLater => 'Hapus dari Tonton Nanti';
	@override String get addedToWatchLater => 'Ditambahkan ke Tonton Nanti';
	@override String get alreadyInWatchLater => 'Sudah ada di Tonton Nanti';
	@override String get removedFromWatchLater => 'Dihapus dari Tonton Nanti';
	@override String removedCount({required Object count}) => 'Menghapus ${count} item';
	@override String get viewWatchLaterList => 'Lihat daftar';
	@override String get addFailed => 'Gagal menambahkan ke Tonton Nanti';
	@override String get invalidItem => 'Tidak Tersedia';
	@override String get clearWatched => 'Bersihkan yang telah ditonton';
	@override String watchedCleared({required Object count}) => 'Membersihkan ${count} item yang ditonton';
	@override String get noWatchedToClear => 'Tidak ada yang ditonton untuk dibersihkan';
	@override String get emptyVideo => 'Belum ada video di Tonton Nanti';
	@override String get emptyGallery => 'Belum ada galeri di Tonton Nanti';
	@override String get filterAll => 'Semua';
	@override String get filterUnwatched => 'Belum Ditonton';
	@override String get sortRecentlyAdded => 'Baru-baru ini ditambahkan';
	@override String get sortEarliestAdded => 'Ditambahkan paling awal';
	@override String get watched => 'Ditonton';
	@override String get playlistLoadFailed => 'Gagal memuat daftar putar';
	@override String get noPlaylists => 'Belum ada daftar putar';
	@override String get undo => 'Urungkan';
	@override String get clearWatchedConfirm => 'Hapus semua yang sudah Anda tonton di tab ini? Tindakan ini tidak dapat dibatalkan.';
	@override String get emptyUnwatchedVideo => 'Tidak ada lagi yang bisa ditonton di sini';
	@override String get emptyUnwatchedGallery => 'Tidak ada lagi yang bisa dilihat di sini';
	@override String get queueLoadFailed => 'Gagal memuat, ketuk untuk mencoba lagi';
}

// Path: mediaMenu
class _TranslationsMediaMenuId extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get like => 'Suka';
	@override String get unlike => 'Batal Suka';
	@override String get viewAuthor => 'Lihat penulis';
	@override String inFolders({required Object count}) => '${count} folder';
	@override String inPlaylists({required Object count}) => '${count} daftar putar';
	@override String get downloaded => 'Terunduh';
}

// Path: mediaPreview
class _TranslationsMediaPreviewId extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Pratinjau';
	@override String get openDetail => 'Buka';
	@override String get moreActions => 'Tindakan lainnya';
	@override String get previousImage => 'Gambar sebelumnya';
	@override String get nextImage => 'Gambar berikutnya';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueId extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} gambar';
	@override String get upNext => 'Berikutnya';
	@override String get sourceTab => 'Sumber';
	@override String get emptyQueue => 'Tidak ada yang dapat diputar dalam antrean ini';
	@override String get emptyGalleryQueue => 'Tidak ada galeri dalam antrean ini';
	@override String get nowPlaying => 'Sedang diputar';
	@override String get myPlaylists => 'Daftar putar saya';
	@override String get authorPlaylists => 'Daftar putar penulis';
	@override String get openQueue => 'Berikutnya';
	@override String get continueInQueue => 'Lanjutkan pemutaran dari antrean saat ini';
	@override String get continueInQueueSubtitle => 'Memutar item berikutnya secara otomatis; menonaktifkan "ulangi saat selesai"';
	@override String get repeatDisabledByQueue => 'Dinonaktifkan saat "lanjutkan pemutaran dari antrean saat ini" aktif';
	@override String get playNext => 'Putar berikutnya';
	@override String get queueEnded => 'Ini adalah item terakhir dalam antrean';
	@override String get playNextHint => 'Ketuk untuk memutar item berikutnya, tekan lama untuk membuka Berikutnya';
	@override String get authorVideos => 'Video penulis';
	@override String get authorGalleries => 'Galeri penulis';
	@override String get favoriteFolders => 'Folder favorit';
	@override String get localFiles => 'Di perangkat ini';
	@override String get currentFolder => 'Folder file ini';
	@override String get playThisFolder => 'Lihat antrean video folder ini';
	@override String get browseThisFolder => 'Lihat antrean galeri folder ini';
	@override String get downloads => 'Diunduh';
	@override String get otherPlaylists => 'Daftar putar pengguna lain';
	@override String get nothingHere => 'Tidak ada apa-apa di sini';
}

// Path: vrFormat
class _TranslationsVrFormatId extends TranslationsVrFormatEn {
	_TranslationsVrFormatId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Putar di pemutar spasial';
	@override String get handingOff => 'Menyerahkan ke ruang…';
	@override String get title => 'Mode pemutaran';
	@override String get spatialSectionTitle => 'Pemutaran spasial';
	@override String get spatialSectionDesc => 'Di headset, video tidak digambar di dalam panel ini — pemutar spasial menempatkannya di layar di dalam ruangan.';
	@override String get spatialPanelEntry => 'Panel kontrol spasial';
	@override String get spatialPanelEntryDesc => 'Jarak layar, ukuran dan kelengkungan, lingkungan latar belakang, serta kecepatan, pengulangan, dan sembunyikan otomatis semuanya ada di panel kontrol spasial.';
	@override String get spatialGuideEntry => 'Panduan kontrol headset';
	@override String get spatialGuideEntryDesc => 'Tombol pengontrol, memegang layar, pencarian stik, dan pembalikan halaman';
	@override String get spatialFlatOmitted => 'Gerakan sentuh, peningkatan gambar, dan parameter audio/video hanya berlaku untuk pemutar 2D; pemutar spasial berjalan pada mesin yang berbeda, sehingga tidak dicantumkan di sini.';
	@override String get spatialGallerySectionTitle => 'Galeri spasial';
	@override String get spatialGalleryPanelDesc => 'Interval tayangan slide, pengulangan klip tunggal, dan kelengkungan layar semuanya diatur di panel kontrol spasial.';
	@override String get autoEnterGallery => 'Buka gambar galeri di galeri spasial';
	@override String get autoEnterGalleryDesc => 'Di Quest, mengetuk gambar akan membuka seluruh galeri di layar melayang dengan strip film, tayangan slide, dan pembalikan halaman pengontrol, alih-alih penampil di dalam panel ini.';
	@override String get panelSettings => 'Panel & latar belakang';
	@override String get panelSettingsDesc => 'Seberapa jauh panel aplikasi ini berada, dan seberapa banyak ruangan Anda terlihat di belakangnya';
	@override String get panelDistance => 'Jarak panel';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Atur ulang penempatan';
	@override String get panelResetBackground => 'Atur ulang ke bawaan';
	@override String get panelBackground => 'Transparansi latar belakang';
	@override String get panelBackgroundHint => '0%: lingkungan hitam · 100%: ruangan nyata Anda, dengan pencahayaan sekitar';
	@override String get panelUnavailable => 'Panel sedang tidak pada tempatnya — coba lagi sebentar lagi';
	@override String get desc => 'Pilih geometri yang harus digunakan untuk memutar video ini. Situs tidak menyediakan informasi ini, jadi deteksi otomatis hanya memilih titik awal — pilihan Anda yang menang.';
	@override String get sectionFlat => 'Datar';
	@override String get sectionStereo => '3D datar';
	@override String get sectionPanorama => 'Panorama VR';
	@override String get flat => 'Video normal';
	@override String get flatDesc => 'Putar apa adanya, tanpa pemetaan ulang';
	@override String get flatSideBySide => '3D berdampingan';
	@override String get flatSideBySideDesc => 'Satu mata per separuh, kiri dan kanan; menampilkan mata kiri dan memulihkan rasio aspeknya';
	@override String get flatTopBottom => '3D atas-bawah';
	@override String get flatTopBottomDesc => 'Satu mata per separuh, atas dan bawah; menampilkan separuh atas dan memulihkan rasio aspeknya';
	@override String get vr180SideBySide => 'VR180 berdampingan';
	@override String get vr180SideBySideDesc => 'Panorama hemisferis dengan kedua mata — sumber VR paling umum';
	@override String get vr180Mono => 'VR180 mono';
	@override String get vr180MonoDesc => 'Panorama hemisferis, satu mata per bingkai';
	@override String get vr360Mono => 'VR360 mono';
	@override String get vr360MonoDesc => 'Panorama sekeliling penuh, satu mata per bingkai';
	@override String get vr360TopBottom => 'VR360 atas-bawah';
	@override String get vr360TopBottomDesc => 'Panorama sekeliling penuh dengan kedua mata ditumpuk';
	@override String get resetView => 'Atur ulang tampilan';
	@override String get resetViewDesc => 'Kembalikan arah pandang dan bidang pandang ke depan';
	@override String get resetToAuto => 'Kembali ke deteksi otomatis';
	@override String get resetToAutoDesc => 'Lupakan pilihan manual untuk video ini dan biarkan deteksi memutuskan lagi';
	@override String get manualBadge => 'Diatur secara manual';
	@override String get panoramaHint => 'Seret gambar untuk melihat sekeliling, cubit untuk mengubah bidang pandang';
	@override String get panoramaGestureNotice => 'Saat melihat sekeliling, menyeret akan memutar tampilan — gunakan bilah kemajuan untuk mencari';
	@override String get shaderUnsupported => 'Perangkat ini tidak dapat menampilkan panorama langsung; menampilkan satu mata sebagai gantinya';
	@override String get handoffTooltip => 'Putar dengan cara lain';
	@override String get suggestedBadge => 'Disarankan';
	@override String suggestedEntryDesc({required Object format}) => 'Tampak seperti ${format} — ketuk untuk beralih';
	@override String suggestionTitle({required Object format}) => 'Ini mungkin video VR (${format})';
	@override String get suggestionTitleShort => 'Ini mungkin video VR';
	@override String get suggestionAction => 'Putar sebagai VR';
	@override String get suggestionDismiss => 'Tutup';
}

// Path: localMedia
class _TranslationsLocalMediaId extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseId browse = _TranslationsLocalMediaBrowseId._(_root);
	@override String get tabFolders => 'Folder';
	@override String get tabFavoriteVideos => 'Favorit';
	@override String get tabAllVideos => 'Semua video';
	@override String get tabAllImages => 'Semua gambar';
	@override String get tabDownloadedVideos => 'Video terunduh';
	@override String get tabDownloadedGalleries => 'Galeri terunduh';
	@override String get title => 'Di perangkat ini';
	@override String get sourceOnline => 'Iwara online';
	@override String get manageSources => 'Kelola sumber';
	@override String get moveToCategory => 'Pindahkan ke kategori';
	@override String get manageCategories => 'Kelola kategori';
	@override String get suggestedFolders => 'Folder dengan video';
	@override String get sortRecentlyAdded => 'Baru ditambahkan';
	@override String get sortRecentlyPlayed => 'Baru diputar';
	@override String get sortName => 'Nama';
	@override String get sortDuration => 'Durasi';
	@override String get sortSize => 'Ukuran';
	@override String get sortFolder => 'Folder';
	@override String get sortRecentlyModified => 'Baru diubah';
	@override String get sortCount => 'Jumlah';
	@override String folderCardItemCount({required Object count}) => '${count} gambar';
	@override String get downloadsSource => 'Diunduh';
	@override String get builtInSourceHint => 'Unduhan dikelola secara otomatis';
	@override String get filterByCategory => 'Saring berdasarkan kategori';
	@override String get longPressToCategorize => 'Tekan lama untuk memindahkan ke kategori';
	@override String get uncategorized => 'Tanpa Kategori';
	@override String get setCategoryFailed => 'Tidak dapat mengatur kategori';
	@override String get categoryUpdated => 'Kategori diperbarui';
	@override String get addFolder => 'Tambah folder';
	@override String get addDeviceVideos => 'Pindai video perangkat';
	@override String get mediaStoreSourceName => 'Video perangkat';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsId itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsId._(_root);
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
	@override late final _TranslationsLocalMediaMissingId missing = _TranslationsLocalMediaMissingId._(_root);
	@override late final _TranslationsLocalMediaWebdavId webdav = _TranslationsLocalMediaWebdavId._(_root);
	@override String get mediaStoreUnavailable => 'Indeks media perangkat hanya tersedia di Android';
	@override String get mediaStorePermissionDenied => 'Akses video tidak diberikan';
	@override String get rescan => 'Pindai ulang';
	@override String scanning({required Object count}) => 'Memindai… ${count} ditemukan';
	@override String scanFailed({required Object reason}) => 'Pemindaian gagal: ${reason}';
	@override String scanTruncated({required Object count}) => 'Folder itu sangat besar — hanya ${count} berkas pertama yang ditambahkan.';
	@override String sourceOverlaps({required Object name}) => 'Sudah tercakup oleh folder "${name}"';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '"${name}" berada di dalam "${source}", jadi ditambahkan ke folder yang disematkan';
	@override String alreadyPinnedFolder({required Object name}) => '"${name}" sudah ada di folder yang disematkan';
	@override String sourceAlreadyAdded({required Object name}) => '"${name}" sudah ditambahkan';
	@override String sourceContainsExisting({required Object name}) => 'Sudah berisi folder yang ditambahkan "${name}"; menambahkan folder induknya belum didukung';
	@override String get addSourceFailed => 'Tidak dapat menambahkan folder tersebut';
	@override String get fileMissing => 'Berkas itu sudah tidak ada di disk';
	@override String get permissionDenied => 'Akses berkas tidak diberikan · ketuk untuk memberi izin';
	@override String get noVideosFound => 'Tidak ada video di folder ini';
	@override String get emptyTitle => 'Tambahkan folder untuk menonton video yang sudah ada di perangkat ini';
	@override String get emptyPrivacyNote => 'Berkas hanya dibaca di perangkat ini. Tidak ada yang diunggah.';
	@override String removeSourceTitle({required Object name}) => 'Hapus "${name}"?';
	@override String get removeSourceBody => 'Berkas tetap ada di disk. Hanya entri pustaka ini yang dihapus.';
	@override String get remove => 'Hapus';
	@override String get removeFolder => 'Hapus folder';
	@override String get removeFolderSelectTitle => 'Pilih folder untuk dihapus';
	@override String get longPressToRemove => 'Tekan lama untuk menghapus folder ini';
	@override String get clearProgress => 'Bersihkan riwayat tontonan lokal';
	@override String clearProgressCount({required Object count}) => '${count} entri';
	@override String get clearProgressEmpty => 'Belum ada riwayat tontonan lokal';
	@override String get clearProgressTitle => 'Bersihkan riwayat tontonan lokal?';
	@override String get clearProgressBody => 'Hanya posisi pemutaran dan tanda tonton yang dihapus. Berkas dan folder Anda tetap seperti semula.';
	@override String clearProgressDone({required Object count}) => 'Membersihkan ${count} entri riwayat tontonan lokal';
	@override String get clearAction => 'Bersihkan';
	@override String get iosManualRescanNotice => 'iOS tidak mendeteksi berkas baru secara otomatis. Anda perlu memindai ulang secara manual setelah menambah atau menghapus berkas.';
}

// Path: historyPage
class _TranslationsHistoryPageId extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Hapus dari riwayat';
	@override String get removed => 'Dihapus dari riwayat';
	@override String watchedTo({required Object time}) => 'Ditonton sampai ${time}';
	@override String get finished => 'Sudah ditonton';
	@override String clearTabTitle({required Object tab}) => 'Bersihkan "${tab}"';
	@override String clearTabConfirm({required Object tab}) => 'Semua riwayat di "${tab}" akan dihapus, beserta progres tontonan video tersebut. Tindakan ini tidak dapat dibatalkan.';
	@override String get rangeByLastViewed => 'Difilter menurut waktu terakhir dilihat';
}

// Path: common.pagination
class _TranslationsCommonPaginationId extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Total ${num} item';
	@override String get jumpToPage => 'Lompat ke halaman';
	@override String pleaseEnterPageNumber({required Object max}) => 'Silakan masukkan nomor halaman (1-${max})';
	@override String get pageNumber => 'Nomor halaman';
	@override String get jump => 'Lompat';
	@override String invalidPageNumber({required Object max}) => 'Silakan masukkan nomor halaman yang valid (1-${max})';
	@override String get invalidInput => 'Silakan masukkan nomor halaman yang valid';
	@override String get waterfall => 'Waterfall';
	@override String get pagination => 'Paginasi';
}

// Path: errors.network
class _TranslationsErrorsNetworkId extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Kesalahan jaringan - ';
	@override String get failedToConnectToServer => 'Gagal terhubung ke server';
	@override String get serverNotAvailable => 'Server tidak tersedia';
	@override String get requestTimeout => 'Permintaan habis waktu';
	@override String get unexpectedError => 'Kesalahan tak terduga';
	@override String get invalidResponse => 'Respons tidak valid';
	@override String get invalidRequest => 'Permintaan tidak valid';
	@override String get invalidUrl => 'URL tidak valid';
	@override String get invalidMethod => 'Metode tidak valid';
	@override String get invalidHeader => 'Header tidak valid';
	@override String get invalidBody => 'Isi permintaan tidak valid';
	@override String get invalidStatusCode => 'Kode status tidak valid';
	@override String get serverError => 'Kesalahan server';
	@override String get requestCanceled => 'Permintaan dibatalkan';
	@override String get invalidPort => 'Port tidak valid';
	@override String get proxyPortError => 'Kesalahan port proxy';
	@override String get connectionRefused => 'Koneksi ditolak';
	@override String get networkUnreachable => 'Jaringan tidak dapat dijangkau';
	@override String get noRouteToHost => 'Tidak ada rute ke host';
	@override String get connectionFailed => 'Koneksi gagal';
	@override String get sslConnectionFailed => 'Koneksi SSL gagal, silakan periksa pengaturan jaringan Anda';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingId extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pintasan Papan Ketik';
	@override String get entryLabel => 'Pintasan Papan Ketik';
	@override String get entryDesc => 'Sesuaikan pintasan papan ketik aplikasi (terutama untuk desktop)';
	@override String get desktopHint => 'Pintasan terutama berlaku untuk papan ketik desktop; seluler biasanya menggunakan gerakan.';
	@override String get resetAll => 'Atur Ulang Semua ke Bawaan';
	@override String get resetAllConfirm => 'Atur ulang semua pintasan aplikasi ke bawaannya?';
	@override String get resetToDefault => 'Atur Ulang ke Bawaan';
	@override String get resetScope => 'Atur Ulang Bagian Ini';
	@override String get notSet => 'Belum diatur';
	@override String get addShortcut => 'Tambah Pintasan';
	@override String get removeShortcut => 'Hapus pintasan ini';
	@override String get pressNewShortcut => 'Tekan pintasan baru…';
	@override String get recordingCancelHint => 'Tekan Esc untuk membatalkan';
	@override String get mouseHint => 'Anda juga dapat mengikat tombol samping mouse (kembali / maju) atau tombol tengah';
	@override String get mouseNotSupportedInScope => 'Area ini tidak menangani tombol mouse; gunakan papan ketik sebagai gantinya';
	@override String get capabilityKeyboardOnly => 'Area ini hanya menerima tombol papan ketik';
	@override String get capabilityKeyboardAndMouse => 'Area ini menerima tombol papan ketik, serta tombol tengah dan samping mouse';
	@override String get capabilityKeyboardAndMouseMobile => 'Area ini menerima tombol papan ketik, serta tombol tengah dan maju mouse (tombol kembali diambil oleh sistem)';
	@override String get rejectMultipleButtons => 'Tekan satu tombol mouse dalam satu waktu';
	@override String get rejectPlatformBack => 'Sistem sudah menggunakan ini untuk Kembali; mengikatnya akan membuat kembali dua kali';
	@override String get detectedLabel => 'Terdeteksi';
	@override String get reservedKey => 'Tombol ini disisihkan oleh sistem dan tidak dapat diikat';
	@override String reservedForGlobalBack({required Object action}) => 'Tombol ini diikat ke "${action}"; tombol tetap disisihkan di sini agar Anda masih dapat meninggalkan layar ini';
	@override String get conflictTitle => 'Konflik Pintasan';
	@override String conflictMessage({required Object action}) => 'Kombinasi ini sudah diikat ke "${action}". Melanjutkan akan menghapus ikatan yang ada.';
	@override String get conflictContinue => 'Tetap Ikat';
	@override String get shadowWarningTitle => 'Tumpang Tindih Pintasan Global';
	@override String shadowWarningMessage({required Object action}) => 'Kombinasi ini diikat ke "${action}" secara global. Mengikatnya di sini akan menimpa tindakan itu hanya di dalam bagian ini.';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'Kombinasi ini sudah diikat ke "${action}" di ${scope}. Di dalam bagian itu, pintasan global ini akan ditimpa olehnya.';
	@override String get searchHint => 'Cari pintasan…';
	@override String get scopeGlobal => 'Global';
	@override String get scopeGallery => 'Galeri';
	@override String get scopeVideo => 'Video';
	@override String get categoryNavigation => 'Navigasi';
	@override String get categoryZoom => 'Zoom';
	@override String get categoryPlayback => 'Pemutaran';
	@override String get categorySeek => 'Pencarian';
	@override String get categoryVolume => 'Volume';
	@override String get categoryDisplay => 'Tampilan';
	@override String get actionGlobalBack => 'Kembali';
	@override String get actionGalleryNext => 'Foto Berikutnya';
	@override String get actionGalleryPrevious => 'Foto Sebelumnya';
	@override String get actionGalleryZoomIn => 'Perbesar';
	@override String get actionGalleryZoomOut => 'Perkecil';
	@override String get actionGalleryResetZoom => 'Atur Ulang Zoom';
	@override String get actionGalleryPlayPause => 'Putar / Jeda';
	@override String get actionGallerySeekBackward => 'Mundur';
	@override String get actionGallerySeekForward => 'Maju Cepat';
	@override String get actionGalleryToggleMute => 'Alihkan Bisu';
	@override String get actionPlayPause => 'Putar / Jeda';
	@override String get actionSpeedUp => 'Tingkatkan Kecepatan';
	@override String get actionSpeedDown => 'Kurangi Kecepatan';
	@override String get actionSeekForward => 'Maju';
	@override String get actionSeekBackward => 'Mundur';
	@override String get actionVolumeUp => 'Besarkan Volume';
	@override String get actionVolumeDown => 'Kecilkan Volume';
	@override String get actionToggleMute => 'Alihkan Bisu';
	@override String get actionToggleFullscreen => 'Alihkan Layar Penuh';
	@override String get seekLongPressHint => 'Tahan tombol maju / mundur untuk memicu mode kecepatan tekan lama';
	@override String get zoomSectionTitle => 'Zoom Gambar (Tetap)';
	@override String get zoomFixedNote => 'Pintasan di bawah ini tetap dan tidak dapat diubah';
	@override String get zoomScaleLabel => 'Perbesar Gambar';
	@override String get zoomScaleHint => 'Ctrl + Roda';
	@override String get zoomRotateLabel => 'Putar Gambar';
	@override String get zoomRotateHint => 'Shift + Roda';
	@override String get zoomPinchGesture => 'Cubit';
	@override String get zoomTwoFingerRotateGesture => 'Putar Dua Jari';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsId extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Forum';
	@override String get configureYourForumSettings => 'Konfigurasikan Pengaturan Forum Anda';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsId extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Pengaturan Galeri';
	@override String get gallerySettingsSubtitle => 'Konfigurasikan preferensi penampil galeri';
	@override String get defaultViewerQuality => 'Kualitas penampil bawaan';
	@override String get defaultViewerQualityDesc => 'Pilih kualitas gambar mana yang ditampilkan secara bawaan saat membuka penampil galeri.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsId extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Blokir Konten';
	@override String get subtitle => 'Secara otomatis menyembunyikan video dan galeri yang judulnya cocok dengan kata kunci atau pola, atau yang berasal dari pengguna yang diblokir. Semua pencocokan dilakukan di perangkat Anda — tidak ada yang diunggah.';
	@override String get blocked => 'Diblokir';
	@override String get reveal => 'Tampilkan';
	@override String get reblock => 'Blokir lagi';
	@override String get why => 'Mengapa diblokir?';
	@override String get manageRules => 'Kelola aturan';
	@override String reasonKeyword({required Object value}) => 'Judul mengandung "${value}"';
	@override String reasonRegex({required Object value}) => 'Judul cocok dengan "${value}"';
	@override String get reasonUser => 'Dari pengguna yang diblokir';
	@override String get addRule => 'Tambah aturan';
	@override String get editRule => 'Edit aturan';
	@override String get deleteRule => 'Hapus aturan';
	@override String get ruleType => 'Jenis aturan';
	@override String get keyword => 'Kata Kunci';
	@override String get regex => 'Regex';
	@override String get userId => 'Pengguna';
	@override String get value => 'Teks yang dicocokkan';
	@override String get caseSensitive => 'Peka huruf besar-kecil';
	@override String get regexHint => 'mis. trailer|teaser';
	@override String get valueRequired => 'Silakan masukkan teks yang akan dicocokkan';
	@override String get invalidRegex => 'Itu bukan ekspresi reguler yang valid';
	@override String get noRules => 'Belum ada aturan. Ketuk + untuk menambahkan.';
	@override String get blockUser => 'Blokir';
	@override String get unblockUser => 'Buka blokir';
	@override String blockUserConfirm({required Object name}) => 'Blokir "${name}"? Video dan galeri mereka akan disembunyikan dari daftar dan pencarian.';
	@override String get userBlocked => 'Pengguna diblokir';
	@override String get userUnblocked => 'Blokir pengguna dibuka';
	@override String get exportRules => 'Ekspor';
	@override String get importRules => 'Impor';
	@override String get importExport => 'Impor / Ekspor';
	@override String get exportSuccess => 'Aturan diekspor';
	@override String get exportFailed => 'Tidak dapat mengekspor aturan';
	@override String importSuccess({required Object count}) => 'Mengimpor ${count} aturan';
	@override String get importFailed => 'Tidak dapat mengimpor aturan';
	@override String get regexHelp => 'Bantuan pola';
	@override String get regexHelpTitle => 'Referensi regex';
	@override String get regexHelpIntro => 'Ekspresi reguler mencocokkan judul lebih fleksibel daripada kata kunci biasa. Beberapa contoh umum:';
	@override String get regexHelpTapHint => 'Ketuk contoh untuk mengisinya.';
	@override String get regexEx1Pattern => 'trailer|teaser|bonus';
	@override String get regexEx1Desc => 'Cocok dengan salah satu kata ini ("|" berarti "atau")';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Judul yang diawali dengan [tanda kurung]';
	@override String get regexEx3Pattern => 'Koleksi\$';
	@override String get regexEx3Desc => 'Judul yang diakhiri dengan "Koleksi"';
	@override String get regexEx4Pattern => 'Ep.[0-9]+';
	@override String get regexEx4Desc => '[0-9]+ berarti satu digit atau lebih — cocok dengan "Ep.12"';
	@override String get regexEx5Pattern => '[0-9]{4}';
	@override String get regexEx5Desc => '[0-9] berarti satu digit dan {4} berarti empat digit berurutan (mis. satu tahun)';
	@override String get regexEx1Sample => 'Trailer game baru sudah tayang';
	@override String get regexEx2Sample => '[Remux] Film Utuh';
	@override String get regexEx3Sample => 'Koleksi Seni Musim Semi';
	@override String get regexEx4Sample => 'Rekap Ep.12 Serial Saya';
	@override String get regexEx5Sample => 'Sorotan Terbaik 2024';
	@override String get regexHelpSampleLabel => 'Contoh judul';
	@override String get regexHelpMatchedTag => 'Diblokir';
	@override String get regexHelpNoMatch => 'Tidak cocok';
	@override String get regexEx6Pattern => '[Ss]eason';
	@override String get regexEx6Desc => '[Ss] cocok dengan huruf S besar maupun kecil — di sini menangkap "Season"';
	@override String get regexEx6Sample => 'Trailer Musim Terakhir';
	@override String get regexEx7Pattern => '(film|serial)';
	@override String get regexEx7Desc => 'Tanda kurung () mengelompokkan pilihan — cocok dengan "film" atau "serial"';
	@override String get regexEx7Sample => 'Tonton Serialnya Sekarang';
	@override String get regexEx8Pattern => 'film(nya)?';
	@override String get regexEx8Desc => '(nya)? membuat akhiran "nya" opsional — cocok dengan "film" dan "filmnya"';
	@override String get regexEx8Sample => 'Tonton Filmnya Sekarang';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ berarti satu atau lebih — cocok dengan !, !!, !!! ...';
	@override String get regexEx9Sample => 'OMG!!! Wajib Tonton';
	@override String get regexEx10Pattern => 'bonus.*adegan';
	@override String get regexEx10Desc => '.* cocok dengan teks apa pun di antaranya — "bonus … adegan"';
	@override String get regexEx10Sample => 'Adegan Bonus yang Dihapus';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsId extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Obrolan';
	@override String get configureYourChatSettings => 'Konfigurasikan Pengaturan Obrolan Anda';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsId extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Pengaturan Unduhan';
	@override String get enableDownloadNotifications => 'Notifikasi Unduhan';
	@override String get enableDownloadNotificationsDescription => 'Tampilkan notifikasi sistem saat satu unduhan selesai atau gagal';
	@override String get notificationPermissionDenied => 'Izin notifikasi ditolak. Notifikasi dalam aplikasi tetap berfungsi; aktifkan notifikasi sistem di pengaturan.';
	@override String get storagePermissionStatus => 'Status Izin Penyimpanan';
	@override String get accessPublicDirectoryNeedStoragePermission => 'Akses Direktori Publik Memerlukan Izin Penyimpanan';
	@override String get checkingPermissionStatus => 'Memeriksa Status Izin...';
	@override String get storagePermissionGranted => 'Izin Penyimpanan Diberikan';
	@override String get storagePermissionNotGranted => 'Izin Penyimpanan Tidak Diberikan';
	@override String get storagePermissionGrantSuccess => 'Pemberian Izin Penyimpanan Berhasil';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Pemberian Izin Penyimpanan Gagal Namun Beberapa Fitur Mungkin Terbatas';
	@override String get storagePermissionRationale => 'Untuk menyimpan unduhan ke folder yang Anda pilih, aplikasi memerlukan akses penyimpanan.\n\nDi Android 11 dan yang lebih baru, ini berarti izin "Akses semua file"; tanpa izin itu, file disimpan ke folder privat aplikasi sebagai gantinya.';
	@override String get storagePermissionRationaleLegacy => 'Untuk menyimpan unduhan ke folder yang Anda pilih, aplikasi memerlukan akses penyimpanan.\n\nTanpa izin itu, file disimpan ke folder privat aplikasi sebagai gantinya.';
	@override String get grantStoragePermission => 'Beri Izin Penyimpanan';
	@override String get customDownloadPath => 'Jalur Unduhan Kustom';
	@override String get customDownloadPathDescription => 'Saat diaktifkan, Anda dapat memilih lokasi penyimpanan kustom untuk file yang diunduh';
	@override String get customDownloadPathTip => '💡 Tips: Memilih direktori publik (seperti folder Unduhan) memerlukan izin penyimpanan, disarankan menggunakan jalur yang direkomendasikan terlebih dahulu';
	@override String get androidWarning => 'Catatan Android: Hindari memilih direktori publik (seperti folder Unduhan), disarankan menggunakan direktori khusus aplikasi untuk memastikan izin akses.';
	@override String get publicDirectoryPermissionTip => '⚠️ Perhatian: Anda memilih direktori publik, izin penyimpanan diperlukan agar file dapat diunduh dengan normal';
	@override String get permissionRequiredForPublicDirectory => 'Izin penyimpanan diperlukan untuk direktori publik';
	@override String get currentDownloadPath => 'Jalur Unduhan Saat Ini';
	@override String get actualDownloadPath => 'Jalur Unduhan Sebenarnya';
	@override String get defaultAppDirectory => 'Direktori Aplikasi Bawaan';
	@override String get permissionGranted => 'Diberikan';
	@override String get permissionRequired => 'Izin Diperlukan';
	@override String get enableCustomDownloadPath => 'Aktifkan Jalur Unduhan Kustom';
	@override String get disableCustomDownloadPath => 'Gunakan jalur bawaan aplikasi saat dinonaktifkan';
	@override String get customDownloadPathLabel => 'Jalur Unduhan Kustom';
	@override String get selectDownloadFolder => 'Pilih folder unduhan';
	@override String get recommendedPath => 'Jalur yang Direkomendasikan';
	@override String get selectFolder => 'Pilih Folder';
	@override String get filenameTemplate => 'Templat Nama File';
	@override String get filenameTemplateDescription => 'Sesuaikan aturan penamaan untuk file yang diunduh, mendukung substitusi variabel';
	@override String get videoFilenameTemplate => 'Templat Nama File Video';
	@override String get galleryFolderTemplate => 'Templat Folder Galeri';
	@override String get imageFilenameTemplate => 'Templat Nama File Gambar';
	@override String get resetToDefault => 'Atur Ulang ke Bawaan';
	@override String get supportedVariables => 'Variabel yang Didukung';
	@override String get supportedVariablesDescription => 'Variabel berikut dapat digunakan dalam templat nama file:';
	@override String get copyVariable => 'Salin Variabel';
	@override String get variableCopied => 'Variabel disalin';
	@override String get warningPublicDirectory => 'Peringatan: Direktori publik yang dipilih mungkin tidak dapat diakses. Disarankan memilih direktori khusus aplikasi.';
	@override String get downloadPathUpdated => 'Jalur unduhan diperbarui';
	@override String get selectPathFailed => 'Gagal memilih jalur';
	@override String get pickerAlreadyActive => 'Pemilih folder sudah terbuka';
	@override String get unsupportedStorageVolume => 'Lokasi penyimpanan tidak didukung. Pilih folder di penyimpanan perangkat atau kartu SD.';
	@override String get recommendedPathSet => 'Diatur ke jalur yang direkomendasikan';
	@override String get setRecommendedPathFailed => 'Gagal mengatur jalur yang direkomendasikan';
	@override String get templateResetToDefault => 'Atur ulang ke templat bawaan';
	@override String get functionalTest => 'Uji Fungsional';
	@override String get testInProgress => 'Menguji...';
	@override String get runTest => 'Jalankan Uji';
	@override String get testDownloadPathAndPermissions => 'Uji apakah jalur unduhan dan konfigurasi izin berfungsi dengan benar';
	@override String get testResults => 'Hasil Uji';
	@override String get testCompleted => 'Uji selesai';
	@override String get testMultisegmentDomain => 'Validasi domain nilai (multi-segmen / kelebihan / bentuk pelolosan)';
	@override String get testMultisegmentPaths => 'Render struktur multi-segmen (issue #126)';
	@override String get testPassed => 'item lulus';
	@override String get testFailed => 'Uji gagal';
	@override String get testStoragePermissionCheck => 'Pemeriksaan Izin Penyimpanan';
	@override String get testStoragePermissionGranted => 'Izin penyimpanan diberikan';
	@override String get testStoragePermissionMissing => 'Izin penyimpanan tidak ada, beberapa fitur mungkin terbatas';
	@override String get testPermissionCheckFailed => 'Pemeriksaan izin gagal';
	@override String get testDownloadPathValidation => 'Validasi Jalur Unduhan';
	@override String get testPathValidationFailed => 'Validasi jalur gagal';
	@override String get testFilenameTemplateValidation => 'Validasi Templat Nama File';
	@override String get testAllTemplatesValid => 'Semua templat valid';
	@override String get testSomeTemplatesInvalid => 'Beberapa templat mengandung karakter yang tidak valid';
	@override String get testTemplateValidationFailed => 'Validasi templat gagal';
	@override String get testDirectoryOperationTest => 'Uji Operasi Direktori';
	@override String get testDirectoryOperationNormal => 'Pembuatan direktori dan penulisan file normal';
	@override String get testDirectoryOperationFailed => 'Operasi direktori gagal';
	@override String get testVideoTemplate => 'Templat Video';
	@override String get testGalleryTemplate => 'Templat Galeri';
	@override String get testImageTemplate => 'Templat Gambar';
	@override String get testValid => 'Valid';
	@override String get testInvalid => 'Tidak Valid';
	@override String get testSuccess => 'Berhasil';
	@override String get testCorrect => 'Benar';
	@override String get testError => 'Kesalahan';
	@override String get testPath => 'Jalur Uji';
	@override String get testBasePath => 'Jalur Dasar';
	@override String get testDirectoryCreation => 'Pembuatan Direktori';
	@override String get testFileWriting => 'Penulisan File';
	@override String get testFileContent => 'Isi File';
	@override String get checkingPathStatus => 'Memeriksa status jalur...';
	@override String get unableToGetPathStatus => 'Tidak dapat memperoleh status jalur';
	@override String get actualPathDifferentFromSelected => 'Catatan: Jalur sebenarnya berbeda dari jalur yang dipilih';
	@override String get grantPermission => 'Beri Izin';
	@override String get fixIssue => 'Perbaiki Masalah';
	@override String get issueFixed => 'Masalah diperbaiki';
	@override String get fixFailed => 'Perbaikan gagal, silakan tangani secara manual';
	@override String get lackStoragePermission => 'Tidak memiliki izin penyimpanan';
	@override String get cannotAccessPublicDirectory => 'Tidak dapat mengakses direktori publik, memerlukan "Izin akses semua file"';
	@override String get cannotCreateDirectory => 'Tidak dapat membuat direktori';
	@override String get directoryNotWritable => 'Direktori tidak dapat ditulis';
	@override String get insufficientSpace => 'Ruang tersedia tidak cukup';
	@override String get pathValid => 'Jalur valid';
	@override String get validationFailed => 'Validasi gagal';
	@override String get usingDefaultAppDirectory => 'Menggunakan direktori aplikasi bawaan';
	@override String get appPrivateDirectory => 'Direktori Privat Aplikasi';
	@override String get appPrivateDirectoryDesc => 'Aman dan andal, tidak memerlukan izin tambahan';
	@override String get downloadDirectory => 'Direktori Unduhan';
	@override String get downloadDirectoryDesc => 'Lokasi unduhan bawaan sistem, mudah dikelola';
	@override String get moviesDirectory => 'Direktori Film';
	@override String get moviesDirectoryDesc => 'Direktori film sistem, dapat dikenali oleh aplikasi media';
	@override String get documentsDirectory => 'Direktori Dokumen';
	@override String get documentsDirectoryDesc => 'Direktori dokumen aplikasi iOS';
	@override String get requiresStoragePermission => 'Memerlukan izin penyimpanan untuk mengakses';
	@override String get recommendedPaths => 'Jalur yang Direkomendasikan';
	@override String get externalAppPrivateDirectory => 'Direktori Privat Aplikasi Eksternal';
	@override String get externalAppPrivateDirectoryDesc => 'Direktori privat aplikasi di penyimpanan eksternal, dapat diakses pengguna, ruang lebih besar';
	@override String get internalAppPrivateDirectory => 'Direktori Privat Aplikasi Internal';
	@override String get internalAppPrivateDirectoryDesc => 'Penyimpanan internal aplikasi, tidak memerlukan izin, ruang lebih kecil';
	@override String get appDocumentsDirectory => 'Direktori Dokumen Aplikasi';
	@override String get appDocumentsDirectoryDesc => 'Direktori dokumen khusus aplikasi, aman dan andal';
	@override String get downloadsFolder => 'Folder Unduhan';
	@override String get downloadsFolderDesc => 'Direktori unduhan bawaan sistem';
	@override String get selectRecommendedDownloadLocation => 'Pilih lokasi unduhan yang direkomendasikan';
	@override String get noRecommendedPaths => 'Tidak ada jalur yang direkomendasikan';
	@override String get recommended => 'Direkomendasikan';
	@override String get requiresPermission => 'Memerlukan Izin';
	@override String get authorizeAndSelect => 'Otorisasi dan Pilih';
	@override String get select => 'Pilih';
	@override String get permissionAuthorizationFailed => 'Otorisasi izin gagal, tidak dapat memilih jalur ini';
	@override String get pathValidationFailed => 'Validasi jalur gagal';
	@override String get downloadPathSetTo => 'Jalur unduhan diatur ke';
	@override String get setPathFailed => 'Gagal mengatur jalur';
	@override String get variableTitle => 'Judul';
	@override String get variableAuthorcache => 'Nama pertama penulis (stabil meski nama diganti)';
	@override String get variableAuthor => 'Nama penulis';
	@override String get variableUsername => 'Nama pengguna penulis';
	@override String get variableQuality => 'Kualitas video';
	@override String get variableFilename => 'Nama file asli';
	@override String get variableId => 'ID Konten';
	@override String get variableCount => 'Jumlah gambar galeri';
	@override String get variableDate => 'Tanggal saat ini (YYYY-MM-DD)';
	@override String get variableTime => 'Waktu saat ini (HH-MM-SS)';
	@override String get variableDatetime => 'Tanggal waktu saat ini (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'Pengaturan Unduhan';
	@override String get downloadSettingsSubtitle => 'Konfigurasikan jalur unduhan dan aturan penamaan file';
	@override String get suchAsTitleQuality => 'Contoh: %title_%quality';
	@override String get suchAsTitleId => 'Contoh: %title_%id';
	@override String get suchAsTitleFilename => 'Contoh: %title_%filename';
	@override String get structureSection => 'Struktur simpan & penamaan';
	@override String get structureSectionDescription => 'File yang diunduh otomatis masuk subfolder sesuai skema di bawah. Hanya memengaruhi unduhan berikutnya; file yang sudah ada tidak diubah.';
	@override String get structureNoticeTitle => 'Fitur baru: arsip otomatis per penulis';
	@override String get structureNoticeBody => 'Pilih di bawah · hanya memengaruhi unduhan baru, file yang sudah ada tidak diubah.';
	@override String get presetFlat => 'Rata';
	@override String get presetFlatDesc => 'Semua file langsung di root unduhan';
	@override String get presetAuthor => 'Per penulis';
	@override String get presetAuthorBadge => 'Direkomendasikan';
	@override String get presetAuthorDesc => 'Satu folder per penulis · tidak terpecah meski nama berubah';
	@override String get presetDate => 'Per tanggal';
	@override String get presetDateDesc => 'Dikelompokkan menurut tanggal unduh';
	@override String get presetCustomActive => 'Digunakan';
	@override String get structurePreviewLabel => 'Pratinjau';
	@override String get structurePreviewNote => 'Segmen berwarna adalah tingkat pengorganisasian, berubah sesuai skema terpilih.';
	@override String get pathTooLongWarning => 'Jalur relatif melebihi 200 karakter, bisa gagal disimpan di sebagian perangkat';
	@override String get pathTemplateEditorEntry => 'Templat jalur kustom';
	@override String get pathTemplateEditorEntryDesc => 'Tentukan sendiri struktur folder dan nama file';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorId pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorId._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesId extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Tren';
	@override String get favorites => 'Favorit';
	@override String get latest => 'Terbaru';
	@override String get popularity => 'Popularitas';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsId extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Permintaan gagal, kode status';
	@override String get connectionTimeout => 'Waktu koneksi habis, silakan periksa koneksi jaringan';
	@override String get sendTimeout => 'Waktu mengirim permintaan habis';
	@override String get receiveTimeout => 'Waktu menerima respons habis';
	@override String get badCertificate => 'Verifikasi sertifikat gagal';
	@override String get resourceNotFound => 'Sumber daya yang diminta tidak ditemukan';
	@override String get accessDenied => 'Akses ditolak, mungkin memerlukan autentikasi atau izin';
	@override String get serverError => 'Kesalahan server internal';
	@override String get serviceUnavailable => 'Layanan sementara tidak tersedia';
	@override String get requestCancelled => 'Permintaan dibatalkan';
	@override String get connectionError => 'Kesalahan koneksi jaringan, silakan periksa pengaturan jaringan';
	@override String get networkRequestFailed => 'Permintaan jaringan gagal';
	@override String get searchVideoError => 'Terjadi kesalahan tidak dikenal saat mencari video';
	@override String get getPopularVideoError => 'Terjadi kesalahan tidak dikenal saat mengambil video populer';
	@override String get getVideoDetailError => 'Terjadi kesalahan tidak dikenal saat mengambil detail video';
	@override String get parseVideoDetailError => 'Terjadi kesalahan tidak dikenal saat mengambil dan mengurai detail video';
	@override String get downloadFileError => 'Terjadi kesalahan tidak dikenal saat mengunduh file';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingId extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Mengambil informasi video...';
	@override String get cancel => 'Batal';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesId extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Video tidak ditemukan atau telah dihapus';
	@override String get unableToGetVideoPlayLink => 'Tidak dapat memperoleh tautan pemutaran video';
	@override String get getVideoDetailFailed => 'Gagal mengambil detail video';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoId extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Info Video';
	@override String get currentQuality => 'Kualitas Saat Ini';
	@override String get duration => 'Durasi';
	@override String get resolution => 'Resolusi';
	@override String get fileInfo => 'Info File';
	@override String get fileName => 'Nama File';
	@override String get fileSize => 'Ukuran File';
	@override String get filePath => 'Jalur File';
	@override String get copyPath => 'Salin Jalur';
	@override String get openFolder => 'Buka Folder';
	@override String get pathCopiedToClipboard => 'Jalur disalin ke papan klip';
	@override String get openFolderFailed => 'Gagal membuka folder';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideId extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Video contoh';
	@override String get title => 'Panduan Gerakan & Interaksi';
	@override String get viewGuide => 'Panduan Gerakan & Interaksi';
	@override String get firstTimeIntro => 'Luangkan beberapa detik untuk mempelajari gerakan pemutar. Anda dapat membuka kembali panduan ini kapan saja dari pengaturan pemutar.';
	@override String get startWatching => 'Mengerti, mulai menonton';
	@override String get basicTitle => 'Kontrol Dasar';
	@override String get zoomTitle => 'Zoom / Putar / Geser';
	@override String get restoreTip => 'Ketuk tombol "Pulihkan" di kanan bawah untuk mengatur ulang zoom, rotasi, dan posisi.';
	@override String get mTap => 'Ketuk sekali: tampilkan / sembunyikan kontrol';
	@override String get mDoubleTap => 'Ketuk dua kali: mundur (kiri) / jeda (tengah) / maju cepat (kanan)';
	@override String get mHorizontalDrag => 'Geser horizontal: mencari';
	@override String get mVerticalDrag => 'Geser vertikal: kecerahan (kiri) / volume (kanan)';
	@override String get mLongPress => 'Tekan lama: percepatan sementara';
	@override String get mPinch => 'Cubit dua jari: perbesar gambar';
	@override String get mRotate => 'Putar dua jari: memutar gambar';
	@override String get dTap => 'Klik: tampilkan / sembunyikan kontrol';
	@override String get dDoubleTap => 'Klik dua kali: mundur (kiri) / jeda (tengah) / maju cepat (kanan)';
	@override String get dKeys => 'Tombol pencarian: ketuk untuk melompat mundur / maju, tahan untuk mempercepat; tombol kecepatan: menyesuaikan kecepatan pemutaran selama pemutaran normal; Spasi: putar / jeda';
	@override String get dTrackpadPinch => 'Cubit trackpad: perbesar gambar';
	@override String get dTrackpadRotate => 'Putar trackpad: memutar gambar';
	@override String get dCtrlWheel => 'Ctrl + roda: perbesar di sekitar kursor';
	@override String get dShiftWheel => 'Shift + roda: putar di sekitar kursor';
	@override late final _TranslationsVideoDetailGestureGuideQuestId quest = _TranslationsVideoDetailGestureGuideQuestId._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerId extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Kesalahan saat memuat sumber video';
	@override String get errorWhileSettingUpListeners => 'Kesalahan saat menyiapkan pemantau';
	@override String get serverFaultDetectedAutoSwitched => 'Kesalahan server terdeteksi, otomatis beralih rute dan mencoba lagi';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonId extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Mengambil info video...';
	@override String get fetchingVideoSources => 'Mengambil sumber video...';
	@override String get loadingVideo => 'Memuat video...';
	@override String get applyingSolution => 'Menerapkan solusi...';
	@override String get addingListeners => 'Menambahkan pemantau...';
	@override String get successFecthVideoDurationInfo => 'Berhasil mengambil durasi video, mulai memuat video...';
	@override String get successFecthVideoHeightInfo => 'Pemuatan selesai';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastId extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Siarkan';
	@override String unableToStartCastingSearch({required Object error}) => 'Gagal memulai pencarian penyiaran: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Mulai menyiarkan ke ${deviceName}';
	@override String castFailed({required Object error}) => 'Penyiaran gagal: ${error}\nSilakan coba cari ulang perangkat atau ganti jaringan';
	@override String get castStopped => 'Penyiaran dihentikan';
	@override late final _TranslationsVideoDetailCastDeviceTypesId deviceTypes = _TranslationsVideoDetailCastDeviceTypesId._(_root);
	@override String get currentPlatformNotSupported => 'Platform saat ini tidak mendukung penyiaran';
	@override String get unableToGetVideoUrl => 'Tidak dapat memperoleh URL video, silakan coba lagi nanti';
	@override String get stopCasting => 'Hentikan penyiaran';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetId dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetId._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsId extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Siapa yang diam-diam menyukai';
	@override String get dialogDescription => 'Penasaran siapa mereka? Telusuri "Album Suka" ini~';
	@override String get closeTooltip => 'Tutup';
	@override String get retry => 'Coba Lagi';
	@override String get noLikesYet => 'Belum ada yang muncul di sini. Jadilah yang pertama!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Halaman ${page} / ${totalPages} · Total ${totalCount} orang';
	@override String get prevPage => 'Halaman Sebelumnya';
	@override String get nextPage => 'Halaman Berikutnya';
}

// Path: forum.sitewide
class _TranslationsForumSitewideId extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get badge => 'Situs';
	@override String get title => 'Pengumuman Situs';
	@override String get readMore => 'Baca selengkapnya';
}

// Path: forum.errors
class _TranslationsForumErrorsId extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Silakan pilih kategori';
	@override String get threadLocked => 'Topik ini terkunci, tidak dapat membalas';
}

// Path: forum.groups
class _TranslationsForumGroupsId extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Administrasi';
	@override String get global => 'Global';
	@override String get chinese => 'Mandarin';
	@override String get japanese => 'Jepang';
	@override String get korean => 'Korea';
	@override String get other => 'Lainnya';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesId extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Pengumuman';
	@override String get feedback => 'Masukan';
	@override String get support => 'Dukungan';
	@override String get general => 'Umum';
	@override String get guides => 'Panduan';
	@override String get questions => 'Pertanyaan';
	@override String get requests => 'Permintaan';
	@override String get sharing => 'Berbagi';
	@override String get general_zh => 'Umum';
	@override String get questions_zh => 'Pertanyaan';
	@override String get requests_zh => 'Permintaan';
	@override String get support_zh => 'Dukungan';
	@override String get general_ja => 'Umum';
	@override String get questions_ja => 'Pertanyaan';
	@override String get requests_ja => 'Permintaan';
	@override String get support_ja => 'Dukungan';
	@override String get korean => 'Korea';
	@override String get other => 'Lainnya';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsId extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Notifikasi dan pengumuman resmi yang penting';
	@override String get feedback => 'Masukan tentang fitur dan layanan situs web';
	@override String get support => 'Bantuan untuk menyelesaikan masalah terkait situs web';
	@override String get general => 'Bahas topik apa saja';
	@override String get guides => 'Bagikan pengalaman dan tutorial Anda';
	@override String get questions => 'Ajukan pertanyaan Anda';
	@override String get requests => 'Kirimkan permintaan Anda';
	@override String get sharing => 'Bagikan konten yang menarik';
	@override String get general_zh => 'Bahas topik apa saja';
	@override String get questions_zh => 'Ajukan pertanyaan Anda';
	@override String get requests_zh => 'Kirimkan permintaan Anda';
	@override String get support_zh => 'Bantuan untuk menyelesaikan masalah terkait situs web';
	@override String get general_ja => 'Bahas topik apa saja';
	@override String get questions_ja => 'Ajukan pertanyaan Anda';
	@override String get requests_ja => 'Kirimkan permintaan Anda';
	@override String get support_ja => 'Bantuan untuk menyelesaikan masalah terkait situs web';
	@override String get korean => 'Diskusi terkait bahasa Korea';
	@override String get other => 'Konten lain yang tidak terklasifikasi';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsId extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Jenis notifikasi tidak didukung';
	@override String get unknownUser => 'Pengguna tidak dikenal';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Jenis notifikasi tidak didukung: ${type}';
	@override String get unknownNotificationType => 'Jenis notifikasi tidak dikenal';
}

// Path: conversation.errors
class _TranslationsConversationErrorsId extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Silakan pilih pengguna';
	@override String get pleaseEnterATitle => 'Silakan masukkan judul';
	@override String get clickToSelectAUser => 'Klik untuk memilih pengguna';
	@override String get loadFailedClickToRetry => 'Gagal memuat, klik untuk mencoba lagi';
	@override String get loadFailed => 'Gagal memuat';
	@override String get clickToRetry => 'Klik untuk mencoba lagi';
	@override String get noMoreConversations => 'Tidak ada percakapan lagi';
}

// Path: splash.errors
class _TranslationsSplashErrorsId extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Inisialisasi gagal, silakan mulai ulang aplikasi';
}

// Path: download.errors
class _TranslationsDownloadErrorsId extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'Model gambar tidak ditemukan';
	@override String get downloadFailed => 'Unduhan gagal';
	@override String get videoInfoNotFound => 'Info video tidak ditemukan';
	@override String get downloadTaskAlreadyExists => 'Tugas unduhan sudah ada';
	@override String get downloadTaskSavePathConflict => 'Jalur penyimpanan sudah digunakan oleh tugas lain';
	@override String get videoAlreadyDownloaded => 'Video sudah diunduh';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'Gagal menambahkan tugas unduhan: ${errorInfo}';
	@override String get userPausedDownload => 'Pengguna menjeda unduhan';
	@override String get unknown => 'Tidak diketahui';
	@override String fileSystemError({required Object errorInfo}) => 'Kesalahan sistem berkas: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Kesalahan tidak diketahui: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'Gagal menulis berkas: ${errorInfo}';
	@override String get connectionTimeout => 'Koneksi habis waktu';
	@override String get sendTimeout => 'Waktu pengiriman habis';
	@override String get receiveTimeout => 'Waktu penerimaan habis';
	@override String serverError({required Object errorInfo}) => 'Kesalahan server: ${errorInfo}';
	@override String get unknownNetworkError => 'Kesalahan jaringan tidak diketahui';
	@override String get sslHandshakeFailed => 'Handshake SSL gagal, silakan periksa jaringan Anda';
	@override String get connectionFailed => 'Koneksi gagal, silakan periksa jaringan Anda';
	@override String get serviceIsClosing => 'Layanan unduhan sedang ditutup';
	@override String get partialDownloadFailed => 'Unduhan konten sebagian gagal';
	@override String get noDownloadTask => 'Tidak ada tugas unduhan';
	@override String get taskNotFoundOrDataError => 'Tugas tidak ditemukan atau data bermasalah';
	@override String get fileNotFound => 'Berkas tidak ditemukan';
	@override String get openFolderFailed => 'Gagal membuka folder';
	@override String get copyDownloadUrlFailed => 'Gagal menyalin URL unduhan';
	@override String openFolderFailedWithMessage({required Object message}) => 'Gagal membuka folder: ${message}';
	@override String get directoryNotFound => 'Direktori tidak ditemukan';
	@override String get copyFailed => 'Gagal menyalin';
	@override String get openFileFailed => 'Gagal membuka berkas';
	@override String openFileFailedWithMessage({required Object message}) => 'Gagal membuka berkas: ${message}';
	@override String get playLocallyFailed => 'Gagal memutar secara lokal';
	@override String playLocallyFailedWithMessage({required Object message}) => 'Gagal memutar secara lokal: ${message}';
	@override String get noDownloadSource => 'Tidak ada sumber unduhan';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'Tidak ada sumber unduhan, harap tunggu hingga pemuatan informasi selesai lalu coba lagi';
	@override String get noActiveDownloadTask => 'Tidak ada tugas unduhan aktif';
	@override String get noFailedDownloadTask => 'Tidak ada tugas unduhan yang gagal';
	@override String get noCompletedDownloadTask => 'Tidak ada tugas unduhan yang selesai';
	@override String get taskAlreadyCompletedDoNotAdd => 'Tugas sudah selesai, jangan tambahkan lagi';
	@override String get linkExpiredTryAgain => 'Tautan kedaluwarsa, mencoba mendapatkan tautan unduhan baru';
	@override String get linkExpiredTryAgainSuccess => 'Tautan kedaluwarsa, berhasil mendapatkan tautan unduhan baru';
	@override String get linkExpiredTryAgainFailed => 'Tautan kedaluwarsa, gagal mendapatkan tautan unduhan baru';
	@override String get taskDeleted => 'Tugas dihapus';
	@override String unsupportedImageFormat({required Object format}) => 'Format gambar tidak didukung: ${format}';
	@override String get deleteFileError => 'Gagal menghapus berkas, mungkin karena berkas sedang digunakan proses lain';
	@override String get deleteTaskError => 'Gagal menghapus tugas';
	@override String get canNotRefreshVideoTask => 'Gagal menyegarkan tugas video';
	@override String get videoRemovedCanNotRefresh => 'Video ini telah dihapus atau tidak lagi ada, sehingga tautan unduhan tidak dapat disegarkan';
	@override String get videoInaccessibleCanNotRefresh => 'Video ini tidak dapat diakses, mungkin bersifat privat atau Anda perlu masuk lagi';
	@override String get videoQualityGone => 'Kualitas ini tidak lagi tersedia, silakan tambahkan unduhan lagi';
	@override String get refreshLinkNetworkFailed => 'Kesalahan jaringan, tautan unduhan tidak dapat disegarkan saat ini, silakan coba lagi nanti';
	@override String get taskAlreadyProcessing => 'Tugas sedang diproses';
	@override String get taskNotFound => 'Tugas tidak ditemukan';
	@override String get failedToLoadTasks => 'Gagal memuat tugas';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'Unduhan sebagian gagal: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Format gambar tidak didukung: ${extension}, Anda dapat mencoba mengunduhnya ke perangkat untuk melihatnya';
	@override String get imageLoadFailed => 'Gagal memuat gambar';
	@override String get pleaseTryOtherViewer => 'Silakan coba gunakan penampil lain untuk membuka';
}

// Path: download.timeline
class _TranslationsDownloadTimelineId extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get today => 'Hari ini';
	@override String get yesterday => 'Kemarin';
	@override String get thisWeek => 'Minggu ini';
	@override String get thisMonth => 'Bulan ini';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesId extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get network => 'Masalah jaringan, coba lagi mungkin membantu';
	@override String get serverRejected => 'Ditolak oleh server, Anda mungkin perlu masuk lagi';
	@override String get notFound => 'Sumber daya hilang atau telah dihapus';
	@override String get diskFull => 'Ruang penyimpanan tidak mencukupi';
	@override String get fileInUse => 'Berkas sedang digunakan oleh program lain';
	@override String get permission => 'Tidak ada izin menulis';
	@override String get cancelled => 'Dibatalkan';
	@override String get unknown => 'Kesalahan tidak diketahui';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedId extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => '${num} tugas yang belum selesai dari sesi terakhir telah dijeda';
	@override String get resume => 'Lanjutkan semua';
	@override String get dismiss => 'Tutup';
}

// Path: download.actions
class _TranslationsDownloadActionsId extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeId extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateId extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Hapus berdasarkan tanggal';
	@override String get dialogTitle => 'Hapus berdasarkan tanggal';
	@override String get description => 'Hapus tugas unduhan secara massal berdasarkan tanggal pembuatan. Tugas yang berkasnya sedang digunakan akan dilewati; tugas yang berkasnya sudah tidak ada akan dibersihkan.';
	@override String get modeRange => 'Rentang tanggal';
	@override String get modeDays => 'Lebih lama dari';
	@override String get startDate => 'Tanggal mulai';
	@override String get endDate => 'Tanggal akhir';
	@override String get notSet => 'Belum diatur';
	@override String get daysUnit => 'hari';
	@override String olderThanDaysHint({required Object days}) => 'Hapus tugas yang dibuat lebih dari ${days} hari lalu';
	@override String get noMatch => 'Tidak ada tugas yang cocok dengan kondisi yang dipilih';
	@override String get invalidRange => 'Tanggal mulai harus sama dengan atau sebelum tanggal akhir';
	@override String get confirmTitle => 'Konfirmasi penghapusan';
	@override String confirmContent({required Object count}) => 'Hapus ${count} tugas unduhan dan berkasnya? Tindakan ini tidak dapat dibatalkan.';
	@override String deleting({required Object done, required Object total}) => 'Menghapus ${done}/${total}…';
	@override String resultSuccess({required Object count}) => 'Menghapus ${count} tugas';
	@override String resultPartial({required Object deleted, required Object skipped}) => 'Menghapus ${deleted} tugas; ${skipped} dilewati (sedang digunakan)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationId extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryId extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Kelola kategori';
	@override String get label => 'Kategori';
	@override String get uncategorized => 'Tanpa Kategori';
	@override String get manage => 'Kelola';
	@override String get createShortcut => 'Baru';
	@override String get newCategoryHint => 'Nama kategori baru';
	@override String get createSuccess => 'Kategori dibuat';
	@override String get createFailed => 'Gagal membuat kategori';
	@override String get nameEmpty => 'Nama kategori tidak boleh kosong';
	@override String get emptyHint => 'Belum ada kategori. Buat satu untuk mengatur unduhan Anda.';
	@override String get moveTo => 'Pindahkan ke kategori';
	@override String moveToWithCount({required Object count}) => 'Pindahkan ${count} item ke…';
	@override String moveSuccess({required Object title}) => 'Dipindahkan ke ${title}';
	@override String get moveToUncategorizedSuccess => 'Dipindahkan ke Tanpa Kategori';
	@override String get moveFailed => 'Gagal memindahkan';
	@override String get renameTitle => 'Ganti nama kategori';
	@override String get renameHint => 'Masukkan nama kategori';
	@override String get renameSuccess => 'Nama kategori diubah';
	@override String get renameFailed => 'Gagal mengganti nama kategori';
	@override String get deleteTitle => 'Hapus kategori';
	@override String deleteConfirm({required Object title, required Object count}) => 'Hapus kategori "${title}"? ${count} item di dalamnya akan dipindahkan ke Tanpa Kategori. Tidak ada berkas yang dihapus.';
	@override String get deleteSuccess => 'Kategori dihapus';
	@override String get deleteFailed => 'Gagal menghapus kategori';
}

// Path: download.location
class _TranslationsDownloadLocationId extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadId extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unduhan Massal';
	@override String get downloadTaskAlreadyRunning => 'Tugas sedang berjalan, mohon tunggu.';
	@override String get userCancelled => 'Dibatalkan pengguna';
	@override String get failedToGetVideoInfo => 'Gagal mendapatkan informasi video';
	@override String get failedToGetVideoSource => 'Gagal mendapatkan sumber video';
	@override String get failedToGetGalleryInfo => 'Gagal mendapatkan informasi galeri';
	@override String get galleryNoImages => 'Galeri tidak memiliki gambar';
	@override String get failedToGetSavePath => 'Gagal mendapatkan jalur penyimpanan';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Unduhan massal gagal: ${exception}';
	@override String get selectQuality => 'Pilih Kualitas';
	@override String get downloading => 'Mengunduh';
	@override String get downloadResult => 'Hasil Unduhan';
	@override String selectedVideosCount({required Object count}) => 'Terpilih ${count} video';
	@override String selectedGalleriesCount({required Object count}) => 'Terpilih ${count} galeri';
	@override String get qualityNote => 'Jika kualitas yang dipilih tidak tersedia, kualitas terbaik yang tersedia akan digunakan';
	@override String progress({required Object current, required Object total}) => 'Memproses ${current}/${total}';
	@override String get queued => 'Dalam Antrean';
	@override String get success => 'Berhasil';
	@override String get skipped => 'Dilewati';
	@override String get failed => 'Gagal';
	@override String get failureDetails => 'Rincian Kegagalan';
	@override String get reasonPrivateVideo => 'Video privat';
	@override String get reasonAlreadyExists => 'Sudah ada';
	@override String get reasonNoSource => 'Tidak ada sumber unduhan';
	@override String get reasonNoSavePath => 'Tidak dapat mendapatkan jalur penyimpanan';
	@override String get reasonOther => 'Kesalahan lain';
	@override String get startDownload => 'Mulai Unduh';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsId extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'Gagal menambahkan';
	@override String get addSuccess => 'Berhasil ditambahkan';
	@override String get deleteFolderFailed => 'Gagal menghapus folder';
	@override String get deleteFolderSuccess => 'Berhasil menghapus folder';
	@override String get folderNameCannotBeEmpty => 'Nama folder tidak boleh kosong';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesId extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'OpenAI Penalaran (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Anthropic Claude Penalaran (pemikiran lanjutan)';
	@override String get gemini => 'Google Gemini (asli)';
	@override String get geminiReasoning => 'Google Gemini Penalaran (berpikir)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'DeepSeek Penalaran (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeId extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Pemberitahuan pemutaran: ${message}';
	@override String get networkUnstable => 'Periksa jaringan Anda; pemutaran mungkin tersendat';
	@override String get audioTrackUnavailable => 'Tidak ada suara; video terus diputar';
	@override String get hardwareDecodeFellBack => 'Beralih ke dekode perangkat lunak; mungkin lebih boros daya';
	@override String get videoDecodeProblem => 'Coba kualitas lain; gambar mungkin rusak';
	@override String get repeatedPlaybackProblems => 'Ekspor log untuk melaporkan masalah pemutaran yang berulang';
	@override String get issuesSheetTitle => 'Masalah pemutaran';
	@override String issueOccurrences({required Object count}) => 'Terjadi ${count} kali';
	@override String issueAtPosition({required Object position}) => 'Pada ${position}';
	@override String get noIssuesRecorded => 'Tidak ada masalah yang tercatat';
	@override String get exportLogsAction => 'Ekspor log';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertId extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Kegagalan flush';
	@override String get sinkDegradedTitle => 'Penulisan log menurun';
	@override String get sinkDegradedDetail => 'Sink berkas dalam kondisi menurun';
	@override String get queueBacklogTitle => 'Tumpukan antrean penulisan';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (ambang=${threshold}, dapat meningkatkan penggunaan memori)';
	@override String get highFlushLatencyTitle => 'Latensi flush tinggi';
	@override String get droppedTooManyTitle => 'Terlalu banyak log yang dijatuhkan';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (ambang=${threshold})';
	@override String get rateLimitedTitle => 'Pembatasan laju terpicu';
	@override String get exportFailedTitle => 'Kegagalan ekspor log';
	@override String get fileNearLimitTitle => 'Berkas log mendekati batas ukuran';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (tekanan rotasi IO lebih tinggi)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastId extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'Layanan log belum diinisialisasi';
	@override String get exportSuccess => 'Log diekspor. Harap tinjau data privasi sebelum mengirim melalui email.';
	@override String exportFailed({required Object error}) => 'Ekspor gagal: ${error}';
	@override String get supportEmailCopied => 'Email dukungan disalin. Tempelkan ke klien email Anda dan lampirkan log.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesId extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'Relevansi';
	@override String get latest => 'Terbaru';
	@override String get views => 'Tayangan';
	@override String get likes => 'Suka';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeId extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selamat Datang';
	@override String get subtitle => 'Mari mulai perjalanan penyiapan yang dipersonalisasi';
	@override String get description => 'Hanya beberapa langkah untuk menyesuaikan pengalaman terbaik bagi Anda';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicId extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Dasar';
	@override String get subtitle => 'Personalisasi pengalaman Anda';
	@override String get description => 'Pilih preferensi yang sesuai untuk Anda';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkId extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Jaringan';
	@override String get subtitle => 'Konfigurasikan opsi jaringan';
	@override String get description => 'Sesuaikan dengan lingkungan jaringan Anda';
	@override String get tip => 'Perlu dimulai ulang setelah konfigurasi berhasil agar berlaku';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeId extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Tema';
	@override String get subtitle => 'Pilih tampilan yang Anda sukai';
	@override String get description => 'Personalisasi pengalaman visual Anda';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerId extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan Pemutar';
	@override String get subtitle => 'Konfigurasikan kontrol pemutaran';
	@override String get description => 'Atur preferensi pemutaran yang umum digunakan dengan cepat';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialId extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pemutaran Spasial';
	@override String get subtitle => 'Menonton dan menelusuri di headset';
	@override String get description => 'Di headset, video dan galeri muncul di ruang sekitar Anda alih-alih di dalam panel melayang ini';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionId extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selesaikan Penyiapan';
	@override String get subtitle => 'Anda siap memulai perjalanan Anda';
	@override String get description => 'Silakan baca dan setujui perjanjian terkait';
	@override String get agreementTitle => 'Perjanjian Pengguna dan Aturan Komunitas';
	@override String get agreementDesc => 'Sebelum menggunakan aplikasi ini, harap baca dan setujui perjanjian pengguna serta aturan komunitas kami dengan saksama. Ketentuan ini membantu menjaga lingkungan yang baik.';
	@override String get checkboxTitle => 'Saya telah membaca dan menyetujui perjanjian pengguna dan aturan komunitas';
	@override String get checkboxSubtitle => 'Anda tidak dapat menggunakan aplikasi jika tidak setuju';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonId extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Pengaturan ini dapat diubah kapan saja di Pengaturan';
	@override String get previousStep => 'Langkah sebelumnya';
	@override String get nextStep => 'Langkah berikutnya';
	@override String get finishSetup => 'Selesaikan penyiapan';
	@override String get agreeAgreementSnackbar => 'Silakan setujui perjanjian pengguna dan aturan komunitas terlebih dahulu';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsId extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Kualitas Tinggi';
	@override String get fast => 'Cepat';
	@override String get lite => 'Ringan';
	@override String get moreLite => 'Lebih Ringan';
	@override String get custom => 'Kustom';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsId extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Cocok untuk sebagian besar animasi 1080p, terutama yang menghadapi blur, resampling, dan artefak kompresi. Memberikan kualitas persepsi tertinggi.';
	@override String get mode_b_hq => 'Cocok untuk animasi dengan blur ringan atau efek ringing akibat penskalaan. Dapat mengurangi ringing dan aliasing secara efektif.';
	@override String get mode_c_hq => 'Cocok untuk sumber berkualitas tinggi (seperti animasi 1080p asli atau film). Menghilangkan noise dan memberikan PSNR tertinggi.';
	@override String get mode_a_a_hq => 'Versi lanjutan Mode A, memberikan kualitas persepsi maksimal dan dapat merekonstruksi hampir semua garis yang rusak. Dapat menimbulkan penajaman berlebihan atau ringing.';
	@override String get mode_b_b_hq => 'Versi lanjutan Mode B, memberikan kualitas persepsi lebih tinggi, lebih mengoptimalkan garis dan mengurangi artefak.';
	@override String get mode_c_a_hq => 'Versi Mode C dengan kualitas persepsi yang ditingkatkan, mempertahankan PSNR tinggi sekaligus mencoba merekonstruksi sebagian detail garis.';
	@override String get mode_a_fast => 'Versi cepat Mode A, menyeimbangkan kualitas dan performa, cocok untuk sebagian besar animasi 1080p.';
	@override String get mode_b_fast => 'Versi cepat Mode B, untuk menangani artefak dan ringing ringan dengan beban lebih rendah.';
	@override String get mode_c_fast => 'Versi cepat Mode C, untuk penghilangan noise dan peningkatan resolusi sumber berkualitas tinggi secara cepat.';
	@override String get mode_a_a_fast => 'Versi cepat Mode A+A, mengejar kualitas persepsi lebih tinggi pada perangkat dengan performa terbatas.';
	@override String get mode_b_b_fast => 'Versi cepat Mode B+B, menyediakan perbaikan garis dan pemrosesan artefak yang ditingkatkan untuk perangkat dengan performa terbatas.';
	@override String get mode_c_a_fast => 'Versi cepat Mode C+A, memproses sumber berkualitas tinggi dengan cepat sekaligus memberikan perbaikan garis ringan.';
	@override String get upscale_only_s => 'Peningkatan resolusi x2 ultra cepat hanya dengan model CNN tercepat, tanpa perbaikan dan penghilangan noise, beban performa minimal.';
	@override String get upscale_deblur_fast => 'Peningkatan resolusi dan penghilangan blur secara cepat menggunakan algoritma tradisional non-CNN, lebih baik daripada algoritma pemutar bawaan dengan beban performa sangat rendah.';
	@override String get restore_s_only => 'Hanya perbaikan menggunakan model CNN tercepat, tanpa peningkatan resolusi. Cocok untuk pemutaran resolusi asli yang ingin ditingkatkan kualitasnya.';
	@override String get denoise_bilateral_fast => 'Penghilangan noise cepat menggunakan filter bilateral tradisional, sangat cepat, cocok untuk menangani noise ringan.';
	@override String get upscale_non_cnn => 'Peningkatan resolusi cepat menggunakan algoritma tradisional, beban performa sangat rendah, lebih baik daripada bawaan pemutar.';
	@override String get mode_a_fast_darken => 'Mode A (Cepat) + Penggelapan garis, menambahkan efek penggelapan garis pada mode A cepat untuk garis yang lebih menonjol dan bergaya.';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + Penipisan garis, menambahkan efek penipisan garis pada mode A kualitas tinggi untuk tampilan yang lebih halus.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesId extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'Peningkatan Resolusi CNN (Ultra Cepat)';
	@override String get upscale_deblur_fast => 'Peningkatan Resolusi & Penghilangan Blur (Cepat)';
	@override String get restore_s_only => 'Restorasi (Ultra Cepat)';
	@override String get denoise_bilateral_fast => 'Penghilangan Noise Bilateral (Ultra Cepat)';
	@override String get upscale_non_cnn => 'Peningkatan Resolusi Non-CNN (Ultra Cepat)';
	@override String get mode_a_fast_darken => 'Mode A (Cepat) + Penggelapan Garis';
	@override String get mode_a_hq_thin => 'Mode A (HQ) + Penipisan Garis';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseId extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Akses cepat';
	@override String get sourcesSection => 'Folder';
	@override String get pin => 'Tambahkan ke akses cepat';
	@override String get unpin => 'Hapus dari akses cepat';
	@override String get pinned => 'Ditambahkan ke akses cepat';
	@override String get unpinned => 'Dihapus dari akses cepat';
	@override String folderCount({required Object count}) => '${count} folder';
	@override String videoCount({required Object count}) => '${count} video';
	@override String imageCount({required Object count}) => '${count} gambar';
	@override String get emptyFolder => 'Folder ini kosong';
	@override String get videosSection => 'Video';
	@override String get imagesSection => 'Gambar';
	@override String get galleriesSection => 'Galeri';
	@override String get filterAll => 'Semua';
	@override String get searchInFolder => 'Cari di folder ini';
	@override String get searchHint => 'Cari berdasarkan nama';
	@override String get clearSearch => 'Hapus pencarian';
	@override String searchNoResult({required Object query}) => 'Tidak ada yang cocok dengan "${query}"';
	@override String viewAllFolders({required Object count}) => 'Lihat semua ${count} folder';
	@override String viewAllVideos({required Object count}) => 'Lihat semua ${count} video';
	@override String viewAllImages({required Object count}) => 'Lihat semua ${count} gambar';
	@override String viewAllGalleries({required Object count}) => 'Lihat semua ${count} galeri';
	@override String get location => 'Lokasi';
	@override String get sourceMissing => 'Sumber ini sudah hilang';
	@override String get notScannedYet => 'Folder ini belum dipindai';
	@override String get scanning => 'Membaca folder ini…';
	@override String get deleteFileTitle => 'Hapus berkas ini?';
	@override String deleteFileBody({required Object name}) => '"${name}" akan dihapus secara permanen dari perangkat ini. Tindakan ini tidak dapat dibatalkan.';
	@override String get hideFolder => 'Sembunyikan folder ini';
	@override String get unhideFolder => 'Tampilkan lagi';
	@override String get showHiddenFolders => 'Tampilkan folder tersembunyi';
	@override String get includeDotFolders => 'Pindai folder yang diawali .';
	@override String get dotFoldersIncluded => 'Folder yang diawali . sekarang dipindai';
	@override String get dotFoldersExcluded => 'Folder yang diawali . tidak lagi dipindai';
	@override String get showDotFolders => 'Tampilkan folder yang diawali .';
	@override String dotFoldersSkipped({required Object count}) => 'Ada ${count} folder yang diawali . di sini yang belum dipindai';
	@override String get scanDotFoldersAction => 'Aktifkan untuk sumber ini';
	@override String get otherAppsPrivateNotice => 'Sejak Android 11, tidak ada aplikasi yang dapat membaca file aplikasi lain di Android/data atau Android/obb, dan aplikasi ini tidak bisa mengakalinya. Unduh atau ekspor video ke folder publik seperti Download di aplikasi aslinya, lalu tambahkan folder itu di sini. Cache saat menonton biasanya terpecah-pecah dan tidak bisa diputar meski terbaca.';
	@override String get folderHidden => 'Disembunyikan — pemindaian juga akan melewatinya';
	@override String get folderUnhidden => 'Tidak lagi disembunyikan';
	@override String get hiddenFolderBadge => 'Tersembunyi';
	@override String get deleteFolder => 'Hapus folder';
	@override String get deleteFolderTitle => 'Hapus folder ini?';
	@override String deleteFolderBody({required Object name}) => '"${name}" beserta seluruh isinya akan dihapus permanen dari perangkat ini. Tindakan ini tidak bisa dibatalkan.';
	@override String get deleteFolderIncludesOthers => 'Berkas lain di dalamnya juga akan dihapus';
	@override String get folderDeleted => 'Folder dihapus';
	@override String get deleteFolderFailed => 'Gagal menghapus — tidak ada izin, atau ada berkas di dalamnya yang sedang dipakai';
	@override String get deleteGalleryTitle => 'Hapus galeri ini?';
	@override String deleteGalleryBody({required Object name}) => 'Catatan unduhan dan berkas gambar lokal "${name}" akan dihapus. Tindakan ini tidak dapat dibatalkan.';
	@override String get galleryResourceMissing => 'Berkas lokal sudah tidak ada. Catatan dibersihkan.';
	@override String get viewDownloadDetail => 'Lihat rincian unduhan';
	@override String get viewOnlineGallery => 'Lihat di situs web';
	@override String get pickFolderTitle => 'Pilih folder';
	@override String get useThisFolder => 'Gunakan folder ini';
	@override String get noSubfolders => 'Tidak ada subfolder di sini';
	@override String get storageRoot => 'Penyimpanan perangkat';
	@override String get homeFolder => 'Beranda';
	@override String get filesystemRoot => 'Akar sistem berkas';
	@override String get folderUnreadable => 'Folder ini tidak dapat dibaca';
	@override String get setCover => 'Atur sampul';
	@override String get setAsFolderCover => 'Gunakan sebagai sampul folder';
	@override String get folderCoverSet => 'Sampul folder diperbarui';
	@override String get setFolderCoverPick => 'Atur sampul…';
	@override String get restoreAutoCover => 'Pulihkan sampul otomatis';
	@override String get autoCoverRestored => 'Sampul otomatis dipulihkan';
	@override String get rescanFolder => 'Pindai ulang folder ini';
	@override String get coverPickerTitle => 'Pilih satu bingkai';
	@override String get folderCoverPickerTitle => 'Pilih sampul';
	@override String get coverPickerEmpty => 'Belum ada gambar di folder ini. Thumbnail video mungkin masih dibuat di latar belakang.';
	@override String get coverSaved => 'Sampul diperbarui';
	@override String get coverSaveFailed => 'Tidak dapat menyimpan sampul';
	@override String get coverUnavailable => 'Tidak ada bingkai video yang dapat dibaca dari berkas ini';
	@override String get deleted => 'Dihapus';
	@override String get deleteFailed => 'Tidak dapat menghapus — berkas mungkin sedang digunakan atau tidak dapat ditulis';
	@override String get openFolder => 'Buka';
	@override String get favorite => 'Tambahkan ke favorit';
	@override String get unfavorite => 'Hapus dari favorit';
	@override String get favorited => 'Ditambahkan ke favorit';
	@override String get unfavorited => 'Dihapus dari favorit';
	@override String get sortBy => 'Urutkan berdasarkan';
	@override String get sortAscending => 'Naik';
	@override String get sortDescending => 'Turun';
	@override String get sortFieldName => 'Nama';
	@override String get sortFieldModified => 'Tanggal diubah';
	@override String get sortFieldDuration => 'Durasi';
	@override String get sortFieldSize => 'Ukuran';
	@override String get sortFieldResolution => 'Resolusi';
	@override String get sortFieldFileType => 'Jenis berkas';
	@override String get sortFieldFps => 'Laju bingkai';
	@override String get sortFieldFavorited => 'Tanggal difavoritkan';
	@override String get emptyAllVideos => 'Belum ada video yang ditemukan. Tambahkan folder di bagian Folder untuk memulai.';
	@override String get emptyAllImages => 'Belum ada gambar yang ditemukan. Tambahkan folder di bagian Folder untuk memulai.';
	@override String get emptyFavorites => 'Belum ada favorit. Tambahkan satu dari menu ⋮ pada video.';
	@override String get emptyPinned => 'Belum ada folder yang disematkan. Tekan lama folder di bagian Folder lalu pilih Sematkan.';
	@override String get emptyDownloadedVideos => 'Belum ada unduhan video yang selesai.';
	@override String get emptyDownloadedGalleries => 'Belum ada unduhan galeri yang selesai.';
	@override String get folderInfo => 'Info folder';
	@override String get folderInfoName => 'Nama';
	@override String get folderInfoPath => 'Jalur';
	@override String get folderInfoSource => 'Sumber';
	@override String get folderInfoContents => 'Isi';
	@override String get folderInfoSize => 'Ukuran di disk';
	@override String get folderInfoScannedAt => 'Terakhir dipindai';
	@override String get folderInfoNeverScanned => 'Belum dipindai';
	@override String get folderInfoNoPath => 'Sumber ini tidak memiliki folder untuk dibuka';
	@override String get copyPath => 'Salin jalur';
	@override String get pathCopied => 'Jalur disalin';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsId extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingId extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavId extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorId extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Templat jalur';
	@override String get subtitle => 'Otomatis memilah unduhan ke subfolder';
	@override String get tabVideo => 'Video';
	@override String get tabGallery => 'Galeri';
	@override String get tabImage => 'Gambar tunggal';
	@override String get previewLabel => 'Pratinjau · hasil tersimpan sesungguhnya setelah pembersihan';
	@override String get galleryPreviewLabel => 'Pratinjau · templat galeri = nama folder (gambar dalam pakai ID gambar)';
	@override String get addFolder => 'Tambah satu tingkat folder';
	@override String get folderCapReached => 'Batas tingkat folder tercapai';
	@override String get folderSegmentHint => '%authorcache, variabel, atau teks tetap';
	@override String get fileSegmentHint => 'mis. %title_%quality';
	@override String videoCapNote({required Object max}) => 'Ekstensi (.mp4) ditambah otomatis · ketik / dalam segmen untuk membagi dua tingkat · maksimal ${max} tingkat';
	@override String imageCapNote({required Object max}) => 'Ekstensi asli ditambah otomatis · ketik / dalam segmen untuk membagi dua tingkat · maksimal ${max} tingkat';
	@override String galleryCapNote({required Object max}) => 'Templat galeri seluruhnya segmen folder, maksimal ${max} tingkat · gambar dalam memakai penamaan ID gambar';
	@override String get trayHint => 'Ketuk untuk menyisipkan di posisi kursor · tahan untuk keterangan';
	@override String get emptySegment => 'Segmen kosong';
	@override String get emptySegmentSaveBlocked => 'Tidak bisa menyimpan: ada segmen kosong, hapus atau isi dulu';
	@override String get tooManySegmentsSaveBlocked => 'Tidak bisa menyimpan: terlalu banyak segmen jalur (maks. 4). Gabungkan atau kurangi';
	@override String get templateInvalidSaveBlocked => 'Tidak bisa menyimpan: templat mengandung karakter tidak valid';
	@override String get variableInserted => 'Variabel disisipkan';
	@override String get savedToast => 'Tersimpan · hanya memengaruhi unduhan berikutnya';
	@override String get trayCategoryContent => 'Konten';
	@override String get trayCategoryAuthor => 'Penulis';
	@override String get trayCategoryTime => 'Waktu';
	@override String get chipAuthorcache => 'Nama penulis·tetap';
	@override String get chipDate => 'Tanggal';
	@override String get chipTime => 'Waktu';
	@override String get chipDatetime => 'Tanggal & waktu';
	@override String get chipCount => 'Indeks';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestId extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Nyaman di Quest';
	@override String get intro => 'Lihat kontrol mana yang melakukan apa, lalu cobalah di ruang Anda.';
	@override String get videoTab => 'Video spasial';
	@override String get galleryTab => 'Galeri spasial';
	@override String get scopeNote => 'Untuk layar dan jendela di ruang Quest Anda. Buka kembali kapan saja dari pengaturan pemutar.';
	@override String get catalog => 'Jelajahi kontrol';
	@override String lessonCount({required Object current, required Object total}) => '${current} dari ${total}';
	@override String get previous => 'Sebelumnya';
	@override String get next => 'Kontrol berikutnya';
	@override String get replay => 'Putar ulang demo';
	@override String get pauseDemo => 'Jeda demo';
	@override String get resumeDemo => 'Lanjutkan demo';
	@override String get looping => 'Demo kontrol';
	@override String get still => 'Ilustrasi diam';
	@override String get done => 'Mengerti, lanjutkan';
	@override String get leftController => 'Tangan kiri';
	@override String get rightController => 'Tangan kanan';
	@override String get trigger => 'Pemicu telunjuk';
	@override String get grip => 'Tombol pegangan';
	@override String get bothGrips => 'Kedua tombol pegangan';
	@override String get stick => 'Stik analog';
	@override String get handTracking => 'Pelacakan tangan';
	@override String get ready => 'Siap';
	@override String get press => 'Tekan';
	@override String get hold => 'Tahan';
	@override String get release => 'Lepaskan';
	@override String get result => 'Lihat hasilnya';
	@override String get pinch => 'Cubit';
	@override String get selectTitle => 'Arahkan dan pilih';
	@override String get selectBody => 'Arahkan sinar ke tombol, lalu tekan dan lepaskan pemicu telunjuk. Gunakan untuk memutar, pengaturan, dan penggeser di panel kontrol.';
	@override String get selectHint => 'Pemicu telunjuk berada di belakang permukaan tombol. Tombol pegangan pada gagang dalam berfungsi memegang jendela.';
	@override String get panelTitle => 'Tampilkan atau sembunyikan panel';
	@override String get panelBody => 'Arahkan ke luar panel kontrol, lalu ketuk pemicu telunjuk untuk menampilkan atau menyembunyikannya. Dengan pelacakan tangan, cubitan cepat di luar panel melakukan hal yang sama.';
	@override String get panelHint => 'Gunakan ketukan singkat tanpa menyeret. Menahan dan menggerakkan adalah seret, bukan mengalihkan panel.';
	@override String get playTitle => 'Putar dan jeda';
	@override String get playBody => 'Arahkan menjauh dari panel kontrol lalu tekan A di kanan atau X di kiri untuk memutar atau menjeda. Anda juga dapat memilih tombol putar di panel.';
	@override String get playHint => 'Pintasan bawaan ini dapat dinonaktifkan di pengaturan pemutar spasial. Saat mengarahkan ke panel, masukan akan masuk ke panel.';
	@override String get seekTitle => 'Geser dengan stik';
	@override String get seekBody => 'Geser salah satu stik ke kiri atau kanan untuk langkah 5 detik. Tahan untuk menggeser lebih cepat sambil mempratinjau waktu target. Lepaskan untuk menerapkan pencarian.';
	@override String get seekHint => 'Jauhkan sinar pengontrol itu dari panel kontrol. Stik yang mengarah ke panel akan menggulir panel sebagai gantinya.';
	@override String get browseTitle => 'Jelajahi dengan stik';
	@override String get browseBody => 'Gerakkan salah satu stik ke kiri atau kanan untuk item sebelumnya atau berikutnya; tahan untuk terus menjelajah. Anda juga dapat memilih gambar mini di strip film.';
	@override String get browseHint => 'Video dalam galeri juga merupakan item. Mengarahkan ke panel kontrol membuat stik menggulir panel.';
	@override String get swipeTitle => 'Seret melintasi untuk membalik halaman';
	@override String get swipeBody => 'Arahkan ke gambar, tahan pemicu telunjuk dan seret ke kiri. Lepaskan setelah isyarat balik halaman untuk maju; seret ke kanan untuk kembali. Cubit-lalu-seret juga berfungsi.';
	@override String get swipeHint => 'Gambar harus pada 1× untuk membalik halaman dengan menyeret. Video galeri juga mendukungnya. Panggung tetap diam hingga Anda melepaskan.';
	@override String get zoomTitle => 'Perbesar ke dalam gambar';
	@override String get zoomBody => 'Arahkan ke detail pada gambar, tahan pemicu telunjuk, lalu dorong stik ke atas untuk memperbesar atau ke bawah untuk memperkecil. Zoom berjangkar di tempat Anda menekan.';
	@override String get zoomHint => 'Ini memperbesar gambar di dalam jendelanya. Tanpa menahan gambar, atas/bawah menyesuaikan jarak pandang.';
	@override String get panTitle => 'Geser dan pulihkan gambar';
	@override String get panBody => 'Setelah diperbesar, tahan pemicu telunjuk dan seret untuk melihat sekeliling. Ketuk dua kali gambar untuk memperbesar ke 2,5× atau memulihkannya. Dengan tangan, cubit dua kali dengan cepat.';
	@override String get panHint => 'Menyeret akan menggeser gambar yang diperbesar. Pulihkan ke 1× sebelum menyeret untuk membalik halaman.';
	@override String get slideshowTitle => 'Mulai tayangan slide';
	@override String get slideshowBody => 'Pada gambar, A / X memulai atau menjeda tayangan slide. Panel menawarkan interval 3, 5, 10, atau 20 detik serta kualitas gambar standar atau asli.';
	@override String get slideshowHint => 'Pada video galeri, A / X mengontrol pemutaran video tersebut. Pintasan pengontrol harus diaktifkan di pengaturan.';
	@override String get moveTitle => 'Pegang dan pindahkan layar';
	@override String get moveBody => 'Tahan tombol pegangan pada gagang dalam, gerakkan pengontrol untuk memposisikan layar, lalu lepaskan. Saat menonton, Anda dapat memegang layar tanpa mengarahkannya.';
	@override String get moveHint => 'Mengarahkan ke jendela aplikasi atau panel kontrol akan memegang jendela itu terlebih dahulu. Pada video panoramik, memegang menyesuaikan orientasi.';
	@override String get scaleTitle => 'Ubah ukuran dengan kedua tangan';
	@override String get scaleBody => 'Tahan kedua tombol pegangan. Rentangkan tangan Anda untuk memperbesar layar, atau dekatkan untuk memperkecilnya. Dengan pelacakan tangan, tahan cubitan di kedua tangan.';
	@override String get scaleHint => 'Untuk layar datar atau melengkung, termasuk panggung galeri. Jauhkan sinar dari panel kontrol. Ini mengubah ukuran seluruh layar.';
	@override String get distanceTitle => 'Sesuaikan jarak pandang';
	@override String get distanceBody => 'Dorong stik ke atas untuk menjauhkan layar, atau ke bawah untuk mendekatkannya. Saat memegang jendela, atas/bawah memindahkan jendela itu. Sesuaikan volume di panel.';
	@override String get distanceHint => 'Arahkan menjauh dari panel kontrol. Menahan gambar mengubah atas/bawah menjadi zoom gambar; video panoramik menyesuaikan tampilan sebagai gantinya.';
	@override String get resizeTitle => 'Gunakan tepi dan sudut';
	@override String get resizeBody => 'Bingkai akan menyala saat sinar Anda mendekati tepi. Tahan pemicu atau cubit pada tepi untuk memindahkan jendela; seret sudut untuk mengubah ukurannya.';
	@override String get resizeHint => 'Berfungsi pada jendela aplikasi, panel kontrol, dan layar. Jendela aplikasi mengubah lebar dan tinggi; layar mempertahankan rasio aspeknya.';
	@override String get navigationTitle => 'Kembali dan buka pengaturan';
	@override String get navigationBody => 'B / Y kembali satu tingkat: menutup popup atau kembali ke beranda panel, menyembunyikan panel, lalu kembali ke aplikasi. Tombol Menu kiri membuka pengaturan spasial.';
	@override String get navigationHint => 'Tombol Meta kanan milik sistem. Pemusatan ulang sistem membawa tampilan kembali ke depan sambil mempertahankan ukuran dan jarak layar.';
	@override String get handsTitle => 'Gunakan tangan Anda';
	@override String get handsBody => 'Dengan pelacakan tangan aktif, arahkan sinar sistem ke tombol, cubit ibu jari dan telunjuk Anda, lalu lepaskan. Gunakan panel untuk pemutaran, pencarian, dan navigasi galeri.';
	@override String get handsHint => 'Cubit di luar untuk mengalihkan panel. Cubit tepi untuk memindahkan, sudut untuk mengubah ukuran, atau cubit dengan kedua tangan dan rentangkan untuk memperbesar layar.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesId extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Pemutar Media';
	@override String get mediaServer => 'Server Media';
	@override String get internetGatewayDevice => 'Router';
	@override String get basicDevice => 'Perangkat Dasar';
	@override String get dimmableLight => 'Lampu Pintar';
	@override String get wlanAccessPoint => 'Titik Akses WLAN';
	@override String get wlanConnectionDevice => 'Perangkat Koneksi WLAN';
	@override String get printer => 'Pencetak';
	@override String get scanner => 'Pemindai';
	@override String get digitalSecurityCamera => 'Kamera Keamanan Digital';
	@override String get unknownDevice => 'Perangkat Tidak Dikenal';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetId extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Penyiaran Jarak Jauh';
	@override String get close => 'Tutup';
	@override String get searchingDevices => 'Mencari perangkat...';
	@override String get searchPrompt => 'Klik tombol cari untuk mencari ulang perangkat penyiaran';
	@override String get searching => 'Mencari';
	@override String get searchAgain => 'Cari Lagi';
	@override String get noDevicesFound => 'Tidak ada perangkat penyiaran yang ditemukan\nPastikan perangkat berada di jaringan yang sama';
	@override String get searchingDevicesPrompt => 'Mencari perangkat, harap tunggu...';
	@override String get cast => 'Siarkan';
	@override String connectedTo({required Object deviceName}) => 'Terhubung ke: ${deviceName}';
	@override String get notConnected => 'Tidak ada perangkat terhubung';
	@override String get stopCasting => 'Hentikan Penyiaran';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsId {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Profil Pribadi',
			'personalProfile.editPersonalProfile' => 'Edit Profil Pribadi',
			'personalProfile.avatar' => 'Avatar',
			'personalProfile.background' => 'Latar Belakang',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'Gagal mengambil profil pengguna: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Resolusi yang disarankan: ${resolution}, ukuran file < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Format yang didukung: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Pengguna premium dapat menggunakan ${type} dinamis (${formats})',
			'personalProfile.homepageBackground' => 'Latar Belakang Halaman Utama',
			'personalProfile.basicInfo' => 'Informasi Dasar',
			'personalProfile.nickname' => 'Nama Panggilan',
			'personalProfile.username' => 'Nama Pengguna',
			'personalProfile.copyUsername' => 'Salin Nama Pengguna',
			'personalProfile.usernameCopied' => 'Nama pengguna disalin',
			'personalProfile.personalIntroduction' => 'Perkenalan Pribadi',
			'personalProfile.noPersonalIntroduction' => 'Tidak ada perkenalan pribadi',
			'personalProfile.clickToEdit' => 'Klik untuk mengedit',
			'personalProfile.privacySettings' => 'Pengaturan Privasi',
			'personalProfile.hideSensitiveContent' => 'Sembunyikan Konten Sensitif',
			'personalProfile.hideSensitiveContentDesc' => 'Sembunyikan video atau gambar yang mengandung tag sensitif.',
			'personalProfile.notificationSettings' => 'Pengaturan Notifikasi',
			'personalProfile.contentCommentNotification' => 'Notifikasi Komentar Konten',
			'personalProfile.contentCommentNotificationDesc' => 'Beri tahu saat seseorang mengomentari konten Anda.',
			'personalProfile.commentReplyNotification' => 'Notifikasi Balasan Komentar',
			'personalProfile.commentReplyNotificationDesc' => 'Beri tahu saat seseorang membalas komentar Anda.',
			'personalProfile.mentionNotification' => 'Notifikasi Sebutan',
			'personalProfile.mentionNotificationDesc' => 'Beri tahu saat seseorang menyebut Anda dalam konten.',
			'personalProfile.accountInfo' => 'Info Akun',
			'personalProfile.registrationTime' => 'Waktu Pendaftaran',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'Gagal memperbarui pengaturan: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'Gagal memperbarui pengaturan notifikasi: ${error}',
			'personalProfile.editNickname' => 'Edit Nama Panggilan',
			'personalProfile.nicknameCannotBeEmpty' => 'Nama panggilan tidak boleh kosong',
			'personalProfile.changeSuccess' => 'Perubahan berhasil',
			'personalProfile.unsupportedFileFormat' => 'Format file tidak didukung',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'Ukuran file tidak boleh melebihi ${size}',
			'personalProfile.uploadFailed' => 'Unggahan gagal',
			'personalProfile.avatarUpdatedSuccessfully' => 'Avatar berhasil diperbarui',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'Gagal memperbarui avatar: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Latar belakang berhasil diperbarui',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'Gagal memperbarui latar belakang: ${error}',
			'personalProfile.editPersonalIntroduction' => 'Edit Perkenalan Pribadi',
			'personalProfile.enterPersonalIntroduction' => 'Silakan masukkan perkenalan pribadi',
			'tutorial.specialFollowFeature' => 'Ikuti Khusus',
			'tutorial.specialFollowDescription' => 'Tandai penulis yang paling sering Anda tonton sebagai ikuti khusus, lalu langsung menuju unggahan terbaru mereka dari sini.',
			'tutorial.stepsTitle' => 'Tiga langkah',
			'tutorial.stepFollowAuthor' => 'Ketuk Ikuti pada video, galeri, atau halaman profil penulis.',
			'tutorial.stepPickSpecial' => 'Ketuk Mengikuti lagi, lalu pilih Ikuti Khusus dari menu.',
			'tutorial.stepSwitchHere' => 'Kembali ke sini dan beralih ke penulis itu menggunakan pemilih avatar di atas.',
			'tutorial.specialFollowManagementTip' => 'Kelola daftar ikuti khusus di Bilah Sisi - Daftar Mengikuti - Ikuti Khusus.',
			'tutorial.gotIt' => 'Mengerti',
			'common.sort' => 'Urutkan',
			'common.filter' => 'Filter',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Batal',
			'common.select' => 'Pilih',
			'common.save' => 'Simpan',
			'common.delete' => 'Hapus',
			'common.visit' => 'Kunjungi',
			'common.loading' => 'Memuat...',
			'common.scrollToTop' => 'Gulir ke Atas',
			'common.privacyHint' => 'Mode privasi aktif, konten disembunyikan',
			'common.latest' => 'Terbaru',
			'common.likesCount' => 'Suka',
			'common.viewsCount' => 'Dilihat',
			'common.popular' => 'Populer',
			'common.trending' => 'Sedang Tren',
			'common.commentList' => 'Daftar Komentar',
			'common.sendComment' => 'Kirim Komentar',
			'common.send' => 'Kirim',
			'common.retry' => 'Coba Lagi',
			'common.premium' => 'Premium',
			'common.follower' => 'Pengikut',
			'common.friend' => 'Teman',
			'common.video' => 'Video',
			'common.following' => 'Mengikuti',
			'common.expand' => 'Perluas',
			'common.collapse' => 'Ciutkan',
			'common.cancelFriendRequest' => 'Batalkan Permintaan',
			'common.cancelSpecialFollow' => 'Batalkan Ikuti Spesial',
			'common.addFriend' => 'Tambah Teman',
			'common.removeFriend' => 'Hapus Teman',
			'common.followed' => 'Diikuti',
			'common.follow' => 'Ikuti',
			'common.unfollow' => 'Berhenti Mengikuti',
			'common.specialFollow' => 'Ikuti Spesial',
			'common.specialFollowed' => 'Diikuti Spesial',
			'common.gallery' => 'Galeri',
			'common.playlist' => 'Daftar Putar',
			'common.commentPostedSuccessfully' => 'Komentar Berhasil Dikirim',
			'common.commentPostedFailed' => 'Gagal Mengirim Komentar',
			'common.success' => 'Berhasil',
			'common.commentDeletedSuccessfully' => 'Komentar Berhasil Dihapus',
			'common.commentUpdatedSuccessfully' => 'Komentar Berhasil Diperbarui',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} Komentar', other: '${n} Komentar', ), 
			'common.writeYourCommentHere' => 'Tulis komentar Anda di sini...',
			'common.tmpNoReplies' => 'Belum ada balasan',
			'common.loadMore' => 'Muat Lebih Banyak',
			'common.loadingMore' => 'Memuat lebih banyak...',
			'common.noMoreDatas' => 'Tidak ada data lagi',
			'common.selectTranslationLanguage' => 'Pilih Bahasa Terjemahan',
			'common.translate' => 'Terjemahkan',
			'common.translateFailedPleaseTryAgainLater' => 'Terjemahan gagal, silakan coba lagi nanti',
			'common.translationResult' => 'Hasil Terjemahan',
			'common.justNow' => 'Baru Saja',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} menit lalu', other: '${n} menit lalu', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} jam lalu', other: '${n} jam lalu', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} hari lalu', other: '${n} hari lalu', ), 
			'common.editedAt' => ({required Object num}) => '${num} diubah',
			'common.editComment' => 'Ubah Komentar',
			'common.commentUpdated' => 'Komentar Diperbarui',
			'common.replyComment' => 'Balas Komentar',
			'common.reply' => 'Balas',
			'common.edit' => 'Ubah',
			'common.unknownUser' => 'Pengguna Tidak Dikenal',
			'common.me' => 'Saya',
			'common.author' => 'Penulis',
			'common.admin' => 'Administrator',
			'common.viewReplies' => ({required Object num}) => 'Lihat Balasan (${num})',
			'common.hideReplies' => 'Sembunyikan Balasan',
			'common.confirmDelete' => 'Konfirmasi Hapus',
			'common.areYouSureYouWantToDeleteThisItem' => 'Apakah Anda yakin ingin menghapus item ini?',
			'common.tmpNoComments' => 'Belum ada komentar',
			'common.refresh' => 'Segarkan',
			'common.back' => 'Kembali',
			'common.tips' => 'Tips',
			'common.linkIsEmpty' => 'Tautan kosong',
			'common.linkCopiedToClipboard' => 'Tautan disalin ke papan klip',
			'common.imageCopiedToClipboard' => 'Gambar disalin ke papan klip',
			'common.copyImageFailed' => 'Gagal menyalin gambar',
			'common.mobileSaveImageIsUnderDevelopment' => 'Simpan gambar di ponsel masih dalam pengembangan',
			'common.imageSavedTo' => 'Gambar disimpan ke',
			'common.saveImageFailed' => 'Gagal menyimpan gambar',
			'common.close' => 'Tutup',
			'common.more' => 'Lainnya',
			'common.unknownError' => 'Kesalahan Tidak Diketahui',
			'common.moreFeaturesToBeDeveloped' => 'Fitur lainnya akan dikembangkan',
			'common.all' => 'Semua',
			'common.selectedRecords' => ({required Object num}) => 'Terpilih ${num} catatan',
			'common.cancelSelectAll' => 'Batalkan Pilih Semua',
			'common.selectAll' => 'Pilih Semua',
			'common.invertSelection' => 'Balik Pilihan',
			'common.exitEditMode' => 'Keluar dari Mode Edit',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => 'Apakah Anda yakin ingin menghapus ${num} item yang dipilih?',
			'common.searchHistoryRecords' => 'Cari Catatan Riwayat...',
			'common.settings' => 'Pengaturan',
			'common.subscriptions' => 'Langganan',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} video', other: '${n} video', ), 
			'common.share' => 'Bagikan',
			'common.areYouSureYouWantToShareThisPlaylist' => 'Apakah Anda yakin ingin membagikan daftar putar ini?',
			'common.editTitle' => 'Ubah Judul',
			'common.editMode' => 'Mode Edit',
			'common.pleaseEnterNewTitle' => 'Silakan masukkan judul baru',
			'common.createPlayList' => 'Buat Daftar Putar',
			'common.create' => 'Buat',
			'common.checkNetworkSettings' => 'Periksa Pengaturan Jaringan',
			'common.general' => 'Umum',
			'common.r18' => 'R18',
			'common.sensitive' => 'Sensitif',
			'common.year' => 'Tahun',
			'common.month' => 'Bulan',
			'common.tag' => 'Tag',
			'common.private' => 'Privat',
			'common.noTitle' => 'Tanpa Judul',
			'common.search' => 'Cari',
			'common.noContent' => 'Tidak ada konten',
			'common.recording' => 'Merekam',
			'common.paused' => 'Dijeda',
			'common.clear' => 'Bersihkan',
			'common.clearSelection' => 'Bersihkan Pilihan',
			'common.selectItemsToContinue' => 'Pilih item untuk melanjutkan',
			'common.andMoreItems' => ({required Object num}) => 'dan ${num} lainnya',
			'common.batchDelete' => 'Hapus Massal',
			'common.user' => 'Pengguna',
			'common.post' => 'Postingan',
			'common.seconds' => 'Detik',
			'common.comingSoon' => 'Segera Hadir',
			'common.confirm' => 'Konfirmasi',
			'common.hour' => 'Jam',
			'common.minute' => 'Menit',
			'common.clickToRefresh' => 'Klik untuk Menyegarkan',
			'common.history' => 'Riwayat',
			'common.favorites' => 'Favorit',
			'common.friends' => 'Teman',
			'common.playList' => 'Daftar Putar',
			'common.checkLicense' => 'Periksa Lisensi',
			'common.logout' => 'Keluar',
			'common.fensi' => 'Penggemar',
			'common.accept' => 'Terima',
			'common.reject' => 'Tolak',
			'common.clearAllHistory' => 'Bersihkan Semua Riwayat',
			'common.clearAllHistoryConfirm' => 'Apakah Anda yakin ingin membersihkan semua riwayat?',
			'common.followingList' => 'Daftar Mengikuti',
			'common.followersList' => 'Daftar Pengikut',
			'common.follows' => 'Mengikuti',
			'common.fans' => 'Penggemar',
			'common.followsAndFans' => 'Mengikuti dan Penggemar',
			'common.numViews' => 'Dilihat',
			'common.updatedAt' => 'Diperbarui Pada',
			'common.publishedAt' => 'Diterbitkan Pada',
			'common.externalVideo' => 'Video Eksternal',
			'common.originalText' => 'Teks Asli',
			'common.showOriginalText' => 'Tampilkan Teks Asli',
			'common.showProcessedText' => 'Tampilkan Teks Hasil Olahan',
			'common.preview' => 'Pratinjau',
			'common.rules' => 'Aturan',
			'common.agree' => 'Setuju',
			'common.disagree' => 'Tidak Setuju',
			'common.agreeToRules' => 'Setujui Aturan',
			'common.markdownSyntaxHelp' => 'Bantuan Sintaks Markdown',
			'common.previewContent' => 'Pratinjau Konten',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Melebihi batas panjang maksimum (${max})',
			'common.agreeToCommunityRules' => 'Setujui Aturan Komunitas',
			'common.createPost' => 'Buat Postingan',
			'common.title' => 'Judul',
			'common.enterTitle' => 'Silakan masukkan judul',
			'common.content' => 'Konten',
			'common.enterContent' => 'Silakan masukkan konten',
			'common.writeYourContentHere' => 'Silakan masukkan konten...',
			'common.tagBlacklist' => 'Daftar Hitam Tag',
			'common.noData' => 'Tidak ada data',
			'common.tagLimit' => 'Batas Tag',
			'common.enableFloatingButtons' => 'Aktifkan Tombol Melayang',
			'common.disableFloatingButtons' => 'Nonaktifkan Tombol Melayang',
			'common.enabledFloatingButtons' => 'Tombol Melayang Diaktifkan',
			'common.disabledFloatingButtons' => 'Tombol Melayang Dinonaktifkan',
			'common.pendingCommentCount' => 'Jumlah Komentar Tertunda',
			'common.joined' => ({required Object str}) => 'Bergabung pada ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Terakhir dilihat ${str}',
			'common.download' => 'Unduh',
			'common.selectQuality' => 'Pilih Kualitas',
			'common.videoQualitySource' => 'Sumber',
			'common.selectImageQuality' => 'Pilih kualitas gambar',
			'common.imageQualityStandard' => 'Standar',
			'common.imageQualityOriginal' => 'Asli',
			'common.selectDateRange' => 'Pilih Rentang Tanggal',
			'common.selectDateRangeHint' => 'Pilih rentang tanggal, bawaan adalah 30 hari terakhir',
			'common.clearDateRange' => 'Bersihkan Rentang Tanggal',
			'common.deleteRecordsInDateRange' => 'Hapus Catatan dalam Rentang Ini',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => 'Apakah Anda yakin ingin menghapus ${num} catatan riwayat dalam rentang tanggal ini? Tindakan ini tidak dapat dibatalkan.',
			'common.noHistoryRecordsInRange' => 'Tidak ada catatan riwayat dalam rentang tanggal ini',
			'common.followSuccessClickAgainToSpecialFollow' => 'Berhasil diikuti, klik lagi untuk mengikuti spesial',
			'common.specialFollowTip' => 'Ditambahkan ke ikuti spesial — pilih mereka dari pemilih di kanan atas halaman Langganan untuk akses cepat',
			'common.exitConfirmTip' => 'Apakah Anda yakin ingin keluar?',
			'common.error' => 'Kesalahan',
			'common.taskRunning' => 'Tugas sedang berjalan, mohon tunggu.',
			'common.operationCancelled' => 'Operasi dibatalkan.',
			'common.unsavedChanges' => 'Anda memiliki perubahan yang belum disimpan',
			'common.specialFollowsManagementTip' => 'Seret gagang untuk mengurutkan ulang • Ketuk tombol untuk menghapus',
			'common.specialFollowsManagement' => 'Pengelolaan Ikuti Spesial',
			'common.removeSpecialFollow' => 'Hapus ikuti spesial',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => 'Hapus ${name} dari ikuti spesial?',
			'common.noSpecialFollows' => 'Belum ada ikuti spesial',
			'common.createTimeDesc' => 'Waktu Dibuat Turun',
			'common.createTimeAsc' => 'Waktu Dibuat Naik',
			'common.pagination.totalItems' => ({required Object num}) => 'Total ${num} item',
			'common.pagination.jumpToPage' => 'Lompat ke halaman',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Silakan masukkan nomor halaman (1-${max})',
			'common.pagination.pageNumber' => 'Nomor halaman',
			'common.pagination.jump' => 'Lompat',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Silakan masukkan nomor halaman yang valid (1-${max})',
			'common.pagination.invalidInput' => 'Silakan masukkan nomor halaman yang valid',
			'common.pagination.waterfall' => 'Waterfall',
			'common.pagination.pagination' => 'Paginasi',
			'common.notice' => 'Pengumuman',
			'common.detail' => 'Rincian',
			'common.parseExceptionDestopHint' => ' - Pengguna desktop dapat mengonfigurasi proxy di pengaturan',
			'common.iwaraTags' => 'Tag Iwara',
			'common.tagInfo' => 'Info Tag',
			'common.tagOriginalKey' => 'Tag Asli',
			'common.tagTranslation' => 'Terjemahan',
			'common.copy' => 'Salin',
			'common.selectCopy' => 'Pilih & Salin',
			'common.copiedToClipboard' => 'Disalin ke papan klip',
			'common.showOriginalTag' => 'Tampilkan Tag Asli',
			'common.showTranslatedTag' => 'Tampilkan Terjemahan',
			'common.tagTranslationFeedback' => 'Ragu dengan terjemahannya? Beri masukan',
			'common.tagLocalizationGuideTitle' => 'Tentang Lokalisasi Tag',
			'common.tagLocalizationGuideContent' => 'Aplikasi menampilkan tag mentah Iwara (mis. mother) menggunakan nama dalam bahasa Anda saat ini.\n\n• Saat mencari tag, baik terjemahan maupun tag asli akan cocok.\n• Tekan lama / klik kanan pada tag untuk melihat dan menyalin kunci asli serta terjemahannya.\n• Terjemahan dikelola komunitas dan bersifat upaya terbaik — dapat mengandung kesalahan.',
			'common.likeThisVideo' => 'Sukai Video Ini',
			'common.likeThisGallery' => 'Sukai Galeri Ini',
			'common.operation' => 'Operasi',
			'common.replies' => 'Balasan',
			'common.externalLinkWarning' => 'Peringatan Tautan Eksternal',
			'common.externalLinkWarningMessage' => 'Anda akan membuka tautan eksternal yang bukan bagian dari iwara.tv. Harap berhati-hati dan pastikan tautan tersebut aman sebelum melanjutkan.',
			'common.continueToExternalLink' => 'Lanjutkan',
			'common.cancelExternalLink' => 'Batal',
			'auth.login' => 'Masuk',
			'auth.logout' => 'Keluar',
			'auth.email' => 'Alamat Email',
			'auth.password' => 'Kata Sandi',
			'auth.loginOrRegister' => 'Masuk / Daftar',
			'auth.register' => 'Daftar',
			'auth.pleaseEnterEmail' => 'Silakan masukkan email',
			'auth.pleaseEnterPassword' => 'Silakan masukkan kata sandi',
			'auth.passwordMustBeAtLeast6Characters' => 'Kata sandi minimal 6 karakter',
			'auth.pleaseEnterCaptcha' => 'Silakan masukkan captcha',
			'auth.captcha' => 'Kode Captcha',
			'auth.refreshCaptcha' => 'Muat Ulang Captcha',
			'auth.captchaNotLoaded' => 'Captcha belum dimuat',
			'auth.loginSuccess' => 'Berhasil Masuk',
			'auth.loginSuccessProfilePending' => 'Sudah masuk. Memuat profil Anda…',
			'auth.emailVerificationSent' => 'Email verifikasi telah dikirim',
			'auth.notLoggedIn' => 'Belum Masuk',
			'auth.clickToLogin' => 'Klik untuk Masuk',
			'auth.logoutConfirmation' => 'Apakah Anda yakin ingin keluar?',
			'auth.logoutSuccess' => 'Berhasil Keluar',
			'auth.logoutFailed' => 'Gagal Keluar',
			'auth.usernameOrEmail' => 'Nama Pengguna atau Email',
			'auth.pleaseEnterUsernameOrEmail' => 'Silakan masukkan nama pengguna atau email',
			'auth.rememberMe' => 'Ingat Nama Pengguna',
			'auth.registerNoticeTitle' => 'Daftar di situs web resmi',
			'auth.registerNoticeDescription' => 'Pendaftaran di dalam aplikasi tidak lagi tersedia. Silakan buka situs web resmi Iwara untuk membuat akun, lalu kembali ke sini untuk masuk.',
			'auth.registerNoticeReturnTip' => 'Setelah mendaftar, kembali ke sini dan masuk dengan akun Anda.',
			'auth.goToOfficialWebsite' => 'Buka situs web resmi',
			'errors.error' => 'Kesalahan',
			'errors.required' => 'Kolom ini wajib diisi',
			'errors.invalidEmail' => 'Alamat email tidak valid',
			'errors.networkError' => 'Kesalahan jaringan, silakan coba lagi',
			'errors.errorWhileFetching' => 'Kesalahan saat mengambil data',
			'errors.commentCanNotBeEmpty' => 'Isi komentar tidak boleh kosong',
			'errors.errorWhileFetchingReplies' => 'Kesalahan saat mengambil balasan, silakan periksa koneksi jaringan',
			'errors.canNotFindCommentController' => 'Tidak dapat menemukan pengendali komentar',
			'errors.errorWhileLoadingGallery' => 'Kesalahan saat memuat galeri',
			'errors.howCouldThereBeNoDataItCantBePossible' => 'Bagaimana bisa tidak ada data? Ini tidak mungkin :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Format gambar tidak didukung: ${str}',
			'errors.invalidGalleryId' => 'ID galeri tidak valid',
			'errors.translationFailedPleaseTryAgainLater' => 'Terjemahan gagal, silakan coba lagi nanti',
			'errors.errorOccurred' => 'Terjadi kesalahan, silakan coba lagi nanti.',
			'errors.errorOccurredWhileProcessingRequest' => 'Terjadi kesalahan saat memproses permintaan',
			'errors.errorWhileFetchingDatas' => 'Kesalahan saat mengambil data, silakan coba lagi nanti',
			'errors.serviceNotInitialized' => 'Layanan belum diinisialisasi',
			'errors.unknownType' => 'Jenis tidak diketahui',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Kesalahan saat membuka tautan: ${link}',
			'errors.invalidUrl' => 'URL tidak valid',
			'errors.failedToOperate' => 'Gagal melakukan operasi',
			'errors.permissionDenied' => 'Izin Ditolak',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'Anda tidak memiliki izin untuk mengakses sumber daya ini',
			'errors.loginFailed' => 'Gagal Masuk',
			'errors.unknownError' => 'Kesalahan Tidak Diketahui',
			'errors.sessionExpired' => 'Sesi Telah Berakhir',
			'errors.failedToFetchCaptcha' => 'Gagal mengambil captcha',
			'errors.emailAlreadyExists' => 'Email sudah terdaftar',
			'errors.invalidCaptcha' => 'Captcha tidak valid',
			'errors.registerFailed' => 'Gagal Daftar',
			'errors.failedToFetchComments' => 'Gagal mengambil komentar',
			'errors.failedToFetchImageDetail' => 'Gagal mengambil rincian gambar',
			'errors.failedToFetchImageList' => 'Gagal mengambil daftar gambar',
			'errors.failedToFetchData' => 'Gagal mengambil data',
			'errors.invalidParameter' => 'Parameter tidak valid',
			'errors.pleaseLoginFirst' => 'Silakan masuk terlebih dahulu',
			'errors.errorWhileLoadingPost' => 'Kesalahan saat memuat postingan',
			'errors.errorWhileLoadingPostDetail' => 'Kesalahan saat memuat rincian postingan',
			'errors.invalidPostId' => 'ID postingan tidak valid',
			'errors.forceUpdateNotPermittedToGoBack' => 'Saat ini dalam status pembaruan wajib, tidak dapat kembali',
			'errors.pleaseLoginAgain' => 'Silakan masuk lagi',
			'errors.invalidLogin' => 'Login tidak valid, silakan periksa email dan kata sandi Anda',
			'errors.tooManyRequests' => 'Terlalu banyak permintaan, silakan coba lagi nanti',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Melebihi panjang maksimum: ${max}',
			'errors.contentCanNotBeEmpty' => 'Konten tidak boleh kosong',
			'errors.titleCanNotBeEmpty' => 'Judul tidak boleh kosong',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Terlalu banyak permintaan, silakan coba lagi nanti, tersisa',
			'errors.remainingHours' => ({required Object num}) => '${num} jam',
			'errors.remainingMinutes' => ({required Object num}) => '${num} menit',
			'errors.remainingSeconds' => ({required Object num}) => '${num} detik',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Batas tag terlampaui, batas: ${limit}',
			'errors.failedToRefresh' => 'Gagal menyegarkan',
			'errors.noPermission' => 'Tidak ada izin',
			'errors.resourceNotFound' => 'Sumber daya tidak ditemukan',
			'errors.failedToSaveCredentials' => 'Gagal menyimpan kredensial login',
			'errors.failedToLoadSavedCredentials' => 'Gagal memuat kredensial yang tersimpan',
			'errors.notFound' => 'Konten tidak ditemukan atau telah dihapus',
			'errors.network.basicPrefix' => 'Kesalahan jaringan - ',
			'errors.network.failedToConnectToServer' => 'Gagal terhubung ke server',
			'errors.network.serverNotAvailable' => 'Server tidak tersedia',
			'errors.network.requestTimeout' => 'Permintaan habis waktu',
			'errors.network.unexpectedError' => 'Kesalahan tak terduga',
			'errors.network.invalidResponse' => 'Respons tidak valid',
			'errors.network.invalidRequest' => 'Permintaan tidak valid',
			'errors.network.invalidUrl' => 'URL tidak valid',
			'errors.network.invalidMethod' => 'Metode tidak valid',
			'errors.network.invalidHeader' => 'Header tidak valid',
			'errors.network.invalidBody' => 'Isi permintaan tidak valid',
			'errors.network.invalidStatusCode' => 'Kode status tidak valid',
			'errors.network.serverError' => 'Kesalahan server',
			'errors.network.requestCanceled' => 'Permintaan dibatalkan',
			'errors.network.invalidPort' => 'Port tidak valid',
			'errors.network.proxyPortError' => 'Kesalahan port proxy',
			'errors.network.connectionRefused' => 'Koneksi ditolak',
			'errors.network.networkUnreachable' => 'Jaringan tidak dapat dijangkau',
			'errors.network.noRouteToHost' => 'Tidak ada rute ke host',
			'errors.network.connectionFailed' => 'Koneksi gagal',
			'errors.network.sslConnectionFailed' => 'Koneksi SSL gagal, silakan periksa pengaturan jaringan Anda',
			'friends.clickToRestoreFriend' => 'Klik untuk memulihkan teman',
			'friends.friendsList' => 'Daftar Teman',
			'friends.friendRequests' => 'Permintaan Pertemanan',
			'friends.friendRequestsList' => 'Daftar Permintaan Pertemanan',
			'friends.removingFriend' => 'Menghapus teman...',
			'friends.failedToRemoveFriend' => 'Gagal menghapus teman',
			'friends.cancelingRequest' => 'Membatalkan permintaan pertemanan...',
			'friends.failedToCancelRequest' => 'Gagal membatalkan permintaan pertemanan',
			'authorProfile.noMoreDatas' => 'Tidak ada data lagi',
			'authorProfile.userProfile' => 'Profil Pengguna',
			'favorites.clickToRestoreFavorite' => 'Klik untuk memulihkan favorit',
			'favorites.myFavorites' => 'Favorit Saya',
			'favorites.batchCancelFavorite' => 'Hapus favorit yang dipilih',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => 'Hapus ${count} item yang dipilih dari favorit? Anda dapat memulihkannya dengan mengetuk kartunya setelah itu.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => 'Menghapus ${count} item dari favorit',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => 'Menghapus ${success} item, ${failed} gagal',
			'galleryDetail.browseInSpace' => 'Telusuri di ruang',
			'galleryDetail.galleryDetail' => 'Rincian Galeri',
			'galleryDetail.viewGalleryDetail' => 'Lihat Rincian Galeri',
			'galleryDetail.zoomReset' => 'Atur ulang zoom',
			'galleryDetail.copyLink' => 'Salin Tautan',
			'galleryDetail.copyImage' => 'Salin Gambar',
			'galleryDetail.saveAs' => 'Simpan Sebagai',
			'galleryDetail.saveToAlbum' => 'Simpan ke Album',
			'galleryDetail.publishedAt' => 'Diterbitkan Pada',
			'galleryDetail.viewsCount' => 'Jumlah Dilihat',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Pengenalan Fungsi Pustaka Gambar',
			'galleryDetail.rightClickToSaveSingleImage' => 'Klik Kanan untuk Menyimpan Satu Gambar',
			'galleryDetail.batchSave' => 'Simpan Massal',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Tombol Kiri dan Kanan untuk Berganti',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Tombol Atas dan Bawah untuk Zoom',
			'galleryDetail.mouseWheelToSwitch' => 'Roda Mouse untuk Berganti',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + Roda Mouse untuk Zoom',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'Fitur Lainnya untuk Ditemukan...',
			'galleryDetail.authorOtherGalleries' => 'Galeri Lain dari Penulis',
			'galleryDetail.relatedGalleries' => 'Galeri Terkait',
			'galleryDetail.authorNoOtherGalleries' => 'Tidak ada galeri lain dari penulis ini',
			'galleryDetail.noRelatedGalleries' => 'Tidak ada galeri terkait',
			'galleryDetail.scrollLeft' => 'Gulir ke kiri',
			'galleryDetail.scrollRight' => 'Gulir ke kanan',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Klik Tepi Kiri dan Kanan untuk Berganti Gambar',
			'galleryDetail.rotateToLandscape' => 'Layar Penuh Lanskap',
			'galleryDetail.backToPortrait' => 'Kembali ke Potret',
			'playList.myPlayList' => 'Daftar Putar Saya',
			'playList.friendlyTips' => 'Tips Berguna',
			'playList.dearUser' => 'Pengguna yang Terhormat',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'sistem daftar putar Iwara belum sempurna',
			'playList.notSupportSetCover' => 'Tidak mendukung mengatur sampul',
			'playList.notSupportDeleteList' => 'Tidak mendukung menghapus daftar',
			'playList.notSupportSetPrivate' => 'Tidak mendukung mengatur privat',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Ya... daftar yang dibuat akan selalu ada dan terlihat oleh semua orang',
			'playList.smallSuggestion' => 'Saran Kecil',
			'playList.useLikeToCollectContent' => 'Jika Anda lebih mementingkan privasi, disarankan menggunakan fungsi "suka" untuk mengumpulkan konten',
			'playList.welcomeToDiscussOnGitHub' => 'Jika Anda memiliki saran atau ide lain, silakan berdiskusi di GitHub!',
			'playList.iUnderstand' => 'Saya Mengerti',
			'playList.searchPlaylists' => 'Cari Daftar Putar...',
			'playList.newPlaylistName' => 'Nama Daftar Putar Baru',
			'playList.createNewPlaylist' => 'Buat Daftar Putar Baru',
			'playList.videos' => 'Video',
			'search.googleSearchScope' => 'Cakupan Pencarian',
			'search.searchTags' => 'Cari Tag...',
			'search.contentRating' => 'Peringkat Konten',
			'search.removeTag' => 'Hapus Tag',
			'search.pleaseEnterSearchContent' => 'Silakan masukkan konten pencarian',
			'search.searchHistory' => 'Riwayat Pencarian',
			'search.searchSuggestion' => 'Saran Pencarian',
			'search.usedTimes' => 'Jumlah Penggunaan',
			'search.lastUsed' => 'Terakhir Digunakan',
			'search.noSearchHistoryRecords' => 'Tidak ada riwayat pencarian',
			'search.clearSearchHistoryConfirm' => 'Apakah Anda yakin ingin menghapus semua riwayat pencarian? Tindakan ini tidak dapat dibatalkan.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Tidak mendukung jenis pencarian saat ini ${searchType}, silakan tunggu pembaruan',
			'search.searchResult' => 'Hasil Pencarian',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Jenis pencarian tidak didukung: ${searchType}',
			'search.googleSearch' => 'Penelusuran Google',
			'search.googleSearchHint' => ({required Object webName}) => 'Fungsi pencarian ${webName} kurang mudah digunakan? Coba Penelusuran Google!',
			'search.googleSearchDescription' => 'Gunakan operator pencarian :site dari Penelusuran Google untuk mencari konten di situs. Ini sangat berguna saat mencari video, galeri, daftar putar, dan pengguna.',
			'search.googleSearchKeywordsHint' => 'Masukkan kata kunci untuk mencari',
			'search.openLinkJump' => 'Buka Tautan Eksternal',
			'search.googleSearchButton' => 'Penelusuran Google',
			'search.pleaseEnterSearchKeywords' => 'Silakan masukkan kata kunci pencarian',
			'search.googleSearchQueryCopied' => 'Kueri pencarian disalin ke papan klip',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'Gagal membuka peramban: ${error}',
			'search.searchRequestTimeout' => 'Permintaan habis waktu, silakan coba lagi nanti',
			'search.searchCannotConnectToServer' => 'Tidak dapat terhubung ke server, silakan periksa koneksi jaringan Anda',
			'search.searchNetworkError' => 'Koneksi jaringan gagal, silakan periksa pengaturan jaringan Anda atau coba lagi nanti',
			'search.searchFailedPleaseRetry' => 'Pencarian gagal, silakan coba lagi nanti',
			'mediaList.personalIntroduction' => 'Perkenalan',
			'settings.listViewMode' => 'Mode Tampilan Daftar',
			'settings.previewEffect' => 'Efek Pratinjau',
			'settings.useTraditionalPaginationMode' => 'Gunakan Mode Penomoran Halaman Tradisional',
			'settings.useTraditionalPaginationModeDesc' => 'Aktifkan mode penomoran halaman tradisional, nonaktifkan mode air terjun. Berlaku setelah merender ulang halaman atau memulai ulang aplikasi',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Tampilkan Bilah Kemajuan Video Saat Bilah Alat Disembunyikan',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Konfigurasi ini menentukan apakah bilah kemajuan video bawah akan ditampilkan saat bilah alat disembunyikan.',
			'settings.seekPreviewSize' => 'Ukuran Pratinjau Pencarian',
			'settings.seekPreviewSizeDesc' => 'Seberapa besar jendela pratinjau di atas bilah kemajuan. Jendela sudah mengikuti ukuran pemutar dan rasio aspek video; ini hanya menyempurnakannya.',
			'settings.seekPreviewSizeSmall' => 'Kecil',
			'settings.seekPreviewSizeStandard' => 'Standar',
			'settings.seekPreviewSizeLarge' => 'Besar',
			'settings.seekPreviewSizeStandardDesc' => 'Ukuran yang diturunkan dari pemutar dan video',
			'settings.showFullscreenUpNextHint' => 'Tampilkan gagang "Berikutnya"',
			'settings.showFullscreenUpNextHintDesc' => 'Menampilkan gagang kecil di tepi kanan pemutar yang membuka laci antrean (sumber / daftar putar / tonton nanti). Tidak ada cara lain untuk masuk setelah ini dinonaktifkan.',
			'settings.basicSettings' => 'Pengaturan Dasar',
			'settings.personalizedSettings' => 'Pengaturan yang Dipersonalisasi',
			'settings.otherSettings' => 'Pengaturan Lain',
			'settings.searchConfig' => 'Konfigurasi Pencarian',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Konfigurasi ini menentukan apakah konfigurasi sebelumnya akan digunakan saat memutar video lagi.',
			'settings.playControl' => 'Kontrol Pemutaran',
			'settings.playbackSpeedSettings' => 'Pemutaran & Kecepatan',
			'settings.playbackBehaviorSettings' => 'Perilaku Pemutaran',
			'settings.enhancementSettings' => 'Teater & Peningkatan',
			'settings.fastForwardTime' => 'Waktu Maju Cepat',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'Waktu maju cepat harus berupa bilangan bulat positif.',
			'settings.rewindTime' => 'Waktu Mundur',
			'settings.rewindTimeMustBeAPositiveInteger' => 'Waktu mundur harus berupa bilangan bulat positif.',
			'settings.longPressPlaybackSpeed' => 'Kecepatan Pemutaran Tekan Lama',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'Kecepatan pemutaran tekan lama harus berupa angka positif.',
			'settings.defaultPlaybackSpeed' => 'Kecepatan Pemutaran Bawaan',
			_ => null,
		} ?? switch (path) {
			'settings.rememberPlaybackSpeed' => 'Ingat Kecepatan Pemutaran',
			'settings.rememberPlaybackSpeedDesc' => 'Saat diaktifkan, kecepatan yang Anda atur di pemutar disimpan sebagai bawaan dan diterapkan secara otomatis ke video baru.',
			'settings.repeat' => 'Ulangi',
			'settings.renderVerticalVideoInVerticalScreen' => 'Tampilkan Video Vertikal di Layar Vertikal',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Konfigurasi ini menentukan apakah video akan ditampilkan di layar vertikal saat diputar dalam layar penuh.',
			'settings.rememberVolume' => 'Ingat Volume',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Konfigurasi ini menentukan apakah volume akan dipertahankan saat memutar video lagi.',
			'settings.rememberBrightness' => 'Ingat Kecerahan',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Konfigurasi ini menentukan apakah kecerahan akan dipertahankan saat memutar video lagi.',
			'settings.playControlArea' => 'Area Kontrol Pemutaran',
			'settings.leftAndRightControlAreaWidth' => 'Lebar Area Kontrol Kiri dan Kanan',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Konfigurasi ini menentukan lebar area kontrol di sisi kiri dan kanan pemutar.',
			'settings.proxyAddressCannotBeEmpty' => 'Alamat proksi tidak boleh kosong.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Format alamat proksi tidak valid. Gunakan format IP:port atau nama domain:port.',
			'settings.proxyNormalWork' => 'Proksi berfungsi normal.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Uji proksi gagal, kode status: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Uji proksi gagal, pengecualian: ${exception}',
			'settings.proxyConfig' => 'Konfigurasi Proksi',
			'settings.thisIsHttpProxyAddress' => 'Ini adalah alamat proksi http',
			'settings.checkProxy' => 'Periksa Proksi',
			'settings.proxyAddress' => 'Alamat Proksi',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Silakan masukkan URL server proksi, misalnya 127.0.0.1:8080',
			'settings.enableProxy' => 'Aktifkan Proksi',
			'settings.left' => 'Kiri',
			'settings.middle' => 'Tengah',
			'settings.right' => 'Kanan',
			'settings.playerSettings' => 'Pengaturan Pemutar',
			'settings.networkSettings' => 'Pengaturan Jaringan',
			'settings.customizeYourPlaybackExperience' => 'Sesuaikan Pengalaman Pemutaran Anda',
			'settings.chooseYourFavoriteAppAppearance' => 'Pilih Tampilan Aplikasi Favorit Anda',
			'settings.configureYourProxyServer' => 'Konfigurasikan Server Proksi Anda',
			'settings.settings' => 'Pengaturan',
			'settings.themeSettings' => 'Pengaturan Tema',
			'settings.followSystem' => 'Ikuti Sistem',
			'settings.lightMode' => 'Mode Terang',
			'settings.darkMode' => 'Mode Gelap',
			'settings.presetTheme' => 'Tema Prasetel',
			'settings.basicTheme' => 'Tema Dasar',
			'settings.needRestartToApply' => 'Perlu memulai ulang aplikasi untuk menerapkan pengaturan',
			'settings.themeNeedRestartDescription' => 'Pengaturan tema memerlukan memulai ulang aplikasi untuk menerapkan pengaturan',
			'settings.about' => 'Tentang',
			'settings.diagnosticsAndFeedback' => 'Diagnostik & Umpan Balik',
			'settings.currentVersion' => 'Versi Saat Ini',
			'settings.latestVersion' => 'Versi Terbaru',
			'settings.checkForUpdates' => 'Periksa Pembaruan',
			'settings.update' => 'Perbarui',
			'settings.newVersionAvailable' => 'Versi Baru Tersedia',
			'settings.projectHome' => 'Beranda Proyek',
			'settings.release' => 'Rilis',
			'settings.issueReport' => 'Laporan Masalah',
			'settings.openSourceLicense' => 'Lisensi Sumber Terbuka',
			'settings.checkForUpdatesFailed' => 'Gagal memeriksa pembaruan, silakan coba lagi nanti',
			'settings.autoCheckUpdate' => 'Periksa Pembaruan Otomatis',
			'settings.updateContent' => 'Konten Pembaruan',
			'settings.releaseDate' => 'Tanggal Rilis',
			'settings.ignoreThisVersion' => 'Abaikan Versi Ini',
			'settings.forceUpdateTip' => 'Ini adalah pembaruan wajib. Harap perbarui ke versi terbaru sesegera mungkin',
			'settings.viewChangelog' => 'Lihat Log Perubahan',
			'settings.alreadyLatestVersion' => 'Sudah versi terbaru',
			'settings.appSettings' => 'Pengaturan Aplikasi',
			'settings.configureYourAppSettings' => 'Konfigurasikan Pengaturan Aplikasi Anda',
			'settings.history' => 'Riwayat',
			'settings.autoRecordHistory' => 'Rekam Riwayat Otomatis',
			'settings.autoRecordHistoryDesc' => 'Secara otomatis merekam video dan gambar yang telah Anda tonton',
			'settings.autoDeleteHistory' => 'Bersihkan Riwayat Otomatis',
			'settings.autoDeleteHistoryDesc' => 'Secara otomatis menghapus riwayat penjelajahan yang lebih lama dari hari retensi saat memulai (nonaktif secara bawaan)',
			'settings.autoDeleteHistoryDays' => 'Hari Retensi',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Simpan ${num} hari terakhir',
			'settings.autoDeleteHistoryDaysInvalid' => 'Silakan masukkan jumlah hari yang valid (minimal 1)',
			'settings.showUnprocessedMarkdownText' => 'Tampilkan Teks Markdown yang Belum Diproses',
			'settings.showUnprocessedMarkdownTextDesc' => 'Tampilkan teks asli dari markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Mode Privasi',
			'settings.activeBackgroundPrivacyModeDesc' => 'Blokir tangkapan layar dan rekaman layar, serta sembunyikan layar di latar belakang',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Sembunyikan layar saat aplikasi masuk ke latar belakang (platform ini tidak dapat memblokir tangkapan layar)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Blokir tangkapan layar dan rekaman layar',
			'settings.privacy' => 'Privasi',
			'settings.appLock' => 'Kunci Aplikasi',
			'settings.appLockEnabled' => 'Aktifkan kunci aplikasi',
			'settings.appLockEnabledDesc' => 'Memerlukan PIN atau biometrik untuk membuka aplikasi; pratinjau latar belakang disembunyikan secara otomatis',
			'settings.appLockEnabledSummary' => 'Aktif · Dilindungi PIN',
			'settings.appLockDisabledSummary' => 'Nonaktif',
			'settings.appLockTimeout' => 'Kunci setelah keluar aplikasi',
			'settings.appLockTimeoutDesc' => 'Waktu yang diizinkan di latar belakang sebelum autentikasi diperlukan',
			'settings.appLockAfterScreenOff' => 'Kunci setelah kunci layar',
			'settings.appLockAfterScreenOffDesc' => 'Memerlukan autentikasi setelah layar perangkat dikunci',
			'settings.appLockTimeoutDisabled' => 'Nonaktif',
			'settings.appLockImmediately' => 'Segera',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} detik',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} menit',
			'settings.appLockUseBiometrics' => 'Gunakan biometrik',
			'settings.appLockUseBiometricsDesc' => 'Buka kunci dengan sidik jari atau pengenalan wajah',
			'settings.appLockBiometricsUnavailable' => 'Tidak ada biometrik terdaftar yang tersedia di perangkat ini',
			'settings.appLockSetPin' => 'Atur PIN',
			'settings.appLockEnterPin' => 'Masukkan PIN',
			'settings.appLockConfirmPin' => 'Konfirmasi PIN',
			'settings.appLockCurrentPin' => 'Masukkan PIN saat ini',
			'settings.appLockNewPin' => 'Masukkan PIN baru',
			'settings.appLockPinRequirements' => 'PIN harus berisi 4–8 digit',
			'settings.appLockPinsDoNotMatch' => 'PIN tidak cocok',
			'settings.appLockInvalidPin' => 'PIN salah',
			'settings.appLockSetupFailed' => 'Tidak dapat menyimpan PIN dengan aman',
			'settings.appLockDisable' => 'Masukkan PIN untuk menonaktifkan kunci aplikasi',
			'settings.appLockChangePin' => 'Ubah PIN',
			'settings.appLockNow' => 'Kunci sekarang',
			'settings.appLockUnlock' => 'Buka Kunci',
			'settings.appLockLockedTitle' => 'Terkunci',
			'settings.appLockLockedDesc' => 'Autentikasi untuk melanjutkan',
			'settings.appLockAuthenticateReason' => 'Autentikasi untuk membuka kunci',
			'settings.appLockEnableBiometricsReason' => 'Autentikasi untuk mengaktifkan buka kunci biometrik',
			'settings.appLockBiometricFailed' => 'Autentikasi biometrik tidak diselesaikan',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Terlalu banyak percobaan. Coba lagi dalam ${seconds} dtk',
			'settings.appLockCredentialUnavailableTitle' => 'Tidak dapat membaca kredensial kunci aplikasi',
			'settings.appLockCredentialUnavailableDesc' => 'Penyimpanan aman sistem sementara tidak tersedia, atau kredensial rusak. Aplikasi tetap terkunci. Coba lagi terlebih dahulu; jika terus gagal, Anda dapat mengatur ulang kunci aplikasi, yang akan mematikannya dan menghapus PIN tersimpan.',
			'settings.appLockRetry' => 'Coba Lagi',
			'settings.appLockReset' => 'Atur ulang kunci aplikasi',
			'settings.appLockResetAction' => 'Atur Ulang',
			'settings.appLockResetConfirmTitle' => 'Atur ulang kunci aplikasi?',
			'settings.appLockResetConfirmDesc' => 'Ini menonaktifkan kunci aplikasi dan menghapus PIN tersimpan serta pengaturan biometrik. Anda dapat mengaturnya lagi setelahnya.',
			'settings.appLockRetrySucceeded' => 'Kredensial berhasil dibaca. Masukkan PIN Anda.',
			'settings.appLockRetryFailed' => 'Masih tidak dapat membaca kredensial',
			'settings.forum' => 'Forum',
			'settings.news' => 'Berita',
			'settings.community' => 'Komunitas',
			'settings.disableForumReplyQuote' => 'Nonaktifkan Kutipan Balasan Forum',
			'settings.disableForumReplyQuoteDesc' => 'Nonaktifkan membawa informasi lantai yang dibalas saat membalas di forum',
			'settings.theaterMode' => 'Mode Teater',
			'settings.theaterModeDesc' => 'Setelah dibuka, latar belakang pemutar akan diatur ke versi buram dari sampul video',
			'settings.appLinks' => 'Tautan Aplikasi',
			'settings.defaultBrowser' => 'Peramban Bawaan',
			'settings.defaultBrowserDesc' => 'Silakan buka item konfigurasi tautan bawaan di pengaturan sistem dan tambahkan tautan situs iwara.tv',
			'settings.themeMode' => 'Mode Tema',
			'settings.themeModeDesc' => 'Konfigurasi ini menentukan mode tema aplikasi',
			'settings.glassEffect' => 'Material Antarmuka',
			'settings.glassEffectDesc' => 'Memilih material yang digunakan di seluruh aplikasi — kapsul header, menu, tombol dialog, dan bilah navigasi bawah',
			'settings.liquidGlassEffect' => 'Kaca Cair',
			'settings.liquidGlassEffectDesc' => 'Blur dan refraksi nyata. Tampilan terbaik, tetapi dapat menurunkan frame dan memakai sedikit lebih banyak daya pada perangkat kelas bawah',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Permukaan Material 3 standar — opak, tanpa blur, tanpa bayangan. Kinerja dan daya terbaik',
			'settings.glassEffectIntroTitle' => 'Pilih material antarmuka Anda',
			'settings.glassEffectIntroContent' => 'Header, bilah tab, dan menu menggunakan kaca cair — blur dan refraksi nyata. Jika terasa lambat di perangkat Anda, atau Anda lebih menyukai tampilan yang lebih sederhana, beralihlah ke Material sekarang (permukaan opak, tanpa blur, tanpa bayangan).',
			'settings.glassEffectIntroHint' => 'Anda dapat mengubahnya kapan saja di Pengaturan → Tema → Material Antarmuka.',
			'settings.glassEffectIntroDone' => 'Pertahankan',
			'settings.dynamicColor' => 'Warna Dinamis',
			'settings.dynamicColorDesc' => 'Konfigurasi ini menentukan apakah aplikasi menggunakan warna dinamis',
			'settings.useDynamicColor' => 'Gunakan Warna Dinamis',
			'settings.useDynamicColorDesc' => 'Konfigurasi ini menentukan apakah aplikasi menggunakan warna dinamis',
			'settings.presetColors' => 'Warna Prasetel',
			'settings.customColors' => 'Warna Kustom',
			'settings.customColorsDisabledByDynamicColor' => 'Warna dinamis aktif, sehingga warna prasetel/kustom tidak tersedia. Nonaktifkan warna dinamis terlebih dahulu.',
			'settings.pickColor' => 'Pilih Warna',
			'settings.cancel' => 'Batal',
			'settings.confirm' => 'Konfirmasi',
			'settings.noCustomColors' => 'Tidak ada warna kustom',
			'settings.recordAndRestorePlaybackProgress' => 'Rekam dan Pulihkan Kemajuan Pemutaran',
			'settings.autoPlayVideoOnFirstEnter' => 'Putar Video Otomatis Saat Pertama Masuk',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Pengaturan ini menentukan apakah video mulai diputar secara otomatis saat pertama kali membuka halaman video.',
			'settings.autoEnterFullscreen' => 'Masuk Layar Penuh Otomatis',
			'settings.autoEnterFullscreenDesc' => 'Kapan pemutar harus masuk layar penuh dengan sendirinya. Video privat, yang dihapus, dan eksternal selalu dibiarkan, begitu juga gambar-dalam-gambar.',
			'settings.autoEnterFullscreenOff' => 'Nonaktif',
			'settings.autoEnterFullscreenOffDesc' => 'Jangan pernah masuk layar penuh dengan sendirinya',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'Saat Pemutaran Dimulai',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Masuk layar penuh tepat saat pemutaran benar-benar dimulai',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'Saat Membuka Video',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Masuk layar penuh segera setelah halaman video terbuka, tanpa menunggu pemutaran',
			'settings.autoEnterFullscreenKind' => 'Jenis Layar Penuh',
			'settings.autoEnterFullscreenKindDesc' => 'Jenis layar penuh mana yang akan dimasuki secara otomatis. Hanya desktop.',
			'settings.autoEnterFullscreenKindSystem' => 'Layar Penuh Sistem',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Biarkan pengelola jendela membuat jendela menjadi layar penuh',
			'settings.autoEnterFullscreenKindApp' => 'Layar Penuh Aplikasi',
			'settings.autoEnterFullscreenKindAppDesc' => 'Pertahankan jendela apa adanya dan ubah seluruh aplikasi menjadi pemutar',
			'settings.signature' => 'Tanda Tangan',
			'settings.enableSignature' => 'Aktifkan Tanda Tangan',
			'settings.enableSignatureDesc' => 'Konfigurasi ini menentukan apakah aplikasi akan menambahkan tanda tangan saat membalas',
			'settings.enterSignature' => 'Masukkan Tanda Tangan',
			'settings.editSignature' => 'Edit Tanda Tangan',
			'settings.signatureContent' => 'Isi Tanda Tangan',
			'settings.exportConfig' => 'Ekspor Konfigurasi Aplikasi',
			'settings.exportConfigDesc' => 'Ekspor pengaturan dan riwayat (riwayat penjelajahan, kemajuan pemutaran, favorit, dll.) ke file untuk pencadangan atau pemindahan ke perangkat lain. Tugas unduhan tidak disertakan.',
			'settings.importConfig' => 'Impor Konfigurasi Aplikasi',
			'settings.importConfigDesc' => 'Impor konfigurasi aplikasi dari file',
			'settings.exportConfigSuccess' => 'Konfigurasi berhasil diekspor!',
			'settings.exportConfigFailed' => 'Gagal mengekspor konfigurasi',
			'settings.importConfigSuccess' => 'Konfigurasi berhasil diimpor!',
			'settings.importConfigFailed' => 'Gagal mengimpor konfigurasi',
			'settings.exportIncludeSensitive' => 'Sertakan info sensitif',
			'settings.exportIncludeSensitiveDesc' => 'Menyertakan kunci API, token sesi, dan alamat proksi. Hanya aktifkan saat mencadangkan ke perangkat Anda sendiri.',
			'settings.importConfigOverwriteWarning' => 'Mengimpor akan menimpa pengaturan dan riwayat Anda saat ini (riwayat penjelajahan, kemajuan pemutaran, favorit, dll.). Lanjutkan?',
			'settings.importConfigRestartTitle' => 'Impor berhasil',
			'settings.importConfigRestartContent' => 'Konfigurasi Anda telah diimpor. Harap tutup sepenuhnya dan buka kembali aplikasi agar semua perubahan berlaku.',
			'settings.historyUpdateLogs' => 'Log Pembaruan Riwayat',
			'settings.noUpdateLogs' => 'Tidak ada log pembaruan yang tersedia',
			'settings.versionLabel' => 'Versi: {version}',
			'settings.releaseDateLabel' => 'Tanggal Rilis: {date}',
			'settings.noChanges' => 'Tidak ada konten pembaruan yang tersedia',
			'settings.interaction' => 'Interaksi',
			'settings.enableVibration' => 'Aktifkan Getaran',
			'settings.enableVibrationDesc' => 'Aktifkan umpan balik getaran saat berinteraksi dengan aplikasi',
			'settings.defaultKeepVideoToolbarVisible' => 'Pertahankan Bilah Alat Video Terlihat',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Pengaturan ini menentukan apakah bilah alat video tetap terlihat saat pertama kali membuka halaman video.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Perangkat seluler mengaktifkan mode teater, yang dapat menyebabkan masalah kinerja. Anda dapat memilih untuk mengaktifkannya.',
			'settings.fullscreenOrientation' => 'Orientasi Layar Vertikal Setelah Masuk Layar Penuh',
			'settings.fullscreenOrientationDesc' => 'Pengaturan ini menentukan orientasi layar bawaan saat masuk layar penuh (khusus seluler)',
			'settings.fullscreenOrientationLeftLandscape' => 'Lanskap Kiri',
			'settings.fullscreenOrientationRightLandscape' => 'Lanskap Kanan',
			'settings.screenFit' => 'Ukuran Layar',
			'settings.screenFitDesc' => 'Pilih bagaimana video mengisi area pemutar.',
			'settings.rememberScreenFit' => 'Ingat Ukuran Layar',
			'settings.rememberScreenFitDesc' => 'Terapkan ukuran yang dipilih ke video yang dibuka nanti.',
			'settings.screenFitFit' => 'Sesuaikan',
			'settings.screenFitFitDesc' => 'Tampilkan seluruh bingkai dengan mempertahankan rasio aspek',
			'settings.screenFitStretch' => 'Regangkan',
			'settings.screenFitStretchDesc' => 'Mengisi area pemutar; gambar mungkin terdistorsi',
			'settings.screenFitCover' => 'Isi Penuh',
			'settings.screenFitCoverDesc' => 'Mengisi area pemutar dengan mempertahankan rasio aspek; bagian berlebih dipotong',
			'settings.screenFitRatioDesc' => 'Paksa rasio aspek ini; gambar mungkin terdistorsi',
			'settings.jumpLink' => 'Lompat Tautan',
			'settings.language' => 'Bahasa',
			'settings.languageNativeName' => 'Bahasa Indonesia',
			'settings.followSystemLanguage' => 'Ikuti sistem',
			'settings.languageChangedMessage' => 'Bahasa berhasil diubah. Beberapa fitur perlu memulai ulang aplikasi agar berlaku.',
			'settings.languageChanged' => 'Pengaturan bahasa telah diubah, harap mulai ulang aplikasi agar berlaku.',
			'settings.keybinding.title' => 'Pintasan Papan Ketik',
			'settings.keybinding.entryLabel' => 'Pintasan Papan Ketik',
			'settings.keybinding.entryDesc' => 'Sesuaikan pintasan papan ketik aplikasi (terutama untuk desktop)',
			'settings.keybinding.desktopHint' => 'Pintasan terutama berlaku untuk papan ketik desktop; seluler biasanya menggunakan gerakan.',
			'settings.keybinding.resetAll' => 'Atur Ulang Semua ke Bawaan',
			'settings.keybinding.resetAllConfirm' => 'Atur ulang semua pintasan aplikasi ke bawaannya?',
			'settings.keybinding.resetToDefault' => 'Atur Ulang ke Bawaan',
			'settings.keybinding.resetScope' => 'Atur Ulang Bagian Ini',
			'settings.keybinding.notSet' => 'Belum diatur',
			'settings.keybinding.addShortcut' => 'Tambah Pintasan',
			'settings.keybinding.removeShortcut' => 'Hapus pintasan ini',
			'settings.keybinding.pressNewShortcut' => 'Tekan pintasan baru…',
			'settings.keybinding.recordingCancelHint' => 'Tekan Esc untuk membatalkan',
			'settings.keybinding.mouseHint' => 'Anda juga dapat mengikat tombol samping mouse (kembali / maju) atau tombol tengah',
			'settings.keybinding.mouseNotSupportedInScope' => 'Area ini tidak menangani tombol mouse; gunakan papan ketik sebagai gantinya',
			'settings.keybinding.capabilityKeyboardOnly' => 'Area ini hanya menerima tombol papan ketik',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Area ini menerima tombol papan ketik, serta tombol tengah dan samping mouse',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Area ini menerima tombol papan ketik, serta tombol tengah dan maju mouse (tombol kembali diambil oleh sistem)',
			'settings.keybinding.rejectMultipleButtons' => 'Tekan satu tombol mouse dalam satu waktu',
			'settings.keybinding.rejectPlatformBack' => 'Sistem sudah menggunakan ini untuk Kembali; mengikatnya akan membuat kembali dua kali',
			'settings.keybinding.detectedLabel' => 'Terdeteksi',
			'settings.keybinding.reservedKey' => 'Tombol ini disisihkan oleh sistem dan tidak dapat diikat',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Tombol ini diikat ke "${action}"; tombol tetap disisihkan di sini agar Anda masih dapat meninggalkan layar ini',
			'settings.keybinding.conflictTitle' => 'Konflik Pintasan',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Kombinasi ini sudah diikat ke "${action}". Melanjutkan akan menghapus ikatan yang ada.',
			'settings.keybinding.conflictContinue' => 'Tetap Ikat',
			'settings.keybinding.shadowWarningTitle' => 'Tumpang Tindih Pintasan Global',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Kombinasi ini diikat ke "${action}" secara global. Mengikatnya di sini akan menimpa tindakan itu hanya di dalam bagian ini.',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'Kombinasi ini sudah diikat ke "${action}" di ${scope}. Di dalam bagian itu, pintasan global ini akan ditimpa olehnya.',
			'settings.keybinding.searchHint' => 'Cari pintasan…',
			'settings.keybinding.scopeGlobal' => 'Global',
			'settings.keybinding.scopeGallery' => 'Galeri',
			'settings.keybinding.scopeVideo' => 'Video',
			'settings.keybinding.categoryNavigation' => 'Navigasi',
			'settings.keybinding.categoryZoom' => 'Zoom',
			'settings.keybinding.categoryPlayback' => 'Pemutaran',
			'settings.keybinding.categorySeek' => 'Pencarian',
			'settings.keybinding.categoryVolume' => 'Volume',
			'settings.keybinding.categoryDisplay' => 'Tampilan',
			'settings.keybinding.actionGlobalBack' => 'Kembali',
			'settings.keybinding.actionGalleryNext' => 'Foto Berikutnya',
			'settings.keybinding.actionGalleryPrevious' => 'Foto Sebelumnya',
			'settings.keybinding.actionGalleryZoomIn' => 'Perbesar',
			'settings.keybinding.actionGalleryZoomOut' => 'Perkecil',
			'settings.keybinding.actionGalleryResetZoom' => 'Atur Ulang Zoom',
			'settings.keybinding.actionGalleryPlayPause' => 'Putar / Jeda',
			'settings.keybinding.actionGallerySeekBackward' => 'Mundur',
			'settings.keybinding.actionGallerySeekForward' => 'Maju Cepat',
			'settings.keybinding.actionGalleryToggleMute' => 'Alihkan Bisu',
			'settings.keybinding.actionPlayPause' => 'Putar / Jeda',
			'settings.keybinding.actionSpeedUp' => 'Tingkatkan Kecepatan',
			'settings.keybinding.actionSpeedDown' => 'Kurangi Kecepatan',
			'settings.keybinding.actionSeekForward' => 'Maju',
			'settings.keybinding.actionSeekBackward' => 'Mundur',
			'settings.keybinding.actionVolumeUp' => 'Besarkan Volume',
			'settings.keybinding.actionVolumeDown' => 'Kecilkan Volume',
			'settings.keybinding.actionToggleMute' => 'Alihkan Bisu',
			'settings.keybinding.actionToggleFullscreen' => 'Alihkan Layar Penuh',
			'settings.keybinding.seekLongPressHint' => 'Tahan tombol maju / mundur untuk memicu mode kecepatan tekan lama',
			'settings.keybinding.zoomSectionTitle' => 'Zoom Gambar (Tetap)',
			'settings.keybinding.zoomFixedNote' => 'Pintasan di bawah ini tetap dan tidak dapat diubah',
			'settings.keybinding.zoomScaleLabel' => 'Perbesar Gambar',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + Roda',
			'settings.keybinding.zoomRotateLabel' => 'Putar Gambar',
			'settings.keybinding.zoomRotateHint' => 'Shift + Roda',
			'settings.keybinding.zoomPinchGesture' => 'Cubit',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Putar Dua Jari',
			'settings.gestureControl' => 'Kontrol Gerakan',
			'settings.leftDoubleTapRewind' => 'Ketuk Ganda Kiri untuk Mundur',
			'settings.rightDoubleTapFastForward' => 'Ketuk Ganda Kanan untuk Maju Cepat',
			'settings.doubleTapPause' => 'Jeda Ketuk Ganda',
			'settings.rightVerticalSwipeVolume' => 'Geser Vertikal Kanan untuk Volume (Berlaku saat memasuki halaman baru)',
			'settings.leftVerticalSwipeBrightness' => 'Geser Vertikal Kiri untuk Kecerahan (Berlaku saat memasuki halaman baru)',
			'settings.longPressFastForward' => 'Tekan Lama untuk Maju Cepat',
			'settings.enableMouseHoverShowToolbar' => 'Aktifkan Tampilkan Bilah Alat saat Kursor Melayang',
			'settings.enableMouseHoverShowToolbarInfo' => 'Saat diaktifkan, bilah alat video akan ditampilkan saat kursor melayang di atas pemutar. Bilah akan disembunyikan secara otomatis setelah 3 detik tidak ada aktivitas.',
			'settings.enableHorizontalDragSeek' => 'Geser Horizontal untuk Mencari',
			'settings.enableVideoGestureZoom' => 'Cubit untuk Memperbesar Bingkai Video',
			'settings.enableVideoGestureZoomInfo' => 'Cubit dengan dua jari (atau Ctrl + roda mouse di desktop) untuk memperbesar gambar video, lalu seret untuk memindahkannya.',
			'settings.showCenterPlayPauseButton' => 'Tombol Putar/Jeda Tengah',
			'settings.showCenterPlayPauseButtonDesc' => 'Tampilkan tombol putar/jeda besar di tengah pemutar.',
			'settings.audioVideoConfig' => 'Konfigurasi Audio Video',
			'settings.expandBuffer' => 'Perluas Buffer',
			'settings.expandBufferInfo' => 'Saat diaktifkan, ukuran buffer bertambah, waktu pemuatan menjadi lebih lama tetapi pemutaran lebih lancar',
			'settings.videoSyncMode' => 'Mode Sinkron Video',
			'settings.videoSyncModeSubtitle' => 'Strategi sinkronisasi audio-video',
			'settings.hardwareDecodingMode' => 'Mode Dekode Perangkat Keras',
			'settings.hardwareDecodingModeSubtitle' => 'Pengaturan dekode perangkat keras',
			'settings.enableHardwareAcceleration' => 'Aktifkan Akselerasi Perangkat Keras',
			'settings.enableHardwareAccelerationInfo' => 'Mengaktifkan akselerasi perangkat keras dapat meningkatkan kinerja dekode, tetapi beberapa perangkat mungkin tidak kompatibel',
			'settings.useOpenSLESAudioOutput' => 'Gunakan Output Audio OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'Gunakan output audio latensi rendah, dapat meningkatkan kinerja audio',
			'settings.videoSyncAudio' => 'Sinkron Audio',
			'settings.videoSyncDisplayResample' => 'Tampilkan Resample',
			'settings.videoSyncDisplayResampleVdrop' => 'Tampilkan Resample (Jatuhkan Bingkai)',
			'settings.videoSyncDisplayResampleDesync' => 'Tampilkan Resample (Desinkron)',
			'settings.videoSyncDisplayTempo' => 'Tampilkan Tempo',
			'settings.videoSyncDisplayVdrop' => 'Tampilkan Jatuhkan Bingkai Video',
			'settings.videoSyncDisplayAdrop' => 'Tampilkan Jatuhkan Bingkai Audio',
			'settings.videoSyncDisplayDesync' => 'Tampilkan Desinkron',
			'settings.videoSyncDesync' => 'Desinkron',
			'settings.forumSettings.name' => 'Forum',
			'settings.forumSettings.configureYourForumSettings' => 'Konfigurasikan Pengaturan Forum Anda',
			'settings.gallerySettings.gallerySettingsTitle' => 'Pengaturan Galeri',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Konfigurasikan preferensi penampil galeri',
			'settings.gallerySettings.defaultViewerQuality' => 'Kualitas penampil bawaan',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Pilih kualitas gambar mana yang ditampilkan secara bawaan saat membuka penampil galeri.',
			'settings.blockSettings.title' => 'Blokir Konten',
			'settings.blockSettings.subtitle' => 'Secara otomatis menyembunyikan video dan galeri yang judulnya cocok dengan kata kunci atau pola, atau yang berasal dari pengguna yang diblokir. Semua pencocokan dilakukan di perangkat Anda — tidak ada yang diunggah.',
			'settings.blockSettings.blocked' => 'Diblokir',
			'settings.blockSettings.reveal' => 'Tampilkan',
			'settings.blockSettings.reblock' => 'Blokir lagi',
			'settings.blockSettings.why' => 'Mengapa diblokir?',
			'settings.blockSettings.manageRules' => 'Kelola aturan',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'Judul mengandung "${value}"',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'Judul cocok dengan "${value}"',
			'settings.blockSettings.reasonUser' => 'Dari pengguna yang diblokir',
			'settings.blockSettings.addRule' => 'Tambah aturan',
			'settings.blockSettings.editRule' => 'Edit aturan',
			'settings.blockSettings.deleteRule' => 'Hapus aturan',
			'settings.blockSettings.ruleType' => 'Jenis aturan',
			'settings.blockSettings.keyword' => 'Kata Kunci',
			'settings.blockSettings.regex' => 'Regex',
			'settings.blockSettings.userId' => 'Pengguna',
			'settings.blockSettings.value' => 'Teks yang dicocokkan',
			'settings.blockSettings.caseSensitive' => 'Peka huruf besar-kecil',
			'settings.blockSettings.regexHint' => 'mis. trailer|teaser',
			'settings.blockSettings.valueRequired' => 'Silakan masukkan teks yang akan dicocokkan',
			'settings.blockSettings.invalidRegex' => 'Itu bukan ekspresi reguler yang valid',
			'settings.blockSettings.noRules' => 'Belum ada aturan. Ketuk + untuk menambahkan.',
			'settings.blockSettings.blockUser' => 'Blokir',
			'settings.blockSettings.unblockUser' => 'Buka blokir',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => 'Blokir "${name}"? Video dan galeri mereka akan disembunyikan dari daftar dan pencarian.',
			'settings.blockSettings.userBlocked' => 'Pengguna diblokir',
			'settings.blockSettings.userUnblocked' => 'Blokir pengguna dibuka',
			'settings.blockSettings.exportRules' => 'Ekspor',
			'settings.blockSettings.importRules' => 'Impor',
			'settings.blockSettings.importExport' => 'Impor / Ekspor',
			'settings.blockSettings.exportSuccess' => 'Aturan diekspor',
			'settings.blockSettings.exportFailed' => 'Tidak dapat mengekspor aturan',
			'settings.blockSettings.importSuccess' => ({required Object count}) => 'Mengimpor ${count} aturan',
			'settings.blockSettings.importFailed' => 'Tidak dapat mengimpor aturan',
			'settings.blockSettings.regexHelp' => 'Bantuan pola',
			'settings.blockSettings.regexHelpTitle' => 'Referensi regex',
			'settings.blockSettings.regexHelpIntro' => 'Ekspresi reguler mencocokkan judul lebih fleksibel daripada kata kunci biasa. Beberapa contoh umum:',
			'settings.blockSettings.regexHelpTapHint' => 'Ketuk contoh untuk mengisinya.',
			'settings.blockSettings.regexEx1Pattern' => 'trailer|teaser|bonus',
			'settings.blockSettings.regexEx1Desc' => 'Cocok dengan salah satu kata ini ("|" berarti "atau")',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Judul yang diawali dengan [tanda kurung]',
			'settings.blockSettings.regexEx3Pattern' => 'Koleksi\$',
			'settings.blockSettings.regexEx3Desc' => 'Judul yang diakhiri dengan "Koleksi"',
			'settings.blockSettings.regexEx4Pattern' => 'Ep.[0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ berarti satu digit atau lebih — cocok dengan "Ep.12"',
			'settings.blockSettings.regexEx5Pattern' => '[0-9]{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9] berarti satu digit dan {4} berarti empat digit berurutan (mis. satu tahun)',
			'settings.blockSettings.regexEx1Sample' => 'Trailer game baru sudah tayang',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Film Utuh',
			'settings.blockSettings.regexEx3Sample' => 'Koleksi Seni Musim Semi',
			'settings.blockSettings.regexEx4Sample' => 'Rekap Ep.12 Serial Saya',
			'settings.blockSettings.regexEx5Sample' => 'Sorotan Terbaik 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'Contoh judul',
			'settings.blockSettings.regexHelpMatchedTag' => 'Diblokir',
			'settings.blockSettings.regexHelpNoMatch' => 'Tidak cocok',
			'settings.blockSettings.regexEx6Pattern' => '[Ss]eason',
			'settings.blockSettings.regexEx6Desc' => '[Ss] cocok dengan huruf S besar maupun kecil — di sini menangkap "Season"',
			'settings.blockSettings.regexEx6Sample' => 'Trailer Musim Terakhir',
			'settings.blockSettings.regexEx7Pattern' => '(film|serial)',
			'settings.blockSettings.regexEx7Desc' => 'Tanda kurung () mengelompokkan pilihan — cocok dengan "film" atau "serial"',
			'settings.blockSettings.regexEx7Sample' => 'Tonton Serialnya Sekarang',
			'settings.blockSettings.regexEx8Pattern' => 'film(nya)?',
			'settings.blockSettings.regexEx8Desc' => '(nya)? membuat akhiran "nya" opsional — cocok dengan "film" dan "filmnya"',
			'settings.blockSettings.regexEx8Sample' => 'Tonton Filmnya Sekarang',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ berarti satu atau lebih — cocok dengan !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => 'OMG!!! Wajib Tonton',
			'settings.blockSettings.regexEx10Pattern' => 'bonus.*adegan',
			'settings.blockSettings.regexEx10Desc' => '.* cocok dengan teks apa pun di antaranya — "bonus … adegan"',
			'settings.blockSettings.regexEx10Sample' => 'Adegan Bonus yang Dihapus',
			'settings.chatSettings.name' => 'Obrolan',
			'settings.chatSettings.configureYourChatSettings' => 'Konfigurasikan Pengaturan Obrolan Anda',
			'settings.hardwareDecodingAuto' => 'Otomatis',
			'settings.hardwareDecodingAutoCopy' => 'Salin Otomatis',
			'settings.hardwareDecodingAutoSafe' => 'Otomatis Aman',
			'settings.hardwareDecodingNo' => 'Dinonaktifkan',
			'settings.hardwareDecodingYes' => 'Paksa Aktifkan',
			'settings.cdnDistributionStrategy' => 'Strategi Distribusi Konten',
			'settings.cdnDistributionStrategyDesc' => 'Pilih strategi distribusi server sumber video untuk mengoptimalkan kecepatan pemuatan',
			'settings.cdnDistributionStrategyLabel' => 'Strategi Distribusi',
			'settings.cdnDistributionStrategyNoChange' => 'Tidak Ada Perubahan (Gunakan Server Asli)',
			'settings.cdnDistributionStrategyAuto' => 'Pilih Otomatis (Server Tercepat)',
			'settings.cdnDistributionStrategySpecial' => 'Tentukan Server',
			'settings.cdnSpecialServer' => 'Tentukan Server',
			'settings.cdnRefreshServerListHint' => 'Silakan klik tombol di bawah untuk menyegarkan daftar server',
			'settings.cdnRefreshButton' => 'Segarkan',
			'settings.cdnFastRingServers' => 'Server Fast Ring',
			'settings.cdnRefreshServerListTooltip' => 'Segarkan daftar server',
			'settings.cdnSpeedTestButton' => 'Uji Kecepatan',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Menguji (${count})',
			'settings.cdnNoServerDataHint' => 'Tidak ada data server yang tersedia, silakan klik tombol segarkan',
			'settings.cdnTestingStatus' => 'Menguji',
			'settings.cdnUnreachableStatus' => 'Tidak Terjangkau',
			'settings.cdnNotTestedStatus' => 'Belum Diuji',
			'settings.downloadSettings.downloadSettings' => 'Pengaturan Unduhan',
			'settings.downloadSettings.enableDownloadNotifications' => 'Notifikasi Unduhan',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Tampilkan notifikasi sistem saat satu unduhan selesai atau gagal',
			'settings.downloadSettings.notificationPermissionDenied' => 'Izin notifikasi ditolak. Notifikasi dalam aplikasi tetap berfungsi; aktifkan notifikasi sistem di pengaturan.',
			'settings.downloadSettings.storagePermissionStatus' => 'Status Izin Penyimpanan',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Akses Direktori Publik Memerlukan Izin Penyimpanan',
			'settings.downloadSettings.checkingPermissionStatus' => 'Memeriksa Status Izin...',
			'settings.downloadSettings.storagePermissionGranted' => 'Izin Penyimpanan Diberikan',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Izin Penyimpanan Tidak Diberikan',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Pemberian Izin Penyimpanan Berhasil',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Pemberian Izin Penyimpanan Gagal Namun Beberapa Fitur Mungkin Terbatas',
			'settings.downloadSettings.storagePermissionRationale' => 'Untuk menyimpan unduhan ke folder yang Anda pilih, aplikasi memerlukan akses penyimpanan.\n\nDi Android 11 dan yang lebih baru, ini berarti izin "Akses semua file"; tanpa izin itu, file disimpan ke folder privat aplikasi sebagai gantinya.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Untuk menyimpan unduhan ke folder yang Anda pilih, aplikasi memerlukan akses penyimpanan.\n\nTanpa izin itu, file disimpan ke folder privat aplikasi sebagai gantinya.',
			'settings.downloadSettings.grantStoragePermission' => 'Beri Izin Penyimpanan',
			'settings.downloadSettings.customDownloadPath' => 'Jalur Unduhan Kustom',
			'settings.downloadSettings.customDownloadPathDescription' => 'Saat diaktifkan, Anda dapat memilih lokasi penyimpanan kustom untuk file yang diunduh',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Tips: Memilih direktori publik (seperti folder Unduhan) memerlukan izin penyimpanan, disarankan menggunakan jalur yang direkomendasikan terlebih dahulu',
			'settings.downloadSettings.androidWarning' => 'Catatan Android: Hindari memilih direktori publik (seperti folder Unduhan), disarankan menggunakan direktori khusus aplikasi untuk memastikan izin akses.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Perhatian: Anda memilih direktori publik, izin penyimpanan diperlukan agar file dapat diunduh dengan normal',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Izin penyimpanan diperlukan untuk direktori publik',
			'settings.downloadSettings.currentDownloadPath' => 'Jalur Unduhan Saat Ini',
			'settings.downloadSettings.actualDownloadPath' => 'Jalur Unduhan Sebenarnya',
			'settings.downloadSettings.defaultAppDirectory' => 'Direktori Aplikasi Bawaan',
			'settings.downloadSettings.permissionGranted' => 'Diberikan',
			'settings.downloadSettings.permissionRequired' => 'Izin Diperlukan',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Aktifkan Jalur Unduhan Kustom',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Gunakan jalur bawaan aplikasi saat dinonaktifkan',
			'settings.downloadSettings.customDownloadPathLabel' => 'Jalur Unduhan Kustom',
			'settings.downloadSettings.selectDownloadFolder' => 'Pilih folder unduhan',
			'settings.downloadSettings.recommendedPath' => 'Jalur yang Direkomendasikan',
			'settings.downloadSettings.selectFolder' => 'Pilih Folder',
			'settings.downloadSettings.filenameTemplate' => 'Templat Nama File',
			'settings.downloadSettings.filenameTemplateDescription' => 'Sesuaikan aturan penamaan untuk file yang diunduh, mendukung substitusi variabel',
			'settings.downloadSettings.videoFilenameTemplate' => 'Templat Nama File Video',
			'settings.downloadSettings.galleryFolderTemplate' => 'Templat Folder Galeri',
			'settings.downloadSettings.imageFilenameTemplate' => 'Templat Nama File Gambar',
			'settings.downloadSettings.resetToDefault' => 'Atur Ulang ke Bawaan',
			'settings.downloadSettings.supportedVariables' => 'Variabel yang Didukung',
			'settings.downloadSettings.supportedVariablesDescription' => 'Variabel berikut dapat digunakan dalam templat nama file:',
			'settings.downloadSettings.copyVariable' => 'Salin Variabel',
			'settings.downloadSettings.variableCopied' => 'Variabel disalin',
			'settings.downloadSettings.warningPublicDirectory' => 'Peringatan: Direktori publik yang dipilih mungkin tidak dapat diakses. Disarankan memilih direktori khusus aplikasi.',
			'settings.downloadSettings.downloadPathUpdated' => 'Jalur unduhan diperbarui',
			'settings.downloadSettings.selectPathFailed' => 'Gagal memilih jalur',
			'settings.downloadSettings.pickerAlreadyActive' => 'Pemilih folder sudah terbuka',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Lokasi penyimpanan tidak didukung. Pilih folder di penyimpanan perangkat atau kartu SD.',
			'settings.downloadSettings.recommendedPathSet' => 'Diatur ke jalur yang direkomendasikan',
			'settings.downloadSettings.setRecommendedPathFailed' => 'Gagal mengatur jalur yang direkomendasikan',
			'settings.downloadSettings.templateResetToDefault' => 'Atur ulang ke templat bawaan',
			'settings.downloadSettings.functionalTest' => 'Uji Fungsional',
			'settings.downloadSettings.testInProgress' => 'Menguji...',
			'settings.downloadSettings.runTest' => 'Jalankan Uji',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Uji apakah jalur unduhan dan konfigurasi izin berfungsi dengan benar',
			'settings.downloadSettings.testResults' => 'Hasil Uji',
			'settings.downloadSettings.testCompleted' => 'Uji selesai',
			'settings.downloadSettings.testMultisegmentDomain' => 'Validasi domain nilai (multi-segmen / kelebihan / bentuk pelolosan)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Render struktur multi-segmen (issue #126)',
			'settings.downloadSettings.testPassed' => 'item lulus',
			'settings.downloadSettings.testFailed' => 'Uji gagal',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Pemeriksaan Izin Penyimpanan',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Izin penyimpanan diberikan',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Izin penyimpanan tidak ada, beberapa fitur mungkin terbatas',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Pemeriksaan izin gagal',
			'settings.downloadSettings.testDownloadPathValidation' => 'Validasi Jalur Unduhan',
			'settings.downloadSettings.testPathValidationFailed' => 'Validasi jalur gagal',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Validasi Templat Nama File',
			'settings.downloadSettings.testAllTemplatesValid' => 'Semua templat valid',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Beberapa templat mengandung karakter yang tidak valid',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Validasi templat gagal',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Uji Operasi Direktori',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'Pembuatan direktori dan penulisan file normal',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Operasi direktori gagal',
			'settings.downloadSettings.testVideoTemplate' => 'Templat Video',
			'settings.downloadSettings.testGalleryTemplate' => 'Templat Galeri',
			'settings.downloadSettings.testImageTemplate' => 'Templat Gambar',
			'settings.downloadSettings.testValid' => 'Valid',
			'settings.downloadSettings.testInvalid' => 'Tidak Valid',
			'settings.downloadSettings.testSuccess' => 'Berhasil',
			'settings.downloadSettings.testCorrect' => 'Benar',
			'settings.downloadSettings.testError' => 'Kesalahan',
			'settings.downloadSettings.testPath' => 'Jalur Uji',
			'settings.downloadSettings.testBasePath' => 'Jalur Dasar',
			'settings.downloadSettings.testDirectoryCreation' => 'Pembuatan Direktori',
			'settings.downloadSettings.testFileWriting' => 'Penulisan File',
			'settings.downloadSettings.testFileContent' => 'Isi File',
			'settings.downloadSettings.checkingPathStatus' => 'Memeriksa status jalur...',
			'settings.downloadSettings.unableToGetPathStatus' => 'Tidak dapat memperoleh status jalur',
			_ => null,
		} ?? switch (path) {
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Catatan: Jalur sebenarnya berbeda dari jalur yang dipilih',
			'settings.downloadSettings.grantPermission' => 'Beri Izin',
			'settings.downloadSettings.fixIssue' => 'Perbaiki Masalah',
			'settings.downloadSettings.issueFixed' => 'Masalah diperbaiki',
			'settings.downloadSettings.fixFailed' => 'Perbaikan gagal, silakan tangani secara manual',
			'settings.downloadSettings.lackStoragePermission' => 'Tidak memiliki izin penyimpanan',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'Tidak dapat mengakses direktori publik, memerlukan "Izin akses semua file"',
			'settings.downloadSettings.cannotCreateDirectory' => 'Tidak dapat membuat direktori',
			'settings.downloadSettings.directoryNotWritable' => 'Direktori tidak dapat ditulis',
			'settings.downloadSettings.insufficientSpace' => 'Ruang tersedia tidak cukup',
			'settings.downloadSettings.pathValid' => 'Jalur valid',
			'settings.downloadSettings.validationFailed' => 'Validasi gagal',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Menggunakan direktori aplikasi bawaan',
			'settings.downloadSettings.appPrivateDirectory' => 'Direktori Privat Aplikasi',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Aman dan andal, tidak memerlukan izin tambahan',
			'settings.downloadSettings.downloadDirectory' => 'Direktori Unduhan',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Lokasi unduhan bawaan sistem, mudah dikelola',
			'settings.downloadSettings.moviesDirectory' => 'Direktori Film',
			'settings.downloadSettings.moviesDirectoryDesc' => 'Direktori film sistem, dapat dikenali oleh aplikasi media',
			'settings.downloadSettings.documentsDirectory' => 'Direktori Dokumen',
			'settings.downloadSettings.documentsDirectoryDesc' => 'Direktori dokumen aplikasi iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'Memerlukan izin penyimpanan untuk mengakses',
			'settings.downloadSettings.recommendedPaths' => 'Jalur yang Direkomendasikan',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Direktori Privat Aplikasi Eksternal',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Direktori privat aplikasi di penyimpanan eksternal, dapat diakses pengguna, ruang lebih besar',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Direktori Privat Aplikasi Internal',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Penyimpanan internal aplikasi, tidak memerlukan izin, ruang lebih kecil',
			'settings.downloadSettings.appDocumentsDirectory' => 'Direktori Dokumen Aplikasi',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'Direktori dokumen khusus aplikasi, aman dan andal',
			'settings.downloadSettings.downloadsFolder' => 'Folder Unduhan',
			'settings.downloadSettings.downloadsFolderDesc' => 'Direktori unduhan bawaan sistem',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Pilih lokasi unduhan yang direkomendasikan',
			'settings.downloadSettings.noRecommendedPaths' => 'Tidak ada jalur yang direkomendasikan',
			'settings.downloadSettings.recommended' => 'Direkomendasikan',
			'settings.downloadSettings.requiresPermission' => 'Memerlukan Izin',
			'settings.downloadSettings.authorizeAndSelect' => 'Otorisasi dan Pilih',
			'settings.downloadSettings.select' => 'Pilih',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Otorisasi izin gagal, tidak dapat memilih jalur ini',
			'settings.downloadSettings.pathValidationFailed' => 'Validasi jalur gagal',
			'settings.downloadSettings.downloadPathSetTo' => 'Jalur unduhan diatur ke',
			'settings.downloadSettings.setPathFailed' => 'Gagal mengatur jalur',
			'settings.downloadSettings.variableTitle' => 'Judul',
			'settings.downloadSettings.variableAuthorcache' => 'Nama pertama penulis (stabil meski nama diganti)',
			'settings.downloadSettings.variableAuthor' => 'Nama penulis',
			'settings.downloadSettings.variableUsername' => 'Nama pengguna penulis',
			'settings.downloadSettings.variableQuality' => 'Kualitas video',
			'settings.downloadSettings.variableFilename' => 'Nama file asli',
			'settings.downloadSettings.variableId' => 'ID Konten',
			'settings.downloadSettings.variableCount' => 'Jumlah gambar galeri',
			'settings.downloadSettings.variableDate' => 'Tanggal saat ini (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'Waktu saat ini (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Tanggal waktu saat ini (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Pengaturan Unduhan',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Konfigurasikan jalur unduhan dan aturan penamaan file',
			'settings.downloadSettings.suchAsTitleQuality' => 'Contoh: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Contoh: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Contoh: %title_%filename',
			'settings.downloadSettings.structureSection' => 'Struktur simpan & penamaan',
			'settings.downloadSettings.structureSectionDescription' => 'File yang diunduh otomatis masuk subfolder sesuai skema di bawah. Hanya memengaruhi unduhan berikutnya; file yang sudah ada tidak diubah.',
			'settings.downloadSettings.structureNoticeTitle' => 'Fitur baru: arsip otomatis per penulis',
			'settings.downloadSettings.structureNoticeBody' => 'Pilih di bawah · hanya memengaruhi unduhan baru, file yang sudah ada tidak diubah.',
			'settings.downloadSettings.presetFlat' => 'Rata',
			'settings.downloadSettings.presetFlatDesc' => 'Semua file langsung di root unduhan',
			'settings.downloadSettings.presetAuthor' => 'Per penulis',
			'settings.downloadSettings.presetAuthorBadge' => 'Direkomendasikan',
			'settings.downloadSettings.presetAuthorDesc' => 'Satu folder per penulis · tidak terpecah meski nama berubah',
			'settings.downloadSettings.presetDate' => 'Per tanggal',
			'settings.downloadSettings.presetDateDesc' => 'Dikelompokkan menurut tanggal unduh',
			'settings.downloadSettings.presetCustomActive' => 'Digunakan',
			'settings.downloadSettings.structurePreviewLabel' => 'Pratinjau',
			'settings.downloadSettings.structurePreviewNote' => 'Segmen berwarna adalah tingkat pengorganisasian, berubah sesuai skema terpilih.',
			'settings.downloadSettings.pathTooLongWarning' => 'Jalur relatif melebihi 200 karakter, bisa gagal disimpan di sebagian perangkat',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Templat jalur kustom',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Tentukan sendiri struktur folder dan nama file',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Templat jalur',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Otomatis memilah unduhan ke subfolder',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Video',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Galeri',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Gambar tunggal',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Pratinjau · hasil tersimpan sesungguhnya setelah pembersihan',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Pratinjau · templat galeri = nama folder (gambar dalam pakai ID gambar)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Tambah satu tingkat folder',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Batas tingkat folder tercapai',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, variabel, atau teks tetap',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'mis. %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'Ekstensi (.mp4) ditambah otomatis · ketik / dalam segmen untuk membagi dua tingkat · maksimal ${max} tingkat',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'Ekstensi asli ditambah otomatis · ketik / dalam segmen untuk membagi dua tingkat · maksimal ${max} tingkat',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'Templat galeri seluruhnya segmen folder, maksimal ${max} tingkat · gambar dalam memakai penamaan ID gambar',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Ketuk untuk menyisipkan di posisi kursor · tahan untuk keterangan',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Segmen kosong',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'Tidak bisa menyimpan: ada segmen kosong, hapus atau isi dulu',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'Tidak bisa menyimpan: terlalu banyak segmen jalur (maks. 4). Gabungkan atau kurangi',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'Tidak bisa menyimpan: templat mengandung karakter tidak valid',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Variabel disisipkan',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Tersimpan · hanya memengaruhi unduhan berikutnya',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Konten',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Penulis',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Waktu',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Nama penulis·tetap',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Tanggal',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Waktu',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Tanggal & waktu',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Indeks',
			'favoriteTags.title' => 'Tag Favorit',
			'favoriteTags.emptyIwara' => 'Belum ada tag Iwara favorit',
			'favoriteTags.emptyOreno3d' => 'Belum ada favorit',
			'favoriteTags.addIwaraTag' => 'Tambah tag Iwara',
			'favoriteTags.quickPickHint' => 'Item favorit muncul sebagai pilihan cepat di pencarian.',
			'favoriteTags.pickerTitle' => 'Pilih Oreno3D',
			'favoriteTags.searchHint' => 'Cari berdasarkan nama atau asli',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('id'))(n, one: '${n} karya', other: '${n} karya', ), 
			'favoriteTags.browseEntry' => 'Telusuri origin / karakter / tag',
			'favoriteTags.favoritesSection' => 'Favorit',
			'favoriteTags.addFavorite' => 'Tambah',
			'favoriteTags.iwaraTitle' => 'Tag Iwara Favorit',
			'favoriteTags.oreno3dTitle' => 'Tag Oreno3D Favorit',
			'favoriteTags.changeTag' => 'Ubah tag',
			'favoriteTags.switchToText' => 'Pencarian teks',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Tag',
			'oreno3d.characters' => 'Karakter',
			'oreno3d.origin' => 'Asal',
			'oreno3d.thirdPartyTagsExplanation' => 'Informasi **tag**, **karakter**, dan **asal** yang ditampilkan di sini disediakan oleh situs pihak ketiga **Oreno3D** hanya sebagai referensi.\n\nKarena sumber informasi ini hanya tersedia dalam bahasa Jepang, saat ini belum ada penyesuaian internasionalisasi.\n\nJika Anda tertarik untuk berkontribusi pada upaya internasionalisasi, silakan kunjungi repositori untuk membantu meningkatkannya!',
			'oreno3d.sortTypes.hot' => 'Tren',
			'oreno3d.sortTypes.favorites' => 'Favorit',
			'oreno3d.sortTypes.latest' => 'Terbaru',
			'oreno3d.sortTypes.popularity' => 'Popularitas',
			'oreno3d.errors.requestFailed' => 'Permintaan gagal, kode status',
			'oreno3d.errors.connectionTimeout' => 'Waktu koneksi habis, silakan periksa koneksi jaringan',
			'oreno3d.errors.sendTimeout' => 'Waktu mengirim permintaan habis',
			'oreno3d.errors.receiveTimeout' => 'Waktu menerima respons habis',
			'oreno3d.errors.badCertificate' => 'Verifikasi sertifikat gagal',
			'oreno3d.errors.resourceNotFound' => 'Sumber daya yang diminta tidak ditemukan',
			'oreno3d.errors.accessDenied' => 'Akses ditolak, mungkin memerlukan autentikasi atau izin',
			'oreno3d.errors.serverError' => 'Kesalahan server internal',
			'oreno3d.errors.serviceUnavailable' => 'Layanan sementara tidak tersedia',
			'oreno3d.errors.requestCancelled' => 'Permintaan dibatalkan',
			'oreno3d.errors.connectionError' => 'Kesalahan koneksi jaringan, silakan periksa pengaturan jaringan',
			'oreno3d.errors.networkRequestFailed' => 'Permintaan jaringan gagal',
			'oreno3d.errors.searchVideoError' => 'Terjadi kesalahan tidak dikenal saat mencari video',
			'oreno3d.errors.getPopularVideoError' => 'Terjadi kesalahan tidak dikenal saat mengambil video populer',
			'oreno3d.errors.getVideoDetailError' => 'Terjadi kesalahan tidak dikenal saat mengambil detail video',
			'oreno3d.errors.parseVideoDetailError' => 'Terjadi kesalahan tidak dikenal saat mengambil dan mengurai detail video',
			'oreno3d.errors.downloadFileError' => 'Terjadi kesalahan tidak dikenal saat mengunduh file',
			'oreno3d.loading.gettingVideoInfo' => 'Mengambil informasi video...',
			'oreno3d.loading.cancel' => 'Batal',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Video tidak ditemukan atau telah dihapus',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'Tidak dapat memperoleh tautan pemutaran video',
			'oreno3d.messages.getVideoDetailFailed' => 'Gagal mengambil detail video',
			'signIn.pleaseLoginFirst' => 'Silakan masuk terlebih dahulu',
			'signIn.alreadySignedInToday' => 'Anda sudah melakukan presensi hari ini!',
			'signIn.youDidNotStickToTheSignIn' => 'Anda tidak konsisten dalam melakukan presensi.',
			'signIn.signInSuccess' => 'Presensi berhasil!',
			'signIn.signInFailed' => 'Presensi gagal, silakan coba lagi nanti',
			'signIn.consecutiveSignIns' => 'Presensi Berturut-turut',
			'signIn.failureReason' => 'Alasan Kegagalan',
			'signIn.selectDateRange' => 'Pilih Rentang Tanggal',
			'signIn.startDate' => 'Tanggal Mulai',
			'signIn.endDate' => 'Tanggal Akhir',
			'signIn.invalidDate' => 'Tanggal Tidak Valid',
			'signIn.invalidDateRange' => 'Rentang Tanggal Tidak Valid',
			'signIn.errorFormatText' => 'Kesalahan Format Tanggal',
			'signIn.errorInvalidText' => 'Rentang Tanggal Tidak Valid',
			'signIn.errorInvalidRangeText' => 'Rentang Tanggal Tidak Valid',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'Rentang tanggal tidak boleh lebih dari satu tahun',
			'signIn.signIn' => 'Presensi',
			'signIn.signInRecord' => 'Riwayat Presensi',
			'signIn.totalSignIns' => 'Total Presensi',
			'signIn.pleaseSelectSignInStatus' => 'Silakan pilih status presensi',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Silakan masuk terlebih dahulu untuk melihat langganan Anda.',
			'subscriptions.selectUser' => 'Pilih Pengguna',
			'subscriptions.noSubscribedUsers' => 'Tidak ada pengguna yang dilanggan',
			'subscriptions.showAllSubscribedUsersContent' => 'Tampilkan konten semua pengguna yang dilanggan',
			'videoDetail.pipMode' => 'Mode PiP',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Lanjutkan dari posisi terakhir: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Dilanjutkan dari ${position}',
			'videoDetail.restartFromBeginning' => 'Mulai dari awal',
			'videoDetail.dismissResumeTip' => 'Tutup',
			'videoDetail.localInfo.videoInfo' => 'Info Video',
			'videoDetail.localInfo.currentQuality' => 'Kualitas Saat Ini',
			'videoDetail.localInfo.duration' => 'Durasi',
			'videoDetail.localInfo.resolution' => 'Resolusi',
			'videoDetail.localInfo.fileInfo' => 'Info File',
			'videoDetail.localInfo.fileName' => 'Nama File',
			'videoDetail.localInfo.fileSize' => 'Ukuran File',
			'videoDetail.localInfo.filePath' => 'Jalur File',
			'videoDetail.localInfo.copyPath' => 'Salin Jalur',
			'videoDetail.localInfo.openFolder' => 'Buka Folder',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Jalur disalin ke papan klip',
			'videoDetail.localInfo.openFolderFailed' => 'Gagal membuka folder',
			'videoDetail.videoIdIsEmpty' => 'ID Video kosong',
			'videoDetail.videoInfoIsEmpty' => 'Info video kosong',
			'videoDetail.thisIsAPrivateVideo' => 'Ini adalah video privat',
			'videoDetail.getVideoInfoFailed' => 'Gagal mendapatkan info video, silakan coba lagi nanti',
			'videoDetail.noVideoSourceFound' => 'Tidak ada sumber video yang ditemukan',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Tag "${tagId}" disalin ke papan klip',
			'videoDetail.errorLoadingVideo' => 'Kesalahan memuat video',
			'videoDetail.play' => 'Putar',
			'videoDetail.pause' => 'Jeda',
			'videoDetail.exitAppFullscreen' => 'Keluar Layar Penuh Aplikasi',
			'videoDetail.enterAppFullscreen' => 'Masuk Layar Penuh Aplikasi',
			'videoDetail.exitSystemFullscreen' => 'Keluar Layar Penuh Sistem',
			'videoDetail.enterSystemFullscreen' => 'Masuk Layar Penuh Sistem',
			'videoDetail.seekTo' => 'Cari Ke',
			'videoDetail.switchResolution' => 'Ganti Resolusi',
			'videoDetail.switchPlaybackSpeed' => 'Ganti Kecepatan Pemutaran',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Mundur ${num} detik',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Maju Cepat ${num} detik',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Memutar pada kecepatan ${rate}x',
			'videoDetail.brightness' => 'Kecerahan',
			'videoDetail.brightnessLowest' => 'Kecerahan paling rendah',
			'videoDetail.volume' => 'Volume',
			'videoDetail.volumeMuted' => 'Volume dibisukan',
			'videoDetail.restoreDefaultZoom' => 'Pulihkan',
			'videoDetail.gestureGuide.sampleVideo' => 'Video contoh',
			'videoDetail.gestureGuide.title' => 'Panduan Gerakan & Interaksi',
			'videoDetail.gestureGuide.viewGuide' => 'Panduan Gerakan & Interaksi',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Luangkan beberapa detik untuk mempelajari gerakan pemutar. Anda dapat membuka kembali panduan ini kapan saja dari pengaturan pemutar.',
			'videoDetail.gestureGuide.startWatching' => 'Mengerti, mulai menonton',
			'videoDetail.gestureGuide.basicTitle' => 'Kontrol Dasar',
			'videoDetail.gestureGuide.zoomTitle' => 'Zoom / Putar / Geser',
			'videoDetail.gestureGuide.restoreTip' => 'Ketuk tombol "Pulihkan" di kanan bawah untuk mengatur ulang zoom, rotasi, dan posisi.',
			'videoDetail.gestureGuide.mTap' => 'Ketuk sekali: tampilkan / sembunyikan kontrol',
			'videoDetail.gestureGuide.mDoubleTap' => 'Ketuk dua kali: mundur (kiri) / jeda (tengah) / maju cepat (kanan)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Geser horizontal: mencari',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Geser vertikal: kecerahan (kiri) / volume (kanan)',
			'videoDetail.gestureGuide.mLongPress' => 'Tekan lama: percepatan sementara',
			'videoDetail.gestureGuide.mPinch' => 'Cubit dua jari: perbesar gambar',
			'videoDetail.gestureGuide.mRotate' => 'Putar dua jari: memutar gambar',
			'videoDetail.gestureGuide.dTap' => 'Klik: tampilkan / sembunyikan kontrol',
			'videoDetail.gestureGuide.dDoubleTap' => 'Klik dua kali: mundur (kiri) / jeda (tengah) / maju cepat (kanan)',
			'videoDetail.gestureGuide.dKeys' => 'Tombol pencarian: ketuk untuk melompat mundur / maju, tahan untuk mempercepat; tombol kecepatan: menyesuaikan kecepatan pemutaran selama pemutaran normal; Spasi: putar / jeda',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Cubit trackpad: perbesar gambar',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Putar trackpad: memutar gambar',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + roda: perbesar di sekitar kursor',
			'videoDetail.gestureGuide.dShiftWheel' => 'Shift + roda: putar di sekitar kursor',
			'videoDetail.gestureGuide.quest.title' => 'Nyaman di Quest',
			'videoDetail.gestureGuide.quest.intro' => 'Lihat kontrol mana yang melakukan apa, lalu cobalah di ruang Anda.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Video spasial',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Galeri spasial',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Untuk layar dan jendela di ruang Quest Anda. Buka kembali kapan saja dari pengaturan pemutar.',
			'videoDetail.gestureGuide.quest.catalog' => 'Jelajahi kontrol',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} dari ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Sebelumnya',
			'videoDetail.gestureGuide.quest.next' => 'Kontrol berikutnya',
			'videoDetail.gestureGuide.quest.replay' => 'Putar ulang demo',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Jeda demo',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Lanjutkan demo',
			'videoDetail.gestureGuide.quest.looping' => 'Demo kontrol',
			'videoDetail.gestureGuide.quest.still' => 'Ilustrasi diam',
			'videoDetail.gestureGuide.quest.done' => 'Mengerti, lanjutkan',
			'videoDetail.gestureGuide.quest.leftController' => 'Tangan kiri',
			'videoDetail.gestureGuide.quest.rightController' => 'Tangan kanan',
			'videoDetail.gestureGuide.quest.trigger' => 'Pemicu telunjuk',
			'videoDetail.gestureGuide.quest.grip' => 'Tombol pegangan',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Kedua tombol pegangan',
			'videoDetail.gestureGuide.quest.stick' => 'Stik analog',
			'videoDetail.gestureGuide.quest.handTracking' => 'Pelacakan tangan',
			'videoDetail.gestureGuide.quest.ready' => 'Siap',
			'videoDetail.gestureGuide.quest.press' => 'Tekan',
			'videoDetail.gestureGuide.quest.hold' => 'Tahan',
			'videoDetail.gestureGuide.quest.release' => 'Lepaskan',
			'videoDetail.gestureGuide.quest.result' => 'Lihat hasilnya',
			'videoDetail.gestureGuide.quest.pinch' => 'Cubit',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Arahkan dan pilih',
			'videoDetail.gestureGuide.quest.selectBody' => 'Arahkan sinar ke tombol, lalu tekan dan lepaskan pemicu telunjuk. Gunakan untuk memutar, pengaturan, dan penggeser di panel kontrol.',
			'videoDetail.gestureGuide.quest.selectHint' => 'Pemicu telunjuk berada di belakang permukaan tombol. Tombol pegangan pada gagang dalam berfungsi memegang jendela.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Tampilkan atau sembunyikan panel',
			'videoDetail.gestureGuide.quest.panelBody' => 'Arahkan ke luar panel kontrol, lalu ketuk pemicu telunjuk untuk menampilkan atau menyembunyikannya. Dengan pelacakan tangan, cubitan cepat di luar panel melakukan hal yang sama.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Gunakan ketukan singkat tanpa menyeret. Menahan dan menggerakkan adalah seret, bukan mengalihkan panel.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Putar dan jeda',
			'videoDetail.gestureGuide.quest.playBody' => 'Arahkan menjauh dari panel kontrol lalu tekan A di kanan atau X di kiri untuk memutar atau menjeda. Anda juga dapat memilih tombol putar di panel.',
			'videoDetail.gestureGuide.quest.playHint' => 'Pintasan bawaan ini dapat dinonaktifkan di pengaturan pemutar spasial. Saat mengarahkan ke panel, masukan akan masuk ke panel.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Geser dengan stik',
			'videoDetail.gestureGuide.quest.seekBody' => 'Geser salah satu stik ke kiri atau kanan untuk langkah 5 detik. Tahan untuk menggeser lebih cepat sambil mempratinjau waktu target. Lepaskan untuk menerapkan pencarian.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Jauhkan sinar pengontrol itu dari panel kontrol. Stik yang mengarah ke panel akan menggulir panel sebagai gantinya.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Jelajahi dengan stik',
			'videoDetail.gestureGuide.quest.browseBody' => 'Gerakkan salah satu stik ke kiri atau kanan untuk item sebelumnya atau berikutnya; tahan untuk terus menjelajah. Anda juga dapat memilih gambar mini di strip film.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Video dalam galeri juga merupakan item. Mengarahkan ke panel kontrol membuat stik menggulir panel.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Seret melintasi untuk membalik halaman',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Arahkan ke gambar, tahan pemicu telunjuk dan seret ke kiri. Lepaskan setelah isyarat balik halaman untuk maju; seret ke kanan untuk kembali. Cubit-lalu-seret juga berfungsi.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Gambar harus pada 1× untuk membalik halaman dengan menyeret. Video galeri juga mendukungnya. Panggung tetap diam hingga Anda melepaskan.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'Perbesar ke dalam gambar',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Arahkan ke detail pada gambar, tahan pemicu telunjuk, lalu dorong stik ke atas untuk memperbesar atau ke bawah untuk memperkecil. Zoom berjangkar di tempat Anda menekan.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Ini memperbesar gambar di dalam jendelanya. Tanpa menahan gambar, atas/bawah menyesuaikan jarak pandang.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Geser dan pulihkan gambar',
			'videoDetail.gestureGuide.quest.panBody' => 'Setelah diperbesar, tahan pemicu telunjuk dan seret untuk melihat sekeliling. Ketuk dua kali gambar untuk memperbesar ke 2,5× atau memulihkannya. Dengan tangan, cubit dua kali dengan cepat.',
			'videoDetail.gestureGuide.quest.panHint' => 'Menyeret akan menggeser gambar yang diperbesar. Pulihkan ke 1× sebelum menyeret untuk membalik halaman.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Mulai tayangan slide',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'Pada gambar, A / X memulai atau menjeda tayangan slide. Panel menawarkan interval 3, 5, 10, atau 20 detik serta kualitas gambar standar atau asli.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'Pada video galeri, A / X mengontrol pemutaran video tersebut. Pintasan pengontrol harus diaktifkan di pengaturan.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Pegang dan pindahkan layar',
			'videoDetail.gestureGuide.quest.moveBody' => 'Tahan tombol pegangan pada gagang dalam, gerakkan pengontrol untuk memposisikan layar, lalu lepaskan. Saat menonton, Anda dapat memegang layar tanpa mengarahkannya.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Mengarahkan ke jendela aplikasi atau panel kontrol akan memegang jendela itu terlebih dahulu. Pada video panoramik, memegang menyesuaikan orientasi.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Ubah ukuran dengan kedua tangan',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Tahan kedua tombol pegangan. Rentangkan tangan Anda untuk memperbesar layar, atau dekatkan untuk memperkecilnya. Dengan pelacakan tangan, tahan cubitan di kedua tangan.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Untuk layar datar atau melengkung, termasuk panggung galeri. Jauhkan sinar dari panel kontrol. Ini mengubah ukuran seluruh layar.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Sesuaikan jarak pandang',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Dorong stik ke atas untuk menjauhkan layar, atau ke bawah untuk mendekatkannya. Saat memegang jendela, atas/bawah memindahkan jendela itu. Sesuaikan volume di panel.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Arahkan menjauh dari panel kontrol. Menahan gambar mengubah atas/bawah menjadi zoom gambar; video panoramik menyesuaikan tampilan sebagai gantinya.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Gunakan tepi dan sudut',
			'videoDetail.gestureGuide.quest.resizeBody' => 'Bingkai akan menyala saat sinar Anda mendekati tepi. Tahan pemicu atau cubit pada tepi untuk memindahkan jendela; seret sudut untuk mengubah ukurannya.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Berfungsi pada jendela aplikasi, panel kontrol, dan layar. Jendela aplikasi mengubah lebar dan tinggi; layar mempertahankan rasio aspeknya.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Kembali dan buka pengaturan',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y kembali satu tingkat: menutup popup atau kembali ke beranda panel, menyembunyikan panel, lalu kembali ke aplikasi. Tombol Menu kiri membuka pengaturan spasial.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'Tombol Meta kanan milik sistem. Pemusatan ulang sistem membawa tampilan kembali ke depan sambil mempertahankan ukuran dan jarak layar.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Gunakan tangan Anda',
			'videoDetail.gestureGuide.quest.handsBody' => 'Dengan pelacakan tangan aktif, arahkan sinar sistem ke tombol, cubit ibu jari dan telunjuk Anda, lalu lepaskan. Gunakan panel untuk pemutaran, pencarian, dan navigasi galeri.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Cubit di luar untuk mengalihkan panel. Cubit tepi untuk memindahkan, sudut untuk mengubah ukuran, atau cubit dengan kedua tangan dan rentangkan untuk memperbesar layar.',
			'videoDetail.home' => 'Beranda',
			'videoDetail.videoPlayer' => 'Pemutar Video',
			'videoDetail.videoPlayerInfo' => 'Info Pemutar Video',
			'videoDetail.moreSettings' => 'Pengaturan Lainnya',
			'videoDetail.videoPlayerFeatureInfo' => 'Info Fitur Pemutar Video',
			'videoDetail.autoRewind' => 'Mundur Otomatis',
			'videoDetail.rewindAndFastForward' => 'Mundur dan Maju Cepat',
			'videoDetail.volumeAndBrightness' => 'Volume dan Kecerahan',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Ketuk Ganda Area Tengah untuk Jeda atau Putar',
			'videoDetail.showVerticalVideoInFullScreen' => 'Tampilkan Video Vertikal dalam Layar Penuh',
			'videoDetail.keepLastVolumeAndBrightness' => 'Pertahankan Volume dan Kecerahan Terakhir',
			'videoDetail.setProxy' => 'Atur Proksi',
			'videoDetail.moreFeaturesToBeDiscovered' => 'Lebih Banyak Fitur untuk Ditemukan...',
			'videoDetail.videoPlayerSettings' => 'Pengaturan Pemutar Video',
			'videoDetail.commentCount' => ({required Object num}) => '${num} komentar',
			'videoDetail.writeYourCommentHere' => 'Tulis komentar Anda di sini...',
			'videoDetail.authorOtherVideos' => 'Video Lain dari Penulis',
			'videoDetail.relatedVideos' => 'Video Terkait',
			'videoDetail.privateVideo' => 'Ini adalah video privat',
			'videoDetail.externalVideo' => 'Ini adalah video eksternal',
			'videoDetail.openInBrowser' => 'Buka di Peramban',
			'videoDetail.resourceDeleted' => 'Video ini tampaknya telah dihapus :/',
			'videoDetail.noDownloadUrl' => 'Tidak ada URL unduhan',
			'videoDetail.startDownloading' => 'Mulai mengunduh',
			'videoDetail.downloadFailed' => 'Unduhan gagal, silakan coba lagi nanti',
			'videoDetail.downloadSuccess' => 'Unduhan berhasil',
			'videoDetail.download' => 'Unduh',
			'videoDetail.downloadManager' => 'Pengelola Unduhan',
			'videoDetail.resourceNotFound' => 'Sumber daya tidak ditemukan',
			'videoDetail.videoLoadError' => 'Kesalahan memuat video',
			'videoDetail.authorNoOtherVideos' => 'Penulis tidak memiliki video lain',
			'videoDetail.noRelatedVideos' => 'Tidak ada video terkait',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Kesalahan saat memuat sumber video',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Kesalahan saat menyiapkan pemantau',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Kesalahan server terdeteksi, otomatis beralih rute dan mencoba lagi',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Mengambil info video...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Mengambil sumber video...',
			'videoDetail.skeleton.loadingVideo' => 'Memuat video...',
			'videoDetail.skeleton.applyingSolution' => 'Menerapkan solusi...',
			'videoDetail.skeleton.addingListeners' => 'Menambahkan pemantau...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Berhasil mengambil durasi video, mulai memuat video...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Pemuatan selesai',
			'videoDetail.cast.dlnaCast' => 'Siarkan',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'Gagal memulai pencarian penyiaran: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Mulai menyiarkan ke ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Penyiaran gagal: ${error}\nSilakan coba cari ulang perangkat atau ganti jaringan',
			'videoDetail.cast.castStopped' => 'Penyiaran dihentikan',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Pemutar Media',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Server Media',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Router',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Perangkat Dasar',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Lampu Pintar',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'Titik Akses WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'Perangkat Koneksi WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'Pencetak',
			'videoDetail.cast.deviceTypes.scanner' => 'Pemindai',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Kamera Keamanan Digital',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Perangkat Tidak Dikenal',
			'videoDetail.cast.currentPlatformNotSupported' => 'Platform saat ini tidak mendukung penyiaran',
			'videoDetail.cast.unableToGetVideoUrl' => 'Tidak dapat memperoleh URL video, silakan coba lagi nanti',
			'videoDetail.cast.stopCasting' => 'Hentikan penyiaran',
			'videoDetail.cast.dlnaCastSheet.title' => 'Penyiaran Jarak Jauh',
			'videoDetail.cast.dlnaCastSheet.close' => 'Tutup',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Mencari perangkat...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Klik tombol cari untuk mencari ulang perangkat penyiaran',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Mencari',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Cari Lagi',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'Tidak ada perangkat penyiaran yang ditemukan\nPastikan perangkat berada di jaringan yang sama',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Mencari perangkat, harap tunggu...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Siarkan',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Terhubung ke: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Tidak ada perangkat terhubung',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Hentikan Penyiaran',
			'videoDetail.likeAvatars.dialogTitle' => 'Siapa yang diam-diam menyukai',
			'videoDetail.likeAvatars.dialogDescription' => 'Penasaran siapa mereka? Telusuri "Album Suka" ini~',
			'videoDetail.likeAvatars.closeTooltip' => 'Tutup',
			'videoDetail.likeAvatars.retry' => 'Coba Lagi',
			'videoDetail.likeAvatars.noLikesYet' => 'Belum ada yang muncul di sini. Jadilah yang pertama!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Halaman ${page} / ${totalPages} · Total ${totalCount} orang',
			'videoDetail.likeAvatars.prevPage' => 'Halaman Sebelumnya',
			'videoDetail.likeAvatars.nextPage' => 'Halaman Berikutnya',
			'share.sharePlayList' => 'Bagikan Daftar Putar',
			'share.wowDidYouSeeThis' => 'Wow, apakah Anda melihat ini?',
			'share.nameIs' => 'Nama adalah',
			'share.clickLinkToView' => 'Klik tautan untuk melihat',
			'share.iReallyLikeThis' => 'Saya sangat menyukai ini',
			'share.shareFailed' => 'Gagal membagikan, silakan coba lagi nanti',
			'share.share' => 'Bagikan',
			'share.shareAsImage' => 'Bagikan sebagai Gambar',
			'share.shareAsText' => 'Bagikan sebagai Teks',
			'share.shareAsImageDesc' => 'Bagikan sampul video sebagai gambar',
			'share.shareAsTextDesc' => 'Bagikan detail video sebagai teks',
			'share.shareAsImageFailed' => 'Gagal membagikan sampul video sebagai gambar, silakan coba lagi nanti',
			'share.shareAsTextFailed' => 'Gagal membagikan detail video sebagai teks, silakan coba lagi nanti',
			'share.shareVideo' => 'Bagikan Video',
			'share.authorIs' => 'Penulis adalah',
			'share.shareGallery' => 'Bagikan Galeri',
			'share.galleryTitleIs' => 'Judul galeri adalah',
			'share.galleryAuthorIs' => 'Penulis galeri adalah',
			'share.shareUser' => 'Bagikan Pengguna',
			'share.userNameIs' => 'Nama pengguna adalah',
			'share.userAuthorIs' => 'Penulis pengguna adalah',
			'share.comments' => 'Komentar',
			'share.shareThread' => 'Bagikan Utas',
			'share.views' => 'Tayangan',
			'share.sharePost' => 'Bagikan Postingan',
			'share.postTitleIs' => 'Judul postingan adalah',
			'share.postAuthorIs' => 'Penulis postingan adalah',
			'markdown.markdownSyntax' => 'Sintaks Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Sintaks Markdown Khusus Iwara',
			'markdown.internalLink' => 'Tautan Internal',
			'markdown.supportAutoConvertLinkBelow' => 'Mendukung konversi otomatis tautan berikut:',
			'markdown.convertLinkExample' => '🎬 Tautan Video\n🖼️ Tautan Gambar\n👤 Tautan Pengguna\n📌 Tautan Forum\n🎵 Tautan Daftar Putar\n💬 Tautan Topik',
			'markdown.mentionUser' => 'Sebutkan Pengguna',
			'markdown.mentionUserDescription' => 'Masukkan @ diikuti nama pengguna, akan otomatis diubah menjadi tautan pengguna',
			'markdown.markdownBasicSyntax' => 'Sintaks Dasar Markdown',
			'markdown.paragraphAndLineBreak' => 'Paragraf dan Pemisah Baris',
			'markdown.paragraphAndLineBreakDescription' => 'Paragraf dipisahkan oleh satu baris, dan dua spasi di akhir baris akan diubah menjadi pemisah baris',
			'markdown.paragraphAndLineBreakSyntax' => 'Ini adalah paragraf pertama\n\nIni adalah paragraf kedua\nBaris ini diakhiri dua spasi  \nakan diubah menjadi pemisah baris',
			'markdown.textStyle' => 'Gaya Teks',
			'markdown.textStyleDescription' => 'Gunakan simbol khusus untuk mengapit teks agar mengubah gayanya',
			'markdown.textStyleSyntax' => '**Teks Tebal**\n*Teks Miring*\n~~Teks Coret~~\n`Teks Kode`',
			'markdown.quote' => 'Kutipan',
			'markdown.quoteDescription' => 'Gunakan simbol > untuk membuat kutipan, beberapa > untuk membuat kutipan bertingkat',
			'markdown.quoteSyntax' => '> Ini kutipan tingkat pertama\n>> Ini kutipan tingkat kedua',
			'markdown.list' => 'Daftar',
			'markdown.listDescription' => 'Buat daftar berurut dengan angka+titik, buat daftar tak berurut dengan -',
			'markdown.listSyntax' => '1. Item pertama\n2. Item kedua\n\n- Item tak berurut\n  - Subitem\n  - Subitem lain',
			'markdown.linkAndImage' => 'Tautan dan Gambar',
			'markdown.linkAndImageDescription' => 'Format tautan: [teks](URL)\nFormat gambar: ![deskripsi](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[teks tautan](${link})\n![deskripsi gambar](${imgUrl})',
			'markdown.title' => 'Judul',
			'markdown.titleDescription' => 'Gunakan simbol # untuk membuat judul, jumlahnya menunjukkan tingkat',
			'markdown.titleSyntax' => '# Judul tingkat pertama\n## Judul tingkat kedua\n### Judul tingkat ketiga',
			'markdown.separator' => 'Pemisah',
			'markdown.separatorDescription' => 'Buat pemisah dengan tiga simbol - atau lebih',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Sintaks',
			'forum.recent' => 'Terkini',
			'forum.category' => 'Kategori',
			'forum.lastReply' => 'Balasan Terakhir',
			'forum.sitewide.badge' => 'Situs',
			'forum.sitewide.title' => 'Pengumuman Situs',
			'forum.sitewide.readMore' => 'Baca selengkapnya',
			'forum.errors.pleaseSelectCategory' => 'Silakan pilih kategori',
			'forum.errors.threadLocked' => 'Topik ini terkunci, tidak dapat membalas',
			'forum.createPost' => 'Buat Postingan',
			'forum.title' => 'Judul',
			'forum.enterTitle' => 'Masukkan Judul',
			'forum.content' => 'Konten',
			'forum.enterContent' => 'Masukkan Konten',
			'forum.writeYourContentHere' => 'Tulis konten Anda di sini...',
			'forum.posts' => 'Postingan',
			'forum.threads' => 'Topik',
			'forum.forum' => 'Forum',
			'forum.createThread' => 'Buat Topik',
			'forum.selectCategory' => 'Pilih Kategori',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Jeda tersisa ${minutes} menit ${seconds} detik',
			'forum.groups.administration' => 'Administrasi',
			'forum.groups.global' => 'Global',
			'forum.groups.chinese' => 'Mandarin',
			'forum.groups.japanese' => 'Jepang',
			'forum.groups.korean' => 'Korea',
			'forum.groups.other' => 'Lainnya',
			'forum.leafNames.announcements' => 'Pengumuman',
			'forum.leafNames.feedback' => 'Masukan',
			'forum.leafNames.support' => 'Dukungan',
			'forum.leafNames.general' => 'Umum',
			'forum.leafNames.guides' => 'Panduan',
			'forum.leafNames.questions' => 'Pertanyaan',
			'forum.leafNames.requests' => 'Permintaan',
			'forum.leafNames.sharing' => 'Berbagi',
			'forum.leafNames.general_zh' => 'Umum',
			'forum.leafNames.questions_zh' => 'Pertanyaan',
			'forum.leafNames.requests_zh' => 'Permintaan',
			'forum.leafNames.support_zh' => 'Dukungan',
			'forum.leafNames.general_ja' => 'Umum',
			'forum.leafNames.questions_ja' => 'Pertanyaan',
			'forum.leafNames.requests_ja' => 'Permintaan',
			'forum.leafNames.support_ja' => 'Dukungan',
			'forum.leafNames.korean' => 'Korea',
			'forum.leafNames.other' => 'Lainnya',
			'forum.leafDescriptions.announcements' => 'Notifikasi dan pengumuman resmi yang penting',
			'forum.leafDescriptions.feedback' => 'Masukan tentang fitur dan layanan situs web',
			'forum.leafDescriptions.support' => 'Bantuan untuk menyelesaikan masalah terkait situs web',
			'forum.leafDescriptions.general' => 'Bahas topik apa saja',
			'forum.leafDescriptions.guides' => 'Bagikan pengalaman dan tutorial Anda',
			'forum.leafDescriptions.questions' => 'Ajukan pertanyaan Anda',
			'forum.leafDescriptions.requests' => 'Kirimkan permintaan Anda',
			'forum.leafDescriptions.sharing' => 'Bagikan konten yang menarik',
			'forum.leafDescriptions.general_zh' => 'Bahas topik apa saja',
			'forum.leafDescriptions.questions_zh' => 'Ajukan pertanyaan Anda',
			'forum.leafDescriptions.requests_zh' => 'Kirimkan permintaan Anda',
			'forum.leafDescriptions.support_zh' => 'Bantuan untuk menyelesaikan masalah terkait situs web',
			'forum.leafDescriptions.general_ja' => 'Bahas topik apa saja',
			'forum.leafDescriptions.questions_ja' => 'Ajukan pertanyaan Anda',
			'forum.leafDescriptions.requests_ja' => 'Kirimkan permintaan Anda',
			'forum.leafDescriptions.support_ja' => 'Bantuan untuk menyelesaikan masalah terkait situs web',
			'forum.leafDescriptions.korean' => 'Diskusi terkait bahasa Korea',
			'forum.leafDescriptions.other' => 'Konten lain yang tidak terklasifikasi',
			'forum.reply' => 'Balas',
			'forum.pendingReview' => 'Menunggu Tinjauan',
			'forum.editedAt' => 'Diubah Pada',
			_ => null,
		} ?? switch (path) {
			'forum.copySuccess' => 'Disalin ke papan klip',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Disalin ke papan klip: ${str}',
			'forum.editReply' => 'Ubah Balasan',
			'forum.editTitle' => 'Ubah Judul',
			'forum.submit' => 'Kirim',
			'notifications.errors.unsupportedNotificationType' => 'Jenis notifikasi tidak didukung',
			'notifications.errors.unknownUser' => 'Pengguna tidak dikenal',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Jenis notifikasi tidak didukung: ${type}',
			'notifications.errors.unknownNotificationType' => 'Jenis notifikasi tidak dikenal',
			'notifications.notifications' => 'Notifikasi',
			'notifications.profile' => 'Profil',
			'notifications.postedNewComment' => 'Memposting komentar baru',
			'notifications.inYour' => 'Di',
			'notifications.video' => 'Video',
			'notifications.repliedYourVideoComment' => 'Membalas komentar video Anda',
			'notifications.copyInfoToClipboard' => 'Salin info notifikasi ke papan klip',
			'notifications.copySuccess' => 'Disalin ke papan klip',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Disalin ke papan klip: ${str}',
			'notifications.markAllAsRead' => 'Tandai semua telah dibaca',
			'notifications.markAllAsReadSuccess' => 'Semua notifikasi telah ditandai sebagai dibaca',
			'notifications.markAllAsReadFailed' => 'Gagal menandai semua telah dibaca',
			'notifications.markSelectedAsRead' => 'Tandai yang dipilih sebagai dibaca',
			'notifications.markSelectedAsReadSuccess' => 'Notifikasi yang dipilih telah ditandai sebagai dibaca',
			'notifications.markSelectedAsReadFailed' => 'Gagal menandai yang dipilih sebagai dibaca',
			'notifications.markAsRead' => 'Tandai sebagai dibaca',
			'notifications.markAsReadSuccess' => 'Notifikasi telah ditandai sebagai dibaca',
			'notifications.markAsReadFailed' => 'Gagal menandai notifikasi sebagai dibaca',
			'notifications.notificationTypeHelp' => 'Bantuan Jenis Notifikasi',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Karena kurangnya detail jenis notifikasi, jenis yang didukung mungkin tidak mencakup pesan yang Anda terima saat ini',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Jika Anda bersedia membantu kami meningkatkan dukungan jenis notifikasi',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Salin informasi notifikasi\n2. 🐞 Kirim issue ke repositori proyek\n\n⚠️ Catatan: Informasi notifikasi dapat berisi privasi pribadi, jika Anda tidak ingin mempublikasikannya, Anda juga dapat mengirimkannya ke penulis proyek melalui email.',
			'notifications.goToRepository' => 'Buka Repositori',
			'notifications.copy' => 'Salin',
			'notifications.commentApproved' => 'Komentar Disetujui',
			'notifications.repliedYourProfileComment' => 'Membalas komentar profil Anda',
			'notifications.kReplied' => 'membalas komentar Anda di',
			'notifications.kCommented' => 'mengomentari',
			'notifications.kVideo' => 'video',
			'notifications.kGallery' => 'galeri',
			'notifications.kProfile' => 'profil',
			'notifications.kThread' => 'utas',
			'notifications.kPost' => 'postingan',
			'notifications.kCommentSection' => 'bagian komentar',
			'notifications.kApprovedComment' => 'Komentar disetujui',
			'notifications.kApprovedVideo' => 'Video disetujui',
			'notifications.kApprovedGallery' => 'Galeri disetujui',
			'notifications.kApprovedThread' => 'Utas disetujui',
			'notifications.kApprovedPost' => 'Postingan disetujui',
			'notifications.kApprovedForumPost' => 'Postingan forum disetujui',
			'notifications.kRejectedContent' => 'Peninjauan konten ditolak',
			'notifications.kUnknownType' => 'Jenis notifikasi tidak dikenal',
			'conversation.errors.pleaseSelectAUser' => 'Silakan pilih pengguna',
			'conversation.errors.pleaseEnterATitle' => 'Silakan masukkan judul',
			'conversation.errors.clickToSelectAUser' => 'Klik untuk memilih pengguna',
			'conversation.errors.loadFailedClickToRetry' => 'Gagal memuat, klik untuk mencoba lagi',
			'conversation.errors.loadFailed' => 'Gagal memuat',
			'conversation.errors.clickToRetry' => 'Klik untuk mencoba lagi',
			'conversation.errors.noMoreConversations' => 'Tidak ada percakapan lagi',
			'conversation.conversation' => 'Percakapan',
			'conversation.startConversation' => 'Mulai Percakapan',
			'conversation.noConversation' => 'Tidak ada percakapan',
			'conversation.selectFromLeftListAndStartConversation' => 'Pilih dari daftar kiri dan mulai percakapan',
			'conversation.title' => 'Judul',
			'conversation.body' => 'Isi',
			'conversation.selectAUser' => 'Pilih pengguna',
			'conversation.searchUsers' => 'Cari pengguna...',
			'conversation.tmpNoConversions' => 'Tidak ada percakapan',
			'conversation.deleteThisMessage' => 'Hapus pesan ini',
			'conversation.deleteThisMessageSubtitle' => 'Tindakan ini tidak dapat dibatalkan',
			'conversation.writeMessageHere' => 'Tulis pesan di sini...',
			'conversation.lastMessageFromMe' => 'Anda: ',
			'conversation.sendMessage' => 'Kirim pesan',
			'splash.errors.initializationFailed' => 'Inisialisasi gagal, silakan mulai ulang aplikasi',
			'splash.preparing' => 'Mempersiapkan...',
			'splash.initializing' => 'Menginisialisasi...',
			'splash.loading' => 'Memuat...',
			'splash.ready' => 'Siap',
			'splash.initializingMessageService' => 'Menginisialisasi layanan pesan...',
			'download.errors.imageModelNotFound' => 'Model gambar tidak ditemukan',
			'download.errors.downloadFailed' => 'Unduhan gagal',
			'download.errors.videoInfoNotFound' => 'Info video tidak ditemukan',
			'download.errors.downloadTaskAlreadyExists' => 'Tugas unduhan sudah ada',
			'download.errors.downloadTaskSavePathConflict' => 'Jalur penyimpanan sudah digunakan oleh tugas lain',
			'download.errors.videoAlreadyDownloaded' => 'Video sudah diunduh',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'Gagal menambahkan tugas unduhan: ${errorInfo}',
			'download.errors.userPausedDownload' => 'Pengguna menjeda unduhan',
			'download.errors.unknown' => 'Tidak diketahui',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Kesalahan sistem berkas: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Kesalahan tidak diketahui: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'Gagal menulis berkas: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Koneksi habis waktu',
			'download.errors.sendTimeout' => 'Waktu pengiriman habis',
			'download.errors.receiveTimeout' => 'Waktu penerimaan habis',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Kesalahan server: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Kesalahan jaringan tidak diketahui',
			'download.errors.sslHandshakeFailed' => 'Handshake SSL gagal, silakan periksa jaringan Anda',
			'download.errors.connectionFailed' => 'Koneksi gagal, silakan periksa jaringan Anda',
			'download.errors.serviceIsClosing' => 'Layanan unduhan sedang ditutup',
			'download.errors.partialDownloadFailed' => 'Unduhan konten sebagian gagal',
			'download.errors.noDownloadTask' => 'Tidak ada tugas unduhan',
			'download.errors.taskNotFoundOrDataError' => 'Tugas tidak ditemukan atau data bermasalah',
			'download.errors.fileNotFound' => 'Berkas tidak ditemukan',
			'download.errors.openFolderFailed' => 'Gagal membuka folder',
			'download.errors.copyDownloadUrlFailed' => 'Gagal menyalin URL unduhan',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'Gagal membuka folder: ${message}',
			'download.errors.directoryNotFound' => 'Direktori tidak ditemukan',
			'download.errors.copyFailed' => 'Gagal menyalin',
			'download.errors.openFileFailed' => 'Gagal membuka berkas',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'Gagal membuka berkas: ${message}',
			'download.errors.playLocallyFailed' => 'Gagal memutar secara lokal',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'Gagal memutar secara lokal: ${message}',
			'download.errors.noDownloadSource' => 'Tidak ada sumber unduhan',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'Tidak ada sumber unduhan, harap tunggu hingga pemuatan informasi selesai lalu coba lagi',
			'download.errors.noActiveDownloadTask' => 'Tidak ada tugas unduhan aktif',
			'download.errors.noFailedDownloadTask' => 'Tidak ada tugas unduhan yang gagal',
			'download.errors.noCompletedDownloadTask' => 'Tidak ada tugas unduhan yang selesai',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'Tugas sudah selesai, jangan tambahkan lagi',
			'download.errors.linkExpiredTryAgain' => 'Tautan kedaluwarsa, mencoba mendapatkan tautan unduhan baru',
			'download.errors.linkExpiredTryAgainSuccess' => 'Tautan kedaluwarsa, berhasil mendapatkan tautan unduhan baru',
			'download.errors.linkExpiredTryAgainFailed' => 'Tautan kedaluwarsa, gagal mendapatkan tautan unduhan baru',
			'download.errors.taskDeleted' => 'Tugas dihapus',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Format gambar tidak didukung: ${format}',
			'download.errors.deleteFileError' => 'Gagal menghapus berkas, mungkin karena berkas sedang digunakan proses lain',
			'download.errors.deleteTaskError' => 'Gagal menghapus tugas',
			'download.errors.canNotRefreshVideoTask' => 'Gagal menyegarkan tugas video',
			'download.errors.videoRemovedCanNotRefresh' => 'Video ini telah dihapus atau tidak lagi ada, sehingga tautan unduhan tidak dapat disegarkan',
			'download.errors.videoInaccessibleCanNotRefresh' => 'Video ini tidak dapat diakses, mungkin bersifat privat atau Anda perlu masuk lagi',
			'download.errors.videoQualityGone' => 'Kualitas ini tidak lagi tersedia, silakan tambahkan unduhan lagi',
			'download.errors.refreshLinkNetworkFailed' => 'Kesalahan jaringan, tautan unduhan tidak dapat disegarkan saat ini, silakan coba lagi nanti',
			'download.errors.taskAlreadyProcessing' => 'Tugas sedang diproses',
			'download.errors.taskNotFound' => 'Tugas tidak ditemukan',
			'download.errors.failedToLoadTasks' => 'Gagal memuat tugas',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'Unduhan sebagian gagal: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Format gambar tidak didukung: ${extension}, Anda dapat mencoba mengunduhnya ke perangkat untuk melihatnya',
			'download.errors.imageLoadFailed' => 'Gagal memuat gambar',
			'download.errors.pleaseTryOtherViewer' => 'Silakan coba gunakan penampil lain untuk membuka',
			'download.downloadList' => 'Daftar Unduhan',
			'download.viewDownloadList' => 'Lihat Daftar Unduhan',
			'download.download' => 'Unduh',
			'download.selectDownloadTitle' => 'Pilih Unduhan',
			'download.qualitySectionLabel' => 'Kualitas',
			'download.categorySectionLabel' => 'Kategori',
			'download.saveToPreviewLabel' => 'Akan disimpan ke',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Nama file saran: ${name} (bisa diubah di dialog sistem)',
			'download.lastUsedBadge' => 'Terakhir digunakan',
			'download.pickedBadge' => 'Dipilih',
			'download.startDownloading' => 'Mulai Mengunduh',
			'download.clearAllFailedTasks' => 'Bersihkan Semua Tugas Gagal',
			'download.clearAllFailedTasksConfirmation' => 'Apakah Anda yakin ingin membersihkan semua tugas unduhan yang gagal? Berkas dari tugas-tugas ini juga akan dihapus.',
			'download.clearAllFailedTasksSuccess' => 'Semua tugas yang gagal telah dibersihkan',
			'download.clearAllFailedTasksError' => 'Terjadi kesalahan saat membersihkan tugas yang gagal',
			'download.downloadStatus' => 'Status Unduhan',
			'download.imageList' => 'Daftar Gambar',
			'download.retryDownload' => 'Coba Unduh Lagi',
			'download.notDownloaded' => 'Belum Diunduh',
			'download.downloaded' => 'Terunduh',
			'download.waitingForDownload' => 'Menunggu Unduhan',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Mengunduh (${downloaded}/${total} gambar ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Mengunduh (${downloaded} gambar)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Dijeda (${downloaded}/${total} gambar ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'Dijeda (${downloaded} gambar)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Terunduh (Total ${total} gambar)',
			'download.viewVideoDetail' => 'Lihat Rincian Video',
			'download.viewGalleryDetail' => 'Lihat Rincian Galeri',
			'download.moreOptions' => 'Opsi Lainnya',
			'download.openFile' => 'Buka Berkas',
			'download.playLocally' => 'Putar Secara Lokal',
			'download.pause' => 'Jeda',
			'download.resume' => 'Lanjutkan',
			'download.copyDownloadUrl' => 'Salin URL Unduhan',
			'download.showInFolder' => 'Tampilkan di Folder',
			'download.deleteTask' => 'Hapus Tugas',
			'download.deleteTaskConfirmation' => 'Apakah Anda yakin ingin menghapus tugas unduhan ini?\nBerkas tugas juga akan dihapus.',
			'download.forceDeleteTask' => 'Paksa Hapus Tugas',
			'download.forceDeleteTaskConfirmation' => 'Apakah Anda yakin ingin memaksa menghapus tugas unduhan ini?\nBerkas tugas juga akan dihapus, meskipun berkas sedang digunakan.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Mengunduh ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Mengunduh ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'Dijeda ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'Dijeda • Terunduh ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Terunduh • ${size}',
			'download.copyDownloadUrlSuccess' => 'URL unduhan disalin',
			'download.totalImageNums' => ({required Object num}) => '${num} gambar',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Mengunduh ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'Mengunduh',
			'download.failed' => 'Gagal',
			'download.completed' => 'Selesai',
			'download.downloadDetail' => 'Rincian Unduhan',
			'download.copy' => 'Salin',
			'download.copySuccess' => 'Disalin',
			'download.waiting' => 'Menunggu',
			'download.paused' => 'Dijeda',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Mengunduh ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Unduhan Galeri Selesai: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Unduhan Selesai: ${fileName}',
			'download.searchTasks' => 'Cari tugas...',
			'download.statusLabel' => ({required Object label}) => 'Status: ${label}',
			'download.allStatus' => 'Semua Status',
			'download.typeLabel' => ({required Object label}) => 'Jenis: ${label}',
			'download.allTypes' => 'Semua Jenis',
			'download.taskType' => 'Jenis',
			'download.video' => 'Video',
			'download.gallery' => 'Galeri',
			'download.other' => 'Lainnya',
			'download.clearFilters' => 'Bersihkan filter',
			'download.pauseAll' => 'Jeda semua',
			'download.resumeAll' => 'Mulai semua',
			'download.remainingTime' => ({required Object time}) => 'sisa ${time}',
			'download.timeline.today' => 'Hari ini',
			'download.timeline.yesterday' => 'Kemarin',
			'download.timeline.thisWeek' => 'Minggu ini',
			'download.timeline.thisMonth' => 'Bulan ini',
			'download.errorTypes.network' => 'Masalah jaringan, coba lagi mungkin membantu',
			'download.errorTypes.serverRejected' => 'Ditolak oleh server, Anda mungkin perlu masuk lagi',
			'download.errorTypes.notFound' => 'Sumber daya hilang atau telah dihapus',
			'download.errorTypes.diskFull' => 'Ruang penyimpanan tidak mencukupi',
			'download.errorTypes.fileInUse' => 'Berkas sedang digunakan oleh program lain',
			'download.errorTypes.permission' => 'Tidak ada izin menulis',
			'download.errorTypes.cancelled' => 'Dibatalkan',
			'download.errorTypes.unknown' => 'Kesalahan tidak diketahui',
			'download.errorDetailCopied' => 'Rincian kesalahan disalin',
			'download.errorDetailCopyHint' => 'Tekan lama untuk menyalin rincian kesalahan',
			'download.restoredPaused.banner' => ({required Object num}) => '${num} tugas yang belum selesai dari sesi terakhir telah dijeda',
			'download.restoredPaused.resume' => 'Lanjutkan semua',
			'download.restoredPaused.dismiss' => 'Tutup',
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
			'download.emptyTaskList' => 'Belum ada tugas unduhan',
			'download.noMatchingTasks' => 'Tidak ada tugas yang cocok',
			'download.deleteByDate.menuTitle' => 'Hapus berdasarkan tanggal',
			'download.deleteByDate.dialogTitle' => 'Hapus berdasarkan tanggal',
			'download.deleteByDate.description' => 'Hapus tugas unduhan secara massal berdasarkan tanggal pembuatan. Tugas yang berkasnya sedang digunakan akan dilewati; tugas yang berkasnya sudah tidak ada akan dibersihkan.',
			'download.deleteByDate.modeRange' => 'Rentang tanggal',
			'download.deleteByDate.modeDays' => 'Lebih lama dari',
			'download.deleteByDate.startDate' => 'Tanggal mulai',
			'download.deleteByDate.endDate' => 'Tanggal akhir',
			'download.deleteByDate.notSet' => 'Belum diatur',
			'download.deleteByDate.daysUnit' => 'hari',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Hapus tugas yang dibuat lebih dari ${days} hari lalu',
			'download.deleteByDate.noMatch' => 'Tidak ada tugas yang cocok dengan kondisi yang dipilih',
			'download.deleteByDate.invalidRange' => 'Tanggal mulai harus sama dengan atau sebelum tanggal akhir',
			'download.deleteByDate.confirmTitle' => 'Konfirmasi penghapusan',
			'download.deleteByDate.confirmContent' => ({required Object count}) => 'Hapus ${count} tugas unduhan dan berkasnya? Tindakan ini tidak dapat dibatalkan.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Menghapus ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => 'Menghapus ${count} tugas',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => 'Menghapus ${deleted} tugas; ${skipped} dilewati (sedang digunakan)',
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
			'download.category.manageTitle' => 'Kelola kategori',
			'download.category.label' => 'Kategori',
			'download.category.uncategorized' => 'Tanpa Kategori',
			'download.category.manage' => 'Kelola',
			'download.category.createShortcut' => 'Baru',
			'download.category.newCategoryHint' => 'Nama kategori baru',
			'download.category.createSuccess' => 'Kategori dibuat',
			'download.category.createFailed' => 'Gagal membuat kategori',
			'download.category.nameEmpty' => 'Nama kategori tidak boleh kosong',
			'download.category.emptyHint' => 'Belum ada kategori. Buat satu untuk mengatur unduhan Anda.',
			'download.category.moveTo' => 'Pindahkan ke kategori',
			'download.category.moveToWithCount' => ({required Object count}) => 'Pindahkan ${count} item ke…',
			'download.category.moveSuccess' => ({required Object title}) => 'Dipindahkan ke ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Dipindahkan ke Tanpa Kategori',
			'download.category.moveFailed' => 'Gagal memindahkan',
			'download.category.renameTitle' => 'Ganti nama kategori',
			'download.category.renameHint' => 'Masukkan nama kategori',
			'download.category.renameSuccess' => 'Nama kategori diubah',
			'download.category.renameFailed' => 'Gagal mengganti nama kategori',
			'download.category.deleteTitle' => 'Hapus kategori',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => 'Hapus kategori "${title}"? ${count} item di dalamnya akan dipindahkan ke Tanpa Kategori. Tidak ada berkas yang dihapus.',
			'download.category.deleteSuccess' => 'Kategori dihapus',
			'download.category.deleteFailed' => 'Gagal menghapus kategori',
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
			'download.maxConcurrentDownloads' => 'Unduhan bersamaan maksimum',
			_ => null,
		} ?? switch (path) {
			'download.maxConcurrentDownloadsDesc' => 'Jumlah tugas yang diunduh pada waktu bersamaan (1-5)',
			'download.stillInDevelopment' => 'Masih dalam pengembangan',
			'download.saveToAppDirectory' => 'Simpan ke direktori aplikasi',
			'download.alreadyDownloadedWithQuality' => 'Sudah diunduh dengan kualitas yang sama, lanjutkan pengunduhan?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Sudah diunduh dengan kualitas: ${qualities}, lanjutkan pengunduhan?',
			'download.otherQualities' => 'Kualitas lain',
			'download.batchDownload.title' => 'Unduhan Massal',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Tugas sedang berjalan, mohon tunggu.',
			'download.batchDownload.userCancelled' => 'Dibatalkan pengguna',
			'download.batchDownload.failedToGetVideoInfo' => 'Gagal mendapatkan informasi video',
			'download.batchDownload.failedToGetVideoSource' => 'Gagal mendapatkan sumber video',
			'download.batchDownload.failedToGetGalleryInfo' => 'Gagal mendapatkan informasi galeri',
			'download.batchDownload.galleryNoImages' => 'Galeri tidak memiliki gambar',
			'download.batchDownload.failedToGetSavePath' => 'Gagal mendapatkan jalur penyimpanan',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Unduhan massal gagal: ${exception}',
			'download.batchDownload.selectQuality' => 'Pilih Kualitas',
			'download.batchDownload.downloading' => 'Mengunduh',
			'download.batchDownload.downloadResult' => 'Hasil Unduhan',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => 'Terpilih ${count} video',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => 'Terpilih ${count} galeri',
			'download.batchDownload.qualityNote' => 'Jika kualitas yang dipilih tidak tersedia, kualitas terbaik yang tersedia akan digunakan',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Memproses ${current}/${total}',
			'download.batchDownload.queued' => 'Dalam Antrean',
			'download.batchDownload.success' => 'Berhasil',
			'download.batchDownload.skipped' => 'Dilewati',
			'download.batchDownload.failed' => 'Gagal',
			'download.batchDownload.failureDetails' => 'Rincian Kegagalan',
			'download.batchDownload.reasonPrivateVideo' => 'Video privat',
			'download.batchDownload.reasonAlreadyExists' => 'Sudah ada',
			'download.batchDownload.reasonNoSource' => 'Tidak ada sumber unduhan',
			'download.batchDownload.reasonNoSavePath' => 'Tidak dapat mendapatkan jalur penyimpanan',
			'download.batchDownload.reasonOther' => 'Kesalahan lain',
			'download.batchDownload.startDownload' => 'Mulai Unduh',
			'downloadNotifications.completedTitle' => 'Unduhan selesai',
			'downloadNotifications.failedTitle' => 'Unduhan gagal',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} berhasil diunduh',
			'downloadNotifications.failedBody' => ({required Object name}) => '${name} gagal diunduh',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} telah diunduh',
			'downloadNotifications.failedToast' => ({required Object name}) => 'Unduhan ${name} gagal',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Tersimpan di ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Tersimpan sebagai ${name} (sudah ada file bernama sama)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Tersimpan di folder aplikasi — tidak bisa menulis ${target} (${reason})',
			'downloadNotifications.viewFolder' => 'Lihat folder',
			'downloadNotifications.fixInSettings' => 'Perbaiki di Pengaturan',
			'downloadNotifications.channelName' => 'Status unduhan',
			'downloadNotifications.channelDescription' => 'Notifikasi untuk unduhan yang selesai dan gagal',
			'favorite.errors.addFailed' => 'Gagal menambahkan',
			'favorite.errors.addSuccess' => 'Berhasil ditambahkan',
			'favorite.errors.deleteFolderFailed' => 'Gagal menghapus folder',
			'favorite.errors.deleteFolderSuccess' => 'Berhasil menghapus folder',
			'favorite.errors.folderNameCannotBeEmpty' => 'Nama folder tidak boleh kosong',
			'favorite.add' => 'Tambah',
			'favorite.addSuccess' => 'Berhasil ditambahkan',
			'favorite.addFailed' => 'Gagal menambahkan',
			'favorite.remove' => 'Hapus',
			'favorite.removeSuccess' => 'Berhasil dihapus',
			'favorite.removeFailed' => 'Gagal menghapus',
			'favorite.removeConfirmation' => 'Apakah Anda yakin ingin menghapus item ini dari favorit?',
			'favorite.removeConfirmationSuccess' => 'Item dihapus dari favorit',
			'favorite.removeConfirmationFailed' => 'Gagal menghapus item dari favorit',
			'favorite.createFolderSuccess' => 'Folder berhasil dibuat',
			'favorite.createFolderFailed' => 'Gagal membuat folder',
			'favorite.createFolder' => 'Buat Folder',
			'favorite.enterFolderName' => 'Masukkan nama folder',
			'favorite.enterFolderNameHere' => 'Masukkan nama folder di sini...',
			'favorite.create' => 'Buat',
			'favorite.items' => 'Item',
			'favorite.newFolderName' => 'Folder Baru',
			'favorite.searchFolders' => 'Cari folder...',
			'favorite.searchItems' => 'Cari item...',
			'favorite.createdAt' => 'Dibuat Pada',
			'favorite.myFavorites' => 'Favorit Saya',
			'favorite.deleteFolderTitle' => 'Hapus Folder',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => 'Apakah Anda yakin ingin menghapus folder ${title}?',
			'favorite.removeItemTitle' => 'Hapus Item',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => 'Apakah Anda yakin ingin menghapus item ${title}?',
			'favorite.removeItemSuccess' => 'Item dihapus dari favorit',
			'favorite.removeItemFailed' => 'Gagal menghapus item dari favorit',
			'favorite.localizeFavorite' => 'Favorit Lokal',
			'favorite.editFolderTitle' => 'Ubah Folder',
			'favorite.editFolderSuccess' => 'Folder berhasil diperbarui',
			'favorite.editFolderFailed' => 'Gagal memperbarui folder',
			'favorite.searchTags' => 'Cari tag',
			'favorite.noTagsInFolder' => 'Belum ada tag pada item di folder ini',
			'favorite.tagFilterMatchAll' => 'Hanya menampilkan item yang memiliki semua tag terpilih',
			'favorite.clearSelectedTags' => 'Bersihkan tag yang dipilih',
			'favorite.selectedTagCount' => ({required Object count}) => '${count} dipilih',
			'favorite.noMatchingTags' => 'Tidak ada tag yang cocok',
			'translation.currentService' => 'Layanan Saat Ini',
			'translation.testConnection' => 'Uji Koneksi',
			'translation.testConnectionSuccess' => 'Uji koneksi berhasil',
			'translation.testConnectionFailed' => 'Uji koneksi gagal',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'Uji koneksi gagal: ${message}',
			'translation.translation' => 'Terjemahan',
			'translation.needVerification' => 'Memerlukan Verifikasi',
			'translation.needVerificationContent' => 'Silakan uji koneksi terlebih dahulu sebelum mengaktifkan terjemahan AI',
			'translation.confirm' => 'Konfirmasi',
			'translation.disclaimer' => 'Penafian',
			'translation.riskWarning' => 'Peringatan Risiko',
			'translation.dureToRisk1' => 'Karena teks dihasilkan oleh pengguna, teks dapat mengandung konten yang melanggar kebijakan konten penyedia layanan AI',
			'translation.dureToRisk2' => 'Konten yang tidak pantas dapat menyebabkan penangguhan kunci API atau penghentian layanan',
			'translation.operationSuggestion' => 'Saran Penggunaan',
			'translation.operationSuggestion1' => '1. Gunakan sebelum meninjau konten yang akan diterjemahkan secara ketat',
			'translation.operationSuggestion2' => '2. Hindari menerjemahkan konten yang melibatkan kekerasan, konten dewasa, dll.',
			'translation.apiConfig' => 'Konfigurasi API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Mengubah konfigurasi akan menutup terjemahan AI secara otomatis, perlu diuji lagi setelah diaktifkan',
			'translation.apiAddress' => 'Alamat API',
			'translation.modelName' => 'Nama Model',
			'translation.modelNameHintText' => 'Misalnya: gpt-4-turbo',
			'translation.maxTokens' => 'Token Maksimum',
			'translation.maxTokensHintText' => 'Misalnya: 32000',
			'translation.temperature' => 'Suhu',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Klik tombol uji untuk memverifikasi validitas koneksi API',
			'translation.requestPreview' => 'Pratinjau Permintaan',
			'translation.enableAITranslation' => 'Aktifkan AI',
			'translation.enabled' => 'Diaktifkan',
			'translation.disabled' => 'Dinonaktifkan',
			'translation.testing' => 'Menguji...',
			'translation.testNow' => 'Uji Sekarang',
			'translation.connectionStatus' => 'Status Koneksi',
			'translation.success' => 'Berhasil',
			'translation.failed' => 'Gagal',
			'translation.information' => 'Informasi',
			'translation.viewRawResponse' => 'Lihat Respons Mentah',
			'translation.pleaseCheckInputParametersFormat' => 'Silakan periksa format parameter masukan',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Silakan isi alamat API, nama model, dan kunci',
			'translation.pleaseFillInValidConfigurationParameters' => 'Silakan isi parameter konfigurasi yang valid',
			'translation.pleaseCompleteConnectionTest' => 'Silakan selesaikan uji koneksi',
			'translation.notConfigured' => 'Belum Dikonfigurasi',
			'translation.apiEndpoint' => 'Endpoint API',
			'translation.configuredKey' => 'Kunci yang Dikonfigurasi',
			'translation.notConfiguredKey' => 'Kunci Belum Dikonfigurasi',
			'translation.authenticationStatus' => 'Status Autentikasi',
			'translation.thisFieldCannotBeEmpty' => 'Kolom ini tidak boleh kosong',
			'translation.apiKey' => 'Kunci API',
			'translation.apiKeyCannotBeEmpty' => 'Kunci API tidak boleh kosong',
			'translation.pleaseEnterValidNumber' => 'Silakan masukkan angka yang valid',
			'translation.range' => 'Rentang',
			'translation.mustBeGreaterThan' => 'Harus lebih besar dari',
			'translation.invalidAPIResponse' => 'Respons API tidak valid',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Koneksi gagal: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'Terjemahan AI tidak diaktifkan, silakan aktifkan di pengaturan',
			'translation.goToSettings' => 'Buka Pengaturan',
			'translation.disableAITranslation' => 'Nonaktifkan Terjemahan AI',
			'translation.currentValue' => 'Nilai Saat Ini',
			'translation.configureTranslationStrategy' => 'Konfigurasikan Strategi Terjemahan',
			'translation.advancedSettings' => 'Pengaturan Lanjutan',
			'translation.translationPrompt' => 'Prompt Terjemahan',
			'translation.promptHint' => 'Silakan masukkan prompt terjemahan, gunakan [TL] sebagai placeholder untuk bahasa target',
			'translation.promptHelperText' => 'Prompt harus berisi [TL] sebagai placeholder untuk bahasa target',
			'translation.promptMustContainTargetLang' => 'Prompt harus berisi placeholder [TL]',
			'translation.aiTranslationWillBeDisabled' => 'Terjemahan AI akan dinonaktifkan',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Karena perubahan konfigurasi dasar, terjemahan AI akan dinonaktifkan',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Karena perubahan prompt terjemahan, terjemahan AI akan dinonaktifkan',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Karena perubahan konfigurasi parameter, terjemahan AI akan dinonaktifkan',
			'translation.onlyOpenAIAPISupported' => 'Saat ini hanya mendukung format API yang kompatibel dengan OpenAI (badan permintaan application/json)',
			'translation.streamingTranslation' => 'Terjemahan Streaming',
			'translation.streamingTranslationSupported' => 'Terjemahan Streaming Didukung',
			'translation.streamingTranslationNotSupported' => 'Terjemahan Streaming Tidak Didukung',
			'translation.streamingTranslationDescription' => 'Terjemahan streaming dapat menampilkan hasil secara real-time selama proses terjemahan, memberikan pengalaman pengguna yang lebih baik',
			'translation.usingFullUrlWithHash' => 'Menggunakan URL lengkap (diakhiri dengan #)',
			'translation.baseUrlInputHelperText' => 'Jika diakhiri dengan #, alamat tersebut akan digunakan sebagai alamat permintaan sebenarnya',
			'translation.currentActualUrl' => ({required Object url}) => 'URL sebenarnya saat ini: ${url}',
			'translation.urlEndingWithHashTip' => 'URL yang diakhiri dengan # akan digunakan langsung tanpa menambahkan akhiran apa pun',
			'translation.streamingTranslationWarning' => 'Catatan: Fitur ini memerlukan dukungan layanan API untuk transmisi streaming, beberapa model mungkin tidak mendukungnya',
			'translation.translationService' => 'Layanan Terjemahan',
			'translation.translationServiceDescription' => 'Pilih layanan terjemahan yang Anda sukai',
			'translation.googleTranslation' => 'Terjemahan Google',
			'translation.googleTranslationDescription' => 'Layanan terjemahan online gratis yang mendukung berbagai bahasa',
			'translation.aiTranslation' => 'Terjemahan AI',
			'translation.aiTranslationDescription' => 'Layanan terjemahan cerdas berbasis model bahasa besar',
			'translation.deeplxTranslation' => 'Terjemahan DeepLX',
			'translation.deeplxTranslationDescription' => 'Implementasi sumber terbuka dari terjemahan DeepL, menyediakan terjemahan berkualitas tinggi',
			'translation.googleTranslationFeatures' => 'Fitur',
			'translation.freeToUse' => 'Gratis digunakan',
			'translation.freeToUseDescription' => 'Tidak perlu konfigurasi, siap digunakan',
			'translation.fastResponse' => 'Respons cepat',
			'translation.fastResponseDescription' => 'Kecepatan terjemahan cepat dengan latensi rendah',
			'translation.stableAndReliable' => 'Stabil dan andal',
			'translation.stableAndReliableDescription' => 'Berbasis API resmi Google',
			'translation.enabledDefaultService' => 'Diaktifkan - Layanan terjemahan bawaan',
			'translation.notEnabled' => 'Tidak diaktifkan',
			'translation.deeplxTranslationService' => 'Layanan Terjemahan DeepLX',
			'translation.deeplxDescription' => 'DeepLX adalah implementasi sumber terbuka dari terjemahan DeepL, yang mendukung mode endpoint Free, Pro, dan Official',
			'translation.serverAddress' => 'Alamat Server',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Alamat dasar server DeepLX',
			'translation.endpointType' => 'Jenis Endpoint',
			'translation.freeEndpoint' => 'Free - Endpoint gratis, mungkin memiliki batas laju',
			'translation.proEndpoint' => 'Pro - Memerlukan dl_session, lebih stabil',
			'translation.officialEndpoint' => 'Official - Format API resmi',
			'translation.finalRequestUrl' => 'URL Permintaan Final',
			'translation.apiKeyOptional' => 'Kunci API (Opsional)',
			'translation.apiKeyOptionalHint' => 'Untuk mengakses layanan DeepLX yang dilindungi',
			'translation.apiKeyOptionalHelperText' => 'Beberapa layanan DeepLX memerlukan Kunci API untuk autentikasi',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'Parameter dl_session diperlukan untuk mode Pro',
			'translation.dlSessionHelperText' => 'Parameter sesi diperlukan untuk endpoint Pro, diperoleh dari akun DeepL Pro',
			'translation.proModeRequiresDlSession' => 'Mode Pro memerlukan dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Klik tombol uji untuk memverifikasi koneksi API DeepLX',
			'translation.enableDeepLXTranslation' => 'Aktifkan Terjemahan DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'Terjemahan DeepLX akan dinonaktifkan karena perubahan konfigurasi',
			'translation.translatedResult' => 'Hasil Terjemahan',
			'translation.testSuccess' => 'Uji berhasil',
			'translation.pleaseFillInDeepLXServerAddress' => 'Silakan isi alamat server DeepLX',
			'translation.invalidAPIResponseFormat' => 'Format respons API tidak valid',
			'translation.translationServiceReturnedError' => 'Layanan terjemahan mengembalikan kesalahan atau hasil kosong',
			'translation.connectionFailed' => 'Koneksi gagal',
			'translation.translationFailed' => 'Terjemahan gagal',
			'translation.aiTranslationFailed' => 'Terjemahan AI gagal',
			'translation.deeplxTranslationFailed' => 'Terjemahan DeepLX gagal',
			'translation.aiTranslationTestFailed' => 'Uji terjemahan AI gagal',
			'translation.deeplxTranslationTestFailed' => 'Uji terjemahan DeepLX gagal',
			'translation.streamingTranslationTimeout' => 'Waktu habis terjemahan streaming, memaksa pembersihan sumber daya',
			'translation.translationRequestTimeout' => 'Waktu habis permintaan terjemahan',
			'translation.streamingTranslationDataTimeout' => 'Waktu habis penerimaan data terjemahan streaming',
			'translation.dataReceptionTimeout' => 'Waktu habis penerimaan data',
			'translation.streamDataParseError' => 'Kesalahan saat mengurai data aliran',
			'translation.streamingTranslationFailed' => 'Terjemahan streaming gagal',
			'translation.fallbackTranslationFailed' => 'Terjemahan cadangan ke terjemahan normal juga gagal',
			'translation.translationSettings' => 'Pengaturan Terjemahan',
			'translation.enableGoogleTranslation' => 'Aktifkan Terjemahan Google',
			'translation.thinking' => 'Berpikir...',
			'translation.thoughtProcess' => 'Proses Pemikiran',
			'translation.modelCompatibility' => 'Kompatibilitas Model',
			'translation.modelCompatibilityDescription' => 'Sesuaikan parameter permintaan untuk model modern seperti model penalaran (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'Model Penalaran',
			'translation.reasoningModelDescription' => 'Untuk o1/o3, DeepSeek-R1, QwQ, dll. Melipat prompt ke dalam pesan pengguna, menghilangkan temperature, dan menggunakan max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'Gunakan max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'Endpoint OpenAI yang lebih baru memerlukan max_completion_tokens alih-alih max_tokens yang sudah usang',
			'translation.sendTemperature' => 'Kirim temperature',
			'translation.sendTemperatureDescription' => 'Nonaktifkan untuk model yang menolak parameter temperature (sebagian besar model penalaran)',
			'translation.showReasoningProcess' => 'Tampilkan proses pemikiran',
			'translation.showReasoningProcessDescription' => 'Tampilkan penalaran yang dapat dilipat dari model penalaran di dialog terjemahan',
			'translation.provider' => 'Penyedia',
			'translation.providerOpenAI' => 'OpenAI (dan yang kompatibel)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Mendukung OpenAI (dan endpoint apa pun yang kompatibel dengan OpenAI), Anthropic, dan Google melalui SDK dartantic_ai',
			'translation.baseUrlOptionalHelperText' => 'Opsional. Biarkan kosong untuk menggunakan endpoint bawaan penyedia; isi untuk endpoint yang kompatibel dengan OpenAI/relai',
			'translation.defaultEndpoint' => 'Endpoint bawaan',
			'translation.providerPreset' => 'Prasetel Penyedia',
			'translation.selectProviderPreset' => 'Pilih prasetel',
			'translation.presetCustom' => 'Kustom',
			'translation.presetApplied' => ({required Object name}) => 'Prasetel diterapkan: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'OpenAI Penalaran (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Anthropic Claude Penalaran (pemikiran lanjutan)',
			'translation.presetNames.gemini' => 'Google Gemini (asli)',
			'translation.presetNames.geminiReasoning' => 'Google Gemini Penalaran (berpikir)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'DeepSeek Penalaran (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Ambil daftar model',
			'translation.fetchingModels' => 'Mengambil...',
			'translation.selectModel' => 'Pilih Model',
			'translation.searchModel' => 'Cari model',
			'translation.noModelsFound' => 'Tidak ada model ditemukan',
			'bottomNav.video' => 'Video',
			'bottomNav.gallery' => 'Galeri',
			'bottomNav.subscription' => 'Feed',
			'bottomNav.community' => 'Forum',
			'bottomNav.localMedia' => 'Lokal',
			'navigationOrderSettings.title' => 'Pengaturan Urutan Navigasi',
			'navigationOrderSettings.customNavigationOrder' => 'Urutan Navigasi Kustom',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Seret untuk menyesuaikan urutan tampilan halaman pada bilah navigasi bawah dan bilah samping',
			'navigationOrderSettings.restartRequired' => 'Perlu memulai ulang aplikasi',
			'navigationOrderSettings.navigationItemSorting' => 'Pengurutan Item Navigasi',
			'navigationOrderSettings.done' => 'Selesai',
			'navigationOrderSettings.edit' => 'Ubah',
			'navigationOrderSettings.reset' => 'Atur Ulang',
			'navigationOrderSettings.previewEffect' => 'Pratinjau Efek',
			'navigationOrderSettings.bottomNavigationPreview' => 'Pratinjau Navigasi Bawah:',
			'navigationOrderSettings.sidebarPreview' => 'Pratinjau Bilah Samping:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Konfirmasi Atur Ulang Urutan Navigasi',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => 'Apakah Anda yakin ingin mengatur ulang urutan navigasi ke pengaturan bawaan?',
			'navigationOrderSettings.cancel' => 'Batal',
			'navigationOrderSettings.show' => 'Tampilkan',
			'navigationOrderSettings.hide' => 'Sembunyikan',
			'navigationOrderSettings.hidden' => 'Tersembunyi',
			'navigationOrderSettings.hideHint' => 'Ketuk ikon mata untuk menampilkan atau menyembunyikan Komunitas dan berkas lokal',
			'navigationOrderSettings.videoDescription' => 'Telusuri konten video populer',
			'navigationOrderSettings.galleryDescription' => 'Telusuri gambar dan galeri',
			'navigationOrderSettings.subscriptionDescription' => 'Lihat konten terbaru dari pengguna yang Anda ikuti',
			'navigationOrderSettings.forumDescription' => 'Ikut serta dalam diskusi komunitas',
			'navigationOrderSettings.newsDescription' => 'Telusuri berita, artikel, dan siaran resmi',
			'navigationOrderSettings.communityDescription' => 'Diskusi forum serta berita, artikel, dan siaran resmi',
			'navigationOrderSettings.localMediaDescription' => 'Telusuri video dan gambar yang tersimpan di perangkat ini',
			'news.title' => 'Berita',
			'news.newsUpdates' => 'Pembaruan Berita',
			'news.articles' => 'Artikel',
			'news.broadcast' => 'Siaran',
			'news.openInBrowser' => 'Buka di Peramban',
			'displaySettings.title' => 'Pengaturan Tampilan',
			'displaySettings.layoutSettings' => 'Pengaturan Tata Letak',
			'displaySettings.layoutSettingsDesc' => 'Sesuaikan jumlah kolom dan konfigurasi titik henti',
			'displaySettings.gridLayout' => 'Tata Letak Kisi',
			'displaySettings.navigationOrderSettings' => 'Pengaturan Urutan Navigasi',
			'displaySettings.customNavigationOrder' => 'Urutan Navigasi Kustom',
			'displaySettings.customNavigationOrderDesc' => 'Sesuaikan urutan tampilan halaman pada bilah navigasi bawah dan bilah samping',
			'layoutSettings.title' => 'Pengaturan Tata Letak',
			'layoutSettings.descriptionTitle' => 'Penjelasan Konfigurasi Tata Letak',
			'layoutSettings.descriptionContent' => 'Konfigurasi di sini akan menentukan jumlah kolom yang ditampilkan pada halaman daftar video dan galeri. Anda dapat memilih mode otomatis agar sistem menyesuaikan secara otomatis berdasarkan lebar layar, atau memilih mode manual untuk menetapkan jumlah kolom.',
			'layoutSettings.layoutMode' => 'Mode Tata Letak',
			'layoutSettings.reset' => 'Atur Ulang',
			'layoutSettings.autoMode' => 'Mode Otomatis',
			'layoutSettings.autoModeDesc' => 'Menyesuaikan secara otomatis berdasarkan lebar layar',
			'layoutSettings.manualMode' => 'Mode Manual',
			'layoutSettings.manualModeDesc' => 'Gunakan jumlah kolom tetap',
			'layoutSettings.manualSettings' => 'Pengaturan Manual',
			'layoutSettings.fixedColumns' => 'Kolom Tetap',
			'layoutSettings.columns' => 'kolom',
			'layoutSettings.breakpointConfig' => 'Konfigurasi Titik Henti',
			'layoutSettings.add' => 'Tambah',
			'layoutSettings.defaultColumns' => 'Kolom Bawaan',
			'layoutSettings.defaultColumnsDesc' => 'Tampilan bawaan untuk layar besar',
			'layoutSettings.previewEffect' => 'Pratinjau Efek',
			'layoutSettings.screenWidth' => 'Lebar Layar',
			'layoutSettings.addBreakpoint' => 'Tambah Titik Henti',
			'layoutSettings.editBreakpoint' => 'Ubah Titik Henti',
			'layoutSettings.deleteBreakpoint' => 'Hapus Titik Henti',
			'layoutSettings.screenWidthLabel' => 'Lebar Layar',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Kolom',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Silakan masukkan lebar',
			'layoutSettings.enterValidWidth' => 'Silakan masukkan lebar yang valid',
			'layoutSettings.widthCannotExceed9999' => 'Lebar tidak boleh melebihi 9999',
			'layoutSettings.breakpointAlreadyExists' => 'Titik henti sudah ada',
			'layoutSettings.enterColumns' => 'Silakan masukkan jumlah kolom',
			'layoutSettings.enterValidColumns' => 'Silakan masukkan jumlah kolom yang valid',
			'layoutSettings.columnsCannotExceed12' => 'Kolom tidak boleh melebihi 12',
			'layoutSettings.breakpointConflict' => 'Titik henti sudah ada',
			'layoutSettings.confirmResetLayoutSettings' => 'Atur Ulang Pengaturan Tata Letak',
			'layoutSettings.confirmResetLayoutSettingsDesc' => 'Apakah Anda yakin ingin mengatur ulang semua pengaturan tata letak ke nilai bawaan?\n\nAkan dikembalikan ke:\n• Mode otomatis\n• Konfigurasi titik henti bawaan',
			'layoutSettings.resetToDefaults' => 'Atur Ulang ke Bawaan',
			'layoutSettings.confirmDeleteBreakpoint' => 'Hapus Titik Henti',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => 'Apakah Anda yakin ingin menghapus titik henti ${width}px?',
			'layoutSettings.noCustomBreakpoints' => 'Tidak ada titik henti kustom, menggunakan kolom bawaan',
			'layoutSettings.breakpointRange' => 'Rentang Titik Henti',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Ubah',
			'layoutSettings.delete' => 'Hapus',
			'layoutSettings.cancel' => 'Batal',
			'layoutSettings.save' => 'Simpan',
			'mediaPlayer.videoPlayerError' => 'Kesalahan Pemutar Video',
			'mediaPlayer.videoLoadFailed' => 'Gagal Memuat Video',
			'mediaPlayer.videoCodecNotSupported' => 'Codec Video Tidak Didukung',
			'mediaPlayer.networkConnectionIssue' => 'Masalah Koneksi Jaringan',
			'mediaPlayer.insufficientPermission' => 'Izin Tidak Cukup',
			'mediaPlayer.unsupportedVideoFormat' => 'Format Video Tidak Didukung',
			'mediaPlayer.retry' => 'Coba Lagi',
			'mediaPlayer.externalPlayer' => 'Pemutar Eksternal',
			'mediaPlayer.detailedErrorInfo' => 'Informasi Kesalahan Terperinci',
			'mediaPlayer.format' => 'Format',
			'mediaPlayer.suggestion' => 'Saran',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Perangkat Android memiliki dukungan terbatas untuk format WEBM. Disarankan menggunakan pemutar eksternal atau mengunduh aplikasi pemutar yang mendukung WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'Perangkat saat ini tidak mendukung codec untuk format video ini',
			'mediaPlayer.checkNetworkConnection' => 'Silakan periksa koneksi jaringan Anda dan coba lagi',
			'mediaPlayer.appMayLackMediaPermission' => 'Aplikasi mungkin kekurangan izin pemutaran media yang diperlukan',
			'mediaPlayer.tryOtherVideoPlayer' => 'Silakan coba gunakan pemutar video lain',
			'mediaPlayer.unrecognizedVideoFormat' => 'Berkas video tidak dikenali',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Tautan mungkin sudah kedaluwarsa, atau responsnya bukan video. Coba lagi, atau buka dengan aplikasi lain.',
			'mediaPlayer.accessDenied' => 'Server menolak permintaan ini (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Tautan pemutaran kemungkinan besar sudah kedaluwarsa. Ketuk Coba Lagi untuk mengambilnya kembali, atau buka dengan aplikasi lain.',
			'mediaPlayer.mute' => 'Bisukan',
			'mediaPlayer.unmute' => 'Bunyikan',
			'mediaPlayer.video' => 'VIDEO',
			'mediaPlayer.serverSelector' => 'Pilihan Server CDN',
			'mediaPlayer.serverSelectorDescription' => 'Pilih server dengan latensi terendah untuk pengalaman pemutaran terbaik',
			'mediaPlayer.retestSpeed' => 'Uji Ulang Kecepatan',
			'mediaPlayer.waitingForSpeedTest' => 'Menunggu uji kecepatan',
			'mediaPlayer.testingSpeed' => 'Menguji kecepatan...',
			'mediaPlayer.testFailed' => 'Uji gagal',
			'mediaPlayer.loadingServerList' => 'Memuat daftar server...',
			'mediaPlayer.noAvailableServers' => 'Tidak ada server yang tersedia',
			'mediaPlayer.refreshServerList' => 'Segarkan Daftar Server',
			'mediaPlayer.cannotGetSource' => 'Tidak dapat mendapatkan sumber video saat ini',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Beralih ke server: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => 'Total ${count} server',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Kode status: ${code}',
			'mediaPlayer.connectionFailed' => 'Koneksi gagal',
			'mediaPlayer.connectionTimeout' => 'Koneksi habis waktu',
			'mediaPlayer.networkError' => 'Kesalahan jaringan',
			'mediaPlayer.sslError' => 'Kesalahan sertifikat SSL',
			'mediaPlayer.testCompleted' => 'Uji selesai',
			'mediaPlayer.local' => 'Lokal',
			'mediaPlayer.unknown' => 'Tidak diketahui',
			'mediaPlayer.localVideoPathEmpty' => 'Jalur video lokal kosong',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'Berkas video lokal tidak ada: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'Tidak dapat memutar video lokal: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Jatuhkan berkas video di sini untuk memutar',
			'mediaPlayer.supportedFormats' => 'Format yang didukung: MP4, MKV, AVI, MOV, WEBM, dll.',
			'mediaPlayer.noSupportedVideoFile' => 'Tidak ditemukan berkas video yang didukung',
			'mediaPlayer.retryingOpenVideoLink' => 'Gagal membuka tautan video, mencoba lagi',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'Tidak dapat memuat dekoder: ${event}. Coba beralih ke dekode perangkat lunak di pengaturan pemutar lalu masuk kembali ke halaman',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Kesalahan pemuatan video: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Terdeteksi kegagalan pemutaran berulang. Buka Pengaturan > Diagnostik & Umpan Balik untuk mengekspor log.',
			'mediaPlayer.openSettingsAction' => 'Lihat',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Pemberitahuan pemutaran: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Periksa jaringan Anda; pemutaran mungkin tersendat',
			'mediaPlayer.notice.audioTrackUnavailable' => 'Tidak ada suara; video terus diputar',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Beralih ke dekode perangkat lunak; mungkin lebih boros daya',
			'mediaPlayer.notice.videoDecodeProblem' => 'Coba kualitas lain; gambar mungkin rusak',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Ekspor log untuk melaporkan masalah pemutaran yang berulang',
			'mediaPlayer.notice.issuesSheetTitle' => 'Masalah pemutaran',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'Terjadi ${count} kali',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'Pada ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'Tidak ada masalah yang tercatat',
			'mediaPlayer.notice.exportLogsAction' => 'Ekspor log',
			'mediaPlayer.imageLoadFailed' => 'Gagal Memuat Gambar',
			'mediaPlayer.unsupportedImageFormat' => 'Format Gambar Tidak Didukung',
			'mediaPlayer.tryOtherViewer' => 'Silakan coba gunakan penampil lain',
			'diagnostics.infoSectionTitle' => 'Info Diagnostik',
			'diagnostics.appVersionLabel' => 'Versi Aplikasi',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Penggunaan memori: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'Tidak dapat mengambil info perangkat',
			'diagnostics.secureStorageLabel' => 'Penyimpanan aman',
			'diagnostics.secureStorageHealthy' => 'Tersedia',
			'diagnostics.secureStorageRecovered' => 'Pulih sendiri melalui reset (data sebelumnya dihapus)',
			'diagnostics.secureStorageUnavailable' => 'Tidak tersedia (login disimpan dengan enkripsi cadangan)',
			'diagnostics.secureStoragePlatformOptOut' => 'Enkripsi lokal sesuai kebijakan platform (keychain sistem tidak digunakan di macOS)',
			'diagnostics.secureStorageDualWrite' => ' (perlindungan penulisan ganda aktif)',
			'diagnostics.schemaHealthLabel' => 'Skema basis data',
			'diagnostics.schemaHealthOk' => 'OK',
			'diagnostics.schemaHealthRepairedNow' => 'Diperbaiki oleh jaring pengaman pada peluncuran ini (migrasi tidak berhasil)',
			'diagnostics.schemaHealthRepairedBefore' => 'Sebelumnya pernah diperbaiki oleh jaring pengaman',
			'diagnostics.logPolicySectionTitle' => 'Kebijakan Log',
			'diagnostics.configServiceUnavailable' => 'Layanan konfigurasi belum diinisialisasi. Kebijakan log tidak dapat disesuaikan.',
			'diagnostics.enableLoggingTitle' => 'Aktifkan pencatatan log',
			'diagnostics.enableLoggingSubtitle' => 'Nonaktifkan untuk menghentikan penulisan log baru',
			'diagnostics.enableLogPersistenceTitle' => 'Aktifkan persistensi log',
			'diagnostics.enableLogPersistenceSubtitle' => 'Nonaktifkan agar log hanya disimpan di memori dan menghentikan penulisan ke disk',
			'diagnostics.minLogLevelTitle' => 'Level log minimum',
			'diagnostics.minLogLevelSubtitle' => 'Log di bawah level ini akan disaring',
			'diagnostics.maxFileSizeTitle' => 'Batas ukuran satu berkas',
			'diagnostics.maxFileSizeSubtitle' => 'Rotasi saat ambang tercapai',
			'diagnostics.rotatedFileCountTitle' => 'Jumlah berkas rotasi log utama',
			'diagnostics.rotatedFileCountSubtitle' => 'Jumlah berkas yang disimpan di luar berkas saat ini',
			'diagnostics.hangFileSizeTitle' => 'Batas ukuran log hang',
			'diagnostics.hangFileSizeSubtitle' => 'Kendalikan pertumbuhan berkas hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'Jumlah berkas rotasi log hang',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Kendalikan riwayat yang disimpan untuk hang_events',
			'diagnostics.healthSectionTitle' => 'Kesehatan Log',
			'diagnostics.refreshMetrics' => 'Segarkan Metrik',
			'diagnostics.toolsSectionTitle' => 'Alat',
			'diagnostics.privacyNotice' => 'Log dapat berisi informasi sensitif seperti data akun dan parameter permintaan. Jangan memposting log lengkap secara publik di issue; tinjau terlebih dahulu lalu kirim melalui email.',
			'diagnostics.exportLogsTitle' => 'Ekspor Log',
			'diagnostics.exportLogsSubtitle' => 'Tinjau data privasi sebelum mengirim ke pengembang',
			'diagnostics.viewLogsTitle' => 'Lihat Log',
			'diagnostics.viewLogsSubtitle' => 'Lihat log runtime secara real-time',
			'diagnostics.copySupportEmailTitle' => 'Salin Email Dukungan',
			'diagnostics.reportIssueTitle' => 'Laporkan Masalah',
			'diagnostics.reportIssueSubtitle' => 'Berikan langkah reproduksi di GitHub (jangan lampirkan log lengkap)',
			'diagnostics.healthSummaryUnavailable' => 'Belum ada data kesehatan log',
			'diagnostics.healthMetricsUnavailable' => 'Metrik kesehatan belum dikumpulkan',
			'diagnostics.healthNoRiskIndicators' => 'Tidak ada indikator risiko yang terdeteksi',
			'diagnostics.healthAlert.flushFailureTitle' => 'Kegagalan flush',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Penulisan log menurun',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'Sink berkas dalam kondisi menurun',
			'diagnostics.healthAlert.queueBacklogTitle' => 'Tumpukan antrean penulisan',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (ambang=${threshold}, dapat meningkatkan penggunaan memori)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Latensi flush tinggi',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Terlalu banyak log yang dijatuhkan',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (ambang=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Pembatasan laju terpicu',
			'diagnostics.healthAlert.exportFailedTitle' => 'Kegagalan ekspor log',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'Berkas log mendekati batas ukuran',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (tekanan rotasi IO lebih tinggi)',
			'diagnostics.toast.logServiceNotInitialized' => 'Layanan log belum diinisialisasi',
			'diagnostics.toast.exportSuccess' => 'Log diekspor. Harap tinjau data privasi sebelum mengirim melalui email.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'Ekspor gagal: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'Email dukungan disalin. Tempelkan ke klien email Anda dan lampirkan log.',
			'diagnostics.shareSubject' => 'Log diagnostik LoveIwara (berisi data sensitif, bagikan dengan hati-hati)',
			'logViewer.title' => 'Penampil Log',
			'logViewer.searchHint' => 'Cari log...',
			'logViewer.emptyState' => 'Tidak ada log',
			'logViewer.copiedToClipboard' => 'Disalin ke papan klip',
			'crashRecoveryDialog.title' => 'Aplikasi keluar secara tak terduga',
			'crashRecoveryDialog.description' => 'Kami mendeteksi penutupan tidak wajar pada sesi terakhir. Silakan ekspor log diagnostik dan kirimkan melalui email kepada pengembang untuk membantu kami memperbaiki masalah ini.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Versi terakhir: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Peluncuran terakhir: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Pengecualian terakhir: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'UI sempat macet terakhir kali dan pulih secara otomatis',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'Kemungkinan pembekuan UI terdeteksi terakhir kali, berlangsung sekitar ${stalledMs}ms',
			'crashRecoveryDialog.exportGuide' => 'Buka Pengaturan > Diagnostik & Umpan Balik > Ekspor Log.',
			'crashRecoveryDialog.privacyHint' => 'Log dapat berisi data pribadi. Harap tinjau sebelum mengirim email ke:',
			'crashRecoveryDialog.issueWarning' => 'Jangan lampirkan log lengkap secara publik di issue GitHub',
			'crashRecoveryDialog.acknowledge' => 'Mengerti',
			'crashRecoveryDialog.supportEmailCopied' => 'Email disalin',
			'linkInputDialog.title' => 'Masukkan Tautan',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Mendukung pengenalan cerdas beberapa tautan ${webName} dan melompat dengan cepat ke halaman terkait di aplikasi (pisahkan tautan dari teks lain dengan spasi)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Silakan masukkan tautan ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'Silakan masukkan tautan',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'Tidak terdeteksi tautan ${webName} yang valid',
			'linkInputDialog.multipleLinksDetected' => 'Terdeteksi beberapa tautan, silakan pilih satu:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'Bukan tautan ${webName} yang valid',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Kesalahan penguraian tautan: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Tautan Tidak Didukung',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Jenis tautan ini tidak dapat dibuka langsung di aplikasi dan perlu diakses menggunakan peramban eksternal.\n\nApakah Anda ingin membuka tautan ini di peramban?',
			'linkInputDialog.openInBrowser' => 'Buka di Peramban',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Konfirmasi Buka Peramban',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'Tautan berikut akan dibuka di peramban eksternal:',
			'linkInputDialog.confirmContinueBrowserOpen' => 'Apakah Anda yakin ingin melanjutkan?',
			'linkInputDialog.browserOpenFailed' => 'Gagal membuka tautan',
			'linkInputDialog.unsupportedLink' => 'Tautan Tidak Didukung',
			_ => null,
		} ?? switch (path) {
			'linkInputDialog.cancel' => 'Batal',
			'linkInputDialog.confirm' => 'Buka di Peramban',
			'log.logManagement' => 'Pengelolaan Log',
			'log.enableLogPersistence' => 'Aktifkan Persistensi Log',
			'log.enableLogPersistenceDesc' => 'Simpan log ke basis data untuk analisis',
			'log.logDatabaseSizeLimit' => 'Batas Ukuran Basis Data Log',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Saat ini: ${size}',
			'log.exportCurrentLogs' => 'Ekspor Log Saat Ini',
			'log.exportCurrentLogsDesc' => 'Ekspor log aplikasi saat ini untuk membantu pengembang mendiagnosis masalah',
			'log.exportHistoryLogs' => 'Ekspor Log Riwayat',
			'log.exportHistoryLogsDesc' => 'Ekspor log dalam rentang tanggal tertentu',
			'log.exportMergedLogs' => 'Ekspor Log Gabungan',
			'log.exportMergedLogsDesc' => 'Ekspor log gabungan dalam rentang tanggal tertentu',
			'log.showLogStats' => 'Tampilkan Statistik Log',
			'log.logExportSuccess' => 'Ekspor log berhasil',
			'log.logExportFailed' => ({required Object error}) => 'Ekspor log gagal: ${error}',
			'log.showLogStatsDesc' => 'Lihat statistik berbagai jenis log',
			'log.logExtractFailed' => ({required Object error}) => 'Gagal mendapatkan statistik log: ${error}',
			'log.clearAllLogs' => 'Bersihkan Semua Log',
			'log.clearAllLogsDesc' => 'Hapus semua data log',
			'log.confirmClearAllLogs' => 'Konfirmasi Bersihkan',
			'log.confirmClearAllLogsDesc' => 'Apakah Anda yakin ingin membersihkan semua data log? Tindakan ini tidak dapat dibatalkan.',
			'log.clearAllLogsSuccess' => 'Log berhasil dibersihkan',
			'log.clearAllLogsFailed' => ({required Object error}) => 'Gagal membersihkan log: ${error}',
			'log.unableToGetLogSizeInfo' => 'Tidak dapat mendapatkan informasi ukuran log',
			'log.currentLogSize' => 'Ukuran Log Saat Ini:',
			'log.logCount' => 'Jumlah Log:',
			'log.logCountUnit' => 'log',
			'log.logSizeLimit' => 'Batas Ukuran Log:',
			'log.usageRate' => 'Tingkat Penggunaan:',
			'log.exceedLimit' => 'Melebihi Batas',
			'log.remaining' => 'Tersisa',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Ukuran log saat ini telah terlampaui, silakan bersihkan log lama atau tingkatkan batas ukuran log',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'Ukuran log saat ini hampir terlampaui, silakan bersihkan log lama',
			'log.cleaningOldLogs' => 'Membersihkan log lama...',
			'log.logCleaningCompleted' => 'Pembersihan log selesai',
			'log.logCleaningProcessMayNotBeCompleted' => 'Proses pembersihan log mungkin belum selesai',
			'log.cleanExceededLogs' => 'Bersihkan log berlebih',
			'log.noLogsToExport' => 'Tidak ada log untuk diekspor',
			'log.exportingLogs' => 'Mengekspor log...',
			'log.noHistoryLogsToExport' => 'Tidak ada log riwayat untuk diekspor, silakan gunakan aplikasi terlebih dahulu untuk beberapa saat',
			'log.selectLogDate' => 'Pilih Tanggal Log',
			'log.today' => 'Hari Ini',
			'log.selectMergeRange' => 'Pilih Rentang Gabungan',
			'log.selectMergeRangeHint' => 'Silakan pilih rentang waktu log yang akan digabungkan',
			'log.selectMergeRangeDays' => ({required Object days}) => '${days} hari terakhir',
			'log.logStats' => 'Statistik Log',
			'log.todayLogs' => ({required Object count}) => 'Log Hari Ini: ${count} log',
			'log.recent7DaysLogs' => ({required Object count}) => 'Log 7 Hari Terakhir: ${count} log',
			'log.totalLogs' => ({required Object count}) => 'Total Log: ${count} log',
			'log.setLogDatabaseSizeLimit' => 'Atur Batas Ukuran Basis Data Log',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Ukuran Log Saat Ini: ${size}',
			'log.warning' => 'Peringatan',
			'log.newSizeLimit' => ({required Object size}) => 'Batas ukuran baru: ${size}',
			'log.confirmToContinue' => 'Konfirmasi untuk melanjutkan',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Batas ukuran log diatur ke ${size}',
			'emoji.name' => 'Emoji',
			'emoji.size' => 'Ukuran',
			'emoji.small' => 'Kecil',
			'emoji.medium' => 'Sedang',
			'emoji.large' => 'Besar',
			'emoji.extraLarge' => 'Sangat Besar',
			'emoji.copyEmojiLinkSuccess' => 'Tautan emoji disalin',
			'emoji.preview' => 'Pratinjau Emoji',
			'emoji.library' => 'Pustaka Emoji',
			'emoji.noEmojis' => 'Tidak ada emoji',
			'emoji.clickToAddEmojis' => 'Klik tombol di kanan atas untuk menambahkan emoji',
			'emoji.addEmojis' => 'Tambah Emoji',
			'emoji.imagePreview' => 'Pratinjau Gambar',
			'emoji.imageLoadFailed' => 'Gagal memuat gambar',
			'emoji.loading' => 'Memuat...',
			'emoji.delete' => 'Hapus',
			'emoji.close' => 'Tutup',
			'emoji.deleteImage' => 'Hapus Gambar',
			'emoji.confirmDeleteImage' => 'Apakah Anda yakin ingin menghapus gambar ini?',
			'emoji.cancel' => 'Batal',
			'emoji.batchDelete' => 'Hapus Massal',
			'emoji.confirmBatchDelete' => ({required Object count}) => 'Apakah Anda yakin ingin menghapus ${count} gambar yang dipilih? Tindakan ini tidak dapat dibatalkan.',
			'emoji.deleteSuccess' => 'Berhasil dihapus',
			'emoji.addImage' => 'Tambah Gambar',
			'emoji.addImageByUrl' => 'Tambah lewat URL',
			'emoji.addImageUrl' => 'Tambah URL Gambar',
			'emoji.imageUrl' => 'URL Gambar',
			'emoji.enterImageUrl' => 'Silakan masukkan URL gambar',
			'emoji.add' => 'Tambah',
			'emoji.batchImport' => 'Impor Massal',
			'emoji.enterJsonUrlArray' => 'Silakan masukkan larik URL dalam format JSON:',
			'emoji.formatExample' => 'Contoh format:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Silakan tempel larik URL dalam format JSON',
			'emoji.import' => 'Impor',
			'emoji.importSuccess' => ({required Object count}) => 'Berhasil mengimpor ${count} gambar',
			'emoji.jsonFormatError' => 'Kesalahan format JSON, silakan periksa masukan',
			'emoji.createGroup' => 'Buat Grup Emoji',
			'emoji.groupName' => 'Nama Grup',
			'emoji.enterGroupName' => 'Silakan masukkan nama grup',
			'emoji.create' => 'Buat',
			'emoji.editGroupName' => 'Ubah Nama Grup',
			'emoji.save' => 'Simpan',
			'emoji.deleteGroup' => 'Hapus Grup',
			'emoji.confirmDeleteGroup' => 'Apakah Anda yakin ingin menghapus grup emoji ini? Semua gambar dalam grup juga akan dihapus.',
			'emoji.imageCount' => ({required Object count}) => '${count} gambar',
			'emoji.selectEmoji' => 'Pilih Emoji',
			'emoji.noEmojisInGroup' => 'Tidak ada emoji di grup ini',
			'emoji.goToSettingsToAddEmojis' => 'Buka pengaturan untuk menambahkan emoji',
			'emoji.emojiManagement' => 'Pengelolaan Emoji',
			'emoji.manageEmojiGroupsAndImages' => 'Kelola grup dan gambar emoji',
			'emoji.uploadLocalImages' => 'Unggah Gambar Lokal',
			'emoji.uploadingImages' => 'Mengunggah Gambar',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Mengunggah ${count} gambar, mohon tunggu...',
			'emoji.doNotCloseDialog' => 'Harap jangan tutup dialog ini',
			'emoji.uploadSuccess' => ({required Object count}) => 'Berhasil mengunggah ${count} gambar',
			'emoji.uploadFailed' => ({required Object count}) => 'Gagal ${count}',
			'emoji.uploadFailedMessage' => 'Gagal mengunggah gambar, silakan periksa koneksi jaringan atau format berkas',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Terjadi kesalahan saat mengunggah: ${error}',
			'searchFilter.selectField' => 'Pilih Bidang',
			'searchFilter.add' => 'Tambah',
			'searchFilter.clear' => 'Bersihkan',
			'searchFilter.clearAll' => 'Bersihkan Semua',
			'searchFilter.generatedQuery' => 'Kueri yang Dihasilkan',
			'searchFilter.copyToClipboard' => 'Salin ke Papan Klip',
			'searchFilter.copied' => 'Disalin',
			'searchFilter.filterCount' => ({required Object count}) => '${count} filter',
			'searchFilter.filterSettings' => 'Pengaturan Filter',
			'searchFilter.field' => 'Bidang',
			'searchFilter.operator' => 'Operator',
			'searchFilter.language' => 'Bahasa',
			'searchFilter.value' => 'Nilai',
			'searchFilter.dateRange' => 'Rentang Tanggal',
			'searchFilter.numberRange' => 'Rentang Angka',
			'searchFilter.from' => 'Dari',
			'searchFilter.to' => 'Sampai',
			'searchFilter.date' => 'Tanggal',
			'searchFilter.number' => 'Angka',
			'searchFilter.boolean' => 'Boolean',
			'searchFilter.tags' => 'Tag',
			'searchFilter.select' => 'Pilih',
			'searchFilter.clickToSelectDate' => 'Klik untuk memilih tanggal',
			'searchFilter.pleaseEnterValidNumber' => 'Silakan masukkan angka yang valid',
			'searchFilter.pleaseEnterValidDate' => 'Silakan masukkan format tanggal yang valid (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'Nilai awal harus kurang dari nilai akhir',
			'searchFilter.startDateMustBeBeforeEndDate' => 'Tanggal mulai harus sebelum tanggal akhir',
			'searchFilter.pleaseFillStartValue' => 'Silakan isi nilai awal',
			'searchFilter.pleaseFillEndValue' => 'Silakan isi nilai akhir',
			'searchFilter.rangeValueFormatError' => 'Kesalahan format nilai rentang',
			'searchFilter.contains' => 'Mengandung',
			'searchFilter.equals' => 'Sama dengan',
			'searchFilter.notEquals' => 'Tidak Sama dengan',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Rentang',
			'searchFilter.kIn' => 'Mengandung Salah Satu',
			'searchFilter.notIn' => 'Tidak Mengandung Salah Satu',
			'searchFilter.username' => 'Nama Pengguna',
			'searchFilter.nickname' => 'Nama Panggilan',
			'searchFilter.registrationDate' => 'Tanggal Pendaftaran',
			'searchFilter.description' => 'Deskripsi',
			'searchFilter.title' => 'Judul',
			'searchFilter.body' => 'Isi',
			'searchFilter.author' => 'Penulis',
			'searchFilter.publishDate' => 'Tanggal Publikasi',
			'searchFilter.private' => 'Privat',
			'searchFilter.duration' => 'Durasi (detik)',
			'searchFilter.likes' => 'Suka',
			'searchFilter.views' => 'Tayangan',
			'searchFilter.comments' => 'Komentar',
			'searchFilter.rating' => 'Peringkat',
			'searchFilter.imageCount' => 'Jumlah Gambar',
			'searchFilter.videoCount' => 'Jumlah Video',
			'searchFilter.createDate' => 'Tanggal Dibuat',
			'searchFilter.content' => 'Konten',
			'searchFilter.all' => 'Semua',
			'searchFilter.adult' => 'Dewasa',
			'searchFilter.general' => 'Umum',
			'searchFilter.yes' => 'Ya',
			'searchFilter.no' => 'Tidak',
			'searchFilter.users' => 'Pengguna',
			'searchFilter.videos' => 'Video',
			'searchFilter.images' => 'Gambar',
			'searchFilter.posts' => 'Postingan',
			'searchFilter.forumThreads' => 'Utas Forum',
			'searchFilter.forumPosts' => 'Postingan Forum',
			'searchFilter.playlists' => 'Daftar Putar',
			'searchFilter.sortTypes.relevance' => 'Relevansi',
			'searchFilter.sortTypes.latest' => 'Terbaru',
			'searchFilter.sortTypes.views' => 'Tayangan',
			'searchFilter.sortTypes.likes' => 'Suka',
			'searchFilter.drawerSubtitle' => 'Perubahan berlaku seketika',
			'firstTimeSetup.welcome.title' => 'Selamat Datang',
			'firstTimeSetup.welcome.subtitle' => 'Mari mulai perjalanan penyiapan yang dipersonalisasi',
			'firstTimeSetup.welcome.description' => 'Hanya beberapa langkah untuk menyesuaikan pengalaman terbaik bagi Anda',
			'firstTimeSetup.basic.title' => 'Pengaturan Dasar',
			'firstTimeSetup.basic.subtitle' => 'Personalisasi pengalaman Anda',
			'firstTimeSetup.basic.description' => 'Pilih preferensi yang sesuai untuk Anda',
			'firstTimeSetup.network.title' => 'Pengaturan Jaringan',
			'firstTimeSetup.network.subtitle' => 'Konfigurasikan opsi jaringan',
			'firstTimeSetup.network.description' => 'Sesuaikan dengan lingkungan jaringan Anda',
			'firstTimeSetup.network.tip' => 'Perlu dimulai ulang setelah konfigurasi berhasil agar berlaku',
			'firstTimeSetup.theme.title' => 'Pengaturan Tema',
			'firstTimeSetup.theme.subtitle' => 'Pilih tampilan yang Anda sukai',
			'firstTimeSetup.theme.description' => 'Personalisasi pengalaman visual Anda',
			'firstTimeSetup.player.title' => 'Pengaturan Pemutar',
			'firstTimeSetup.player.subtitle' => 'Konfigurasikan kontrol pemutaran',
			'firstTimeSetup.player.description' => 'Atur preferensi pemutaran yang umum digunakan dengan cepat',
			'firstTimeSetup.spatial.title' => 'Pemutaran Spasial',
			'firstTimeSetup.spatial.subtitle' => 'Menonton dan menelusuri di headset',
			'firstTimeSetup.spatial.description' => 'Di headset, video dan galeri muncul di ruang sekitar Anda alih-alih di dalam panel melayang ini',
			'firstTimeSetup.completion.title' => 'Selesaikan Penyiapan',
			'firstTimeSetup.completion.subtitle' => 'Anda siap memulai perjalanan Anda',
			'firstTimeSetup.completion.description' => 'Silakan baca dan setujui perjanjian terkait',
			'firstTimeSetup.completion.agreementTitle' => 'Perjanjian Pengguna dan Aturan Komunitas',
			'firstTimeSetup.completion.agreementDesc' => 'Sebelum menggunakan aplikasi ini, harap baca dan setujui perjanjian pengguna serta aturan komunitas kami dengan saksama. Ketentuan ini membantu menjaga lingkungan yang baik.',
			'firstTimeSetup.completion.checkboxTitle' => 'Saya telah membaca dan menyetujui perjanjian pengguna dan aturan komunitas',
			'firstTimeSetup.completion.checkboxSubtitle' => 'Anda tidak dapat menggunakan aplikasi jika tidak setuju',
			'firstTimeSetup.common.settingsChangeableTip' => 'Pengaturan ini dapat diubah kapan saja di Pengaturan',
			'firstTimeSetup.common.previousStep' => 'Langkah sebelumnya',
			'firstTimeSetup.common.nextStep' => 'Langkah berikutnya',
			'firstTimeSetup.common.finishSetup' => 'Selesaikan penyiapan',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Silakan setujui perjanjian pengguna dan aturan komunitas terlebih dahulu',
			'proxyHelper.systemProxyDetected' => 'Proksi sistem terdeteksi',
			'proxyHelper.copied' => 'Disalin',
			'proxyHelper.copy' => 'Salin',
			'tagSelector.selectTags' => 'Pilih Tag',
			'tagSelector.clickToSelectTags' => 'Klik untuk memilih tag',
			'tagSelector.addTag' => 'Tambah Tag',
			'tagSelector.removeTag' => 'Hapus Tag',
			'tagSelector.deleteTag' => 'Hapus Tag',
			'tagSelector.usageInstructions' => 'Tambahkan tag terlebih dahulu, lalu klik untuk memilih dari tag yang ada',
			'tagSelector.usageInstructionsTooltip' => 'Petunjuk Penggunaan',
			'tagSelector.addTagTooltip' => 'Tambah Tag',
			'tagSelector.removeTagTooltip' => 'Hapus Tag',
			'tagSelector.cancelSelection' => 'Batalkan Pilihan',
			'tagSelector.selectAll' => 'Pilih Semua',
			'tagSelector.cancelSelectAll' => 'Batalkan Pilih Semua',
			'tagSelector.delete' => 'Hapus',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Peningkatan resolusi dan penghilangan noise video secara real-time, meningkatkan kualitas video animasi',
			'anime4k.settings' => 'Pengaturan Anime4K',
			'anime4k.preset' => 'Preset Anime4K',
			'anime4k.disable' => 'Nonaktifkan Anime4K',
			'anime4k.disableDescription' => 'Nonaktifkan efek peningkatan video',
			'anime4k.highQualityPresets' => 'Preset Kualitas Tinggi',
			'anime4k.fastPresets' => 'Preset Cepat',
			'anime4k.litePresets' => 'Preset Ringan',
			'anime4k.moreLitePresets' => 'Preset Lebih Ringan',
			'anime4k.customPresets' => 'Preset Kustom',
			'anime4k.presetGroups.highQuality' => 'Kualitas Tinggi',
			'anime4k.presetGroups.fast' => 'Cepat',
			'anime4k.presetGroups.lite' => 'Ringan',
			'anime4k.presetGroups.moreLite' => 'Lebih Ringan',
			'anime4k.presetGroups.custom' => 'Kustom',
			'anime4k.presetDescriptions.mode_a_hq' => 'Cocok untuk sebagian besar animasi 1080p, terutama yang menghadapi blur, resampling, dan artefak kompresi. Memberikan kualitas persepsi tertinggi.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Cocok untuk animasi dengan blur ringan atau efek ringing akibat penskalaan. Dapat mengurangi ringing dan aliasing secara efektif.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Cocok untuk sumber berkualitas tinggi (seperti animasi 1080p asli atau film). Menghilangkan noise dan memberikan PSNR tertinggi.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Versi lanjutan Mode A, memberikan kualitas persepsi maksimal dan dapat merekonstruksi hampir semua garis yang rusak. Dapat menimbulkan penajaman berlebihan atau ringing.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Versi lanjutan Mode B, memberikan kualitas persepsi lebih tinggi, lebih mengoptimalkan garis dan mengurangi artefak.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Versi Mode C dengan kualitas persepsi yang ditingkatkan, mempertahankan PSNR tinggi sekaligus mencoba merekonstruksi sebagian detail garis.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Versi cepat Mode A, menyeimbangkan kualitas dan performa, cocok untuk sebagian besar animasi 1080p.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Versi cepat Mode B, untuk menangani artefak dan ringing ringan dengan beban lebih rendah.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Versi cepat Mode C, untuk penghilangan noise dan peningkatan resolusi sumber berkualitas tinggi secara cepat.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Versi cepat Mode A+A, mengejar kualitas persepsi lebih tinggi pada perangkat dengan performa terbatas.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Versi cepat Mode B+B, menyediakan perbaikan garis dan pemrosesan artefak yang ditingkatkan untuk perangkat dengan performa terbatas.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Versi cepat Mode C+A, memproses sumber berkualitas tinggi dengan cepat sekaligus memberikan perbaikan garis ringan.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Peningkatan resolusi x2 ultra cepat hanya dengan model CNN tercepat, tanpa perbaikan dan penghilangan noise, beban performa minimal.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Peningkatan resolusi dan penghilangan blur secara cepat menggunakan algoritma tradisional non-CNN, lebih baik daripada algoritma pemutar bawaan dengan beban performa sangat rendah.',
			'anime4k.presetDescriptions.restore_s_only' => 'Hanya perbaikan menggunakan model CNN tercepat, tanpa peningkatan resolusi. Cocok untuk pemutaran resolusi asli yang ingin ditingkatkan kualitasnya.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Penghilangan noise cepat menggunakan filter bilateral tradisional, sangat cepat, cocok untuk menangani noise ringan.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Peningkatan resolusi cepat menggunakan algoritma tradisional, beban performa sangat rendah, lebih baik daripada bawaan pemutar.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Mode A (Cepat) + Penggelapan garis, menambahkan efek penggelapan garis pada mode A cepat untuk garis yang lebih menonjol dan bergaya.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Mode A (HQ) + Penipisan garis, menambahkan efek penipisan garis pada mode A kualitas tinggi untuk tampilan yang lebih halus.',
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
			'anime4k.presetNames.upscale_only_s' => 'Peningkatan Resolusi CNN (Ultra Cepat)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Peningkatan Resolusi & Penghilangan Blur (Cepat)',
			'anime4k.presetNames.restore_s_only' => 'Restorasi (Ultra Cepat)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Penghilangan Noise Bilateral (Ultra Cepat)',
			'anime4k.presetNames.upscale_non_cnn' => 'Peningkatan Resolusi Non-CNN (Ultra Cepat)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Mode A (Cepat) + Penggelapan Garis',
			'anime4k.presetNames.mode_a_hq_thin' => 'Mode A (HQ) + Penipisan Garis',
			'anime4k.performanceTip' => '💡 Tips: Pilih preset yang sesuai dengan performa perangkat. Perangkat kelas bawah disarankan menggunakan preset ringan.',
			'anime4k.compatibilityTip' => '⚠️ Sebagian GPU seluler (mis. Kirin 980 / Mali-G76) tidak dapat merender shader kustom apa pun. Jika gambar menjadi hitam sementara audio tetap berjalan, nonaktifkan Anime4K di sini.',
			'anime4k.autoDisabledOnRenderFailure' => 'GPU perangkat Anda gagal merender shader Anime4K, sehingga dinonaktifkan secara otomatis.',
			'siteMode.title' => 'Mode Situs',
			'siteMode.mainSite' => 'Main',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Saat ini ${currentSite} · Ketuk untuk beralih ke ${nextSite}',
			'siteMode.dialogTitle' => 'Beralih Mode Situs',
			'siteMode.dialogDescription' => 'Beralih akan menyegarkan seluruh aplikasi dan mengatur ulang daftar serta status halaman yang dimuat sebelumnya.',
			'siteMode.chooseLinkTargetTitle' => 'Pilih Situs Tujuan',
			'siteMode.chooseLinkTargetDescription' => 'Tautan ini tidak menyertakan domain. Silakan pilih apakah akan membukanya di Main atau AI.',
			'siteMode.chooseLinkTargetHint' => 'Setelah dibuka, halaman ini dan permintaan detail lanjutannya akan terus menggunakan situs yang dipilih.',
			'siteMode.alreadyUsing' => 'Anda sudah menggunakan mode situs ini.',
			'siteMode.openInSite' => ({required Object site}) => 'Buka di ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'Setelah dikonfirmasi, permintaan mendatang akan menggunakan mode ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Beralih ke ${site}. Aplikasi telah disegarkan.',
			'savedSearchConfig.title' => 'Filter Tersimpan',
			'savedSearchConfig.empty' => 'Belum ada filter tersimpan',
			'savedSearchConfig.saveTooltip' => 'Simpan filter saat ini',
			'savedSearchConfig.namePromptTitle' => 'Simpan Filter',
			'savedSearchConfig.nameLabel' => 'Nama',
			'savedSearchConfig.nameHint' => 'Masukkan nama',
			'savedSearchConfig.saveSuccess' => 'Filter disimpan',
			'savedSearchConfig.deleteSuccess' => 'Filter dihapus',
			'savedSearchConfig.addCurrent' => 'Simpan filter saat ini',
			'savedSearchConfig.reorderHint' => 'Tekan lama dan seret untuk mengurutkan',
			'savedSearchConfig.rename' => 'Ganti Nama',
			'savedSearchConfig.unnamed' => 'Tanpa Nama',
			'savedSearchConfig.noConditions' => 'Semua konten (tanpa filter)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} tag',
			'savedSearch.title' => 'Pencarian Tersimpan',
			'savedSearch.empty' => 'Belum ada pencarian tersimpan',
			'savedSearch.saveTooltip' => 'Simpan pencarian saat ini',
			'savedSearch.namePromptTitle' => 'Simpan Pencarian',
			'savedSearch.nameLabel' => 'Nama',
			'savedSearch.nameHint' => 'Masukkan nama',
			'savedSearch.saveSuccess' => 'Pencarian disimpan',
			'savedSearch.deleteSuccess' => 'Pencarian dihapus',
			'savedSearch.addCurrent' => 'Simpan pencarian saat ini',
			'savedSearch.reorderHint' => 'Tekan lama dan seret untuk mengurutkan',
			'savedSearch.rename' => 'Ganti Nama',
			'savedSearch.noKeyword' => '(Tanpa kata kunci)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} filter',
			'defaultBlacklistReminder.title' => 'Daftar Hitam Tag Bawaan Terdeteksi',
			'defaultBlacklistReminder.content' => 'Akun Anda masih menggunakan daftar hitam tag yang diterapkan situs web secara otomatis ke setiap akun baru. Ingin meninjau dan mengelolanya?',
			'defaultBlacklistReminder.goManage' => 'Kelola',
			'defaultBlacklistReminder.dismiss' => 'Nanti saja',
			'colorVisionAssist.title' => 'Bantuan Penglihatan Warna',
			'colorVisionAssist.description' => 'Mengoreksi warna video bagi penonton dengan defisiensi penglihatan warna, dapat digunakan bersama Anime4K',
			'colorVisionAssist.galleryDescription' => 'Mengoreksi warna gambar galeri bagi penonton dengan defisiensi penglihatan warna (terlepas dari sakelar pemutar)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Mengoreksi warna gambar galeri bagi penonton dengan defisiensi penglihatan warna. Hanya berlaku untuk penampil 2D di panel ini — gambar pada layar spasial dirender secara native dan tidak melewati filter ini',
			'colorVisionAssist.disable' => 'Nonaktif',
			'colorVisionAssist.disableDescription' => 'Tanpa koreksi warna',
			'colorVisionAssist.protanopia' => 'Bantuan Merah (Protanopia)',
			'colorVisionAssist.protanopiaDescription' => 'Untuk protanopia — sulit membedakan warna merah',
			'colorVisionAssist.deuteranopia' => 'Bantuan Hijau (Deuteranopia)',
			'colorVisionAssist.deuteranopiaDescription' => 'Untuk deuteranopia — sulit membedakan warna hijau',
			'colorVisionAssist.tritanopia' => 'Bantuan Biru (Tritanopia)',
			'colorVisionAssist.tritanopiaDescription' => 'Untuk tritanopia — sulit membedakan warna biru dan kuning',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} diterapkan, langsung berlaku',
			'colorVisionAssist.disabledToast' => 'Bantuan penglihatan warna dinonaktifkan',
			'externalPlayer.title' => 'Buka dengan aplikasi lain',
			'externalPlayer.description' => 'Serahkan video saat ini ke pemutar lain di perangkat ini, seperti Skybox atau Pigasus pada headset VR, atau MX Player dan VLC di ponsel',
			'externalPlayer.openWithOtherApp' => 'Pilih aplikasi lain',
			'externalPlayer.openWithOtherAppDescription' => 'Tampilkan pemilih sistem dan pilih pemutar untuk mengambil alih',
			'externalPlayer.openWithSystemPlayer' => 'Buka di pemutar bawaan',
			'externalPlayer.openWithSystemPlayerDescription' => 'Serahkan ke aplikasi video bawaan sistem',
			'externalPlayer.copyLink' => 'Salin tautan video',
			'externalPlayer.copyLinkDescription' => 'Untuk pemutar yang hanya dapat menempel URL, seperti Skybox atau DeoVR',
			'externalPlayer.linkCopied' => 'Tautan video disalin',
			'externalPlayer.sourceLocal' => 'Berkas lokal',
			'externalPlayer.sourceOnline' => 'Tautan langsung',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Tautan langsung · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'Tautan langsung dapat kedaluwarsa, sehingga pemutar eksternal mungkin berhenti di tengah jalan. Mengunduh terlebih dahulu adalah cara yang andal.',
			'externalPlayer.vrPlayerHint' => 'Jika pemutar VR Anda tidak ada di pemilih, gunakan Salin tautan video lalu tempelkan di dalam pemutar tersebut.',
			'externalPlayer.noHandler' => 'Tidak ada aplikasi di perangkat ini yang dapat membuka video',
			'externalPlayer.handoffFailed' => ({required Object message}) => 'Penyerahan gagal: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'Penyerahan gagal',
			'externalPlayer.sourceUnavailable' => 'Tidak dapat mendapatkan alamat video saat ini, silakan coba lagi',
			'externalPlayer.localFileMissing' => 'Berkas lokal sudah tidak ada',
			'externalPlayer.handedOff' => 'Diserahkan ke pemutar eksternal',
			'externalPlayer.desktopSectionTitle' => 'Pemutar eksternal',
			'externalPlayer.managePlayers' => 'Kelola pemutar eksternal',
			'externalPlayer.managePlayersDescWindows' => 'Pemutar PCVR seperti HereSphere, DeoVR, dan Whirligig bukan aplikasi bawaan sistem. Arahkan ini ke berkas .exe mereka dan Anda dapat menyerahkan video saat ini langsung dari pemutar.',
			'externalPlayer.managePlayersDescMac' => 'Arahkan ini ke pemutar seperti IINA, VLC, atau mpv dan Anda dapat menyerahkan video saat ini langsung dari pemutar.',
			'externalPlayer.managePlayersDescLinux' => 'Arahkan ini ke pemutar seperti mpv, VLC, atau Celluloid dan Anda dapat menyerahkan video saat ini langsung dari pemutar.',
			'externalPlayer.pickExecutableHintWindows' => 'Pilih berkas .exe utama di dalam folder pemasangan pemutar, mis. HereSphere.exe atau vlc.exe. Pintasan desktop (.lnk) tidak akan berfungsi.',
			'externalPlayer.pickExecutableHintMac' => 'Pilih berkas .app pemutar di Applications, mis. IINA.app — berkas eksekusi sebenarnya di dalamnya akan ditemukan untuk Anda.',
			'externalPlayer.pickExecutableHintLinux' => 'Pilih berkas eksekusi pemutar, mis. /usr/bin/mpv. Menjalankan which mpv akan memberi tahu lokasinya.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'Setelah dikonfigurasi, ia muncul sebagai entri tersendiri di bawah Buka dengan aplikasi lain pada halaman pemutar. Yang umum: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'Tidak ada pemutar terpasang yang ditemukan. Folder pemasangan kustom dan versi portabel tidak dapat dideteksi — gunakan Tambah pemutar untuk menunjuk pemutar sendiri.',
			'externalPlayer.detectNothingNew' => 'Tidak ada pemutar baru yang ditemukan; semua yang terpasang sudah ada dalam daftar',
			'externalPlayer.detectFailed' => 'Deteksi gagal — gunakan Tambah pemutar untuk menunjuk pemutar sendiri',
			'externalPlayer.advancedOptions' => 'Lanjutan',
			'externalPlayer.playerNameHint' => 'Biarkan kosong untuk menggunakan nama berkas',
			'externalPlayer.executablePathRequired' => 'Pilih berkas eksekusi pemutar terlebih dahulu',
			'externalPlayer.playerCount' => ({required Object count}) => '${count} dikonfigurasi',
			'externalPlayer.noPlayerConfigured' => 'Belum ada pemutar eksternal yang dikonfigurasi',
			'externalPlayer.autoDetect' => 'Deteksi otomatis',
			'externalPlayer.detecting' => 'Mendeteksi…',
			'externalPlayer.detectFound' => ({required Object count}) => 'Menemukan ${count} pemutar',
			'externalPlayer.detectNothingFound' => 'Tidak ada pemutar baru yang ditemukan, tambahkan secara manual',
			'externalPlayer.autoDetectedTag' => 'terdeteksi',
			'externalPlayer.addPlayer' => 'Tambah pemutar',
			'externalPlayer.editPlayer' => 'Ubah pemutar',
			'externalPlayer.playerName' => 'Nama',
			'externalPlayer.executablePath' => 'Berkas eksekusi',
			'externalPlayer.browse' => 'Telusuri',
			'externalPlayer.argumentTemplate' => 'Argumen peluncuran',
			'externalPlayer.argumentTemplateHint' => 'Gunakan {input} untuk jalur atau URL video. Biarkan kosong untuk meneruskannya sebagai satu-satunya argumen.',
			'externalPlayer.nameAndPathRequired' => 'Nama dan berkas eksekusi keduanya wajib diisi',
			'externalPlayer.testLaunch' => 'Uji peluncuran',
			'externalPlayer.testLaunched' => 'Pemutar diluncurkan',
			'externalPlayer.testFailed' => 'Peluncuran gagal, periksa jalur berkas eksekusi',
			'externalPlayer.executableMissing' => 'Berkas eksekusi tidak ditemukan',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'Buka di ${name}',
			'externalPlayer.managePlayersEntry' => 'Kelola pemutar eksternal…',
			'watchLater.title' => 'Tonton Nanti',
			'watchLater.addToWatchLater' => 'Tonton nanti',
			'watchLater.removeFromWatchLater' => 'Hapus dari Tonton Nanti',
			'watchLater.addedToWatchLater' => 'Ditambahkan ke Tonton Nanti',
			'watchLater.alreadyInWatchLater' => 'Sudah ada di Tonton Nanti',
			'watchLater.removedFromWatchLater' => 'Dihapus dari Tonton Nanti',
			'watchLater.removedCount' => ({required Object count}) => 'Menghapus ${count} item',
			'watchLater.viewWatchLaterList' => 'Lihat daftar',
			'watchLater.addFailed' => 'Gagal menambahkan ke Tonton Nanti',
			'watchLater.invalidItem' => 'Tidak Tersedia',
			'watchLater.clearWatched' => 'Bersihkan yang telah ditonton',
			'watchLater.watchedCleared' => ({required Object count}) => 'Membersihkan ${count} item yang ditonton',
			'watchLater.noWatchedToClear' => 'Tidak ada yang ditonton untuk dibersihkan',
			'watchLater.emptyVideo' => 'Belum ada video di Tonton Nanti',
			'watchLater.emptyGallery' => 'Belum ada galeri di Tonton Nanti',
			'watchLater.filterAll' => 'Semua',
			'watchLater.filterUnwatched' => 'Belum Ditonton',
			'watchLater.sortRecentlyAdded' => 'Baru-baru ini ditambahkan',
			'watchLater.sortEarliestAdded' => 'Ditambahkan paling awal',
			'watchLater.watched' => 'Ditonton',
			'watchLater.playlistLoadFailed' => 'Gagal memuat daftar putar',
			'watchLater.noPlaylists' => 'Belum ada daftar putar',
			'watchLater.undo' => 'Urungkan',
			'watchLater.clearWatchedConfirm' => 'Hapus semua yang sudah Anda tonton di tab ini? Tindakan ini tidak dapat dibatalkan.',
			'watchLater.emptyUnwatchedVideo' => 'Tidak ada lagi yang bisa ditonton di sini',
			'watchLater.emptyUnwatchedGallery' => 'Tidak ada lagi yang bisa dilihat di sini',
			'watchLater.queueLoadFailed' => 'Gagal memuat, ketuk untuk mencoba lagi',
			'mediaMenu.like' => 'Suka',
			'mediaMenu.unlike' => 'Batal Suka',
			'mediaMenu.viewAuthor' => 'Lihat penulis',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} folder',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} daftar putar',
			'mediaMenu.downloaded' => 'Terunduh',
			'mediaPreview.preview' => 'Pratinjau',
			'mediaPreview.openDetail' => 'Buka',
			'mediaPreview.moreActions' => 'Tindakan lainnya',
			'mediaPreview.previousImage' => 'Gambar sebelumnya',
			'mediaPreview.nextImage' => 'Gambar berikutnya',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} gambar',
			'playbackQueue.upNext' => 'Berikutnya',
			'playbackQueue.sourceTab' => 'Sumber',
			'playbackQueue.emptyQueue' => 'Tidak ada yang dapat diputar dalam antrean ini',
			'playbackQueue.emptyGalleryQueue' => 'Tidak ada galeri dalam antrean ini',
			'playbackQueue.nowPlaying' => 'Sedang diputar',
			'playbackQueue.myPlaylists' => 'Daftar putar saya',
			'playbackQueue.authorPlaylists' => 'Daftar putar penulis',
			'playbackQueue.openQueue' => 'Berikutnya',
			'playbackQueue.continueInQueue' => 'Lanjutkan pemutaran dari antrean saat ini',
			'playbackQueue.continueInQueueSubtitle' => 'Memutar item berikutnya secara otomatis; menonaktifkan "ulangi saat selesai"',
			'playbackQueue.repeatDisabledByQueue' => 'Dinonaktifkan saat "lanjutkan pemutaran dari antrean saat ini" aktif',
			'playbackQueue.playNext' => 'Putar berikutnya',
			'playbackQueue.queueEnded' => 'Ini adalah item terakhir dalam antrean',
			'playbackQueue.playNextHint' => 'Ketuk untuk memutar item berikutnya, tekan lama untuk membuka Berikutnya',
			'playbackQueue.authorVideos' => 'Video penulis',
			'playbackQueue.authorGalleries' => 'Galeri penulis',
			'playbackQueue.favoriteFolders' => 'Folder favorit',
			'playbackQueue.localFiles' => 'Di perangkat ini',
			'playbackQueue.currentFolder' => 'Folder file ini',
			'playbackQueue.playThisFolder' => 'Lihat antrean video folder ini',
			'playbackQueue.browseThisFolder' => 'Lihat antrean galeri folder ini',
			'playbackQueue.downloads' => 'Diunduh',
			'playbackQueue.otherPlaylists' => 'Daftar putar pengguna lain',
			'playbackQueue.nothingHere' => 'Tidak ada apa-apa di sini',
			'vrFormat.playInSpace' => 'Putar di pemutar spasial',
			'vrFormat.handingOff' => 'Menyerahkan ke ruang…',
			'vrFormat.title' => 'Mode pemutaran',
			'vrFormat.spatialSectionTitle' => 'Pemutaran spasial',
			'vrFormat.spatialSectionDesc' => 'Di headset, video tidak digambar di dalam panel ini — pemutar spasial menempatkannya di layar di dalam ruangan.',
			'vrFormat.spatialPanelEntry' => 'Panel kontrol spasial',
			'vrFormat.spatialPanelEntryDesc' => 'Jarak layar, ukuran dan kelengkungan, lingkungan latar belakang, serta kecepatan, pengulangan, dan sembunyikan otomatis semuanya ada di panel kontrol spasial.',
			'vrFormat.spatialGuideEntry' => 'Panduan kontrol headset',
			'vrFormat.spatialGuideEntryDesc' => 'Tombol pengontrol, memegang layar, pencarian stik, dan pembalikan halaman',
			'vrFormat.spatialFlatOmitted' => 'Gerakan sentuh, peningkatan gambar, dan parameter audio/video hanya berlaku untuk pemutar 2D; pemutar spasial berjalan pada mesin yang berbeda, sehingga tidak dicantumkan di sini.',
			'vrFormat.spatialGallerySectionTitle' => 'Galeri spasial',
			'vrFormat.spatialGalleryPanelDesc' => 'Interval tayangan slide, pengulangan klip tunggal, dan kelengkungan layar semuanya diatur di panel kontrol spasial.',
			'vrFormat.autoEnterGallery' => 'Buka gambar galeri di galeri spasial',
			'vrFormat.autoEnterGalleryDesc' => 'Di Quest, mengetuk gambar akan membuka seluruh galeri di layar melayang dengan strip film, tayangan slide, dan pembalikan halaman pengontrol, alih-alih penampil di dalam panel ini.',
			'vrFormat.panelSettings' => 'Panel & latar belakang',
			'vrFormat.panelSettingsDesc' => 'Seberapa jauh panel aplikasi ini berada, dan seberapa banyak ruangan Anda terlihat di belakangnya',
			'vrFormat.panelDistance' => 'Jarak panel',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Atur ulang penempatan',
			'vrFormat.panelResetBackground' => 'Atur ulang ke bawaan',
			'vrFormat.panelBackground' => 'Transparansi latar belakang',
			'vrFormat.panelBackgroundHint' => '0%: lingkungan hitam · 100%: ruangan nyata Anda, dengan pencahayaan sekitar',
			'vrFormat.panelUnavailable' => 'Panel sedang tidak pada tempatnya — coba lagi sebentar lagi',
			'vrFormat.desc' => 'Pilih geometri yang harus digunakan untuk memutar video ini. Situs tidak menyediakan informasi ini, jadi deteksi otomatis hanya memilih titik awal — pilihan Anda yang menang.',
			'vrFormat.sectionFlat' => 'Datar',
			'vrFormat.sectionStereo' => '3D datar',
			'vrFormat.sectionPanorama' => 'Panorama VR',
			'vrFormat.flat' => 'Video normal',
			'vrFormat.flatDesc' => 'Putar apa adanya, tanpa pemetaan ulang',
			'vrFormat.flatSideBySide' => '3D berdampingan',
			'vrFormat.flatSideBySideDesc' => 'Satu mata per separuh, kiri dan kanan; menampilkan mata kiri dan memulihkan rasio aspeknya',
			'vrFormat.flatTopBottom' => '3D atas-bawah',
			'vrFormat.flatTopBottomDesc' => 'Satu mata per separuh, atas dan bawah; menampilkan separuh atas dan memulihkan rasio aspeknya',
			'vrFormat.vr180SideBySide' => 'VR180 berdampingan',
			'vrFormat.vr180SideBySideDesc' => 'Panorama hemisferis dengan kedua mata — sumber VR paling umum',
			'vrFormat.vr180Mono' => 'VR180 mono',
			'vrFormat.vr180MonoDesc' => 'Panorama hemisferis, satu mata per bingkai',
			'vrFormat.vr360Mono' => 'VR360 mono',
			'vrFormat.vr360MonoDesc' => 'Panorama sekeliling penuh, satu mata per bingkai',
			'vrFormat.vr360TopBottom' => 'VR360 atas-bawah',
			'vrFormat.vr360TopBottomDesc' => 'Panorama sekeliling penuh dengan kedua mata ditumpuk',
			'vrFormat.resetView' => 'Atur ulang tampilan',
			'vrFormat.resetViewDesc' => 'Kembalikan arah pandang dan bidang pandang ke depan',
			_ => null,
		} ?? switch (path) {
			'vrFormat.resetToAuto' => 'Kembali ke deteksi otomatis',
			'vrFormat.resetToAutoDesc' => 'Lupakan pilihan manual untuk video ini dan biarkan deteksi memutuskan lagi',
			'vrFormat.manualBadge' => 'Diatur secara manual',
			'vrFormat.panoramaHint' => 'Seret gambar untuk melihat sekeliling, cubit untuk mengubah bidang pandang',
			'vrFormat.panoramaGestureNotice' => 'Saat melihat sekeliling, menyeret akan memutar tampilan — gunakan bilah kemajuan untuk mencari',
			'vrFormat.shaderUnsupported' => 'Perangkat ini tidak dapat menampilkan panorama langsung; menampilkan satu mata sebagai gantinya',
			'vrFormat.handoffTooltip' => 'Putar dengan cara lain',
			'vrFormat.suggestedBadge' => 'Disarankan',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Tampak seperti ${format} — ketuk untuk beralih',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Ini mungkin video VR (${format})',
			'vrFormat.suggestionTitleShort' => 'Ini mungkin video VR',
			'vrFormat.suggestionAction' => 'Putar sebagai VR',
			'vrFormat.suggestionDismiss' => 'Tutup',
			'localMedia.browse.pinnedSection' => 'Akses cepat',
			'localMedia.browse.sourcesSection' => 'Folder',
			'localMedia.browse.pin' => 'Tambahkan ke akses cepat',
			'localMedia.browse.unpin' => 'Hapus dari akses cepat',
			'localMedia.browse.pinned' => 'Ditambahkan ke akses cepat',
			'localMedia.browse.unpinned' => 'Dihapus dari akses cepat',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} folder',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} video',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} gambar',
			'localMedia.browse.emptyFolder' => 'Folder ini kosong',
			'localMedia.browse.videosSection' => 'Video',
			'localMedia.browse.imagesSection' => 'Gambar',
			'localMedia.browse.galleriesSection' => 'Galeri',
			'localMedia.browse.filterAll' => 'Semua',
			'localMedia.browse.searchInFolder' => 'Cari di folder ini',
			'localMedia.browse.searchHint' => 'Cari berdasarkan nama',
			'localMedia.browse.clearSearch' => 'Hapus pencarian',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'Tidak ada yang cocok dengan "${query}"',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Lihat semua ${count} folder',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Lihat semua ${count} video',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Lihat semua ${count} gambar',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Lihat semua ${count} galeri',
			'localMedia.browse.location' => 'Lokasi',
			'localMedia.browse.sourceMissing' => 'Sumber ini sudah hilang',
			'localMedia.browse.notScannedYet' => 'Folder ini belum dipindai',
			'localMedia.browse.scanning' => 'Membaca folder ini…',
			'localMedia.browse.deleteFileTitle' => 'Hapus berkas ini?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '"${name}" akan dihapus secara permanen dari perangkat ini. Tindakan ini tidak dapat dibatalkan.',
			'localMedia.browse.hideFolder' => 'Sembunyikan folder ini',
			'localMedia.browse.unhideFolder' => 'Tampilkan lagi',
			'localMedia.browse.showHiddenFolders' => 'Tampilkan folder tersembunyi',
			'localMedia.browse.includeDotFolders' => 'Pindai folder yang diawali .',
			'localMedia.browse.dotFoldersIncluded' => 'Folder yang diawali . sekarang dipindai',
			'localMedia.browse.dotFoldersExcluded' => 'Folder yang diawali . tidak lagi dipindai',
			'localMedia.browse.showDotFolders' => 'Tampilkan folder yang diawali .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'Ada ${count} folder yang diawali . di sini yang belum dipindai',
			'localMedia.browse.scanDotFoldersAction' => 'Aktifkan untuk sumber ini',
			'localMedia.browse.otherAppsPrivateNotice' => 'Sejak Android 11, tidak ada aplikasi yang dapat membaca file aplikasi lain di Android/data atau Android/obb, dan aplikasi ini tidak bisa mengakalinya. Unduh atau ekspor video ke folder publik seperti Download di aplikasi aslinya, lalu tambahkan folder itu di sini. Cache saat menonton biasanya terpecah-pecah dan tidak bisa diputar meski terbaca.',
			'localMedia.browse.folderHidden' => 'Disembunyikan — pemindaian juga akan melewatinya',
			'localMedia.browse.folderUnhidden' => 'Tidak lagi disembunyikan',
			'localMedia.browse.hiddenFolderBadge' => 'Tersembunyi',
			'localMedia.browse.deleteFolder' => 'Hapus folder',
			'localMedia.browse.deleteFolderTitle' => 'Hapus folder ini?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '"${name}" beserta seluruh isinya akan dihapus permanen dari perangkat ini. Tindakan ini tidak bisa dibatalkan.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Berkas lain di dalamnya juga akan dihapus',
			'localMedia.browse.folderDeleted' => 'Folder dihapus',
			'localMedia.browse.deleteFolderFailed' => 'Gagal menghapus — tidak ada izin, atau ada berkas di dalamnya yang sedang dipakai',
			'localMedia.browse.deleteGalleryTitle' => 'Hapus galeri ini?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'Catatan unduhan dan berkas gambar lokal "${name}" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
			'localMedia.browse.galleryResourceMissing' => 'Berkas lokal sudah tidak ada. Catatan dibersihkan.',
			'localMedia.browse.viewDownloadDetail' => 'Lihat rincian unduhan',
			'localMedia.browse.viewOnlineGallery' => 'Lihat di situs web',
			'localMedia.browse.pickFolderTitle' => 'Pilih folder',
			'localMedia.browse.useThisFolder' => 'Gunakan folder ini',
			'localMedia.browse.noSubfolders' => 'Tidak ada subfolder di sini',
			'localMedia.browse.storageRoot' => 'Penyimpanan perangkat',
			'localMedia.browse.homeFolder' => 'Beranda',
			'localMedia.browse.filesystemRoot' => 'Akar sistem berkas',
			'localMedia.browse.folderUnreadable' => 'Folder ini tidak dapat dibaca',
			'localMedia.browse.setCover' => 'Atur sampul',
			'localMedia.browse.setAsFolderCover' => 'Gunakan sebagai sampul folder',
			'localMedia.browse.folderCoverSet' => 'Sampul folder diperbarui',
			'localMedia.browse.setFolderCoverPick' => 'Atur sampul…',
			'localMedia.browse.restoreAutoCover' => 'Pulihkan sampul otomatis',
			'localMedia.browse.autoCoverRestored' => 'Sampul otomatis dipulihkan',
			'localMedia.browse.rescanFolder' => 'Pindai ulang folder ini',
			'localMedia.browse.coverPickerTitle' => 'Pilih satu bingkai',
			'localMedia.browse.folderCoverPickerTitle' => 'Pilih sampul',
			'localMedia.browse.coverPickerEmpty' => 'Belum ada gambar di folder ini. Thumbnail video mungkin masih dibuat di latar belakang.',
			'localMedia.browse.coverSaved' => 'Sampul diperbarui',
			'localMedia.browse.coverSaveFailed' => 'Tidak dapat menyimpan sampul',
			'localMedia.browse.coverUnavailable' => 'Tidak ada bingkai video yang dapat dibaca dari berkas ini',
			'localMedia.browse.deleted' => 'Dihapus',
			'localMedia.browse.deleteFailed' => 'Tidak dapat menghapus — berkas mungkin sedang digunakan atau tidak dapat ditulis',
			'localMedia.browse.openFolder' => 'Buka',
			'localMedia.browse.favorite' => 'Tambahkan ke favorit',
			'localMedia.browse.unfavorite' => 'Hapus dari favorit',
			'localMedia.browse.favorited' => 'Ditambahkan ke favorit',
			'localMedia.browse.unfavorited' => 'Dihapus dari favorit',
			'localMedia.browse.sortBy' => 'Urutkan berdasarkan',
			'localMedia.browse.sortAscending' => 'Naik',
			'localMedia.browse.sortDescending' => 'Turun',
			'localMedia.browse.sortFieldName' => 'Nama',
			'localMedia.browse.sortFieldModified' => 'Tanggal diubah',
			'localMedia.browse.sortFieldDuration' => 'Durasi',
			'localMedia.browse.sortFieldSize' => 'Ukuran',
			'localMedia.browse.sortFieldResolution' => 'Resolusi',
			'localMedia.browse.sortFieldFileType' => 'Jenis berkas',
			'localMedia.browse.sortFieldFps' => 'Laju bingkai',
			'localMedia.browse.sortFieldFavorited' => 'Tanggal difavoritkan',
			'localMedia.browse.emptyAllVideos' => 'Belum ada video yang ditemukan. Tambahkan folder di bagian Folder untuk memulai.',
			'localMedia.browse.emptyAllImages' => 'Belum ada gambar yang ditemukan. Tambahkan folder di bagian Folder untuk memulai.',
			'localMedia.browse.emptyFavorites' => 'Belum ada favorit. Tambahkan satu dari menu ⋮ pada video.',
			'localMedia.browse.emptyPinned' => 'Belum ada folder yang disematkan. Tekan lama folder di bagian Folder lalu pilih Sematkan.',
			'localMedia.browse.emptyDownloadedVideos' => 'Belum ada unduhan video yang selesai.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Belum ada unduhan galeri yang selesai.',
			'localMedia.browse.folderInfo' => 'Info folder',
			'localMedia.browse.folderInfoName' => 'Nama',
			'localMedia.browse.folderInfoPath' => 'Jalur',
			'localMedia.browse.folderInfoSource' => 'Sumber',
			'localMedia.browse.folderInfoContents' => 'Isi',
			'localMedia.browse.folderInfoSize' => 'Ukuran di disk',
			'localMedia.browse.folderInfoScannedAt' => 'Terakhir dipindai',
			'localMedia.browse.folderInfoNeverScanned' => 'Belum dipindai',
			'localMedia.browse.folderInfoNoPath' => 'Sumber ini tidak memiliki folder untuk dibuka',
			'localMedia.browse.copyPath' => 'Salin jalur',
			'localMedia.browse.pathCopied' => 'Jalur disalin',
			'localMedia.tabFolders' => 'Folder',
			'localMedia.tabFavoriteVideos' => 'Favorit',
			'localMedia.tabAllVideos' => 'Semua video',
			'localMedia.tabAllImages' => 'Semua gambar',
			'localMedia.tabDownloadedVideos' => 'Video terunduh',
			'localMedia.tabDownloadedGalleries' => 'Galeri terunduh',
			'localMedia.title' => 'Di perangkat ini',
			'localMedia.sourceOnline' => 'Iwara online',
			'localMedia.manageSources' => 'Kelola sumber',
			'localMedia.moveToCategory' => 'Pindahkan ke kategori',
			'localMedia.manageCategories' => 'Kelola kategori',
			'localMedia.suggestedFolders' => 'Folder dengan video',
			'localMedia.sortRecentlyAdded' => 'Baru ditambahkan',
			'localMedia.sortRecentlyPlayed' => 'Baru diputar',
			'localMedia.sortName' => 'Nama',
			'localMedia.sortDuration' => 'Durasi',
			'localMedia.sortSize' => 'Ukuran',
			'localMedia.sortFolder' => 'Folder',
			'localMedia.sortRecentlyModified' => 'Baru diubah',
			'localMedia.sortCount' => 'Jumlah',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} gambar',
			'localMedia.downloadsSource' => 'Diunduh',
			'localMedia.builtInSourceHint' => 'Unduhan dikelola secara otomatis',
			'localMedia.filterByCategory' => 'Saring berdasarkan kategori',
			'localMedia.longPressToCategorize' => 'Tekan lama untuk memindahkan ke kategori',
			'localMedia.uncategorized' => 'Tanpa Kategori',
			'localMedia.setCategoryFailed' => 'Tidak dapat mengatur kategori',
			'localMedia.categoryUpdated' => 'Kategori diperbarui',
			'localMedia.addFolder' => 'Tambah folder',
			'localMedia.addDeviceVideos' => 'Pindai video perangkat',
			'localMedia.mediaStoreSourceName' => 'Video perangkat',
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
			'localMedia.mediaStoreUnavailable' => 'Indeks media perangkat hanya tersedia di Android',
			'localMedia.mediaStorePermissionDenied' => 'Akses video tidak diberikan',
			'localMedia.rescan' => 'Pindai ulang',
			'localMedia.scanning' => ({required Object count}) => 'Memindai… ${count} ditemukan',
			'localMedia.scanFailed' => ({required Object reason}) => 'Pemindaian gagal: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Folder itu sangat besar — hanya ${count} berkas pertama yang ditambahkan.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Sudah tercakup oleh folder "${name}"',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '"${name}" berada di dalam "${source}", jadi ditambahkan ke folder yang disematkan',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '"${name}" sudah ada di folder yang disematkan',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '"${name}" sudah ditambahkan',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Sudah berisi folder yang ditambahkan "${name}"; menambahkan folder induknya belum didukung',
			'localMedia.addSourceFailed' => 'Tidak dapat menambahkan folder tersebut',
			'localMedia.fileMissing' => 'Berkas itu sudah tidak ada di disk',
			'localMedia.permissionDenied' => 'Akses berkas tidak diberikan · ketuk untuk memberi izin',
			'localMedia.noVideosFound' => 'Tidak ada video di folder ini',
			'localMedia.emptyTitle' => 'Tambahkan folder untuk menonton video yang sudah ada di perangkat ini',
			'localMedia.emptyPrivacyNote' => 'Berkas hanya dibaca di perangkat ini. Tidak ada yang diunggah.',
			'localMedia.removeSourceTitle' => ({required Object name}) => 'Hapus "${name}"?',
			'localMedia.removeSourceBody' => 'Berkas tetap ada di disk. Hanya entri pustaka ini yang dihapus.',
			'localMedia.remove' => 'Hapus',
			'localMedia.removeFolder' => 'Hapus folder',
			'localMedia.removeFolderSelectTitle' => 'Pilih folder untuk dihapus',
			'localMedia.longPressToRemove' => 'Tekan lama untuk menghapus folder ini',
			'localMedia.clearProgress' => 'Bersihkan riwayat tontonan lokal',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} entri',
			'localMedia.clearProgressEmpty' => 'Belum ada riwayat tontonan lokal',
			'localMedia.clearProgressTitle' => 'Bersihkan riwayat tontonan lokal?',
			'localMedia.clearProgressBody' => 'Hanya posisi pemutaran dan tanda tonton yang dihapus. Berkas dan folder Anda tetap seperti semula.',
			'localMedia.clearProgressDone' => ({required Object count}) => 'Membersihkan ${count} entri riwayat tontonan lokal',
			'localMedia.clearAction' => 'Bersihkan',
			'localMedia.iosManualRescanNotice' => 'iOS tidak mendeteksi berkas baru secara otomatis. Anda perlu memindai ulang secara manual setelah menambah atau menghapus berkas.',
			'historyPage.removeFromHistory' => 'Hapus dari riwayat',
			'historyPage.removed' => 'Dihapus dari riwayat',
			'historyPage.watchedTo' => ({required Object time}) => 'Ditonton sampai ${time}',
			'historyPage.finished' => 'Sudah ditonton',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'Bersihkan "${tab}"',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Semua riwayat di "${tab}" akan dihapus, beserta progres tontonan video tersebut. Tindakan ini tidak dapat dibatalkan.',
			'historyPage.rangeByLastViewed' => 'Difilter menurut waktu terakhir dilihat',
			_ => null,
		};
	}
}
