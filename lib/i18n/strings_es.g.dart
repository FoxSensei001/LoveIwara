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
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsPersonalProfileEs personalProfile = _TranslationsPersonalProfileEs._(_root);
	@override late final _TranslationsTutorialEs tutorial = _TranslationsTutorialEs._(_root);
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsErrorsEs errors = _TranslationsErrorsEs._(_root);
	@override late final _TranslationsFriendsEs friends = _TranslationsFriendsEs._(_root);
	@override late final _TranslationsAuthorProfileEs authorProfile = _TranslationsAuthorProfileEs._(_root);
	@override late final _TranslationsFavoritesEs favorites = _TranslationsFavoritesEs._(_root);
	@override late final _TranslationsGalleryDetailEs galleryDetail = _TranslationsGalleryDetailEs._(_root);
	@override late final _TranslationsPlayListEs playList = _TranslationsPlayListEs._(_root);
	@override late final _TranslationsSearchEs search = _TranslationsSearchEs._(_root);
	@override late final _TranslationsMediaListEs mediaList = _TranslationsMediaListEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
	@override late final _TranslationsFavoriteTagsEs favoriteTags = _TranslationsFavoriteTagsEs._(_root);
	@override late final _TranslationsOreno3dEs oreno3d = _TranslationsOreno3dEs._(_root);
	@override late final _TranslationsSignInEs signIn = _TranslationsSignInEs._(_root);
	@override late final _TranslationsSubscriptionsEs subscriptions = _TranslationsSubscriptionsEs._(_root);
	@override late final _TranslationsVideoDetailEs videoDetail = _TranslationsVideoDetailEs._(_root);
	@override late final _TranslationsShareEs share = _TranslationsShareEs._(_root);
	@override late final _TranslationsMarkdownEs markdown = _TranslationsMarkdownEs._(_root);
	@override late final _TranslationsForumEs forum = _TranslationsForumEs._(_root);
	@override late final _TranslationsNotificationsEs notifications = _TranslationsNotificationsEs._(_root);
	@override late final _TranslationsConversationEs conversation = _TranslationsConversationEs._(_root);
	@override late final _TranslationsSplashEs splash = _TranslationsSplashEs._(_root);
	@override late final _TranslationsDownloadEs download = _TranslationsDownloadEs._(_root);
	@override late final _TranslationsDownloadNotificationsEs downloadNotifications = _TranslationsDownloadNotificationsEs._(_root);
	@override late final _TranslationsFavoriteEs favorite = _TranslationsFavoriteEs._(_root);
	@override late final _TranslationsTranslationEs translation = _TranslationsTranslationEs._(_root);
	@override late final _TranslationsBottomNavEs bottomNav = _TranslationsBottomNavEs._(_root);
	@override late final _TranslationsNavigationOrderSettingsEs navigationOrderSettings = _TranslationsNavigationOrderSettingsEs._(_root);
	@override late final _TranslationsNewsEs news = _TranslationsNewsEs._(_root);
	@override late final _TranslationsDisplaySettingsEs displaySettings = _TranslationsDisplaySettingsEs._(_root);
	@override late final _TranslationsLayoutSettingsEs layoutSettings = _TranslationsLayoutSettingsEs._(_root);
	@override late final _TranslationsMediaPlayerEs mediaPlayer = _TranslationsMediaPlayerEs._(_root);
	@override late final _TranslationsDiagnosticsEs diagnostics = _TranslationsDiagnosticsEs._(_root);
	@override late final _TranslationsLogViewerEs logViewer = _TranslationsLogViewerEs._(_root);
	@override late final _TranslationsCrashRecoveryDialogEs crashRecoveryDialog = _TranslationsCrashRecoveryDialogEs._(_root);
	@override late final _TranslationsLinkInputDialogEs linkInputDialog = _TranslationsLinkInputDialogEs._(_root);
	@override late final _TranslationsLogEs log = _TranslationsLogEs._(_root);
	@override late final _TranslationsEmojiEs emoji = _TranslationsEmojiEs._(_root);
	@override late final _TranslationsSearchFilterEs searchFilter = _TranslationsSearchFilterEs._(_root);
	@override late final _TranslationsFirstTimeSetupEs firstTimeSetup = _TranslationsFirstTimeSetupEs._(_root);
	@override late final _TranslationsProxyHelperEs proxyHelper = _TranslationsProxyHelperEs._(_root);
	@override late final _TranslationsTagSelectorEs tagSelector = _TranslationsTagSelectorEs._(_root);
	@override late final _TranslationsAnime4kEs anime4k = _TranslationsAnime4kEs._(_root);
	@override late final _TranslationsSiteModeEs siteMode = _TranslationsSiteModeEs._(_root);
	@override late final _TranslationsSavedSearchConfigEs savedSearchConfig = _TranslationsSavedSearchConfigEs._(_root);
	@override late final _TranslationsSavedSearchEs savedSearch = _TranslationsSavedSearchEs._(_root);
	@override late final _TranslationsDefaultBlacklistReminderEs defaultBlacklistReminder = _TranslationsDefaultBlacklistReminderEs._(_root);
	@override late final _TranslationsColorVisionAssistEs colorVisionAssist = _TranslationsColorVisionAssistEs._(_root);
	@override late final _TranslationsExternalPlayerEs externalPlayer = _TranslationsExternalPlayerEs._(_root);
	@override late final _TranslationsWatchLaterEs watchLater = _TranslationsWatchLaterEs._(_root);
	@override late final _TranslationsMediaMenuEs mediaMenu = _TranslationsMediaMenuEs._(_root);
	@override late final _TranslationsMediaPreviewEs mediaPreview = _TranslationsMediaPreviewEs._(_root);
	@override late final _TranslationsPlaybackQueueEs playbackQueue = _TranslationsPlaybackQueueEs._(_root);
	@override late final _TranslationsVrFormatEs vrFormat = _TranslationsVrFormatEs._(_root);
	@override late final _TranslationsLocalMediaEs localMedia = _TranslationsLocalMediaEs._(_root);
	@override late final _TranslationsHistoryPageEs historyPage = _TranslationsHistoryPageEs._(_root);
}

// Path: personalProfile
class _TranslationsPersonalProfileEs extends TranslationsPersonalProfileEn {
	_TranslationsPersonalProfileEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get personalProfile => 'Perfil personal';
	@override String get editPersonalProfile => 'Editar perfil personal';
	@override String get avatar => 'Avatar';
	@override String get background => 'Fondo';
	@override String fetchUserProfileFailed({required Object error}) => 'No se pudo obtener el perfil del usuario: ${error}';
	@override String suggestedResolution({required Object resolution, required Object size}) => 'Resolución sugerida: ${resolution}, tamaño de archivo < ${size}';
	@override String supportedFormats({required Object formats}) => 'Formatos admitidos: ${formats}';
	@override String premiumBenefit({required Object type, required Object formats}) => 'Los usuarios premium pueden usar ${type} dinámico (${formats})';
	@override String get homepageBackground => 'Fondo de la página de inicio';
	@override String get basicInfo => 'Información básica';
	@override String get nickname => 'Apodo';
	@override String get username => 'Nombre de usuario';
	@override String get copyUsername => 'Copiar nombre de usuario';
	@override String get usernameCopied => 'Nombre de usuario copiado';
	@override String get personalIntroduction => 'Presentación personal';
	@override String get noPersonalIntroduction => 'Sin presentación personal';
	@override String get clickToEdit => 'Toque para editar';
	@override String get privacySettings => 'Configuración de privacidad';
	@override String get hideSensitiveContent => 'Ocultar contenido sensible';
	@override String get hideSensitiveContentDesc => 'Ocultar cualquier video o imagen con etiquetas sensibles.';
	@override String get notificationSettings => 'Configuración de notificaciones';
	@override String get contentCommentNotification => 'Notificación de comentarios en contenido';
	@override String get contentCommentNotificationDesc => 'Notificar cuando alguien comente en su contenido.';
	@override String get commentReplyNotification => 'Notificación de respuestas a comentarios';
	@override String get commentReplyNotificationDesc => 'Notificar cuando alguien responda a su comentario.';
	@override String get mentionNotification => 'Notificación de menciones';
	@override String get mentionNotificationDesc => 'Notificar cuando alguien lo mencione en contenido.';
	@override String get accountInfo => 'Información de la cuenta';
	@override String get registrationTime => 'Fecha de registro';
	@override String updateSettingsFailed({required Object error}) => 'No se pudo actualizar la configuración: ${error}';
	@override String updateNotificationSettingsFailed({required Object error}) => 'No se pudo actualizar la configuración de notificaciones: ${error}';
	@override String get editNickname => 'Editar apodo';
	@override String get nicknameCannotBeEmpty => 'El apodo no puede estar vacío';
	@override String get changeSuccess => 'Cambio realizado correctamente';
	@override String get unsupportedFileFormat => 'Formato de archivo no admitido';
	@override String fileTooLarge({required Object size}) => 'El tamaño del archivo no puede superar ${size}';
	@override String get uploadFailed => 'Error al subir';
	@override String get avatarUpdatedSuccessfully => 'Avatar actualizado correctamente';
	@override String updateAvatarFailed({required Object error}) => 'No se pudo actualizar el avatar: ${error}';
	@override String get backgroundUpdatedSuccessfully => 'Fondo actualizado correctamente';
	@override String updateBackgroundFailed({required Object error}) => 'No se pudo actualizar el fondo: ${error}';
	@override String get editPersonalIntroduction => 'Editar presentación personal';
	@override String get enterPersonalIntroduction => 'Introduzca su presentación personal';
}

// Path: tutorial
class _TranslationsTutorialEs extends TranslationsTutorialEn {
	_TranslationsTutorialEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get specialFollowFeature => 'Seguido especial';
	@override String get specialFollowDescription => 'Marque como seguidos especiales a los autores que más ve y acceda directamente a sus últimas subidas desde aquí.';
	@override String get stepsTitle => 'Tres pasos';
	@override String get stepFollowAuthor => 'Toque Seguir en el video, la galería o la página de perfil del autor.';
	@override String get stepPickSpecial => 'Toque Seguido de nuevo y elija Seguido especial en el menú.';
	@override String get stepSwitchHere => 'Vuelva aquí y cambie a ese autor con el selector de avatar de arriba.';
	@override String get specialFollowManagementTip => 'Gestione la lista de seguidos especiales en Barra lateral → Lista de seguidos → Seguidos especiales.';
	@override String get gotIt => 'Entendido';
}

// Path: common
class _TranslationsCommonEs extends TranslationsCommonEn {
	_TranslationsCommonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sort => 'Ordenar';
	@override String get filter => 'Filtrar';
	@override String get appName => 'Love Iwara';
	@override String get ok => 'OK';
	@override String get cancel => 'Cancelar';
	@override String get select => 'Seleccionar';
	@override String get save => 'Guardar';
	@override String get delete => 'Eliminar';
	@override String get visit => 'Visitar';
	@override String get loading => 'Cargando...';
	@override String get scrollToTop => 'Ir arriba';
	@override String get privacyHint => 'El modo privacidad está activado; el contenido está oculto';
	@override String get latest => 'Recientes';
	@override String get likesCount => 'Me gusta';
	@override String get viewsCount => 'Visualizaciones';
	@override String get popular => 'Popular';
	@override String get trending => 'Tendencias';
	@override String get commentList => 'Lista de comentarios';
	@override String get sendComment => 'Enviar comentario';
	@override String get send => 'Enviar';
	@override String get retry => 'Reintentar';
	@override String get premium => 'Premium';
	@override String get follower => 'Seguidor';
	@override String get friend => 'Amigo';
	@override String get video => 'Vídeo';
	@override String get following => 'Siguiendo';
	@override String get expand => 'Expandir';
	@override String get collapse => 'Contraer';
	@override String get cancelFriendRequest => 'Cancelar solicitud';
	@override String get cancelSpecialFollow => 'Cancelar seguimiento especial';
	@override String get addFriend => 'Añadir amigo';
	@override String get removeFriend => 'Eliminar amigo';
	@override String get followed => 'Siguiendo';
	@override String get follow => 'Seguir';
	@override String get unfollow => 'Dejar de seguir';
	@override String get specialFollow => 'Seguimiento especial';
	@override String get specialFollowed => 'Con seguimiento especial';
	@override String get gallery => 'Galería';
	@override String get playlist => 'Lista de reproducción';
	@override String get commentPostedSuccessfully => 'Comentario publicado';
	@override String get commentPostedFailed => 'No se pudo publicar el comentario';
	@override String get success => 'Correcto';
	@override String get commentDeletedSuccessfully => 'Comentario eliminado';
	@override String get commentUpdatedSuccessfully => 'Comentario actualizado';
	@override String totalComments({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} comentario',
		other: '${n} comentarios',
	);
	@override String get writeYourCommentHere => 'Escriba aquí su comentario...';
	@override String get tmpNoReplies => 'Aún no hay respuestas';
	@override String get loadMore => 'Cargar más';
	@override String get loadingMore => 'Cargando más...';
	@override String get noMoreDatas => 'No hay más datos';
	@override String get selectTranslationLanguage => 'Seleccionar idioma de traducción';
	@override String get translate => 'Traducir';
	@override String get translateFailedPleaseTryAgainLater => 'No se pudo traducir; inténtelo de nuevo más tarde';
	@override String get translationResult => 'Resultado de la traducción';
	@override String get justNow => 'Ahora mismo';
	@override String minutesAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'hace ${n} minuto',
		other: 'hace ${n} minutos',
	);
	@override String hoursAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'hace ${n} hora',
		other: 'hace ${n} horas',
	);
	@override String daysAgo({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: 'hace ${n} día',
		other: 'hace ${n} días',
	);
	@override String editedAt({required Object num}) => 'editado ${num} veces';
	@override String get editComment => 'Editar comentario';
	@override String get commentUpdated => 'Comentario actualizado';
	@override String get replyComment => 'Responder al comentario';
	@override String get reply => 'Responder';
	@override String get edit => 'Editar';
	@override String get unknownUser => 'Usuario desconocido';
	@override String get me => 'Yo';
	@override String get author => 'Autor';
	@override String get admin => 'Administrador';
	@override String viewReplies({required Object num}) => 'Ver respuestas (${num})';
	@override String get hideReplies => 'Ocultar respuestas';
	@override String get confirmDelete => 'Confirmar eliminación';
	@override String get areYouSureYouWantToDeleteThisItem => '¿Seguro que quiere eliminar este elemento?';
	@override String get tmpNoComments => 'Aún no hay comentarios';
	@override String get refresh => 'Actualizar';
	@override String get back => 'Atrás';
	@override String get tips => 'Consejos';
	@override String get linkIsEmpty => 'El enlace está vacío';
	@override String get linkCopiedToClipboard => 'Enlace copiado al portapapeles';
	@override String get imageCopiedToClipboard => 'Imagen copiada al portapapeles';
	@override String get copyImageFailed => 'No se pudo copiar la imagen';
	@override String get mobileSaveImageIsUnderDevelopment => 'La función de guardar imágenes en el móvil está en desarrollo';
	@override String get imageSavedTo => 'Imagen guardada en';
	@override String get saveImageFailed => 'No se pudo guardar la imagen';
	@override String get close => 'Cerrar';
	@override String get more => 'Más';
	@override String get unknownError => 'Error desconocido';
	@override String get moreFeaturesToBeDeveloped => 'Más funciones en desarrollo';
	@override String get all => 'Todos';
	@override String selectedRecords({required Object num}) => '${num} registros seleccionados';
	@override String get cancelSelectAll => 'Cancelar selección';
	@override String get selectAll => 'Seleccionar todo';
	@override String get invertSelection => 'Invertir selección';
	@override String get exitEditMode => 'Salir del modo de edición';
	@override String areYouSureYouWantToDeleteSelectedItems({required Object num}) => '¿Seguro que quiere eliminar los ${num} elementos seleccionados?';
	@override String get searchHistoryRecords => 'Buscar en el historial...';
	@override String get settings => 'Ajustes';
	@override String get subscriptions => 'Suscripciones';
	@override String videoCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} vídeo',
		other: '${n} vídeos',
	);
	@override String get share => 'Compartir';
	@override String get areYouSureYouWantToShareThisPlaylist => '¿Seguro que quiere compartir esta lista de reproducción?';
	@override String get editTitle => 'Editar título';
	@override String get editMode => 'Modo de edición';
	@override String get pleaseEnterNewTitle => 'Introduzca el nuevo título';
	@override String get createPlayList => 'Crear lista de reproducción';
	@override String get create => 'Crear';
	@override String get checkNetworkSettings => 'Comprobar la configuración de red';
	@override String get general => 'General';
	@override String get r18 => 'R18';
	@override String get sensitive => 'Sensible';
	@override String get year => 'Año';
	@override String get month => 'Mes';
	@override String get tag => 'Etiqueta';
	@override String get private => 'Privado';
	@override String get noTitle => 'Sin título';
	@override String get search => 'Buscar';
	@override String get noContent => 'Sin contenido';
	@override String get recording => 'Grabando';
	@override String get paused => 'En pausa';
	@override String get clear => 'Borrar';
	@override String get clearSelection => 'Borrar selección';
	@override String get selectItemsToContinue => 'Seleccione elementos para continuar';
	@override String andMoreItems({required Object num}) => 'y ${num} más';
	@override String get batchDelete => 'Eliminación por lotes';
	@override String get user => 'Usuario';
	@override String get post => 'Publicación';
	@override String get seconds => 'Segundos';
	@override String get comingSoon => 'Próximamente';
	@override String get confirm => 'Confirmar';
	@override String get hour => 'Hora';
	@override String get minute => 'Minuto';
	@override String get clickToRefresh => 'Pulse para actualizar';
	@override String get history => 'Historial';
	@override String get favorites => 'Favoritos';
	@override String get friends => 'Amigos';
	@override String get playList => 'Lista de reproducción';
	@override String get checkLicense => 'Comprobar licencia';
	@override String get logout => 'Cerrar sesión';
	@override String get fensi => 'Seguidores';
	@override String get accept => 'Aceptar';
	@override String get reject => 'Rechazar';
	@override String get clearAllHistory => 'Borrar todo el historial';
	@override String get clearAllHistoryConfirm => '¿Seguro que quiere borrar todo el historial?';
	@override String get followingList => 'Lista de seguidos';
	@override String get followersList => 'Lista de seguidores';
	@override String get follows => 'Seguidos';
	@override String get fans => 'Seguidores';
	@override String get followsAndFans => 'Seguidos y seguidores';
	@override String get numViews => 'Visualizaciones';
	@override String get updatedAt => 'Actualizado el';
	@override String get publishedAt => 'Publicado el';
	@override String get externalVideo => 'Vídeo externo';
	@override String get originalText => 'Texto original';
	@override String get showOriginalText => 'Mostrar texto original';
	@override String get showProcessedText => 'Mostrar texto procesado';
	@override String get preview => 'Vista previa';
	@override String get rules => 'Normas';
	@override String get agree => 'Acepto';
	@override String get disagree => 'No acepto';
	@override String get agreeToRules => 'Aceptar las normas';
	@override String get markdownSyntaxHelp => 'Ayuda de sintaxis de Markdown';
	@override String get previewContent => 'Vista previa del contenido';
	@override String characterCount({required Object current, required Object max}) => '${current}/${max}';
	@override String exceedsMaxLengthLimit({required Object max}) => 'Supera el límite máximo de longitud (${max})';
	@override String get agreeToCommunityRules => 'Aceptar las normas de la comunidad';
	@override String get createPost => 'Crear publicación';
	@override String get title => 'Título';
	@override String get enterTitle => 'Introduzca el título';
	@override String get content => 'Contenido';
	@override String get enterContent => 'Introduzca el contenido';
	@override String get writeYourContentHere => 'Introduzca el contenido...';
	@override String get tagBlacklist => 'Lista negra de etiquetas';
	@override String get noData => 'Sin datos';
	@override String get tagLimit => 'Límite de etiquetas';
	@override String get enableFloatingButtons => 'Activar botones flotantes';
	@override String get disableFloatingButtons => 'Desactivar botones flotantes';
	@override String get enabledFloatingButtons => 'Botones flotantes activados';
	@override String get disabledFloatingButtons => 'Botones flotantes desactivados';
	@override String get pendingCommentCount => 'Comentarios pendientes';
	@override String joined({required Object str}) => 'Se unió el ${str}';
	@override String lastSeenAt({required Object str}) => 'Visto por última vez el ${str}';
	@override String get download => 'Descargar';
	@override String get selectQuality => 'Seleccionar calidad';
	@override String get videoQualitySource => 'Origen';
	@override String get selectImageQuality => 'Seleccione la calidad de imagen';
	@override String get imageQualityStandard => 'Estándar';
	@override String get imageQualityOriginal => 'Original';
	@override String get selectDateRange => 'Seleccionar intervalo de fechas';
	@override String get selectDateRangeHint => 'Seleccione un intervalo de fechas; por defecto, los últimos 30 días';
	@override String get clearDateRange => 'Borrar intervalo de fechas';
	@override String get deleteRecordsInDateRange => 'Eliminar los registros de este intervalo';
	@override String deleteRecordsInDateRangeConfirm({required Object num}) => '¿Seguro que quiere eliminar ${num} registros del historial en este intervalo de fechas? Esta acción no se puede deshacer.';
	@override String get noHistoryRecordsInRange => 'No hay registros del historial en este intervalo de fechas';
	@override String get followSuccessClickAgainToSpecialFollow => 'Seguido correctamente; pulse de nuevo para seguimiento especial';
	@override String get specialFollowTip => 'Añadido a los seguimientos especiales: selecciónelos desde el selector de la esquina superior derecha de la página Suscripciones para acceder rápidamente';
	@override String get exitConfirmTip => '¿Seguro que quiere salir?';
	@override String get error => 'Error';
	@override String get taskRunning => 'Ya hay una tarea en curso; espere, por favor.';
	@override String get operationCancelled => 'Operación cancelada.';
	@override String get unsavedChanges => 'Tiene cambios sin guardar';
	@override String get specialFollowsManagementTip => 'Arrastre el tirador para reordenar • Pulse el botón para quitar';
	@override String get specialFollowsManagement => 'Gestión de seguimientos especiales';
	@override String get removeSpecialFollow => 'Quitar seguimiento especial';
	@override String removeSpecialFollowConfirm({required Object name}) => '¿Quitar a ${name} de los seguimientos especiales?';
	@override String get noSpecialFollows => 'Aún no hay seguimientos especiales';
	@override String get createTimeDesc => 'Fecha de creación descendente';
	@override String get createTimeAsc => 'Fecha de creación ascendente';
	@override late final _TranslationsCommonPaginationEs pagination = _TranslationsCommonPaginationEs._(_root);
	@override String get notice => 'Aviso';
	@override String get detail => 'Detalle';
	@override String get parseExceptionDestopHint => ' - Los usuarios de escritorio pueden configurar un proxy en los ajustes';
	@override String get iwaraTags => 'Etiquetas de Iwara';
	@override String get tagInfo => 'Información de la etiqueta';
	@override String get tagOriginalKey => 'Etiqueta original';
	@override String get tagTranslation => 'Traducción';
	@override String get copy => 'Copiar';
	@override String get selectCopy => 'Seleccionar y copiar';
	@override String get copiedToClipboard => 'Copiado al portapapeles';
	@override String get showOriginalTag => 'Mostrar etiqueta original';
	@override String get showTranslatedTag => 'Mostrar traducción';
	@override String get tagTranslationFeedback => '¿Tiene dudas sobre una traducción? Envíe sus comentarios';
	@override String get tagLocalizationGuideTitle => 'Acerca de la traducción de etiquetas';
	@override String get tagLocalizationGuideContent => 'La aplicación muestra las etiquetas originales de Iwara (p. ej. mother) con el nombre en su idioma actual.\n\n• Al buscar etiquetas, coinciden tanto la traducción como la etiqueta original.\n• Mantenga pulsada o haga clic derecho sobre una etiqueta para ver y copiar su clave original y su traducción.\n• Las traducciones las mantiene la comunidad y se hacen con el mejor esfuerzo posible; pueden contener errores.';
	@override String get likeThisVideo => 'Me gusta este vídeo';
	@override String get likeThisGallery => 'Me gusta esta galería';
	@override String get operation => 'Acción';
	@override String get replies => 'Respuestas';
	@override String get externalLinkWarning => 'Aviso de enlace externo';
	@override String get externalLinkWarningMessage => 'Está a punto de abrir un enlace externo que no forma parte de iwara.tv. Tenga cuidado y asegúrese de que el enlace sea seguro antes de continuar.';
	@override String get continueToExternalLink => 'Continuar';
	@override String get cancelExternalLink => 'Cancelar';
}

// Path: auth
class _TranslationsAuthEs extends TranslationsAuthEn {
	_TranslationsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Iniciar sesión';
	@override String get logout => 'Cerrar sesión';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
	@override String get loginOrRegister => 'Iniciar sesión / Registrarse';
	@override String get register => 'Registrarse';
	@override String get pleaseEnterEmail => 'Introduzca el correo electrónico';
	@override String get pleaseEnterPassword => 'Introduzca la contraseña';
	@override String get passwordMustBeAtLeast6Characters => 'La contraseña debe tener al menos 6 caracteres';
	@override String get pleaseEnterCaptcha => 'Introduzca el captcha';
	@override String get captcha => 'Captcha';
	@override String get refreshCaptcha => 'Actualizar captcha';
	@override String get captchaNotLoaded => 'Captcha no cargado';
	@override String get loginSuccess => 'Sesión iniciada';
	@override String get loginSuccessProfilePending => 'Sesión iniciada. Cargando su perfil…';
	@override String get emailVerificationSent => 'Verificación de correo enviada';
	@override String get notLoggedIn => 'No ha iniciado sesión';
	@override String get clickToLogin => 'Pulse para iniciar sesión';
	@override String get logoutConfirmation => '¿Seguro que quiere cerrar sesión?';
	@override String get logoutSuccess => 'Sesión cerrada';
	@override String get logoutFailed => 'No se pudo cerrar sesión';
	@override String get usernameOrEmail => 'Nombre de usuario o correo electrónico';
	@override String get pleaseEnterUsernameOrEmail => 'Introduzca el nombre de usuario o el correo electrónico';
	@override String get rememberMe => 'Recordar nombre de usuario';
	@override String get registerNoticeTitle => 'Regístrese en el sitio web oficial';
	@override String get registerNoticeDescription => 'El registro en la aplicación ya no está disponible. Vaya al sitio web oficial de Iwara, cree su cuenta y luego vuelva aquí para iniciar sesión.';
	@override String get registerNoticeReturnTip => 'Cuando se haya registrado, vuelva aquí e inicie sesión con su cuenta.';
	@override String get goToOfficialWebsite => 'Ir al sitio web oficial';
}

// Path: errors
class _TranslationsErrorsEs extends TranslationsErrorsEn {
	_TranslationsErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get error => 'Error';
	@override String get required => 'Este campo es obligatorio';
	@override String get invalidEmail => 'Dirección de correo electrónico no válida';
	@override String get networkError => 'Error de red; inténtelo de nuevo';
	@override String get errorWhileFetching => 'Error al obtener los datos';
	@override String get commentCanNotBeEmpty => 'El contenido del comentario no puede estar vacío';
	@override String get errorWhileFetchingReplies => 'Error al obtener las respuestas; compruebe la conexión de red';
	@override String get canNotFindCommentController => 'No se encuentra el controlador de comentarios';
	@override String get errorWhileLoadingGallery => 'Error al cargar la galería';
	@override String get howCouldThereBeNoDataItCantBePossible => '¿Cómo no va a haber datos? Es imposible :<';
	@override String unsupportedImageFormat({required Object str}) => 'Formato de imagen no compatible: ${str}';
	@override String get invalidGalleryId => 'ID de galería no válido';
	@override String get translationFailedPleaseTryAgainLater => 'No se pudo traducir; inténtelo de nuevo más tarde';
	@override String get errorOccurred => 'Se produjo un error; inténtelo de nuevo más tarde.';
	@override String get errorOccurredWhileProcessingRequest => 'Se produjo un error al procesar la solicitud';
	@override String get errorWhileFetchingDatas => 'Error al obtener los datos; inténtelo de nuevo más tarde';
	@override String get serviceNotInitialized => 'Servicio no inicializado';
	@override String get unknownType => 'Tipo desconocido';
	@override String errorWhileOpeningLink({required Object link}) => 'Error al abrir el enlace: ${link}';
	@override String get invalidUrl => 'URL no válida';
	@override String get failedToOperate => 'No se pudo completar la operación';
	@override String get permissionDenied => 'Permiso denegado';
	@override String get youDoNotHavePermissionToAccessThisResource => 'No tiene permiso para acceder a este recurso';
	@override String get loginFailed => 'No se pudo iniciar sesión';
	@override String get unknownError => 'Error desconocido';
	@override String get sessionExpired => 'Sesión caducada';
	@override String get failedToFetchCaptcha => 'No se pudo obtener el captcha';
	@override String get emailAlreadyExists => 'El correo electrónico ya existe';
	@override String get invalidCaptcha => 'Captcha no válido';
	@override String get registerFailed => 'No se pudo registrar';
	@override String get failedToFetchComments => 'No se pudieron obtener los comentarios';
	@override String get failedToFetchImageDetail => 'No se pudieron obtener los detalles de la imagen';
	@override String get failedToFetchImageList => 'No se pudo obtener la lista de imágenes';
	@override String get failedToFetchData => 'No se pudieron obtener los datos';
	@override String get invalidParameter => 'Parámetro no válido';
	@override String get pleaseLoginFirst => 'Inicie sesión primero';
	@override String get errorWhileLoadingPost => 'Error al cargar la publicación';
	@override String get errorWhileLoadingPostDetail => 'Error al cargar los detalles de la publicación';
	@override String get invalidPostId => 'ID de publicación no válido';
	@override String get forceUpdateNotPermittedToGoBack => 'La aplicación está en estado de actualización obligatoria; no se puede volver atrás';
	@override String get pleaseLoginAgain => 'Inicie sesión de nuevo';
	@override String get invalidLogin => 'Inicio de sesión no válido; compruebe su correo electrónico y su contraseña';
	@override String get tooManyRequests => 'Demasiadas solicitudes; inténtelo de nuevo más tarde';
	@override String exceedsMaxLength({required Object max}) => 'Supera la longitud máxima: ${max}';
	@override String get contentCanNotBeEmpty => 'El contenido no puede estar vacío';
	@override String get titleCanNotBeEmpty => 'El título no puede estar vacío';
	@override String get tooManyRequestsPleaseTryAgainLaterText => 'Demasiadas solicitudes; inténtelo de nuevo más tarde. Restante';
	@override String remainingHours({required Object num}) => '${num} horas';
	@override String remainingMinutes({required Object num}) => '${num} minutos';
	@override String remainingSeconds({required Object num}) => '${num} segundos';
	@override String tagLimitExceeded({required Object limit}) => 'Se superó el límite de etiquetas; límite: ${limit}';
	@override String get failedToRefresh => 'No se pudo actualizar';
	@override String get noPermission => 'Sin permiso';
	@override String get resourceNotFound => 'Recurso no encontrado';
	@override String get failedToSaveCredentials => 'No se pudieron guardar las credenciales de inicio de sesión';
	@override String get failedToLoadSavedCredentials => 'No se pudieron cargar las credenciales guardadas';
	@override String get notFound => 'El contenido no se encontró o se ha eliminado';
	@override late final _TranslationsErrorsNetworkEs network = _TranslationsErrorsNetworkEs._(_root);
}

// Path: friends
class _TranslationsFriendsEs extends TranslationsFriendsEn {
	_TranslationsFriendsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFriend => 'Pulse para restaurar el amigo';
	@override String get friendsList => 'Lista de amigos';
	@override String get friendRequests => 'Solicitudes de amistad';
	@override String get friendRequestsList => 'Lista de solicitudes de amistad';
	@override String get removingFriend => 'Eliminando al amigo...';
	@override String get failedToRemoveFriend => 'No se pudo eliminar al amigo';
	@override String get cancelingRequest => 'Cancelando la solicitud de amistad...';
	@override String get failedToCancelRequest => 'No se pudo cancelar la solicitud de amistad';
}

// Path: authorProfile
class _TranslationsAuthorProfileEs extends TranslationsAuthorProfileEn {
	_TranslationsAuthorProfileEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get noMoreDatas => 'No hay más datos';
	@override String get userProfile => 'Perfil del usuario';
}

// Path: favorites
class _TranslationsFavoritesEs extends TranslationsFavoritesEn {
	_TranslationsFavoritesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get clickToRestoreFavorite => 'Pulse para restaurar el favorito';
	@override String get myFavorites => 'Mis favoritos';
	@override String get batchCancelFavorite => 'Quitar los favoritos seleccionados';
	@override String batchCancelFavoriteConfirm({required Object count}) => '¿Quitar los ${count} elementos seleccionados de favoritos? Puede restaurarlos tocando las tarjetas después.';
	@override String batchCancelFavoriteSuccess({required Object count}) => 'Se quitaron ${count} elemento(s) de favoritos';
	@override String batchCancelFavoriteResult({required Object success, required Object failed}) => 'Se quitaron ${success} elemento(s); ${failed} fallaron';
}

// Path: galleryDetail
class _TranslationsGalleryDetailEs extends TranslationsGalleryDetailEn {
	_TranslationsGalleryDetailEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get browseInSpace => 'Explorar en el espacio';
	@override String get galleryDetail => 'Detalles de la galería';
	@override String get viewGalleryDetail => 'Ver los detalles de la galería';
	@override String get zoomReset => 'Restablecer el zoom';
	@override String get copyLink => 'Copiar enlace';
	@override String get copyImage => 'Copiar imagen';
	@override String get saveAs => 'Guardar como';
	@override String get saveToAlbum => 'Guardar en el álbum';
	@override String get publishedAt => 'Publicado el';
	@override String get viewsCount => 'Número de visualizaciones';
	@override String get imageLibraryFunctionIntroduction => 'Presentación de las funciones de la biblioteca de imágenes';
	@override String get rightClickToSaveSingleImage => 'Clic derecho para guardar una sola imagen';
	@override String get batchSave => 'Guardado por lotes';
	@override String get keyboardLeftAndRightToSwitch => 'Flechas izquierda y derecha del teclado para cambiar';
	@override String get keyboardUpAndDownToZoom => 'Flechas arriba y abajo del teclado para ampliar';
	@override String get mouseWheelToSwitch => 'Rueda del ratón para cambiar';
	@override String get ctrlAndMouseWheelToZoom => 'CTRL + rueda del ratón para ampliar';
	@override String get moreFeaturesToBeDiscovered => 'Más funciones por descubrir...';
	@override String get authorOtherGalleries => 'Otras galerías del autor';
	@override String get relatedGalleries => 'Galerías relacionadas';
	@override String get authorNoOtherGalleries => 'No hay otras galerías de este autor';
	@override String get noRelatedGalleries => 'No hay galerías relacionadas';
	@override String get scrollLeft => 'Desplazar a la izquierda';
	@override String get scrollRight => 'Desplazar a la derecha';
	@override String get clickLeftAndRightEdgeToSwitchImage => 'Pulse los bordes izquierdo y derecho para cambiar de imagen';
	@override String get rotateToLandscape => 'Pantalla completa horizontal';
	@override String get backToPortrait => 'Volver a vertical';
}

// Path: playList
class _TranslationsPlayListEs extends TranslationsPlayListEn {
	_TranslationsPlayListEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get myPlayList => 'Mi lista de reproducción';
	@override String get friendlyTips => 'Consejo amistoso';
	@override String get dearUser => 'Estimado usuario';
	@override String get iwaraPlayListSystemIsNotPerfectYet => 'El sistema de listas de reproducción de Iwara aún no es perfecto';
	@override String get notSupportSetCover => 'No se admite establecer portada';
	@override String get notSupportDeleteList => 'No se admite eliminar la lista';
	@override String get notSupportSetPrivate => 'No se admite establecer como privada';
	@override String get yesCreateListWillAlwaysExistAndVisibleToEveryone => 'Sí... las listas creadas siempre existirán y serán visibles para todos';
	@override String get smallSuggestion => 'Pequeña sugerencia';
	@override String get useLikeToCollectContent => 'Si le preocupa más la privacidad, se recomienda usar la función de "me gusta" para guardar contenido';
	@override String get welcomeToDiscussOnGitHub => 'Si tiene otras sugerencias o ideas, ¡le invitamos a comentarlas en GitHub!';
	@override String get iUnderstand => 'Entendido';
	@override String get searchPlaylists => 'Buscar listas de reproducción...';
	@override String get newPlaylistName => 'Nombre de la nueva lista';
	@override String get createNewPlaylist => 'Crear nueva lista de reproducción';
	@override String get videos => 'Vídeos';
}

// Path: search
class _TranslationsSearchEs extends TranslationsSearchEn {
	_TranslationsSearchEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get googleSearchScope => 'Ámbito de búsqueda';
	@override String get searchTags => 'Buscar etiquetas...';
	@override String get contentRating => 'Clasificación de contenido';
	@override String get removeTag => 'Quitar etiqueta';
	@override String get pleaseEnterSearchContent => 'Introduzca el contenido de búsqueda';
	@override String get searchHistory => 'Historial de búsqueda';
	@override String get searchSuggestion => 'Sugerencia de búsqueda';
	@override String get usedTimes => 'Veces usado';
	@override String get lastUsed => 'Usado por última vez';
	@override String get noSearchHistoryRecords => 'Sin historial de búsqueda';
	@override String get clearSearchHistoryConfirm => '¿Seguro que desea borrar todo el historial de búsqueda? Esta acción no se puede deshacer.';
	@override String notSupportCurrentSearchType({required Object searchType}) => 'Tipo de búsqueda actual no admitido ${searchType}; espere la actualización';
	@override String get searchResult => 'Resultado de búsqueda';
	@override String unsupportedSearchType({required Object searchType}) => 'Tipo de búsqueda no admitido: ${searchType}';
	@override String get googleSearch => 'Búsqueda de Google';
	@override String googleSearchHint({required Object webName}) => '¿La función de búsqueda de ${webName} no es fácil de usar? ¡Pruebe la Búsqueda de Google!';
	@override String get googleSearchDescription => 'Use el operador de búsqueda :site de Búsqueda de Google para buscar contenido en el sitio. Es muy útil para buscar videos, galerías, listas de reproducción y usuarios.';
	@override String get googleSearchKeywordsHint => 'Introduzca palabras clave para buscar';
	@override String get openLinkJump => 'Abrir enlace';
	@override String get googleSearchButton => 'Búsqueda de Google';
	@override String get pleaseEnterSearchKeywords => 'Introduzca las palabras clave de búsqueda';
	@override String get googleSearchQueryCopied => 'Consulta de búsqueda copiada al portapapeles';
	@override String googleSearchBrowserOpenFailed({required Object error}) => 'No se pudo abrir el navegador: ${error}';
	@override String get searchRequestTimeout => 'La solicitud agotó el tiempo de espera; inténtelo de nuevo más tarde';
	@override String get searchCannotConnectToServer => 'No se puede conectar al servidor; compruebe su conexión de red';
	@override String get searchNetworkError => 'Error de conexión de red; compruebe la configuración de red o inténtelo de nuevo más tarde';
	@override String get searchFailedPleaseRetry => 'La búsqueda falló; inténtelo de nuevo más tarde';
}

// Path: mediaList
class _TranslationsMediaListEs extends TranslationsMediaListEn {
	_TranslationsMediaListEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get personalIntroduction => 'Presentación';
}

// Path: settings
class _TranslationsSettingsEs extends TranslationsSettingsEn {
	_TranslationsSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get listViewMode => 'Modo de vista de lista';
	@override String get previewEffect => 'Vista previa del efecto';
	@override String get useTraditionalPaginationMode => 'Usar el modo de paginación tradicional';
	@override String get useTraditionalPaginationModeDesc => 'Activar el modo de paginación tradicional y desactivar el modo cascada. Surte efecto tras volver a renderizar la página o reiniciar la aplicación';
	@override String get showVideoProgressBottomBarWhenToolbarHidden => 'Mostrar la barra inferior de progreso del video cuando la barra de herramientas está oculta';
	@override String get showVideoProgressBottomBarWhenToolbarHiddenDesc => 'Esta configuración determina si se mostrará la barra inferior de progreso del video cuando la barra de herramientas esté oculta.';
	@override String get seekPreviewSize => 'Tamaño de la vista previa de búsqueda';
	@override String get seekPreviewSizeDesc => 'Tamaño de la ventana de vista previa situada sobre la barra de progreso. Ya sigue el tamaño del reproductor y la relación de aspecto del video; esto solo la ajusta ligeramente.';
	@override String get seekPreviewSizeSmall => 'Pequeño';
	@override String get seekPreviewSizeStandard => 'Estándar';
	@override String get seekPreviewSizeLarge => 'Grande';
	@override String get seekPreviewSizeStandardDesc => 'El tamaño derivado del reproductor y del video';
	@override String get showFullscreenUpNextHint => 'Mostrar el asa de "A continuación"';
	@override String get showFullscreenUpNextHintDesc => 'Muestra un asa pequeña en el borde derecho del reproductor que abre el panel de la cola (origen / lista de reproducción / ver más tarde). Una vez desactivada, no hay otra forma de acceder.';
	@override String get basicSettings => 'Ajustes básicos';
	@override String get personalizedSettings => 'Ajustes personalizados';
	@override String get otherSettings => 'Otros ajustes';
	@override String get searchConfig => 'Configuración de búsqueda';
	@override String get thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain => 'Esta configuración determina si se usará la configuración anterior al reproducir videos de nuevo.';
	@override String get playControl => 'Control de reproducción';
	@override String get playbackSpeedSettings => 'Reproducción y velocidad';
	@override String get playbackBehaviorSettings => 'Comportamiento de reproducción';
	@override String get enhancementSettings => 'Cine y mejoras';
	@override String get fastForwardTime => 'Tiempo de avance rápido';
	@override String get fastForwardTimeMustBeAPositiveInteger => 'El tiempo de avance rápido debe ser un número entero positivo.';
	@override String get rewindTime => 'Tiempo de retroceso';
	@override String get rewindTimeMustBeAPositiveInteger => 'El tiempo de retroceso debe ser un número entero positivo.';
	@override String get longPressPlaybackSpeed => 'Velocidad de reproducción con pulsación larga';
	@override String get longPressPlaybackSpeedMustBeAPositiveNumber => 'La velocidad de reproducción con pulsación larga debe ser un número positivo.';
	@override String get defaultPlaybackSpeed => 'Velocidad de reproducción predeterminada';
	@override String get rememberPlaybackSpeed => 'Recordar la velocidad de reproducción';
	@override String get rememberPlaybackSpeedDesc => 'Cuando está activado, la velocidad que ajuste en el reproductor se guarda como predeterminada y se aplica automáticamente a los videos nuevos.';
	@override String get repeat => 'Repetir';
	@override String get renderVerticalVideoInVerticalScreen => 'Mostrar el video vertical en pantalla vertical';
	@override String get thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen => 'Esta configuración determina si el video se mostrará en pantalla vertical al reproducirse en pantalla completa.';
	@override String get rememberVolume => 'Recordar el volumen';
	@override String get thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain => 'Esta configuración determina si el volumen se mantendrá al reproducir videos de nuevo.';
	@override String get rememberBrightness => 'Recordar el brillo';
	@override String get thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain => 'Esta configuración determina si el brillo se mantendrá al reproducir videos de nuevo.';
	@override String get playControlArea => 'Área de control de reproducción';
	@override String get leftAndRightControlAreaWidth => 'Ancho de las áreas de control izquierda y derecha';
	@override String get thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer => 'Esta configuración determina el ancho de las áreas de control situadas a la izquierda y a la derecha del reproductor.';
	@override String get proxyAddressCannotBeEmpty => 'La dirección del proxy no puede estar vacía.';
	@override String get invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort => 'Formato de dirección de proxy no válido. Use el formato IP:puerto o nombre de dominio:puerto.';
	@override String get proxyNormalWork => 'El proxy funciona correctamente.';
	@override String testProxyFailedWithStatusCode({required Object code}) => 'Error al probar el proxy; código de estado: ${code}';
	@override String testProxyFailedWithException({required Object exception}) => 'Error al probar el proxy; excepción: ${exception}';
	@override String get proxyConfig => 'Configuración del proxy';
	@override String get thisIsHttpProxyAddress => 'Esta es la dirección del proxy HTTP';
	@override String get checkProxy => 'Comprobar proxy';
	@override String get proxyAddress => 'Dirección del proxy';
	@override String get pleaseEnterTheUrlOfTheProxyServerForExample1270018080 => 'Introduzca la URL del servidor proxy; por ejemplo, 127.0.0.1:8080';
	@override String get enableProxy => 'Activar proxy';
	@override String get left => 'Izquierda';
	@override String get middle => 'Centro';
	@override String get right => 'Derecha';
	@override String get playerSettings => 'Ajustes del reproductor';
	@override String get networkSettings => 'Ajustes de red';
	@override String get customizeYourPlaybackExperience => 'Personalice su experiencia de reproducción';
	@override String get chooseYourFavoriteAppAppearance => 'Elija el aspecto que prefiera para la aplicación';
	@override String get configureYourProxyServer => 'Configure su servidor proxy';
	@override String get settings => 'Ajustes';
	@override String get themeSettings => 'Ajustes de tema';
	@override String get followSystem => 'Seguir el sistema';
	@override String get lightMode => 'Modo claro';
	@override String get darkMode => 'Modo oscuro';
	@override String get presetTheme => 'Tema predefinido';
	@override String get basicTheme => 'Tema básico';
	@override String get needRestartToApply => 'Reinicie la aplicación para aplicar los ajustes';
	@override String get themeNeedRestartDescription => 'Los ajustes de tema requieren reiniciar la aplicación para aplicarse';
	@override String get about => 'Acerca de';
	@override String get diagnosticsAndFeedback => 'Diagnóstico y comentarios';
	@override String get currentVersion => 'Versión actual';
	@override String get latestVersion => 'Última versión';
	@override String get checkForUpdates => 'Buscar actualizaciones';
	@override String get update => 'Actualizar';
	@override String get newVersionAvailable => 'Nueva versión disponible';
	@override String get projectHome => 'Página del proyecto';
	@override String get release => 'Versión';
	@override String get issueReport => 'Informe de problema';
	@override String get openSourceLicense => 'Licencia de código abierto';
	@override String get checkForUpdatesFailed => 'No se pudieron buscar actualizaciones; inténtelo de nuevo más tarde';
	@override String get autoCheckUpdate => 'Buscar actualizaciones automáticamente';
	@override String get updateContent => 'Contenido de la actualización';
	@override String get releaseDate => 'Fecha de publicación';
	@override String get ignoreThisVersion => 'Ignorar esta versión';
	@override String get forceUpdateTip => 'Esta es una actualización obligatoria. Actualice a la última versión lo antes posible';
	@override String get viewChangelog => 'Ver el registro de cambios';
	@override String get alreadyLatestVersion => 'Ya está en la última versión';
	@override String get appSettings => 'Configuración de la aplicación';
	@override String get configureYourAppSettings => 'Configure los ajustes de su aplicación';
	@override String get history => 'Historial';
	@override String get autoRecordHistory => 'Registrar el historial automáticamente';
	@override String get autoRecordHistoryDesc => 'Registrar automáticamente los videos e imágenes que ha visto';
	@override String get autoDeleteHistory => 'Limpiar el historial automáticamente';
	@override String get autoDeleteHistoryDesc => 'Eliminar automáticamente al inicio el historial de navegación anterior a los días de conservación (desactivado de forma predeterminada)';
	@override String get autoDeleteHistoryDays => 'Días de conservación';
	@override String autoDeleteHistoryDaysValue({required Object num}) => 'Conservar los últimos ${num} días';
	@override String get autoDeleteHistoryDaysInvalid => 'Introduzca un número de días válido (al menos 1)';
	@override String get showUnprocessedMarkdownText => 'Mostrar el texto Markdown sin procesar';
	@override String get showUnprocessedMarkdownTextDesc => 'Mostrar el texto original del markdown';
	@override String get markdown => 'Markdown';
	@override String get activeBackgroundPrivacyMode => 'Modo privacidad';
	@override String get activeBackgroundPrivacyModeDesc => 'Bloquea las capturas de pantalla y la grabación de pantalla, y oculta la pantalla en segundo plano';
	@override String get activeBackgroundPrivacyModeDescNonAndroid => 'Oculta la pantalla cuando la aplicación pasa a segundo plano (esta plataforma no puede bloquear las capturas de pantalla)';
	@override String get activeBackgroundPrivacyModeDescScreenshotOnly => 'Bloquea las capturas de pantalla y la grabación de pantalla';
	@override String get privacy => 'Privacidad';
	@override String get appLock => 'Bloqueo de la aplicación';
	@override String get appLockEnabled => 'Activar el bloqueo de la aplicación';
	@override String get appLockEnabledDesc => 'Exigir un PIN o datos biométricos para abrir la aplicación; la vista previa en segundo plano se oculta automáticamente';
	@override String get appLockEnabledSummary => 'Activado · Protegido con PIN';
	@override String get appLockDisabledSummary => 'Desactivado';
	@override String get appLockTimeout => 'Bloquear al salir de la aplicación';
	@override String get appLockTimeoutDesc => 'Tiempo permitido en segundo plano antes de exigir autenticación';
	@override String get appLockAfterScreenOff => 'Bloquear tras bloquear la pantalla';
	@override String get appLockAfterScreenOffDesc => 'Exigir autenticación una vez bloqueada la pantalla del dispositivo';
	@override String get appLockTimeoutDisabled => 'Desactivado';
	@override String get appLockImmediately => 'Inmediatamente';
	@override String appLockSeconds({required Object seconds}) => '${seconds} segundos';
	@override String appLockMinutes({required Object minutes}) => '${minutes} minutos';
	@override String get appLockUseBiometrics => 'Usar datos biométricos';
	@override String get appLockUseBiometricsDesc => 'Desbloquear con huella digital o reconocimiento facial';
	@override String get appLockBiometricsUnavailable => 'No hay datos biométricos registrados en este dispositivo';
	@override String get appLockSetPin => 'Establecer PIN';
	@override String get appLockEnterPin => 'Introduzca el PIN';
	@override String get appLockConfirmPin => 'Confirmar PIN';
	@override String get appLockCurrentPin => 'Introduzca el PIN actual';
	@override String get appLockNewPin => 'Introduzca el PIN nuevo';
	@override String get appLockPinRequirements => 'El PIN debe contener de 4 a 8 dígitos';
	@override String get appLockPinsDoNotMatch => 'Los PIN no coinciden';
	@override String get appLockInvalidPin => 'PIN incorrecto';
	@override String get appLockSetupFailed => 'No se pudo guardar el PIN de forma segura';
	@override String get appLockDisable => 'Introduzca el PIN para desactivar el bloqueo de la aplicación';
	@override String get appLockChangePin => 'Cambiar PIN';
	@override String get appLockNow => 'Bloquear ahora';
	@override String get appLockUnlock => 'Desbloquear';
	@override String get appLockLockedTitle => 'Bloqueado';
	@override String get appLockLockedDesc => 'Autentíquese para continuar';
	@override String get appLockAuthenticateReason => 'Autentíquese para desbloquear';
	@override String get appLockEnableBiometricsReason => 'Autentíquese para activar el desbloqueo biométrico';
	@override String get appLockBiometricFailed => 'No se completó la autenticación biométrica';
	@override String appLockTooManyAttempts({required Object seconds}) => 'Demasiados intentos. Vuelva a intentarlo en ${seconds} s';
	@override String get appLockCredentialUnavailableTitle => 'No se puede leer la credencial del bloqueo de la aplicación';
	@override String get appLockCredentialUnavailableDesc => 'El almacenamiento seguro del sistema no está disponible temporalmente, o la credencial está dañada. La aplicación permanece bloqueada. Inténtelo de nuevo primero; si sigue fallando, puede restablecer el bloqueo de la aplicación, lo que lo desactiva y borra el PIN guardado.';
	@override String get appLockRetry => 'Reintentar';
	@override String get appLockReset => 'Restablecer el bloqueo de la aplicación';
	@override String get appLockResetAction => 'Restablecer';
	@override String get appLockResetConfirmTitle => '¿Restablecer el bloqueo de la aplicación?';
	@override String get appLockResetConfirmDesc => 'Esto desactiva el bloqueo de la aplicación y borra el PIN guardado y la configuración biométrica. Puede configurarlo de nuevo después.';
	@override String get appLockRetrySucceeded => 'Credencial leída correctamente. Introduzca su PIN.';
	@override String get appLockRetryFailed => 'Aún no se puede leer la credencial';
	@override String get forum => 'Foro';
	@override String get news => 'Noticias';
	@override String get community => 'Comunidad';
	@override String get disableForumReplyQuote => 'Desactivar la cita en las respuestas del foro';
	@override String get disableForumReplyQuoteDesc => 'Desactivar la inclusión de la información del piso citado al responder en el foro';
	@override String get theaterMode => 'Modo cine';
	@override String get theaterModeDesc => 'Al activarlo, el fondo del reproductor se establecerá como la versión desenfocada de la portada del video';
	@override String get appLinks => 'Enlaces de la aplicación';
	@override String get defaultBrowser => 'Navegador predeterminado';
	@override String get defaultBrowserDesc => 'Abra el elemento de configuración de enlace predeterminado en los ajustes del sistema y añada el enlace del sitio web iwara.tv';
	@override String get themeMode => 'Modo de tema';
	@override String get themeModeDesc => 'Esta configuración determina el modo de tema de la aplicación';
	@override String get glassEffect => 'Material de la interfaz';
	@override String get glassEffectDesc => 'Elige el material usado en toda la aplicación: cápsulas de encabezado, menús, botones de diálogo y la barra de navegación inferior';
	@override String get liquidGlassEffect => 'Vidrio líquido';
	@override String get liquidGlassEffectDesc => 'Desenfoque y refracción reales. El mejor aspecto, pero puede perder fotogramas y consumir algo más de batería en dispositivos de gama baja';
	@override String get plainGlassEffect => 'Material';
	@override String get plainGlassEffectDesc => 'Superficies estándar de Material 3: opacas, sin desenfoque ni sombras. El mejor rendimiento y la mejor autonomía';
	@override String get glassEffectIntroTitle => 'Elija el material de su interfaz';
	@override String get glassEffectIntroContent => 'Los encabezados, la barra de pestañas y los menús usan vidrio líquido: desenfoque y refracción reales. Si le parece lento en su dispositivo, o prefiere algo más sencillo, cambie a Material ahora (superficies opacas, sin desenfoque ni sombras).';
	@override String get glassEffectIntroHint => 'Puede cambiarlo cuando quiera en Ajustes → Tema → Material de la interfaz.';
	@override String get glassEffectIntroDone => 'Mantenerlo';
	@override String get dynamicColor => 'Color dinámico';
	@override String get dynamicColorDesc => 'Esta configuración determina si la aplicación usa el color dinámico';
	@override String get useDynamicColor => 'Usar color dinámico';
	@override String get useDynamicColorDesc => 'Esta configuración determina si la aplicación usa el color dinámico';
	@override String get presetColors => 'Colores predefinidos';
	@override String get customColors => 'Colores personalizados';
	@override String get customColorsDisabledByDynamicColor => 'El color dinámico está activado, por lo que los colores predefinidos y personalizados no están disponibles. Desactive primero el color dinámico.';
	@override String get pickColor => 'Elegir color';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Confirmar';
	@override String get noCustomColors => 'Sin colores personalizados';
	@override String get recordAndRestorePlaybackProgress => 'Registrar y restaurar el progreso de reproducción';
	@override String get autoPlayVideoOnFirstEnter => 'Reproducir el video automáticamente al entrar por primera vez';
	@override String get autoPlayVideoOnFirstEnterDesc => 'Esta opción determina si el video empieza a reproducirse automáticamente al entrar por primera vez en la página del video.';
	@override String get autoEnterFullscreen => 'Entrar en pantalla completa automáticamente';
	@override String get autoEnterFullscreenDesc => 'Cuándo debe pasar el reproductor a pantalla completa por sí solo. Los videos privados, eliminados y externos siempre se dejan igual, al igual que el modo imagen en imagen.';
	@override String get autoEnterFullscreenOff => 'Desactivado';
	@override String get autoEnterFullscreenOffDesc => 'No entrar nunca en pantalla completa por sí solo';
	@override String get autoEnterFullscreenOnPlaybackStart => 'Al iniciar la reproducción';
	@override String get autoEnterFullscreenOnPlaybackStartDesc => 'Pasar a pantalla completa en el momento en que la reproducción comienza de verdad';
	@override String get autoEnterFullscreenOnDetailPageEnter => 'Al abrir el video';
	@override String get autoEnterFullscreenOnDetailPageEnterDesc => 'Pasar a pantalla completa en cuanto se abre la página del video, sin esperar a la reproducción';
	@override String get autoEnterFullscreenKind => 'Tipo de pantalla completa';
	@override String get autoEnterFullscreenKindDesc => 'Qué tipo de pantalla completa entrar automáticamente. Solo en escritorio.';
	@override String get autoEnterFullscreenKindSystem => 'Pantalla completa del sistema';
	@override String get autoEnterFullscreenKindSystemDesc => 'Dejar que el gestor de ventanas ponga la ventana en pantalla completa';
	@override String get autoEnterFullscreenKindApp => 'Pantalla completa de la aplicación';
	@override String get autoEnterFullscreenKindAppDesc => 'Mantener la ventana tal cual y convertir toda la aplicación en el reproductor';
	@override String get signature => 'Firma';
	@override String get enableSignature => 'Activar firma';
	@override String get enableSignatureDesc => 'Esta configuración determina si la aplicación añade la firma al responder';
	@override String get enterSignature => 'Introducir firma';
	@override String get editSignature => 'Editar firma';
	@override String get signatureContent => 'Contenido de la firma';
	@override String get exportConfig => 'Exportar la configuración de la aplicación';
	@override String get exportConfigDesc => 'Exporte los ajustes y el historial (historial de navegación, progreso de reproducción, favoritos, etc.) a un archivo para hacer una copia de seguridad o transferirlo a otro dispositivo. Las tareas de descarga no se incluyen.';
	@override String get importConfig => 'Importar la configuración de la aplicación';
	@override String get importConfigDesc => 'Importar la configuración de la aplicación desde un archivo';
	@override String get exportConfigSuccess => '¡Configuración exportada correctamente!';
	@override String get exportConfigFailed => 'No se pudo exportar la configuración';
	@override String get importConfigSuccess => '¡Configuración importada correctamente!';
	@override String get importConfigFailed => 'No se pudo importar la configuración';
	@override String get exportIncludeSensitive => 'Incluir información sensible';
	@override String get exportIncludeSensitiveDesc => 'Incluye claves de API, tokens de sesión y la dirección del proxy. Actívelo solo al hacer una copia de seguridad en su propio dispositivo.';
	@override String get importConfigOverwriteWarning => 'La importación sobrescribirá sus ajustes e historial actuales (historial de navegación, progreso de reproducción, favoritos, etc.). ¿Continuar?';
	@override String get importConfigRestartTitle => 'Importación correcta';
	@override String get importConfigRestartContent => 'Su configuración se ha importado. Cierre por completo la aplicación y vuelva a abrirla para que todos los cambios surtan efecto.';
	@override String get historyUpdateLogs => 'Registros de actualización del historial';
	@override String get noUpdateLogs => 'No hay registros de actualización disponibles';
	@override String get versionLabel => 'Versión: {version}';
	@override String get releaseDateLabel => 'Fecha de publicación: {date}';
	@override String get noChanges => 'No hay contenido de actualización disponible';
	@override String get interaction => 'Interacción';
	@override String get enableVibration => 'Activar vibración';
	@override String get enableVibrationDesc => 'Activar la respuesta por vibración al interactuar con la aplicación';
	@override String get defaultKeepVideoToolbarVisible => 'Mantener visible la barra de herramientas del video';
	@override String get defaultKeepVideoToolbarVisibleDesc => 'Esta opción determina si la barra de herramientas del video permanece visible al entrar por primera vez en la página del video.';
	@override String get theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt => 'Activar el modo cine en dispositivos móviles puede causar problemas de rendimiento. Puede elegir activarlo.';
	@override String get fullscreenOrientation => 'Orientación de la pantalla tras entrar en pantalla completa';
	@override String get fullscreenOrientationDesc => 'Esta opción determina la orientación de pantalla predeterminada al entrar en pantalla completa (solo móvil)';
	@override String get fullscreenOrientationLeftLandscape => 'Horizontal izquierda';
	@override String get fullscreenOrientationRightLandscape => 'Horizontal derecha';
	@override String get screenFit => 'Tamaño de pantalla';
	@override String get screenFitDesc => 'Elija cómo rellena el video el área del reproductor.';
	@override String get rememberScreenFit => 'Recordar el tamaño de pantalla';
	@override String get rememberScreenFitDesc => 'Aplicar el tamaño seleccionado a los videos que se abran después.';
	@override String get screenFitFit => 'Ajustar';
	@override String get screenFitFitDesc => 'Muestra el fotograma completo manteniendo la relación de aspecto';
	@override String get screenFitStretch => 'Estirar';
	@override String get screenFitStretchDesc => 'Rellena el área del reproductor; la imagen puede verse distorsionada';
	@override String get screenFitCover => 'Rellenar';
	@override String get screenFitCoverDesc => 'Rellena el área del reproductor manteniendo la relación de aspecto; el sobrante se recorta';
	@override String get screenFitRatioDesc => 'Forzar esta relación de aspecto; la imagen puede verse distorsionada';
	@override String get jumpLink => 'Enlace de salto';
	@override String get language => 'Idioma';
	@override String get languageNativeName => 'Español';
	@override String get followSystemLanguage => 'Seguir el sistema';
	@override String get languageChangedMessage => 'Idioma cambiado correctamente; algunas funciones requieren reiniciar la aplicación.';
	@override String get languageChanged => 'El idioma se ha cambiado. Reinicie la aplicación para que surta efecto.';
	@override late final _TranslationsSettingsKeybindingEs keybinding = _TranslationsSettingsKeybindingEs._(_root);
	@override String get gestureControl => 'Control por gestos';
	@override String get leftDoubleTapRewind => 'Doble toque a la izquierda para retroceder';
	@override String get rightDoubleTapFastForward => 'Doble toque a la derecha para avanzar rápido';
	@override String get doubleTapPause => 'Pausa con doble toque';
	@override String get rightVerticalSwipeVolume => 'Volumen con deslizamiento vertical a la derecha (efectivo al entrar en una página nueva)';
	@override String get leftVerticalSwipeBrightness => 'Brillo con deslizamiento vertical a la izquierda (efectivo al entrar en una página nueva)';
	@override String get longPressFastForward => 'Avance rápido con pulsación larga';
	@override String get enableMouseHoverShowToolbar => 'Mostrar la barra de herramientas al pasar el ratón';
	@override String get enableMouseHoverShowToolbarInfo => 'Cuando está activado, la barra de herramientas del video se muestra al pasar el ratón sobre el reproductor. Se oculta automáticamente tras 3 segundos de inactividad.';
	@override String get enableHorizontalDragSeek => 'Deslizamiento horizontal para buscar';
	@override String get enableVideoGestureZoom => 'Pellizcar para ampliar el fotograma del video';
	@override String get enableVideoGestureZoomInfo => 'Pellizque con dos dedos (o Ctrl + rueda del ratón en escritorio) para ampliar la imagen del video y luego arrastre para moverla.';
	@override String get showCenterPlayPauseButton => 'Botón de reproducir/pausar central';
	@override String get showCenterPlayPauseButtonDesc => 'Mostrar el botón grande de reproducir/pausar en el centro del reproductor.';
	@override String get audioVideoConfig => 'Configuración de audio y video';
	@override String get expandBuffer => 'Ampliar el búfer';
	@override String get expandBufferInfo => 'Cuando está activado, el tamaño del búfer aumenta: el tiempo de carga se alarga, pero la reproducción es más fluida';
	@override String get videoSyncMode => 'Modo de sincronización de video';
	@override String get videoSyncModeSubtitle => 'Estrategia de sincronización de audio y video';
	@override String get hardwareDecodingMode => 'Modo de decodificación por hardware';
	@override String get hardwareDecodingModeSubtitle => 'Ajustes de decodificación por hardware';
	@override String get enableHardwareAcceleration => 'Activar la aceleración por hardware';
	@override String get enableHardwareAccelerationInfo => 'Activar la aceleración por hardware puede mejorar el rendimiento de decodificación, pero algunos dispositivos pueden no ser compatibles';
	@override String get useOpenSLESAudioOutput => 'Usar salida de audio OpenSLES';
	@override String get useOpenSLESAudioOutputInfo => 'Usar salida de audio de baja latencia; puede mejorar el rendimiento del audio';
	@override String get videoSyncAudio => 'Sincronización de audio';
	@override String get videoSyncDisplayResample => 'Mostrar remuestreo';
	@override String get videoSyncDisplayResampleVdrop => 'Mostrar remuestreo (pérdida de fotogramas)';
	@override String get videoSyncDisplayResampleDesync => 'Mostrar remuestreo (desincronización)';
	@override String get videoSyncDisplayTempo => 'Mostrar tempo';
	@override String get videoSyncDisplayVdrop => 'Mostrar caída de fotogramas de video';
	@override String get videoSyncDisplayAdrop => 'Mostrar caída de fotogramas de audio';
	@override String get videoSyncDisplayDesync => 'Mostrar desincronización';
	@override String get videoSyncDesync => 'Desincronización';
	@override late final _TranslationsSettingsForumSettingsEs forumSettings = _TranslationsSettingsForumSettingsEs._(_root);
	@override late final _TranslationsSettingsGallerySettingsEs gallerySettings = _TranslationsSettingsGallerySettingsEs._(_root);
	@override late final _TranslationsSettingsBlockSettingsEs blockSettings = _TranslationsSettingsBlockSettingsEs._(_root);
	@override late final _TranslationsSettingsChatSettingsEs chatSettings = _TranslationsSettingsChatSettingsEs._(_root);
	@override String get hardwareDecodingAuto => 'Automático';
	@override String get hardwareDecodingAutoCopy => 'Copia automática';
	@override String get hardwareDecodingAutoSafe => 'Seguro automático';
	@override String get hardwareDecodingNo => 'Desactivado';
	@override String get hardwareDecodingYes => 'Forzar activación';
	@override String get cdnDistributionStrategy => 'Estrategia de distribución de contenido';
	@override String get cdnDistributionStrategyDesc => 'Seleccione la estrategia de distribución del servidor de origen del video para optimizar la velocidad de carga';
	@override String get cdnDistributionStrategyLabel => 'Estrategia de distribución';
	@override String get cdnDistributionStrategyNoChange => 'Sin cambios (usar el servidor original)';
	@override String get cdnDistributionStrategyAuto => 'Selección automática (servidor más rápido)';
	@override String get cdnDistributionStrategySpecial => 'Especificar servidor';
	@override String get cdnSpecialServer => 'Especificar servidor';
	@override String get cdnRefreshServerListHint => 'Pulse el botón de abajo para actualizar la lista de servidores';
	@override String get cdnRefreshButton => 'Actualizar';
	@override String get cdnFastRingServers => 'Servidores de anillo rápido';
	@override String get cdnRefreshServerListTooltip => 'Actualizar la lista de servidores';
	@override String get cdnSpeedTestButton => 'Prueba de velocidad';
	@override String cdnSpeedTestingButton({required Object count}) => 'Probando (${count})';
	@override String get cdnNoServerDataHint => 'No hay datos de servidores disponibles; pulse el botón de actualizar';
	@override String get cdnTestingStatus => 'Probando';
	@override String get cdnUnreachableStatus => 'Inaccesible';
	@override String get cdnNotTestedStatus => 'Sin probar';
	@override late final _TranslationsSettingsDownloadSettingsEs downloadSettings = _TranslationsSettingsDownloadSettingsEs._(_root);
}

// Path: favoriteTags
class _TranslationsFavoriteTagsEs extends TranslationsFavoriteTagsEn {
	_TranslationsFavoriteTagsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Etiquetas favoritas';
	@override String get emptyIwara => 'Aún no hay etiquetas de Iwara favoritas';
	@override String get emptyOreno3d => 'Aún no hay favoritos';
	@override String get addIwaraTag => 'Añadir etiqueta de Iwara';
	@override String get quickPickHint => 'Los elementos marcados como favoritos aparecen como selecciones rápidas en la búsqueda.';
	@override String get pickerTitle => 'Seleccionar Oreno3D';
	@override String get searchHint => 'Buscar por nombre u original';
	@override String worksCount({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n,
		one: '${n} obra',
		other: '${n} obras',
	);
	@override String get browseEntry => 'Explorar origen / personaje / etiqueta';
	@override String get favoritesSection => 'Favoritos';
	@override String get addFavorite => 'Añadir';
	@override String get iwaraTitle => 'Etiquetas de Iwara favoritas';
	@override String get oreno3dTitle => 'Etiquetas de Oreno3D favoritas';
	@override String get changeTag => 'Cambiar etiqueta';
	@override String get switchToText => 'Búsqueda de texto';
}

// Path: oreno3d
class _TranslationsOreno3dEs extends TranslationsOreno3dEn {
	_TranslationsOreno3dEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Oreno3D';
	@override String get tags => 'Etiquetas';
	@override String get characters => 'Personajes';
	@override String get origin => 'Origen';
	@override String get thirdPartyTagsExplanation => 'La información de **etiquetas**, **personajes** y **origen** que se muestra aquí la proporciona el sitio de terceros **Oreno3D** únicamente como referencia.\n\nComo esta fuente de información solo está disponible en japonés, por ahora no cuenta con adaptación de internacionalización.\n\nSi te interesa contribuir a la internacionalización, visita el repositorio para ayudar a mejorarla.';
	@override late final _TranslationsOreno3dSortTypesEs sortTypes = _TranslationsOreno3dSortTypesEs._(_root);
	@override late final _TranslationsOreno3dErrorsEs errors = _TranslationsOreno3dErrorsEs._(_root);
	@override late final _TranslationsOreno3dLoadingEs loading = _TranslationsOreno3dLoadingEs._(_root);
	@override late final _TranslationsOreno3dMessagesEs messages = _TranslationsOreno3dMessagesEs._(_root);
}

// Path: signIn
class _TranslationsSignInEs extends TranslationsSignInEn {
	_TranslationsSignInEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirst => 'Inicie sesión primero';
	@override String get alreadySignedInToday => '¡Ya se ha registrado hoy!';
	@override String get youDidNotStickToTheSignIn => 'No ha sido constante con el registro diario.';
	@override String get signInSuccess => '¡Registro correcto!';
	@override String get signInFailed => 'No se pudo registrar; inténtelo de nuevo más tarde';
	@override String get consecutiveSignIns => 'Registros consecutivos';
	@override String get failureReason => 'Motivo del fallo';
	@override String get selectDateRange => 'Seleccionar rango de fechas';
	@override String get startDate => 'Fecha de inicio';
	@override String get endDate => 'Fecha de fin';
	@override String get invalidDate => 'Fecha no válida';
	@override String get invalidDateRange => 'Rango de fechas no válido';
	@override String get errorFormatText => 'Error de formato de fecha';
	@override String get errorInvalidText => 'Rango de fechas no válido';
	@override String get errorInvalidRangeText => 'Rango de fechas no válido';
	@override String get dateRangeCantBeMoreThanOneYear => 'El rango de fechas no puede superar un año';
	@override String get signIn => 'Registrarse';
	@override String get signInRecord => 'Historial de registros';
	@override String get totalSignIns => 'Total de registros';
	@override String get pleaseSelectSignInStatus => 'Seleccione el estado de registro';
}

// Path: subscriptions
class _TranslationsSubscriptionsEs extends TranslationsSubscriptionsEn {
	_TranslationsSubscriptionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pleaseLoginFirstToViewYourSubscriptions => 'Inicie sesión primero para ver sus suscripciones.';
	@override String get selectUser => 'Seleccionar usuario';
	@override String get noSubscribedUsers => 'No hay usuarios suscritos';
	@override String get showAllSubscribedUsersContent => 'Mostrar el contenido de todos los usuarios suscritos';
}

// Path: videoDetail
class _TranslationsVideoDetailEs extends TranslationsVideoDetailEn {
	_TranslationsVideoDetailEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pipMode => 'Modo PiP';
	@override String resumeFromLastPosition({required Object position}) => 'Reanudar desde la última posición: ${position}';
	@override String resumedFromHistoryTip({required Object position}) => 'Reanudado desde ${position}';
	@override String get restartFromBeginning => 'Empezar de nuevo';
	@override String get dismissResumeTip => 'Descartar';
	@override late final _TranslationsVideoDetailLocalInfoEs localInfo = _TranslationsVideoDetailLocalInfoEs._(_root);
	@override String get videoIdIsEmpty => 'El ID del video está vacío';
	@override String get videoInfoIsEmpty => 'La información del video está vacía';
	@override String get thisIsAPrivateVideo => 'Este es un video privado';
	@override String get getVideoInfoFailed => 'No se pudo obtener la información del video; inténtelo de nuevo más tarde';
	@override String get noVideoSourceFound => 'No se encontró ninguna fuente de video';
	@override String tagCopiedToClipboard({required Object tagId}) => 'Etiqueta "${tagId}" copiada al portapapeles';
	@override String get errorLoadingVideo => 'Error al cargar el video';
	@override String get play => 'Reproducir';
	@override String get pause => 'Pausar';
	@override String get exitAppFullscreen => 'Salir de pantalla completa de la aplicación';
	@override String get enterAppFullscreen => 'Entrar en pantalla completa de la aplicación';
	@override String get exitSystemFullscreen => 'Salir de pantalla completa del sistema';
	@override String get enterSystemFullscreen => 'Entrar en pantalla completa del sistema';
	@override String get seekTo => 'Buscar hasta';
	@override String get switchResolution => 'Cambiar la resolución';
	@override String get switchPlaybackSpeed => 'Cambiar la velocidad de reproducción';
	@override String rewindSeconds({required Object num}) => 'Retroceder ${num} segundos';
	@override String fastForwardSeconds({required Object num}) => 'Avanzar ${num} segundos';
	@override String playbackSpeedIng({required Object rate}) => 'Reproduciendo a velocidad ${rate}x';
	@override String get brightness => 'Brillo';
	@override String get brightnessLowest => 'El brillo está al mínimo';
	@override String get volume => 'Volumen';
	@override String get volumeMuted => 'El volumen está silenciado';
	@override String get restoreDefaultZoom => 'Restaurar';
	@override late final _TranslationsVideoDetailGestureGuideEs gestureGuide = _TranslationsVideoDetailGestureGuideEs._(_root);
	@override String get home => 'Inicio';
	@override String get videoPlayer => 'Reproductor de video';
	@override String get videoPlayerInfo => 'Información del reproductor de video';
	@override String get moreSettings => 'Más ajustes';
	@override String get videoPlayerFeatureInfo => 'Información de funciones del reproductor de video';
	@override String get autoRewind => 'Retroceso automático';
	@override String get rewindAndFastForward => 'Retroceder y avanzar';
	@override String get volumeAndBrightness => 'Volumen y brillo';
	@override String get centerAreaDoubleTapPauseOrPlay => 'Doble toque en el área central para pausar o reproducir';
	@override String get showVerticalVideoInFullScreen => 'Mostrar el video vertical en pantalla completa';
	@override String get keepLastVolumeAndBrightness => 'Mantener el último volumen y brillo';
	@override String get setProxy => 'Configurar proxy';
	@override String get moreFeaturesToBeDiscovered => 'Más funciones por descubrir...';
	@override String get videoPlayerSettings => 'Ajustes del reproductor de video';
	@override String commentCount({required Object num}) => '${num} comentarios';
	@override String get writeYourCommentHere => 'Escriba su comentario aquí...';
	@override String get authorOtherVideos => 'Otros videos del autor';
	@override String get relatedVideos => 'Videos relacionados';
	@override String get privateVideo => 'Este es un video privado';
	@override String get externalVideo => 'Este es un video externo';
	@override String get openInBrowser => 'Abrir en el navegador';
	@override String get resourceDeleted => 'Parece que este video se ha eliminado :/';
	@override String get noDownloadUrl => 'No hay URL de descarga';
	@override String get startDownloading => 'Empezar a descargar';
	@override String get downloadFailed => 'La descarga falló; inténtelo de nuevo más tarde';
	@override String get downloadSuccess => 'Descarga correcta';
	@override String get download => 'Descargar';
	@override String get downloadManager => 'Gestor de descargas';
	@override String get resourceNotFound => 'Recurso no encontrado';
	@override String get videoLoadError => 'Error al cargar el video';
	@override String get authorNoOtherVideos => 'El autor no tiene otros videos';
	@override String get noRelatedVideos => 'No hay videos relacionados';
	@override late final _TranslationsVideoDetailPlayerEs player = _TranslationsVideoDetailPlayerEs._(_root);
	@override late final _TranslationsVideoDetailSkeletonEs skeleton = _TranslationsVideoDetailSkeletonEs._(_root);
	@override late final _TranslationsVideoDetailCastEs cast = _TranslationsVideoDetailCastEs._(_root);
	@override late final _TranslationsVideoDetailLikeAvatarsEs likeAvatars = _TranslationsVideoDetailLikeAvatarsEs._(_root);
}

// Path: share
class _TranslationsShareEs extends TranslationsShareEn {
	_TranslationsShareEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sharePlayList => 'Compartir lista de reproducción';
	@override String get wowDidYouSeeThis => '¡Vaya, ha visto esto?';
	@override String get nameIs => 'El nombre es';
	@override String get clickLinkToView => 'Pulse el enlace para verlo';
	@override String get iReallyLikeThis => 'Me gusta mucho esto';
	@override String get shareFailed => 'No se pudo compartir; inténtelo de nuevo más tarde';
	@override String get share => 'Compartir';
	@override String get shareAsImage => 'Compartir como imagen';
	@override String get shareAsText => 'Compartir como texto';
	@override String get shareAsImageDesc => 'Compartir la portada del video como imagen';
	@override String get shareAsTextDesc => 'Compartir los detalles del video como texto';
	@override String get shareAsImageFailed => 'No se pudo compartir la portada del video como imagen; inténtelo de nuevo más tarde';
	@override String get shareAsTextFailed => 'No se pudieron compartir los detalles del video como texto; inténtelo de nuevo más tarde';
	@override String get shareVideo => 'Compartir video';
	@override String get authorIs => 'El autor es';
	@override String get shareGallery => 'Compartir galería';
	@override String get galleryTitleIs => 'El título de la galería es';
	@override String get galleryAuthorIs => 'El autor de la galería es';
	@override String get shareUser => 'Compartir usuario';
	@override String get userNameIs => 'El nombre del usuario es';
	@override String get userAuthorIs => 'El autor del usuario es';
	@override String get comments => 'Comentarios';
	@override String get shareThread => 'Compartir hilo';
	@override String get views => 'Visualizaciones';
	@override String get sharePost => 'Compartir publicación';
	@override String get postTitleIs => 'El título de la publicación es';
	@override String get postAuthorIs => 'El autor de la publicación es';
}

// Path: markdown
class _TranslationsMarkdownEs extends TranslationsMarkdownEn {
	_TranslationsMarkdownEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get markdownSyntax => 'Sintaxis de Markdown';
	@override String get iwaraSpecialMarkdownSyntax => 'Sintaxis especial de Markdown de Iwara';
	@override String get internalLink => 'Enlace interno';
	@override String get supportAutoConvertLinkBelow => 'Se admite la conversión automática de los siguientes enlaces:';
	@override String get convertLinkExample => '🎬 Enlace de vídeo\n🖼️ Enlace de imagen\n👤 Enlace de usuario\n📌 Enlace del foro\n🎵 Enlace de lista de reproducción\n💬 Enlace de hilo';
	@override String get mentionUser => 'Mencionar usuario';
	@override String get mentionUserDescription => 'Escriba @ seguido del nombre de usuario; se convertirá automáticamente en un enlace al usuario';
	@override String get markdownBasicSyntax => 'Sintaxis básica de Markdown';
	@override String get paragraphAndLineBreak => 'Párrafo y salto de línea';
	@override String get paragraphAndLineBreakDescription => 'Los párrafos se separan con una línea, y dos espacios al final de la línea se convertirán en un salto de línea';
	@override String get paragraphAndLineBreakSyntax => 'Este es el primer párrafo\n\nEste es el segundo párrafo\nEsta línea termina con dos espacios  \nse convertirá en un salto de línea';
	@override String get textStyle => 'Estilo de texto';
	@override String get textStyleDescription => 'Use símbolos especiales alrededor del texto para cambiar su estilo';
	@override String get textStyleSyntax => '**Texto en negrita**\n*Texto en cursiva*\n~~Texto tachado~~\n`Texto de código`';
	@override String get quote => 'Cita';
	@override String get quoteDescription => 'Use el símbolo > para crear una cita y varios > para crear una cita de varios niveles';
	@override String get quoteSyntax => '> Esta es una cita de primer nivel\n>> Esta es una cita de segundo nivel';
	@override String get list => 'Lista';
	@override String get listDescription => 'Cree una lista ordenada con número+punto y una lista sin orden con -';
	@override String get listSyntax => '1. Primer elemento\n2. Segundo elemento\n\n- Elemento sin orden\n  - Subelemento\n  - Otro subelemento';
	@override String get linkAndImage => 'Enlace e imagen';
	@override String get linkAndImageDescription => 'Formato de enlace: [texto](URL)\nFormato de imagen: ![descripción](URL)';
	@override String linkAndImageSyntax({required Object link, required Object imgUrl}) => '[texto del enlace](${link})\n![descripción de la imagen](${imgUrl})';
	@override String get title => 'Título';
	@override String get titleDescription => 'Use el símbolo # para crear un título y más # para indicar el nivel';
	@override String get titleSyntax => '# Título de primer nivel\n## Título de segundo nivel\n### Título de tercer nivel';
	@override String get separator => 'Separador';
	@override String get separatorDescription => 'Cree un separador con tres o más símbolos -';
	@override String get separatorSyntax => '---';
	@override String get syntax => 'Sintaxis';
}

// Path: forum
class _TranslationsForumEs extends TranslationsForumEn {
	_TranslationsForumEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get recent => 'Recientes';
	@override String get category => 'Categoría';
	@override String get lastReply => 'Última respuesta';
	@override late final _TranslationsForumSitewideEs sitewide = _TranslationsForumSitewideEs._(_root);
	@override late final _TranslationsForumErrorsEs errors = _TranslationsForumErrorsEs._(_root);
	@override String get createPost => 'Crear publicación';
	@override String get title => 'Título';
	@override String get enterTitle => 'Introducir título';
	@override String get content => 'Contenido';
	@override String get enterContent => 'Introducir contenido';
	@override String get writeYourContentHere => 'Escriba aquí su contenido...';
	@override String get posts => 'Publicaciones';
	@override String get threads => 'Hilos';
	@override String get forum => 'Foro';
	@override String get createThread => 'Crear hilo';
	@override String get selectCategory => 'Seleccionar categoría';
	@override String cooldownRemaining({required Object minutes, required Object seconds}) => 'Tiempo de espera restante: ${minutes} minutos ${seconds} segundos';
	@override late final _TranslationsForumGroupsEs groups = _TranslationsForumGroupsEs._(_root);
	@override late final _TranslationsForumLeafNamesEs leafNames = _TranslationsForumLeafNamesEs._(_root);
	@override late final _TranslationsForumLeafDescriptionsEs leafDescriptions = _TranslationsForumLeafDescriptionsEs._(_root);
	@override String get reply => 'Responder';
	@override String get pendingReview => 'Pendiente de revisión';
	@override String get editedAt => 'Editado el';
	@override String get copySuccess => 'Copiado al portapapeles';
	@override String copySuccessForMessage({required Object str}) => 'Copiado al portapapeles: ${str}';
	@override String get editReply => 'Editar respuesta';
	@override String get editTitle => 'Editar título';
	@override String get submit => 'Enviar';
}

// Path: notifications
class _TranslationsNotificationsEs extends TranslationsNotificationsEn {
	_TranslationsNotificationsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsNotificationsErrorsEs errors = _TranslationsNotificationsErrorsEs._(_root);
	@override String get notifications => 'Notificaciones';
	@override String get profile => 'Perfil';
	@override String get postedNewComment => 'Publicó un comentario nuevo';
	@override String get inYour => 'En su';
	@override String get video => 'Vídeo';
	@override String get repliedYourVideoComment => 'Respondió a su comentario del video';
	@override String get copyInfoToClipboard => 'Copiar la información de la notificación al portapapeles';
	@override String get copySuccess => 'Copiado al portapapeles';
	@override String copySuccessForMessage({required Object str}) => 'Copiado al portapapeles: ${str}';
	@override String get markAllAsRead => 'Marcar todo como leído';
	@override String get markAllAsReadSuccess => 'Todas las notificaciones se marcaron como leídas';
	@override String get markAllAsReadFailed => 'No se pudo marcar todo como leído';
	@override String get markSelectedAsRead => 'Marcar seleccionadas como leídas';
	@override String get markSelectedAsReadSuccess => 'Las notificaciones seleccionadas se marcaron como leídas';
	@override String get markSelectedAsReadFailed => 'No se pudieron marcar las seleccionadas como leídas';
	@override String get markAsRead => 'Marcar como leído';
	@override String get markAsReadSuccess => 'La notificación se marcó como leída';
	@override String get markAsReadFailed => 'No se pudo marcar la notificación como leída';
	@override String get notificationTypeHelp => 'Ayuda sobre los tipos de notificación';
	@override String get dueToLackOfNotificationTypeDetails => 'Debido a la falta de detalles del tipo de notificación, los tipos admitidos pueden no cubrir los mensajes que recibe actualmente';
	@override String get helpUsImproveNotificationTypeSupport => 'Si desea ayudarnos a mejorar la compatibilidad con los tipos de notificación';
	@override String get helpUsImproveNotificationTypeSupportLongText => '1. 📋 Copie la información de la notificación\n2. 🐞 Envíe un informe de problema al repositorio del proyecto\n\n⚠️ Nota: la información de la notificación puede contener datos personales privados; si no desea hacerla pública, también puede enviarla al autor del proyecto por correo electrónico.';
	@override String get goToRepository => 'Ir al repositorio';
	@override String get copy => 'Copiar';
	@override String get commentApproved => 'Comentario aprobado';
	@override String get repliedYourProfileComment => 'Respondió a su comentario del perfil';
	@override String get kReplied => 'respondió a su comentario en';
	@override String get kCommented => 'comentó en su';
	@override String get kVideo => 'Vídeo';
	@override String get kGallery => 'galería';
	@override String get kProfile => 'perfil';
	@override String get kThread => 'hilo';
	@override String get kPost => 'publicación';
	@override String get kCommentSection => 'sección de comentarios';
	@override String get kApprovedComment => 'Comentario aprobado';
	@override String get kApprovedVideo => 'Video aprobado';
	@override String get kApprovedGallery => 'Galería aprobada';
	@override String get kApprovedThread => 'Hilo aprobado';
	@override String get kApprovedPost => 'Publicación aprobada';
	@override String get kApprovedForumPost => 'Publicación del foro aprobada';
	@override String get kRejectedContent => 'Revisión de contenido rechazada';
	@override String get kUnknownType => 'Tipo de notificación desconocido';
}

// Path: conversation
class _TranslationsConversationEs extends TranslationsConversationEn {
	_TranslationsConversationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsConversationErrorsEs errors = _TranslationsConversationErrorsEs._(_root);
	@override String get conversation => 'Conversación';
	@override String get startConversation => 'Iniciar conversación';
	@override String get noConversation => 'Sin conversación';
	@override String get selectFromLeftListAndStartConversation => 'Seleccione un usuario de la lista de la izquierda e inicie una conversación';
	@override String get title => 'Título';
	@override String get body => 'Cuerpo';
	@override String get selectAUser => 'Seleccione un usuario';
	@override String get searchUsers => 'Buscar usuarios...';
	@override String get tmpNoConversions => 'No hay conversaciones';
	@override String get deleteThisMessage => 'Eliminar este mensaje';
	@override String get deleteThisMessageSubtitle => 'Esta operación no se puede deshacer';
	@override String get writeMessageHere => 'Escriba aquí el mensaje...';
	@override String get lastMessageFromMe => 'Yo: ';
	@override String get sendMessage => 'Enviar mensaje';
}

// Path: splash
class _TranslationsSplashEs extends TranslationsSplashEn {
	_TranslationsSplashEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSplashErrorsEs errors = _TranslationsSplashErrorsEs._(_root);
	@override String get preparing => 'Preparando...';
	@override String get initializing => 'Inicializando...';
	@override String get loading => 'Cargando...';
	@override String get ready => 'Listo';
	@override String get initializingMessageService => 'Inicializando el servicio de mensajes...';
}

// Path: download
class _TranslationsDownloadEs extends TranslationsDownloadEn {
	_TranslationsDownloadEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDownloadErrorsEs errors = _TranslationsDownloadErrorsEs._(_root);
	@override String get downloadList => 'Lista de descargas';
	@override String get viewDownloadList => 'Ver la lista de descargas';
	@override String get download => 'Descargar';
	@override String get selectDownloadTitle => 'Seleccionar descarga';
	@override String get qualitySectionLabel => 'Calidad';
	@override String get categorySectionLabel => 'Categoría';
	@override String get saveToPreviewLabel => 'Se guardará en';
	@override String saveToPreviewSuggested({required Object name}) => 'Nombre sugerido: ${name} (editable en el diálogo del sistema)';
	@override String get lastUsedBadge => 'Último uso';
	@override String get pickedBadge => 'Seleccionado';
	@override String get startDownloading => 'Iniciar descarga';
	@override String get clearAllFailedTasks => 'Borrar todas las tareas fallidas';
	@override String get clearAllFailedTasksConfirmation => '¿Seguro que quiere borrar todas las tareas de descarga fallidas? También se eliminarán los archivos de estas tareas.';
	@override String get clearAllFailedTasksSuccess => 'Se borraron todas las tareas fallidas';
	@override String get clearAllFailedTasksError => 'Se produjo un error al borrar las tareas fallidas';
	@override String get downloadStatus => 'Estado de la descarga';
	@override String get imageList => 'Lista de imágenes';
	@override String get retryDownload => 'Reintentar descarga';
	@override String get notDownloaded => 'Sin descargar';
	@override String get downloaded => 'Descargado';
	@override String get waitingForDownload => 'En espera de descarga';
	@override String downloadingProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'Descargando (${downloaded}/${total} imágenes ${progress}%)';
	@override String downloadingSingleImageProgress({required Object downloaded}) => 'Descargando (${downloaded} imágenes)';
	@override String pausedProgressForImageProgress({required Object downloaded, required Object total, required Object progress}) => 'En pausa (${downloaded}/${total} imágenes ${progress}%)';
	@override String pausedSingleImageProgress({required Object downloaded}) => 'En pausa (${downloaded} imágenes)';
	@override String downloadedProgressForImageProgress({required Object total}) => 'Descargado (${total} imágenes en total)';
	@override String get viewVideoDetail => 'Ver los detalles del vídeo';
	@override String get viewGalleryDetail => 'Ver los detalles de la galería';
	@override String get moreOptions => 'Más opciones';
	@override String get openFile => 'Abrir archivo';
	@override String get playLocally => 'Reproducir localmente';
	@override String get pause => 'Pausar';
	@override String get resume => 'Reanudar';
	@override String get copyDownloadUrl => 'Copiar URL de descarga';
	@override String get showInFolder => 'Mostrar en la carpeta';
	@override String get deleteTask => 'Eliminar tarea';
	@override String get deleteTaskConfirmation => '¿Seguro que quiere eliminar esta tarea de descarga?\nTambién se eliminará el archivo de la tarea.';
	@override String get forceDeleteTask => 'Forzar eliminación de la tarea';
	@override String get forceDeleteTaskConfirmation => '¿Seguro que quiere forzar la eliminación de esta tarea de descarga?\nTambién se eliminará el archivo de la tarea, aunque esté en uso.';
	@override String downloadingProgressForVideoTask({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Descargando ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String downloadingOnlyDownloadedAndSpeed({required Object downloaded, required Object speed}) => 'Descargando ${downloaded} • ${speed}MB/s';
	@override String pausedForDownloadedAndTotal({required Object downloaded, required Object total, required Object progress}) => 'En pausa ${downloaded}/${total} (${progress}%)';
	@override String pausedAndDownloaded({required Object downloaded}) => 'En pausa • Descargado ${downloaded}';
	@override String downloadedWithSize({required Object size}) => 'Descargado • ${size}';
	@override String get copyDownloadUrlSuccess => 'URL de descarga copiada';
	@override String totalImageNums({required Object num}) => '${num} imágenes';
	@override String downloadingDownloadedTotalProgressSpeed({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Descargando ${downloaded}/${total} (${progress}%) • ${speed}MB/s';
	@override String get downloading => 'Descargando';
	@override String get failed => 'Fallido';
	@override String get completed => 'Completado';
	@override String get downloadDetail => 'Detalles de la descarga';
	@override String get copy => 'Copiar';
	@override String get copySuccess => 'Copiado';
	@override String get waiting => 'En espera';
	@override String get paused => 'En pausa';
	@override String downloadingOnlyDownloaded({required Object downloaded}) => 'Descargando ${downloaded}';
	@override String galleryDownloadCompletedWithName({required Object galleryName}) => 'Descarga de la galería completada: ${galleryName}';
	@override String downloadCompletedWithName({required Object fileName}) => 'Descarga completada: ${fileName}';
	@override String get searchTasks => 'Buscar tareas...';
	@override String statusLabel({required Object label}) => 'Estado: ${label}';
	@override String get allStatus => 'Todos los estados';
	@override String typeLabel({required Object label}) => 'Tipo: ${label}';
	@override String get allTypes => 'Todos los tipos';
	@override String get taskType => 'Tipo';
	@override String get video => 'Vídeo';
	@override String get gallery => 'Galería';
	@override String get other => 'Otro';
	@override String get clearFilters => 'Borrar filtros';
	@override String get pauseAll => 'Pausar todo';
	@override String get resumeAll => 'Iniciar todo';
	@override String remainingTime({required Object time}) => 'quedan ${time}';
	@override late final _TranslationsDownloadTimelineEs timeline = _TranslationsDownloadTimelineEs._(_root);
	@override late final _TranslationsDownloadErrorTypesEs errorTypes = _TranslationsDownloadErrorTypesEs._(_root);
	@override String get errorDetailCopied => 'Detalles del error copiados';
	@override String get errorDetailCopyHint => 'Mantenga pulsado para copiar los detalles del error';
	@override late final _TranslationsDownloadRestoredPausedEs restoredPaused = _TranslationsDownloadRestoredPausedEs._(_root);
	@override late final _TranslationsDownloadActionsEs actions = _TranslationsDownloadActionsEs._(_root);
	@override late final _TranslationsDownloadNoticeEs notice = _TranslationsDownloadNoticeEs._(_root);
	@override String get emptyTaskList => 'Aún no hay tareas de descarga';
	@override String get noMatchingTasks => 'Ninguna tarea coincide';
	@override late final _TranslationsDownloadDeleteByDateEs deleteByDate = _TranslationsDownloadDeleteByDateEs._(_root);
	@override late final _TranslationsDownloadRelocationEs relocation = _TranslationsDownloadRelocationEs._(_root);
	@override late final _TranslationsDownloadCategoryEs category = _TranslationsDownloadCategoryEs._(_root);
	@override late final _TranslationsDownloadLocationEs location = _TranslationsDownloadLocationEs._(_root);
	@override String get maxConcurrentDownloads => 'Descargas simultáneas máximas';
	@override String get maxConcurrentDownloadsDesc => 'Número de tareas que se descargan a la vez (1-5)';
	@override String get stillInDevelopment => 'Aún en desarrollo';
	@override String get saveToAppDirectory => 'Guardar en el directorio de la aplicación';
	@override String get alreadyDownloadedWithQuality => 'Ya se descargó con la misma calidad. ¿Continuar con la descarga?';
	@override String alreadyDownloadedWithQualities({required Object qualities}) => 'Ya se descargó con las calidades: ${qualities}. ¿Continuar con la descarga?';
	@override String get otherQualities => 'Otras calidades';
	@override late final _TranslationsDownloadBatchDownloadEs batchDownload = _TranslationsDownloadBatchDownloadEs._(_root);
}

// Path: downloadNotifications
class _TranslationsDownloadNotificationsEs extends TranslationsDownloadNotificationsEn {
	_TranslationsDownloadNotificationsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get completedTitle => 'Descarga completada';
	@override String get failedTitle => 'No se pudo descargar';
	@override String completedBody({required Object name}) => '${name} se descargó correctamente';
	@override String failedBody({required Object name}) => 'No se pudo descargar ${name}';
	@override String completedToast({required Object name}) => '${name} descargado';
	@override String failedToast({required Object name}) => 'No se pudo descargar ${name}';
	@override String savedToFolder({required Object dir}) => 'Guardado en ${dir}';
	@override String savedAsRenamed({required Object name}) => 'Guardado como ${name} (ya existía un archivo con el mismo nombre)';
	@override String savedToAppFolder({required Object target, required Object reason}) => 'Guardado en la carpeta de la app — no se pudo escribir en ${target} (${reason})';
	@override String get viewFolder => 'Ver carpeta';
	@override String get fixInSettings => 'Corregir en Ajustes';
	@override String get channelName => 'Estado de las descargas';
	@override String get channelDescription => 'Notificaciones de descargas completadas y fallidas';
}

// Path: favorite
class _TranslationsFavoriteEs extends TranslationsFavoriteEn {
	_TranslationsFavoriteEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFavoriteErrorsEs errors = _TranslationsFavoriteErrorsEs._(_root);
	@override String get add => 'Añadir';
	@override String get addSuccess => 'Añadido correctamente';
	@override String get addFailed => 'No se pudo añadir';
	@override String get remove => 'Quitar';
	@override String get removeSuccess => 'Quitado correctamente';
	@override String get removeFailed => 'No se pudo quitar';
	@override String get removeConfirmation => '¿Seguro que quiere quitar este elemento de favoritos?';
	@override String get removeConfirmationSuccess => 'Elemento quitado de favoritos';
	@override String get removeConfirmationFailed => 'No se pudo quitar el elemento de favoritos';
	@override String get createFolderSuccess => 'Carpeta creada correctamente';
	@override String get createFolderFailed => 'No se pudo crear la carpeta';
	@override String get createFolder => 'Crear carpeta';
	@override String get enterFolderName => 'Introduzca el nombre de la carpeta';
	@override String get enterFolderNameHere => 'Introduzca aquí el nombre de la carpeta...';
	@override String get create => 'Crear';
	@override String get items => 'Elementos';
	@override String get newFolderName => 'Nueva carpeta';
	@override String get searchFolders => 'Buscar carpetas...';
	@override String get searchItems => 'Buscar elementos...';
	@override String get createdAt => 'Creado el';
	@override String get myFavorites => 'Mis favoritos';
	@override String get deleteFolderTitle => 'Eliminar carpeta';
	@override String deleteFolderConfirmWithTitle({required Object title}) => '¿Seguro que quiere eliminar la carpeta ${title}?';
	@override String get removeItemTitle => 'Quitar elemento';
	@override String removeItemConfirmWithTitle({required Object title}) => '¿Seguro que quiere eliminar el elemento ${title}?';
	@override String get removeItemSuccess => 'Elemento quitado de favoritos';
	@override String get removeItemFailed => 'No se pudo quitar el elemento de favoritos';
	@override String get localizeFavorite => 'Favorito local';
	@override String get editFolderTitle => 'Editar carpeta';
	@override String get editFolderSuccess => 'Carpeta actualizada correctamente';
	@override String get editFolderFailed => 'No se pudo actualizar la carpeta';
	@override String get searchTags => 'Buscar etiquetas';
	@override String get noTagsInFolder => 'Aún no hay etiquetas en los elementos de esta carpeta';
	@override String get tagFilterMatchAll => 'Muestra solo los elementos que tienen todas las etiquetas seleccionadas';
	@override String get clearSelectedTags => 'Borrar las etiquetas seleccionadas';
	@override String selectedTagCount({required Object count}) => '${count} seleccionadas';
	@override String get noMatchingTags => 'No hay etiquetas coincidentes';
}

// Path: translation
class _TranslationsTranslationEs extends TranslationsTranslationEn {
	_TranslationsTranslationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get currentService => 'Servicio actual';
	@override String get testConnection => 'Probar conexión';
	@override String get testConnectionSuccess => 'Conexión probada correctamente';
	@override String get testConnectionFailed => 'La prueba de conexión falló';
	@override String testConnectionFailedWithMessage({required Object message}) => 'La prueba de conexión falló: ${message}';
	@override String get translation => 'Traducción';
	@override String get needVerification => 'Requiere verificación';
	@override String get needVerificationContent => 'Pruebe la conexión antes de activar la traducción con IA';
	@override String get confirm => 'Confirmar';
	@override String get disclaimer => 'Aviso legal';
	@override String get riskWarning => 'Advertencia de riesgo';
	@override String get dureToRisk1 => 'Como el texto lo generan los usuarios, puede contener contenido que infrinja la política de contenido del proveedor del servicio de IA';
	@override String get dureToRisk2 => 'El contenido inapropiado puede provocar la suspensión de la clave de API o la cancelación del servicio';
	@override String get operationSuggestion => 'Sugerencia de uso';
	@override String get operationSuggestion1 => '1. Úselo tras revisar estrictamente el contenido que se va a traducir';
	@override String get operationSuggestion2 => '2. Evite traducir contenido que implique violencia, contenido para adultos, etc.';
	@override String get apiConfig => 'Configuración de la API';
	@override String get modifyConfigWillAutoCloseAITranslation => 'Modificar la configuración cerrará automáticamente la traducción con IA; deberá probarla de nuevo tras activarla';
	@override String get apiAddress => 'Dirección de la API';
	@override String get modelName => 'Nombre del modelo';
	@override String get modelNameHintText => 'Por ejemplo: gpt-4-turbo';
	@override String get maxTokens => 'Tokens máximos';
	@override String get maxTokensHintText => 'Por ejemplo: 32000';
	@override String get temperature => 'Temperatura';
	@override String get temperatureHintText => '0.0-2.0';
	@override String get clickTestButtonToVerifyAPIConnection => 'Pulse el botón de prueba para verificar la validez de la conexión con la API';
	@override String get requestPreview => 'Vista previa de la solicitud';
	@override String get enableAITranslation => 'Activar IA';
	@override String get enabled => 'Activado';
	@override String get disabled => 'Desactivado';
	@override String get testing => 'Probando...';
	@override String get testNow => 'Probar ahora';
	@override String get connectionStatus => 'Estado de la conexión';
	@override String get success => 'Correcto';
	@override String get failed => 'Fallido';
	@override String get information => 'Información';
	@override String get viewRawResponse => 'Ver la respuesta sin procesar';
	@override String get pleaseCheckInputParametersFormat => 'Compruebe el formato de los parámetros de entrada';
	@override String get pleaseFillInAPIAddressModelNameAndKey => 'Rellene la dirección de la API, el nombre del modelo y la clave';
	@override String get pleaseFillInValidConfigurationParameters => 'Rellene parámetros de configuración válidos';
	@override String get pleaseCompleteConnectionTest => 'Complete la prueba de conexión';
	@override String get notConfigured => 'Sin configurar';
	@override String get apiEndpoint => 'Punto de conexión de la API';
	@override String get configuredKey => 'Clave configurada';
	@override String get notConfiguredKey => 'Clave sin configurar';
	@override String get authenticationStatus => 'Estado de autenticación';
	@override String get thisFieldCannotBeEmpty => 'Este campo no puede estar vacío';
	@override String get apiKey => 'Clave de API';
	@override String get apiKeyCannotBeEmpty => 'La clave de API no puede estar vacía';
	@override String get pleaseEnterValidNumber => 'Introduzca un número válido';
	@override String get range => 'Rango';
	@override String get mustBeGreaterThan => 'Debe ser mayor que';
	@override String get invalidAPIResponse => 'Respuesta de API no válida';
	@override String connectionFailedForMessage({required Object message}) => 'Error de conexión: ${message}';
	@override String get aiTranslationNotEnabledHint => 'La traducción con IA no está activada; actívela en los ajustes';
	@override String get goToSettings => 'Ir a los ajustes';
	@override String get disableAITranslation => 'Desactivar la traducción con IA';
	@override String get currentValue => 'Valor actual';
	@override String get configureTranslationStrategy => 'Configurar la estrategia de traducción';
	@override String get advancedSettings => 'Ajustes avanzados';
	@override String get translationPrompt => 'Mensaje de traducción';
	@override String get promptHint => 'Introduzca el mensaje de traducción; use [TL] como marcador de posición para el idioma de destino';
	@override String get promptHelperText => 'El mensaje debe contener [TL] como marcador de posición para el idioma de destino';
	@override String get promptMustContainTargetLang => 'El mensaje debe contener el marcador de posición [TL]';
	@override String get aiTranslationWillBeDisabled => 'La traducción con IA se desactivará';
	@override String get aiTranslationWillBeDisabledDueToConfigChange => 'Debido al cambio de la configuración básica, la traducción con IA se desactivará';
	@override String get aiTranslationWillBeDisabledDueToPromptChange => 'Debido al cambio del mensaje de traducción, la traducción con IA se desactivará';
	@override String get aiTranslationWillBeDisabledDueToParamChange => 'Debido al cambio de la configuración de parámetros, la traducción con IA se desactivará';
	@override String get onlyOpenAIAPISupported => 'Actualmente solo se admite el formato de API compatible con OpenAI (cuerpo de solicitud application/json)';
	@override String get streamingTranslation => 'Traducción en flujo';
	@override String get streamingTranslationSupported => 'Traducción en flujo admitida';
	@override String get streamingTranslationNotSupported => 'Traducción en flujo no admitida';
	@override String get streamingTranslationDescription => 'La traducción en flujo puede mostrar los resultados en tiempo real durante el proceso de traducción, ofreciendo una mejor experiencia de usuario';
	@override String get usingFullUrlWithHash => 'Usando la URL completa (termina con #)';
	@override String get baseUrlInputHelperText => 'Si termina con #, se usará como dirección de solicitud real';
	@override String currentActualUrl({required Object url}) => 'URL real actual: ${url}';
	@override String get urlEndingWithHashTip => 'La URL que termina con # se usará directamente sin añadir ningún sufijo';
	@override String get streamingTranslationWarning => 'Nota: esta función requiere que el servicio de API admita la transmisión en flujo; algunos modelos pueden no admitirlo';
	@override String get translationService => 'Servicio de traducción';
	@override String get translationServiceDescription => 'Seleccione el servicio de traducción que prefiera';
	@override String get googleTranslation => 'Traducción de Google';
	@override String get googleTranslationDescription => 'Servicio de traducción en línea gratuito compatible con varios idiomas';
	@override String get aiTranslation => 'Traducción con IA';
	@override String get aiTranslationDescription => 'Servicio de traducción inteligente basado en modelos de lenguaje grandes';
	@override String get deeplxTranslation => 'Traducción con DeepLX';
	@override String get deeplxTranslationDescription => 'Implementación de código abierto de la traducción DeepL, con traducción de alta calidad';
	@override String get googleTranslationFeatures => 'Funciones';
	@override String get freeToUse => 'Uso gratuito';
	@override String get freeToUseDescription => 'No requiere configuración; listo para usar';
	@override String get fastResponse => 'Respuesta rápida';
	@override String get fastResponseDescription => 'Velocidad de traducción rápida y baja latencia';
	@override String get stableAndReliable => 'Estable y fiable';
	@override String get stableAndReliableDescription => 'Basado en la API oficial de Google';
	@override String get enabledDefaultService => 'Activado: servicio de traducción predeterminado';
	@override String get notEnabled => 'No activado';
	@override String get deeplxTranslationService => 'Servicio de traducción DeepLX';
	@override String get deeplxDescription => 'DeepLX es una implementación de código abierto de la traducción DeepL; admite los modos de punto de conexión Free, Pro y Official';
	@override String get serverAddress => 'Dirección del servidor';
	@override String get serverAddressHint => 'https://api.deeplx.org';
	@override String get serverAddressHelperText => 'Dirección base del servidor DeepLX';
	@override String get endpointType => 'Tipo de punto de conexión';
	@override String get freeEndpoint => 'Free: punto de conexión gratuito, puede tener límites de velocidad';
	@override String get proEndpoint => 'Pro: requiere dl_session, más estable';
	@override String get officialEndpoint => 'Official: formato de API oficial';
	@override String get finalRequestUrl => 'URL de solicitud final';
	@override String get apiKeyOptional => 'Clave de API (opcional)';
	@override String get apiKeyOptionalHint => 'Para acceder a servicios DeepLX protegidos';
	@override String get apiKeyOptionalHelperText => 'Algunos servicios DeepLX requieren una clave de API para la autenticación';
	@override String get dlSession => 'DL Session';
	@override String get dlSessionHint => 'El modo Pro requiere el parámetro dl_session';
	@override String get dlSessionHelperText => 'Parámetro de sesión requerido para el punto de conexión Pro, obtenido de la cuenta DeepL Pro';
	@override String get proModeRequiresDlSession => 'El modo Pro requiere dl_session';
	@override String get clickTestButtonToVerifyDeepLXAPI => 'Pulse el botón de prueba para verificar la conexión con la API de DeepLX';
	@override String get enableDeepLXTranslation => 'Activar la traducción con DeepLX';
	@override String get deepLXTranslationWillBeDisabled => 'La traducción con DeepLX se desactivará debido a cambios en la configuración';
	@override String get translatedResult => 'Resultado de la traducción';
	@override String get testSuccess => 'Prueba correcta';
	@override String get pleaseFillInDeepLXServerAddress => 'Rellene la dirección del servidor DeepLX';
	@override String get invalidAPIResponseFormat => 'Formato de respuesta de API no válido';
	@override String get translationServiceReturnedError => 'El servicio de traducción devolvió un error o un resultado vacío';
	@override String get connectionFailed => 'Error de conexión';
	@override String get translationFailed => 'La traducción falló';
	@override String get aiTranslationFailed => 'La traducción con IA falló';
	@override String get deeplxTranslationFailed => 'La traducción con DeepLX falló';
	@override String get aiTranslationTestFailed => 'La prueba de traducción con IA falló';
	@override String get deeplxTranslationTestFailed => 'La prueba de traducción con DeepLX falló';
	@override String get streamingTranslationTimeout => 'Se agotó el tiempo de espera de la traducción en flujo; forzando la limpieza de recursos';
	@override String get translationRequestTimeout => 'Se agotó el tiempo de espera de la solicitud de traducción';
	@override String get streamingTranslationDataTimeout => 'Tiempo de espera de recepción de datos de la traducción en flujo agotado';
	@override String get dataReceptionTimeout => 'Tiempo de espera de recepción de datos agotado';
	@override String get streamDataParseError => 'Error al analizar los datos del flujo';
	@override String get streamingTranslationFailed => 'La traducción en flujo falló';
	@override String get fallbackTranslationFailed => 'La alternativa a la traducción normal también falló';
	@override String get translationSettings => 'Ajustes de traducción';
	@override String get enableGoogleTranslation => 'Activar la traducción de Google';
	@override String get thinking => 'Pensando...';
	@override String get thoughtProcess => 'Proceso de razonamiento';
	@override String get modelCompatibility => 'Compatibilidad de modelos';
	@override String get modelCompatibilityDescription => 'Adapta los parámetros de solicitud para modelos modernos como los modelos de razonamiento (o1/o3, DeepSeek-R1, QwQ)';
	@override String get reasoningModel => 'Modelo de razonamiento';
	@override String get reasoningModelDescription => 'Para o1/o3, DeepSeek-R1, QwQ, etc. Integra el mensaje en el mensaje del usuario, omite la temperatura y usa max_completion_tokens';
	@override String get useMaxCompletionTokens => 'Usar max_completion_tokens';
	@override String get useMaxCompletionTokensDescription => 'Los puntos de conexión más recientes de OpenAI requieren max_completion_tokens en lugar del obsoleto max_tokens';
	@override String get sendTemperature => 'Enviar temperatura';
	@override String get sendTemperatureDescription => 'Desactívelo para los modelos que rechazan el parámetro de temperatura (la mayoría de los modelos de razonamiento)';
	@override String get showReasoningProcess => 'Mostrar el proceso de razonamiento';
	@override String get showReasoningProcessDescription => 'Mostrar el razonamiento plegable de los modelos de razonamiento en el diálogo de traducción';
	@override String get provider => 'Proveedor';
	@override String get providerOpenAI => 'OpenAI (y compatibles)';
	@override String get providerAnthropic => 'Anthropic (Claude)';
	@override String get providerGoogle => 'Google (Gemini)';
	@override String get multiProviderHint => 'Admite OpenAI (y cualquier punto de conexión compatible con OpenAI), Anthropic y Google mediante el SDK dartantic_ai';
	@override String get baseUrlOptionalHelperText => 'Opcional. Déjelo vacío para usar el punto de conexión predeterminado del proveedor; rellénelo para puntos de conexión compatibles con OpenAI o de retransmisión';
	@override String get defaultEndpoint => 'Punto de conexión predeterminado';
	@override String get providerPreset => 'Predefinición de proveedor';
	@override String get selectProviderPreset => 'Seleccione una predefinición';
	@override String get presetCustom => 'Personalizado';
	@override String presetApplied({required Object name}) => 'Predefinición aplicada: ${name}';
	@override late final _TranslationsTranslationPresetNamesEs presetNames = _TranslationsTranslationPresetNamesEs._(_root);
	@override String get fetchModelList => 'Obtener la lista de modelos';
	@override String get fetchingModels => 'Obteniendo...';
	@override String get selectModel => 'Seleccionar modelo';
	@override String get searchModel => 'Buscar modelo';
	@override String get noModelsFound => 'No se encontraron modelos';
}

// Path: bottomNav
class _TranslationsBottomNavEs extends TranslationsBottomNavEn {
	_TranslationsBottomNavEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get video => 'Vídeo';
	@override String get gallery => 'Galería';
	@override String get subscription => 'Feed';
	@override String get community => 'Foro';
	@override String get localMedia => 'Local';
}

// Path: navigationOrderSettings
class _TranslationsNavigationOrderSettingsEs extends TranslationsNavigationOrderSettingsEn {
	_TranslationsNavigationOrderSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes del orden de navegación';
	@override String get customNavigationOrder => 'Orden de navegación personalizado';
	@override String get customNavigationOrderDesc => 'Arrastre para ajustar el orden de visualización de las páginas en la barra de navegación inferior y la barra lateral';
	@override String get restartRequired => 'Es necesario reiniciar la aplicación';
	@override String get navigationItemSorting => 'Ordenación de los elementos de navegación';
	@override String get done => 'Listo';
	@override String get edit => 'Editar';
	@override String get reset => 'Restablecer';
	@override String get previewEffect => 'Efecto de vista previa';
	@override String get bottomNavigationPreview => 'Vista previa de la navegación inferior:';
	@override String get sidebarPreview => 'Vista previa de la barra lateral:';
	@override String get confirmResetNavigationOrder => 'Confirmar el restablecimiento del orden de navegación';
	@override String get confirmResetNavigationOrderDesc => '¿Seguro que quiere restablecer el orden de navegación a los ajustes predeterminados?';
	@override String get cancel => 'Cancelar';
	@override String get show => 'Mostrar';
	@override String get hide => 'Ocultar';
	@override String get hidden => 'Oculto';
	@override String get hideHint => 'Toque el icono del ojo para mostrar u ocultar el foro y los archivos locales';
	@override String get videoDescription => 'Explore contenido de vídeo popular';
	@override String get galleryDescription => 'Explore imágenes y galerías';
	@override String get subscriptionDescription => 'Vea el contenido más reciente de los usuarios a los que sigue';
	@override String get forumDescription => 'Participe en los debates de la comunidad';
	@override String get newsDescription => 'Explore noticias, artículos y emisiones oficiales';
	@override String get communityDescription => 'Debates del foro, además de noticias, artículos y emisiones oficiales';
	@override String get localMediaDescription => 'Explore los vídeos e imágenes almacenados en este dispositivo';
}

// Path: news
class _TranslationsNewsEs extends TranslationsNewsEn {
	_TranslationsNewsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Noticias';
	@override String get newsUpdates => 'Novedades';
	@override String get articles => 'Artículos';
	@override String get broadcast => 'Difusión';
	@override String get openInBrowser => 'Abrir en el navegador';
}

// Path: displaySettings
class _TranslationsDisplaySettingsEs extends TranslationsDisplaySettingsEn {
	_TranslationsDisplaySettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes de pantalla';
	@override String get layoutSettings => 'Ajustes de diseño';
	@override String get layoutSettingsDesc => 'Personalice el número de columnas y la configuración de puntos de corte';
	@override String get gridLayout => 'Diseño de cuadrícula';
	@override String get navigationOrderSettings => 'Ajustes del orden de navegación';
	@override String get customNavigationOrder => 'Orden de navegación personalizado';
	@override String get customNavigationOrderDesc => 'Ajuste el orden de visualización de las páginas en la barra de navegación inferior y la barra lateral';
}

// Path: layoutSettings
class _TranslationsLayoutSettingsEs extends TranslationsLayoutSettingsEn {
	_TranslationsLayoutSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes de diseño';
	@override String get descriptionTitle => 'Descripción de la configuración de diseño';
	@override String get descriptionContent => 'La configuración de aquí determina el número de columnas que se muestran en las páginas de lista de vídeos y galerías. Puede elegir el modo automático para que el sistema se ajuste según el ancho de pantalla, o el modo manual para fijar el número de columnas.';
	@override String get layoutMode => 'Modo de diseño';
	@override String get reset => 'Restablecer';
	@override String get autoMode => 'Modo automático';
	@override String get autoModeDesc => 'Ajustar automáticamente según el ancho de pantalla';
	@override String get manualMode => 'Modo manual';
	@override String get manualModeDesc => 'Usar un número fijo de columnas';
	@override String get manualSettings => 'Ajustes manuales';
	@override String get fixedColumns => 'Columnas fijas';
	@override String get columns => 'columnas';
	@override String get breakpointConfig => 'Configuración de puntos de corte';
	@override String get add => 'Añadir';
	@override String get defaultColumns => 'Columnas predeterminadas';
	@override String get defaultColumnsDesc => 'Visualización predeterminada para pantallas grandes';
	@override String get previewEffect => 'Efecto de vista previa';
	@override String get screenWidth => 'Ancho de pantalla';
	@override String get addBreakpoint => 'Añadir punto de corte';
	@override String get editBreakpoint => 'Editar punto de corte';
	@override String get deleteBreakpoint => 'Eliminar punto de corte';
	@override String get screenWidthLabel => 'Ancho de pantalla';
	@override String get screenWidthHint => '600';
	@override String get columnsLabel => 'Columnas';
	@override String get columnsHint => '3';
	@override String get enterWidth => 'Introduzca el ancho';
	@override String get enterValidWidth => 'Introduzca un ancho válido';
	@override String get widthCannotExceed9999 => 'El ancho no puede superar 9999';
	@override String get breakpointAlreadyExists => 'El punto de corte ya existe';
	@override String get enterColumns => 'Introduzca el número de columnas';
	@override String get enterValidColumns => 'Introduzca un número de columnas válido';
	@override String get columnsCannotExceed12 => 'Las columnas no pueden superar 12';
	@override String get breakpointConflict => 'El punto de corte ya existe';
	@override String get confirmResetLayoutSettings => 'Restablecer los ajustes de diseño';
	@override String get confirmResetLayoutSettingsDesc => '¿Seguro que quiere restablecer todos los ajustes de diseño a sus valores predeterminados?\n\nSe restaurará a:\n• Modo automático\n• Configuración de puntos de corte predeterminada';
	@override String get resetToDefaults => 'Restablecer valores predeterminados';
	@override String get confirmDeleteBreakpoint => 'Eliminar punto de corte';
	@override String confirmDeleteBreakpointDesc({required Object width}) => '¿Seguro que quiere eliminar el punto de corte de ${width}px?';
	@override String get noCustomBreakpoints => 'No hay puntos de corte personalizados; se usan las columnas predeterminadas';
	@override String get breakpointRange => 'Intervalo del punto de corte';
	@override String breakpointRangeDesc({required Object range}) => '${range}px';
	@override String breakpointRangeDescFirst({required Object width}) => '≤${width}px';
	@override String breakpointRangeDescMiddle({required Object start, required Object end}) => '${start}-${end}px';
	@override String get edit => 'Editar';
	@override String get delete => 'Eliminar';
	@override String get cancel => 'Cancelar';
	@override String get save => 'Guardar';
}

// Path: mediaPlayer
class _TranslationsMediaPlayerEs extends TranslationsMediaPlayerEn {
	_TranslationsMediaPlayerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get videoPlayerError => 'Error del reproductor de vídeo';
	@override String get videoLoadFailed => 'No se pudo cargar el vídeo';
	@override String get videoCodecNotSupported => 'Códec de vídeo no compatible';
	@override String get networkConnectionIssue => 'Problema de conexión de red';
	@override String get insufficientPermission => 'Permisos insuficientes';
	@override String get unsupportedVideoFormat => 'Formato de vídeo no compatible';
	@override String get retry => 'Reintentar';
	@override String get externalPlayer => 'Reproductor externo';
	@override String get detailedErrorInfo => 'Información detallada del error';
	@override String get format => 'Formato';
	@override String get suggestion => 'Sugerencia';
	@override String get androidWebmCompatibilityIssue => 'Los dispositivos Android tienen una compatibilidad limitada con el formato WEBM. Se recomienda usar un reproductor externo o descargar una aplicación de reproducción compatible con WEBM';
	@override String get currentDeviceCodecNotSupported => 'El dispositivo actual no admite el códec de este formato de vídeo';
	@override String get checkNetworkConnection => 'Compruebe su conexión de red e inténtelo de nuevo';
	@override String get appMayLackMediaPermission => 'Es posible que la aplicación no tenga los permisos necesarios para la reproducción multimedia';
	@override String get tryOtherVideoPlayer => 'Pruebe con otros reproductores de vídeo';
	@override String get unrecognizedVideoFormat => 'Archivo de vídeo no reconocido';
	@override String get unrecognizedVideoFormatSuggestion => 'Es posible que el enlace haya caducado o que la respuesta no fuera un vídeo. Inténtelo de nuevo o ábralo con otra aplicación.';
	@override String get accessDenied => 'El servidor rechazó esta solicitud (403)';
	@override String get accessDeniedSuggestion => 'Es muy probable que el enlace de reproducción haya caducado. Pulse Reintentar para obtenerlo de nuevo o ábralo con otra aplicación.';
	@override String get mute => 'Silenciar';
	@override String get unmute => 'Activar sonido';
	@override String get video => 'VÍDEO';
	@override String get serverSelector => 'Selección de servidor CDN';
	@override String get serverSelectorDescription => 'Seleccione el servidor con la latencia más baja para obtener la mejor experiencia de reproducción';
	@override String get retestSpeed => 'Volver a medir la velocidad';
	@override String get waitingForSpeedTest => 'En espera de la prueba de velocidad';
	@override String get testingSpeed => 'Midiendo la velocidad...';
	@override String get testFailed => 'Prueba fallida';
	@override String get loadingServerList => 'Cargando la lista de servidores...';
	@override String get noAvailableServers => 'No hay servidores disponibles';
	@override String get refreshServerList => 'Actualizar la lista de servidores';
	@override String get cannotGetSource => 'No se puede obtener la fuente del vídeo actual';
	@override String switchedToServer({required Object serverName}) => 'Se cambió al servidor: ${serverName}';
	@override String serverCount({required Object count}) => '${count} servidores en total';
	@override String statusCode({required Object code}) => 'Código de estado: ${code}';
	@override String get connectionFailed => 'No se pudo conectar';
	@override String get connectionTimeout => 'Se agotó el tiempo de conexión';
	@override String get networkError => 'Error de red';
	@override String get sslError => 'Error de certificado SSL';
	@override String get testCompleted => 'Prueba completada';
	@override String get local => 'Local';
	@override String get unknown => 'Desconocido';
	@override String get localVideoPathEmpty => 'La ruta del vídeo local está vacía';
	@override String localVideoFileNotExists({required Object path}) => 'El archivo de vídeo local no existe: ${path}';
	@override String unableToPlayLocalVideo({required Object error}) => 'No se puede reproducir el vídeo local: ${error}';
	@override String unableToPlayNasVideo({required Object error}) => 'Unable to play the NAS video: ${error}';
	@override String get dropVideoFileHere => 'Suelte aquí un archivo de vídeo para reproducirlo';
	@override String get supportedFormats => 'Formatos compatibles: MP4, MKV, AVI, MOV, WEBM, etc.';
	@override String get noSupportedVideoFile => 'No se encontró ningún archivo de vídeo compatible';
	@override String get retryingOpenVideoLink => 'No se pudo abrir el enlace del vídeo; reintentando';
	@override String decoderOpenFailedWithSuggestion({required Object event}) => 'No se pudo cargar el decodificador: ${event}. Pruebe a cambiar a la decodificación por software en los ajustes del reproductor y vuelva a entrar en la página';
	@override String videoLoadErrorWithDetail({required Object event}) => 'Error al cargar el vídeo: ${event}';
	@override String get playbackFailureDiagnosticsHint => 'Se detectaron fallos de reproducción repetidos. Vaya a Ajustes > Diagnóstico y comentarios para exportar los registros.';
	@override String get openSettingsAction => 'Ver';
	@override late final _TranslationsMediaPlayerNoticeEs notice = _TranslationsMediaPlayerNoticeEs._(_root);
	@override String get imageLoadFailed => 'No se pudo cargar la imagen';
	@override String get unsupportedImageFormat => 'Formato de imagen no compatible';
	@override String get tryOtherViewer => 'Pruebe con otros visores';
}

// Path: diagnostics
class _TranslationsDiagnosticsEs extends TranslationsDiagnosticsEn {
	_TranslationsDiagnosticsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get infoSectionTitle => 'Información de diagnóstico';
	@override String get appVersionLabel => 'Versión de la aplicación';
	@override String memoryUsage({required Object memMB}) => 'Uso de memoria: ${memMB}MB';
	@override String get deviceInfoUnavailable => 'No se pudo obtener la información del dispositivo';
	@override String get secureStorageLabel => 'Almacenamiento seguro';
	@override String get secureStorageHealthy => 'Disponible';
	@override String get secureStorageRecovered => 'Se autorreparó mediante un restablecimiento (se borraron los datos anteriores)';
	@override String get secureStorageUnavailable => 'No disponible (el inicio de sesión se guardó con cifrado alternativo)';
	@override String get secureStoragePlatformOptOut => 'Cifrado local por política de la plataforma (no se usa el llavero del sistema en macOS)';
	@override String get secureStorageDualWrite => ' (protección de escritura doble activada)';
	@override String get schemaHealthLabel => 'Esquema de la base de datos';
	@override String get schemaHealthOk => 'OK';
	@override String get schemaHealthRepairedNow => 'Se reparó mediante la red de seguridad en este inicio (la migración no surtió efecto)';
	@override String get schemaHealthRepairedBefore => 'Ya se reparó antes mediante la red de seguridad';
	@override String get logPolicySectionTitle => 'Política de registros';
	@override String get configServiceUnavailable => 'El servicio de configuración no está inicializado. No se puede ajustar la política de registros.';
	@override String get enableLoggingTitle => 'Activar el registro';
	@override String get enableLoggingSubtitle => 'Desactívelo para dejar de escribir nuevos registros';
	@override String get enableLogPersistenceTitle => 'Activar la persistencia de registros';
	@override String get enableLogPersistenceSubtitle => 'Desactívelo para mantener los registros solo en memoria y dejar de escribir en el disco';
	@override String get minLogLevelTitle => 'Nivel mínimo de registro';
	@override String get minLogLevelSubtitle => 'Los registros por debajo de este nivel se filtrarán';
	@override String get maxFileSizeTitle => 'Límite de tamaño de un solo archivo';
	@override String get maxFileSizeSubtitle => 'Rota al alcanzar el umbral';
	@override String get rotatedFileCountTitle => 'Número de archivos rotados del registro principal';
	@override String get rotatedFileCountSubtitle => 'Número de archivos conservados sin contar el archivo actual';
	@override String get hangFileSizeTitle => 'Límite de tamaño del registro de bloqueos';
	@override String get hangFileSizeSubtitle => 'Controla el crecimiento del archivo hang_events';
	@override String get hangRotatedFileCountTitle => 'Número de archivos rotados del registro de bloqueos';
	@override String get hangRotatedFileCountSubtitle => 'Controla el historial conservado de hang_events';
	@override String get healthSectionTitle => 'Estado de los registros';
	@override String get refreshMetrics => 'Actualizar métricas';
	@override String get toolsSectionTitle => 'Herramientas';
	@override String get privacyNotice => 'Los registros pueden contener información sensible, como datos de la cuenta y parámetros de las solicitudes. No publique los registros completos en incidencias; revíselos primero y envíelos por correo.';
	@override String get exportLogsTitle => 'Exportar registros';
	@override String get exportLogsSubtitle => 'Revise los datos privados antes de enviarlos a los desarrolladores';
	@override String get viewLogsTitle => 'Ver registros';
	@override String get viewLogsSubtitle => 'Consulte los registros de ejecución en tiempo real';
	@override String get copySupportEmailTitle => 'Copiar correo de soporte';
	@override String get reportIssueTitle => 'Informar de un problema';
	@override String get reportIssueSubtitle => 'Indique los pasos para reproducirlo en GitHub (no adjunte los registros completos)';
	@override String get healthSummaryUnavailable => 'Aún no hay datos de estado de los registros';
	@override String get healthMetricsUnavailable => 'Aún no se han recopilado métricas de estado';
	@override String get healthNoRiskIndicators => 'No se detectaron indicadores de riesgo';
	@override late final _TranslationsDiagnosticsHealthAlertEs healthAlert = _TranslationsDiagnosticsHealthAlertEs._(_root);
	@override late final _TranslationsDiagnosticsToastEs toast = _TranslationsDiagnosticsToastEs._(_root);
	@override String get shareSubject => 'Registros de diagnóstico de LoveIwara (contienen datos sensibles; compártalos con cuidado)';
}

// Path: logViewer
class _TranslationsLogViewerEs extends TranslationsLogViewerEn {
	_TranslationsLogViewerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Visor de registros';
	@override String get searchHint => 'Buscar en los registros...';
	@override String get emptyState => 'Sin registros';
	@override String get copiedToClipboard => 'Copiado al portapapeles';
}

// Path: crashRecoveryDialog
class _TranslationsCrashRecoveryDialogEs extends TranslationsCrashRecoveryDialogEn {
	_TranslationsCrashRecoveryDialogEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'La aplicación se cerró de forma inesperada';
	@override String get description => 'Se detectó un cierre anómalo en la última sesión. Exporte los registros de diagnóstico y envíelos por correo al desarrollador para ayudarnos a solucionar el problema.';
	@override String previousVersion({required Object version}) => 'Última versión: ${version}';
	@override String previousStart({required Object time}) => 'Último inicio: ${time}';
	@override String lastException({required Object message}) => 'Última excepción: ${message}';
	@override String get lastHangRecovered => 'La última vez se detectó un bloqueo de la interfaz y se recuperó automáticamente';
	@override String lastHangStalled({required Object stalledMs}) => 'La última vez se detectó un posible bloqueo de la interfaz que duró unos ${stalledMs}ms';
	@override String get exportGuide => 'Vaya a Ajustes > Diagnóstico y comentarios > Exportar registros.';
	@override String get privacyHint => 'Los registros pueden contener datos privados. Revíselos antes de enviarlos por correo a:';
	@override String get issueWarning => 'No adjunte los registros completos en las incidencias públicas de GitHub';
	@override String get acknowledge => 'Entendido';
	@override String get supportEmailCopied => 'Correo copiado';
}

// Path: linkInputDialog
class _TranslationsLinkInputDialogEs extends TranslationsLinkInputDialogEn {
	_TranslationsLinkInputDialogEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Introducir enlace';
	@override String supportedLinksHint({required Object webName}) => 'Permite detectar de forma inteligente varios enlaces de ${webName} y saltar rápidamente a la página correspondiente en la aplicación (separe los enlaces del resto del texto con espacios)';
	@override String inputHint({required Object webName}) => 'Introduzca el enlace de ${webName}';
	@override String get validatorEmptyLink => 'Introduzca un enlace';
	@override String validatorNoIwaraLink({required Object webName}) => 'No se detectó ningún enlace válido de ${webName}';
	@override String get multipleLinksDetected => 'Se detectaron varios enlaces; seleccione uno:';
	@override String notIwaraLink({required Object webName}) => 'No es un enlace válido de ${webName}';
	@override String linkParseError({required Object error}) => 'Error al analizar el enlace: ${error}';
	@override String get unsupportedLinkDialogTitle => 'Enlace no compatible';
	@override String get unsupportedLinkDialogContent => 'Este tipo de enlace no se puede abrir directamente en la aplicación y debe abrirse con un navegador externo.\n\n¿Quiere abrir este enlace en un navegador?';
	@override String get openInBrowser => 'Abrir en el navegador';
	@override String get confirmOpenBrowserDialogTitle => 'Confirmar apertura del navegador';
	@override String get confirmOpenBrowserDialogContent => 'El siguiente enlace está a punto de abrirse en un navegador externo:';
	@override String get confirmContinueBrowserOpen => '¿Seguro que quiere continuar?';
	@override String get browserOpenFailed => 'No se pudo abrir el enlace';
	@override String get unsupportedLink => 'Enlace no compatible';
	@override String get cancel => 'Cancelar';
	@override String get confirm => 'Abrir en el navegador';
}

// Path: log
class _TranslationsLogEs extends TranslationsLogEn {
	_TranslationsLogEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get logManagement => 'Gestión de registros';
	@override String get enableLogPersistence => 'Activar la persistencia de registros';
	@override String get enableLogPersistenceDesc => 'Guarda los registros en la base de datos para su análisis';
	@override String get logDatabaseSizeLimit => 'Límite de tamaño de la base de datos de registros';
	@override String logDatabaseSizeLimitDesc({required Object size}) => 'Actual: ${size}';
	@override String get exportCurrentLogs => 'Exportar los registros actuales';
	@override String get exportCurrentLogsDesc => 'Exporte los registros actuales de la aplicación para ayudar a los desarrolladores a diagnosticar problemas';
	@override String get exportHistoryLogs => 'Exportar registros del historial';
	@override String get exportHistoryLogsDesc => 'Exporte los registros de un intervalo de fechas concreto';
	@override String get exportMergedLogs => 'Exportar registros combinados';
	@override String get exportMergedLogsDesc => 'Exporte los registros combinados de un intervalo de fechas concreto';
	@override String get showLogStats => 'Mostrar estadísticas de registros';
	@override String get logExportSuccess => 'Registros exportados correctamente';
	@override String logExportFailed({required Object error}) => 'No se pudieron exportar los registros: ${error}';
	@override String get showLogStatsDesc => 'Consulte las estadísticas de los distintos tipos de registros';
	@override String logExtractFailed({required Object error}) => 'No se pudieron obtener las estadísticas de los registros: ${error}';
	@override String get clearAllLogs => 'Borrar todos los registros';
	@override String get clearAllLogsDesc => 'Borrar todos los datos de registro';
	@override String get confirmClearAllLogs => 'Confirmar borrado';
	@override String get confirmClearAllLogsDesc => '¿Seguro que quiere borrar todos los datos de registro? Esta operación no se puede deshacer.';
	@override String get clearAllLogsSuccess => 'Registros borrados correctamente';
	@override String clearAllLogsFailed({required Object error}) => 'No se pudieron borrar los registros: ${error}';
	@override String get unableToGetLogSizeInfo => 'No se pudo obtener la información del tamaño de los registros';
	@override String get currentLogSize => 'Tamaño actual del registro:';
	@override String get logCount => 'Número de registros:';
	@override String get logCountUnit => 'registros';
	@override String get logSizeLimit => 'Límite de tamaño de los registros:';
	@override String get usageRate => 'Tasa de uso:';
	@override String get exceedLimit => 'Supera el límite';
	@override String get remaining => 'Restante';
	@override String get currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit => 'Se superó el tamaño del registro; limpie los registros antiguos o aumente el límite de tamaño';
	@override String get currentLogSizeAlmostExceededPleaseCleanOldLogs => 'El tamaño del registro está a punto de superarse; limpie los registros antiguos';
	@override String get cleaningOldLogs => 'Limpiando registros antiguos...';
	@override String get logCleaningCompleted => 'Limpieza de registros completada';
	@override String get logCleaningProcessMayNotBeCompleted => 'Es posible que el proceso de limpieza de registros no se haya completado';
	@override String get cleanExceededLogs => 'Limpiar los registros excedentes';
	@override String get noLogsToExport => 'No hay registros que exportar';
	@override String get exportingLogs => 'Exportando registros...';
	@override String get noHistoryLogsToExport => 'No hay registros del historial que exportar; use la aplicación durante un tiempo primero';
	@override String get selectLogDate => 'Seleccionar fecha del registro';
	@override String get today => 'Hoy';
	@override String get selectMergeRange => 'Seleccionar intervalo para combinar';
	@override String get selectMergeRangeHint => 'Seleccione el intervalo de tiempo de los registros que quiere combinar';
	@override String selectMergeRangeDays({required Object days}) => 'Últimos ${days} días';
	@override String get logStats => 'Estadísticas de registros';
	@override String todayLogs({required Object count}) => 'Registros de hoy: ${count} registros';
	@override String recent7DaysLogs({required Object count}) => 'Registros de los últimos 7 días: ${count} registros';
	@override String totalLogs({required Object count}) => 'Total de registros: ${count} registros';
	@override String get setLogDatabaseSizeLimit => 'Establecer el límite de tamaño de la base de datos de registros';
	@override String currentLogSizeWithSize({required Object size}) => 'Tamaño actual del registro: ${size}';
	@override String get warning => 'Advertencia';
	@override String newSizeLimit({required Object size}) => 'Nuevo límite de tamaño: ${size}';
	@override String get confirmToContinue => 'Confirme para continuar';
	@override String logSizeLimitSetSuccess({required Object size}) => 'Límite de tamaño de los registros establecido en ${size}';
}

// Path: emoji
class _TranslationsEmojiEs extends TranslationsEmojiEn {
	_TranslationsEmojiEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Emoji';
	@override String get size => 'Tamaño';
	@override String get small => 'Pequeño';
	@override String get medium => 'Mediano';
	@override String get large => 'Grande';
	@override String get extraLarge => 'Extragrande';
	@override String get copyEmojiLinkSuccess => 'Enlace del emoji copiado';
	@override String get preview => 'Vista previa del emoji';
	@override String get library => 'Biblioteca de emojis';
	@override String get noEmojis => 'Sin emojis';
	@override String get clickToAddEmojis => 'Pulse el botón de la esquina superior derecha para añadir emojis';
	@override String get addEmojis => 'Añadir emojis';
	@override String get imagePreview => 'Vista previa de la imagen';
	@override String get imageLoadFailed => 'No se pudo cargar la imagen';
	@override String get loading => 'Cargando...';
	@override String get delete => 'Eliminar';
	@override String get close => 'Cerrar';
	@override String get deleteImage => 'Eliminar imagen';
	@override String get confirmDeleteImage => '¿Seguro que quiere eliminar esta imagen?';
	@override String get cancel => 'Cancelar';
	@override String get batchDelete => 'Eliminación por lotes';
	@override String confirmBatchDelete({required Object count}) => '¿Seguro que quiere eliminar las ${count} imágenes seleccionadas? Esta operación no se puede deshacer.';
	@override String get deleteSuccess => 'Eliminado correctamente';
	@override String get addImage => 'Añadir imagen';
	@override String get addImageByUrl => 'Añadir por URL';
	@override String get addImageUrl => 'Añadir URL de imagen';
	@override String get imageUrl => 'URL de la imagen';
	@override String get enterImageUrl => 'Introduzca la URL de la imagen';
	@override String get add => 'Añadir';
	@override String get batchImport => 'Importación por lotes';
	@override String get enterJsonUrlArray => 'Introduzca una matriz de URL en formato JSON:';
	@override String get formatExample => 'Ejemplo de formato:\n["url1", "url2", "url3"]';
	@override String get pasteJsonUrlArray => 'Pegue una matriz de URL en formato JSON';
	@override String get import => 'Importar';
	@override String importSuccess({required Object count}) => 'Se importaron ${count} imágenes correctamente';
	@override String get jsonFormatError => 'Error de formato JSON; revise lo introducido';
	@override String get createGroup => 'Crear grupo de emojis';
	@override String get groupName => 'Nombre del grupo';
	@override String get enterGroupName => 'Introduzca el nombre del grupo';
	@override String get create => 'Crear';
	@override String get editGroupName => 'Editar el nombre del grupo';
	@override String get save => 'Guardar';
	@override String get deleteGroup => 'Eliminar grupo';
	@override String get confirmDeleteGroup => '¿Seguro que quiere eliminar este grupo de emojis? También se eliminarán todas las imágenes del grupo.';
	@override String imageCount({required Object count}) => '${count} imágenes';
	@override String get selectEmoji => 'Seleccionar emoji';
	@override String get noEmojisInGroup => 'No hay emojis en este grupo';
	@override String get goToSettingsToAddEmojis => 'Vaya a los ajustes para añadir emojis';
	@override String get emojiManagement => 'Gestión de emojis';
	@override String get manageEmojiGroupsAndImages => 'Gestione grupos e imágenes de emojis';
	@override String get uploadLocalImages => 'Subir imágenes locales';
	@override String get uploadingImages => 'Subiendo imágenes';
	@override String uploadingImagesProgress({required Object count}) => 'Subiendo ${count} imágenes; espere, por favor...';
	@override String get doNotCloseDialog => 'No cierre este cuadro de diálogo';
	@override String uploadSuccess({required Object count}) => 'Se subieron ${count} imágenes correctamente';
	@override String uploadFailed({required Object count}) => 'Fallaron ${count}';
	@override String get uploadFailedMessage => 'No se pudieron subir las imágenes; compruebe la conexión de red o el formato del archivo';
	@override String uploadErrorMessage({required Object error}) => 'Se produjo un error durante la carga: ${error}';
}

// Path: searchFilter
class _TranslationsSearchFilterEs extends TranslationsSearchFilterEn {
	_TranslationsSearchFilterEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get selectField => 'Seleccionar campo';
	@override String get add => 'Añadir';
	@override String get clear => 'Borrar';
	@override String get clearAll => 'Borrar todo';
	@override String get generatedQuery => 'Consulta generada';
	@override String get copyToClipboard => 'Copiar al portapapeles';
	@override String get copied => 'Copiado';
	@override String filterCount({required Object count}) => '${count} filtros';
	@override String get filterSettings => 'Configuración de filtros';
	@override String get field => 'Campo';
	@override String get operator => 'Operador';
	@override String get language => 'Idioma';
	@override String get value => 'Valor';
	@override String get dateRange => 'Rango de fechas';
	@override String get numberRange => 'Rango numérico';
	@override String get from => 'Desde';
	@override String get to => 'Hasta';
	@override String get date => 'Fecha';
	@override String get number => 'Número';
	@override String get boolean => 'Booleano';
	@override String get tags => 'Etiquetas';
	@override String get select => 'Seleccionar';
	@override String get clickToSelectDate => 'Toque para seleccionar la fecha';
	@override String get pleaseEnterValidNumber => 'Introduzca un número válido';
	@override String get pleaseEnterValidDate => 'Introduzca un formato de fecha válido (YYYY-MM-DD)';
	@override String get startValueMustBeLessThanEndValue => 'El valor inicial debe ser menor que el valor final';
	@override String get startDateMustBeBeforeEndDate => 'La fecha de inicio debe ser anterior a la fecha de fin';
	@override String get pleaseFillStartValue => 'Complete el valor inicial';
	@override String get pleaseFillEndValue => 'Complete el valor final';
	@override String get rangeValueFormatError => 'Error de formato del valor del rango';
	@override String get contains => 'Contiene';
	@override String get equals => 'Igual a';
	@override String get notEquals => 'No igual a';
	@override String get greaterThan => '>';
	@override String get greaterEqual => '>=';
	@override String get lessThan => '<';
	@override String get lessEqual => '<=';
	@override String get range => 'Rango';
	@override String get kIn => 'Contiene alguno';
	@override String get notIn => 'No contiene ninguno';
	@override String get username => 'Nombre de usuario';
	@override String get nickname => 'Apodo';
	@override String get registrationDate => 'Fecha de registro';
	@override String get description => 'Descripción';
	@override String get title => 'Título';
	@override String get body => 'Cuerpo';
	@override String get author => 'Autor';
	@override String get publishDate => 'Fecha de publicación';
	@override String get private => 'Privado';
	@override String get duration => 'Duración (segundos)';
	@override String get likes => 'Me gusta';
	@override String get views => 'Visualizaciones';
	@override String get comments => 'Comentarios';
	@override String get rating => 'Clasificación';
	@override String get imageCount => 'Cantidad de imágenes';
	@override String get videoCount => 'Cantidad de videos';
	@override String get createDate => 'Fecha de creación';
	@override String get content => 'Contenido';
	@override String get all => 'Todo';
	@override String get adult => 'Adulto';
	@override String get general => 'General';
	@override String get yes => 'Sí';
	@override String get no => 'No';
	@override String get users => 'Usuarios';
	@override String get videos => 'Vídeos';
	@override String get images => 'Imágenes';
	@override String get posts => 'Publicaciones';
	@override String get forumThreads => 'Hilos del foro';
	@override String get forumPosts => 'Publicaciones del foro';
	@override String get playlists => 'Listas de reproducción';
	@override late final _TranslationsSearchFilterSortTypesEs sortTypes = _TranslationsSearchFilterSortTypesEs._(_root);
	@override String get drawerSubtitle => 'Los cambios se aplican al instante';
}

// Path: firstTimeSetup
class _TranslationsFirstTimeSetupEs extends TranslationsFirstTimeSetupEn {
	_TranslationsFirstTimeSetupEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFirstTimeSetupWelcomeEs welcome = _TranslationsFirstTimeSetupWelcomeEs._(_root);
	@override late final _TranslationsFirstTimeSetupBasicEs basic = _TranslationsFirstTimeSetupBasicEs._(_root);
	@override late final _TranslationsFirstTimeSetupNetworkEs network = _TranslationsFirstTimeSetupNetworkEs._(_root);
	@override late final _TranslationsFirstTimeSetupThemeEs theme = _TranslationsFirstTimeSetupThemeEs._(_root);
	@override late final _TranslationsFirstTimeSetupPlayerEs player = _TranslationsFirstTimeSetupPlayerEs._(_root);
	@override late final _TranslationsFirstTimeSetupSpatialEs spatial = _TranslationsFirstTimeSetupSpatialEs._(_root);
	@override late final _TranslationsFirstTimeSetupCompletionEs completion = _TranslationsFirstTimeSetupCompletionEs._(_root);
	@override late final _TranslationsFirstTimeSetupCommonEs common = _TranslationsFirstTimeSetupCommonEs._(_root);
}

// Path: proxyHelper
class _TranslationsProxyHelperEs extends TranslationsProxyHelperEn {
	_TranslationsProxyHelperEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get systemProxyDetected => 'Proxy del sistema detectado';
	@override String get copied => 'Copiado';
	@override String get copy => 'Copiar';
}

// Path: tagSelector
class _TranslationsTagSelectorEs extends TranslationsTagSelectorEn {
	_TranslationsTagSelectorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get selectTags => 'Seleccionar etiquetas';
	@override String get clickToSelectTags => 'Toque para seleccionar etiquetas';
	@override String get addTag => 'Añadir etiqueta';
	@override String get removeTag => 'Quitar etiqueta';
	@override String get deleteTag => 'Eliminar etiqueta';
	@override String get usageInstructions => 'Primero añada etiquetas y luego pulse para seleccionar entre las etiquetas existentes';
	@override String get usageInstructionsTooltip => 'Instrucciones de uso';
	@override String get addTagTooltip => 'Añadir etiqueta';
	@override String get removeTagTooltip => 'Quitar etiqueta';
	@override String get cancelSelection => 'Cancelar selección';
	@override String get selectAll => 'Seleccionar todo';
	@override String get cancelSelectAll => 'Anular la selección de todo';
	@override String get delete => 'Eliminar';
}

// Path: anime4k
class _TranslationsAnime4kEs extends TranslationsAnime4kEn {
	_TranslationsAnime4kEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get realTimeVideoUpscalingAndDenoising => 'Escalado y eliminación de ruido de vídeo en tiempo real, mejorando la calidad del vídeo de animación';
	@override String get settings => 'Ajustes de Anime4K';
	@override String get preset => 'Preajuste de Anime4K';
	@override String get disable => 'Desactivar Anime4K';
	@override String get disableDescription => 'Desactivar los efectos de mejora de vídeo';
	@override String get highQualityPresets => 'Preajustes de alta calidad';
	@override String get fastPresets => 'Preajustes rápidos';
	@override String get litePresets => 'Preajustes ligeros';
	@override String get moreLitePresets => 'Preajustes más ligeros';
	@override String get customPresets => 'Preajustes personalizados';
	@override late final _TranslationsAnime4kPresetGroupsEs presetGroups = _TranslationsAnime4kPresetGroupsEs._(_root);
	@override late final _TranslationsAnime4kPresetDescriptionsEs presetDescriptions = _TranslationsAnime4kPresetDescriptionsEs._(_root);
	@override late final _TranslationsAnime4kPresetNamesEs presetNames = _TranslationsAnime4kPresetNamesEs._(_root);
	@override String get performanceTip => '💡 Sugerencia: elija los preajustes adecuados según el rendimiento de su dispositivo. En dispositivos de gama baja se recomienda usar preajustes ligeros.';
	@override String get compatibilityTip => '⚠️ Algunas GPU móviles (p. ej. Kirin 980 / Mali-G76) no pueden renderizar ningún sombreador personalizado. Si la imagen se pone negra mientras el audio sigue reproduciéndose, desactive Anime4K aquí.';
	@override String get autoDisabledOnRenderFailure => 'La GPU de su dispositivo no pudo renderizar el sombreador de Anime4K, por lo que se desactivó automáticamente.';
}

// Path: siteMode
class _TranslationsSiteModeEs extends TranslationsSiteModeEn {
	_TranslationsSiteModeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Modo de sitio';
	@override String get mainSite => 'Principal';
	@override String get aiSite => 'AI';
	@override String drawerSubtitle({required Object currentSite, required Object nextSite}) => 'Actual: ${currentSite} · Toque para cambiar a ${nextSite}';
	@override String get dialogTitle => 'Cambiar el modo de sitio';
	@override String get dialogDescription => 'El cambio actualizará toda la aplicación y restablecerá las listas y el estado de página cargados previamente.';
	@override String get chooseLinkTargetTitle => 'Elegir sitio de destino';
	@override String get chooseLinkTargetDescription => 'Este enlace no incluye un dominio. Elija si desea abrirlo en Principal o en AI.';
	@override String get chooseLinkTargetHint => 'Una vez abierta, esta página y sus solicitudes de detalle posteriores seguirán usando el sitio seleccionado.';
	@override String get alreadyUsing => 'Ya está usando este modo de sitio.';
	@override String openInSite({required Object site}) => 'Abrir en ${site}';
	@override String confirmUsing({required Object site}) => 'Tras confirmar, las solicitudes futuras usarán el modo ${site}.';
	@override String switched({required Object site}) => 'Se cambió a ${site}. La aplicación se ha actualizado.';
}

// Path: savedSearchConfig
class _TranslationsSavedSearchConfigEs extends TranslationsSavedSearchConfigEn {
	_TranslationsSavedSearchConfigEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filtros guardados';
	@override String get empty => 'Aún no hay filtros guardados';
	@override String get saveTooltip => 'Guardar filtro actual';
	@override String get namePromptTitle => 'Guardar filtro';
	@override String get nameLabel => 'Nombre';
	@override String get nameHint => 'Introduzca un nombre';
	@override String get saveSuccess => 'Filtro guardado';
	@override String get deleteSuccess => 'Filtro eliminado';
	@override String get addCurrent => 'Guardar filtro actual';
	@override String get reorderHint => 'Mantenga pulsado y arrastre para reordenar';
	@override String get rename => 'Renombrar';
	@override String get unnamed => 'Sin nombre';
	@override String get noConditions => 'Todo el contenido (sin filtro)';
	@override String tagsCount({required Object count}) => '${count} etiquetas';
}

// Path: savedSearch
class _TranslationsSavedSearchEs extends TranslationsSavedSearchEn {
	_TranslationsSavedSearchEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Búsquedas guardadas';
	@override String get empty => 'Aún no hay búsquedas guardadas';
	@override String get saveTooltip => 'Guardar búsqueda actual';
	@override String get namePromptTitle => 'Guardar búsqueda';
	@override String get nameLabel => 'Nombre';
	@override String get nameHint => 'Introduzca un nombre';
	@override String get saveSuccess => 'Búsqueda guardada';
	@override String get deleteSuccess => 'Búsqueda eliminada';
	@override String get addCurrent => 'Guardar búsqueda actual';
	@override String get reorderHint => 'Mantenga pulsado y arrastre para reordenar';
	@override String get rename => 'Renombrar';
	@override String get noKeyword => '(Sin palabra clave)';
	@override String filtersCount({required Object count}) => '${count} filtros';
}

// Path: defaultBlacklistReminder
class _TranslationsDefaultBlacklistReminderEs extends TranslationsDefaultBlacklistReminderEn {
	_TranslationsDefaultBlacklistReminderEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Se detectó la lista negra de etiquetas predeterminada';
	@override String get content => 'Su cuenta sigue usando la lista negra de etiquetas que el sitio web aplica automáticamente a cada cuenta nueva. ¿Quiere revisarla y gestionarla?';
	@override String get goManage => 'Gestionar';
	@override String get dismiss => 'Ahora no';
}

// Path: colorVisionAssist
class _TranslationsColorVisionAssistEs extends TranslationsColorVisionAssistEn {
	_TranslationsColorVisionAssistEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Asistencia de visión del color';
	@override String get description => 'Corrige los colores del vídeo para personas con deficiencia en la visión del color; puede usarse junto con Anime4K';
	@override String get galleryDescription => 'Corrige los colores de las imágenes de la galería para personas con deficiencia en la visión del color (independiente del interruptor del reproductor)';
	@override String get galleryDescriptionSpatial => 'Corrige los colores de las imágenes de la galería para personas con deficiencia en la visión del color. Solo se aplica al visor 2D dentro de este panel; las imágenes de la pantalla espacial se renderizan de forma nativa y no pasan por este filtro';
	@override String get disable => 'Desactivado';
	@override String get disableDescription => 'Sin corrección de color';
	@override String get protanopia => 'Asistencia para el rojo (protanopía)';
	@override String get protanopiaDescription => 'Para la protanopía: dificultad para distinguir el rojo';
	@override String get deuteranopia => 'Asistencia para el verde (deuteranopía)';
	@override String get deuteranopiaDescription => 'Para la deuteranopía: dificultad para distinguir el verde';
	@override String get tritanopia => 'Asistencia para el azul (tritanopía)';
	@override String get tritanopiaDescription => 'Para la tritanopía: dificultad para distinguir el azul y el amarillo';
	@override String appliedToast({required Object filterName}) => '${filterName} aplicado, surte efecto de inmediato';
	@override String get disabledToast => 'Asistencia de visión del color desactivada';
}

// Path: externalPlayer
class _TranslationsExternalPlayerEs extends TranslationsExternalPlayerEn {
	_TranslationsExternalPlayerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Abrir con otra aplicación';
	@override String get description => 'Pase el vídeo actual a otro reproductor de este dispositivo, como Skybox o Pigasus en un visor VR, o MX Player y VLC en un teléfono';
	@override String get openWithOtherApp => 'Elegir otra aplicación';
	@override String get openWithOtherAppDescription => 'Muestre el selector del sistema y elija un reproductor';
	@override String get openWithSystemPlayer => 'Abrir en el reproductor predeterminado';
	@override String get openWithSystemPlayerDescription => 'Páselo a la aplicación de vídeo predeterminada del sistema';
	@override String get copyLink => 'Copiar enlace del vídeo';
	@override String get copyLinkDescription => 'Para reproductores que solo permiten pegar una URL, como Skybox o DeoVR';
	@override String get linkCopied => 'Enlace del vídeo copiado';
	@override String get sourceLocal => 'Archivo local';
	@override String get sourceOnline => 'Enlace directo';
	@override String sourceOnlineWithQuality({required Object quality}) => 'Enlace directo · ${quality}';
	@override String get onlineLinkExpiryHint => 'Los enlaces directos caducan, por lo que un reproductor externo puede detenerse a mitad. Descargarlo primero es la opción fiable.';
	@override String get vrPlayerHint => 'Si su reproductor de VR no aparece en el selector, use Copiar enlace del vídeo y péguelo en ese reproductor.';
	@override String get noHandler => 'Ninguna aplicación de este dispositivo puede abrir el vídeo';
	@override String handoffFailed({required Object message}) => 'No se pudo pasar: ${message}';
	@override String get handoffFailedUnknown => 'No se pudo pasar al reproductor externo';
	@override String get sourceUnavailable => 'No se pudo obtener la dirección del vídeo actual; inténtelo de nuevo';
	@override String get localFileMissing => 'El archivo local ya no existe';
	@override String get handedOff => 'Se pasó al reproductor externo';
	@override String get desktopSectionTitle => 'Reproductores externos';
	@override String get managePlayers => 'Gestionar reproductores externos';
	@override String get managePlayersDescWindows => 'Los reproductores de PCVR como HereSphere, DeoVR y Whirligig no son la aplicación predeterminada del sistema. Apunte esto a su .exe y podrá pasar el vídeo actual directamente desde el reproductor.';
	@override String get managePlayersDescMac => 'Apunte esto a reproductores como IINA, VLC o mpv y podrá pasar el vídeo actual directamente desde el reproductor.';
	@override String get managePlayersDescLinux => 'Apunte esto a reproductores como mpv, VLC o Celluloid y podrá pasar el vídeo actual directamente desde el reproductor.';
	@override String get pickExecutableHintWindows => 'Elija el .exe principal dentro de la carpeta de instalación del reproductor, p. ej. HereSphere.exe o vlc.exe. Los accesos directos del escritorio (.lnk) no funcionarán.';
	@override String get pickExecutableHintMac => 'Elija el .app del reproductor en Aplicaciones, p. ej. IINA.app; el ejecutable real que contiene se localizará por usted.';
	@override String get pickExecutableHintLinux => 'Elija el ejecutable del reproductor, p. ej. /usr/bin/mpv. Ejecutar which mpv le indicará dónde se encuentra.';
	@override String emptyStateGuide({required Object examples}) => 'Una vez configurado, aparecerá como una entrada propia en Abrir con otra aplicación, en la página del reproductor. Los más comunes: ${examples}';
	@override String get detectNothingFoundGuide => 'No se encontraron reproductores instalados. Las carpetas de instalación personalizadas y las versiones portátiles no se pueden detectar; use Añadir reproductor para indicar uno manualmente.';
	@override String get detectNothingNew => 'No se encontraron reproductores nuevos; todo lo instalado ya está en la lista';
	@override String get detectFailed => 'La detección falló; use Añadir reproductor para indicar uno manualmente';
	@override String get advancedOptions => 'Avanzado';
	@override String get playerNameHint => 'Déjelo vacío para usar el nombre del archivo';
	@override String get executablePathRequired => 'Elija primero el ejecutable del reproductor';
	@override String playerCount({required Object count}) => '${count} configurados';
	@override String get noPlayerConfigured => 'Aún no hay ningún reproductor externo configurado';
	@override String get autoDetect => 'Detección automática';
	@override String get detecting => 'Detectando…';
	@override String detectFound({required Object count}) => 'Se encontraron ${count} reproductor(es)';
	@override String get detectNothingFound => 'No se encontraron reproductores nuevos; añada uno manualmente';
	@override String get autoDetectedTag => 'detectado';
	@override String get addPlayer => 'Añadir reproductor';
	@override String get editPlayer => 'Editar reproductor';
	@override String get playerName => 'Nombre';
	@override String get executablePath => 'Ejecutable';
	@override String get browse => 'Examinar';
	@override String get argumentTemplate => 'Argumentos de inicio';
	@override String get argumentTemplateHint => 'Use {input} para la ruta o la URL del vídeo. Déjelo vacío para pasarla como único argumento.';
	@override String get nameAndPathRequired => 'Se requieren tanto el nombre como el ejecutable';
	@override String get testLaunch => 'Probar inicio';
	@override String get testLaunched => 'Reproductor iniciado';
	@override String get testFailed => 'No se pudo iniciar; compruebe la ruta del ejecutable';
	@override String get executableMissing => 'No se encontró el ejecutable';
	@override String openWithNamed({required Object name}) => 'Abrir en ${name}';
	@override String get managePlayersEntry => 'Gestionar reproductores externos…';
}

// Path: watchLater
class _TranslationsWatchLaterEs extends TranslationsWatchLaterEn {
	_TranslationsWatchLaterEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ver más tarde';
	@override String get addToWatchLater => 'Ver más tarde';
	@override String get removeFromWatchLater => 'Quitar de Ver más tarde';
	@override String get addedToWatchLater => 'Añadido a Ver más tarde';
	@override String get alreadyInWatchLater => 'Ya está en Ver más tarde';
	@override String get removedFromWatchLater => 'Quitado de Ver más tarde';
	@override String removedCount({required Object count}) => 'Se quitaron ${count} elementos';
	@override String get viewWatchLaterList => 'Ver la lista';
	@override String get addFailed => 'No se pudo añadir a Ver más tarde';
	@override String get invalidItem => 'No disponible';
	@override String get clearWatched => 'Borrar lo visto';
	@override String watchedCleared({required Object count}) => 'Se borraron ${count} elementos vistos';
	@override String get noWatchedToClear => 'No hay nada visto que borrar';
	@override String get emptyVideo => 'Aún no hay videos en Ver más tarde';
	@override String get emptyGallery => 'Aún no hay galerías en Ver más tarde';
	@override String get filterAll => 'Todo';
	@override String get filterUnwatched => 'No visto';
	@override String get sortRecentlyAdded => 'Añadidos recientemente';
	@override String get sortEarliestAdded => 'Añadidos primero';
	@override String get watched => 'Visto';
	@override String get playlistLoadFailed => 'No se pudieron cargar las listas de reproducción';
	@override String get noPlaylists => 'Aún no hay listas de reproducción';
	@override String get undo => 'Deshacer';
	@override String get clearWatchedConfirm => '¿Borrar todo lo que ya ha visto en esta pestaña? Esta acción no se puede deshacer.';
	@override String get emptyUnwatchedVideo => 'No queda nada por ver aquí';
	@override String get emptyUnwatchedGallery => 'No queda nada por ver aquí';
	@override String get queueLoadFailed => 'No se pudo cargar; toque para reintentar';
}

// Path: mediaMenu
class _TranslationsMediaMenuEs extends TranslationsMediaMenuEn {
	_TranslationsMediaMenuEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get like => 'Me gusta';
	@override String get unlike => 'Ya no me gusta';
	@override String get viewAuthor => 'Ver el autor';
	@override String inFolders({required Object count}) => '${count} carpetas';
	@override String inPlaylists({required Object count}) => '${count} listas de reproducción';
	@override String get downloaded => 'Descargado';
}

// Path: mediaPreview
class _TranslationsMediaPreviewEs extends TranslationsMediaPreviewEn {
	_TranslationsMediaPreviewEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get preview => 'Vista previa';
	@override String get openDetail => 'Abrir';
	@override String get moreActions => 'Más acciones';
	@override String get previousImage => 'Imagen anterior';
	@override String get nextImage => 'Imagen siguiente';
}

// Path: playbackQueue
class _TranslationsPlaybackQueueEs extends TranslationsPlaybackQueueEn {
	_TranslationsPlaybackQueueEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String galleryImageCount({required Object count}) => '${count} imágenes';
	@override String get upNext => 'A continuación';
	@override String get sourceTab => 'Origen';
	@override String get emptyQueue => 'Nada reproducible en esta cola';
	@override String get emptyGalleryQueue => 'No hay galerías en esta cola';
	@override String get nowPlaying => 'Reproduciendo ahora';
	@override String get myPlaylists => 'Mis listas de reproducción';
	@override String get authorPlaylists => 'Listas de reproducción del autor';
	@override String get openQueue => 'A continuación';
	@override String get continueInQueue => 'Seguir reproduciendo desde la cola actual';
	@override String get continueInQueueSubtitle => 'Reproduce el siguiente elemento automáticamente; desactiva "repetir al finalizar"';
	@override String get repeatDisabledByQueue => 'Desactivado mientras "seguir reproduciendo desde la cola actual" está activado';
	@override String get playNext => 'Reproducir siguiente';
	@override String get queueEnded => 'Este es el último elemento de la cola';
	@override String get playNextHint => 'Toque para reproducir el siguiente elemento; mantenga pulsado para abrir "A continuación"';
	@override String get authorVideos => 'Videos del autor';
	@override String get authorGalleries => 'Galerías del autor';
	@override String get favoriteFolders => 'Carpetas favoritas';
	@override String get localFiles => 'En este dispositivo';
	@override String get currentFolder => 'Carpeta de este archivo';
	@override String get playThisFolder => 'Ver la cola de videos de esta carpeta';
	@override String get browseThisFolder => 'Ver la cola de galerías de esta carpeta';
	@override String get downloads => 'Descargados';
	@override String get otherPlaylists => 'Listas de reproducción de otros usuarios';
	@override String get nothingHere => 'Nada por aquí';
}

// Path: vrFormat
class _TranslationsVrFormatEs extends TranslationsVrFormatEn {
	_TranslationsVrFormatEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get playInSpace => 'Reproducir en el reproductor espacial';
	@override String get handingOff => 'Pasando al espacio…';
	@override String get title => 'Modo de reproducción';
	@override String get spatialSectionTitle => 'Reproducción espacial';
	@override String get spatialSectionDesc => 'En el visor, un video no se dibuja dentro de este panel: el reproductor espacial lo coloca en una pantalla de la habitación.';
	@override String get spatialPanelEntry => 'Panel de control espacial';
	@override String get spatialPanelEntryDesc => 'La distancia, el tamaño y la curvatura de la pantalla, el entorno de fondo, además de la velocidad, la repetición y el ocultado automático se encuentran en el panel de control espacial.';
	@override String get spatialGuideEntry => 'Guía de controles del visor';
	@override String get spatialGuideEntryDesc => 'Botones del controlador, agarrar la pantalla, búsqueda con el joystick y pasar páginas';
	@override String get spatialFlatOmitted => 'Los gestos táctiles, la mejora de imagen y los parámetros de audio/video solo se aplican al reproductor 2D; el reproductor espacial usa un motor diferente, por lo que no se enumeran aquí.';
	@override String get spatialGallerySectionTitle => 'Galería espacial';
	@override String get spatialGalleryPanelDesc => 'El intervalo de la presentación, la repetición de un solo clip y la curvatura de la pantalla se ajustan en el panel de control espacial.';
	@override String get autoEnterGallery => 'Abrir las imágenes de la galería en la galería espacial';
	@override String get autoEnterGalleryDesc => 'En Quest, tocar una imagen abre toda la galería en la pantalla flotante con tira de película, presentación y paginación con el controlador, en lugar del visor dentro de este panel.';
	@override String get panelSettings => 'Panel y fondo';
	@override String get panelSettingsDesc => 'A qué distancia se sitúa este panel de la aplicación y cuánto de su habitación se ve detrás';
	@override String get panelDistance => 'Distancia del panel';
	@override String panelDistanceValue({required Object meters}) => '${meters} m';
	@override String get panelResetPlacement => 'Restablecer la ubicación';
	@override String get panelResetBackground => 'Restablecer al valor predeterminado';
	@override String get panelBackground => 'Transparencia del fondo';
	@override String get panelBackgroundHint => '0 %: entorno negro · 100 %: su habitación real, con luz ambiental';
	@override String get panelUnavailable => 'El panel no está en su sitio ahora mismo; inténtelo de nuevo en un momento';
	@override String get desc => 'Elija la geometría con la que debe reproducirse este video. El sitio no proporciona esta información, por lo que la detección automática solo elige un punto de partida: su elección manda.';
	@override String get sectionFlat => 'Plano';
	@override String get sectionStereo => '3D plano';
	@override String get sectionPanorama => 'Panorama VR';
	@override String get flat => 'Video normal';
	@override String get flatDesc => 'Reproducir tal cual, sin reasignación';
	@override String get flatSideBySide => '3D lado a lado';
	@override String get flatSideBySideDesc => 'Un ojo por mitad, izquierda y derecha; muestra el ojo izquierdo y restaura su relación de aspecto';
	@override String get flatTopBottom => '3D arriba y abajo';
	@override String get flatTopBottomDesc => 'Un ojo por mitad, arriba y abajo; muestra la mitad superior y restaura su relación de aspecto';
	@override String get vr180SideBySide => 'VR180 lado a lado';
	@override String get vr180SideBySideDesc => 'Panorama hemisférico con ambos ojos; la fuente VR más común';
	@override String get vr180Mono => 'VR180 mono';
	@override String get vr180MonoDesc => 'Panorama hemisférico, un solo ojo por fotograma';
	@override String get vr360Mono => 'VR360 mono';
	@override String get vr360MonoDesc => 'Panorama envolvente completo, un solo ojo por fotograma';
	@override String get vr360TopBottom => 'VR360 arriba y abajo';
	@override String get vr360TopBottomDesc => 'Panorama envolvente completo con ambos ojos apilados';
	@override String get resetView => 'Restablecer la vista';
	@override String get resetViewDesc => 'Devolver la dirección de mirada y el campo de visión al frente';
	@override String get resetToAuto => 'Volver a la detección automática';
	@override String get resetToAutoDesc => 'Olvidar la elección manual para este video y dejar que la detección decida de nuevo';
	@override String get manualBadge => 'Establecido manualmente';
	@override String get panoramaHint => 'Arrastre la imagen para mirar alrededor; pellizque para cambiar el campo de visión';
	@override String get panoramaGestureNotice => 'Mientras mira alrededor, arrastrar gira la vista; use la barra de progreso para buscar';
	@override String get shaderUnsupported => 'Este dispositivo no puede renderizar el panorama en vivo; se muestra un solo ojo en su lugar';
	@override String get handoffTooltip => 'Reproducir de otra forma';
	@override String get suggestedBadge => 'Sugerido';
	@override String suggestedEntryDesc({required Object format}) => 'Parece ${format}: toque para cambiar';
	@override String suggestionTitle({required Object format}) => 'Puede que este sea un video VR (${format})';
	@override String get suggestionTitleShort => 'Puede que este sea un video VR';
	@override String get suggestionAction => 'Reproducir como VR';
	@override String get suggestionDismiss => 'Descartar';
}

// Path: localMedia
class _TranslationsLocalMediaEs extends TranslationsLocalMediaEn {
	_TranslationsLocalMediaEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLocalMediaBrowseEs browse = _TranslationsLocalMediaBrowseEs._(_root);
	@override String get tabFolders => 'Carpetas';
	@override String get tabFavoriteVideos => 'Favoritos';
	@override String get tabAllVideos => 'Todos los vídeos';
	@override String get tabAllImages => 'Todas las imágenes';
	@override String get tabDownloadedVideos => 'Vídeos descargados';
	@override String get tabDownloadedGalleries => 'Galerías descargadas';
	@override String get title => 'En este dispositivo';
	@override String get sourceOnline => 'Iwara en línea';
	@override String get manageSources => 'Gestionar fuentes';
	@override String get moveToCategory => 'Mover a categoría';
	@override String get manageCategories => 'Gestionar categorías';
	@override String get suggestedFolders => 'Carpetas con vídeos';
	@override String get sortRecentlyAdded => 'Añadidos recientemente';
	@override String get sortRecentlyPlayed => 'Reproducidos recientemente';
	@override String get sortName => 'Nombre';
	@override String get sortDuration => 'Duración';
	@override String get sortSize => 'Tamaño';
	@override String get sortFolder => 'Carpeta';
	@override String get sortRecentlyModified => 'Modificados recientemente';
	@override String get sortCount => 'Cantidad';
	@override String folderCardItemCount({required Object count}) => '${count} imágenes';
	@override String get downloadsSource => 'Descargados';
	@override String get builtInSourceHint => 'Descargados se gestiona automáticamente';
	@override String get filterByCategory => 'Filtrar por categoría';
	@override String get longPressToCategorize => 'Mantenga pulsado para mover a una categoría';
	@override String get uncategorized => 'Sin categoría';
	@override String get setCategoryFailed => 'No se pudo establecer la categoría';
	@override String get categoryUpdated => 'Categoría actualizada';
	@override String get addFolder => 'Añadir carpeta';
	@override String get addDeviceVideos => 'Escanear los vídeos del dispositivo';
	@override String get mediaStoreSourceName => 'Vídeos del dispositivo';
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
	@override late final _TranslationsLocalMediaItemInfoLabelsEs itemInfoLabels = _TranslationsLocalMediaItemInfoLabelsEs._(_root);
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
	@override late final _TranslationsLocalMediaMissingEs missing = _TranslationsLocalMediaMissingEs._(_root);
	@override late final _TranslationsLocalMediaWebdavEs webdav = _TranslationsLocalMediaWebdavEs._(_root);
	@override String get mediaStoreUnavailable => 'El índice multimedia del dispositivo solo está disponible en Android';
	@override String get mediaStorePermissionDenied => 'No se concedió el acceso a los vídeos';
	@override String get rescan => 'Volver a escanear';
	@override String scanning({required Object count}) => 'Escaneando… ${count} encontrados';
	@override String scanFailed({required Object reason}) => 'No se pudo escanear: ${reason}';
	@override String scanTruncated({required Object count}) => 'Esa carpeta es muy grande; solo se añadieron los primeros ${count} archivos.';
	@override String sourceOverlaps({required Object name}) => 'Ya está cubierta por la carpeta "${name}"';
	@override String addedAsPinnedFolder({required Object name, required Object source}) => '"${name}" está dentro de "${source}", así que se añadió a las carpetas fijadas';
	@override String alreadyPinnedFolder({required Object name}) => '"${name}" ya está en las carpetas fijadas';
	@override String sourceAlreadyAdded({required Object name}) => '"${name}" ya se ha añadido';
	@override String sourceContainsExisting({required Object name}) => 'Ya contiene la carpeta añadida "${name}"; aún no se admite añadir su carpeta superior';
	@override String get addSourceFailed => 'No se pudo añadir esa carpeta';
	@override String get fileMissing => 'Ese archivo ya no está en el disco';
	@override String get permissionDenied => 'Acceso a archivos no concedido · toque para concederlo';
	@override String get noVideosFound => 'No hay vídeos en esta carpeta';
	@override String get emptyTitle => 'Añada una carpeta para ver los vídeos que ya están en este dispositivo';
	@override String get emptyPrivacyNote => 'Los archivos solo se leen en este dispositivo. No se sube nada.';
	@override String removeSourceTitle({required Object name}) => '¿Quitar "${name}"?';
	@override String get removeSourceBody => 'Los archivos permanecen en el disco. Solo se quita esta entrada de la biblioteca.';
	@override String get remove => 'Quitar';
	@override String get removeFolder => 'Quitar carpeta';
	@override String get removeFolderSelectTitle => 'Seleccione la carpeta que quiere quitar';
	@override String get longPressToRemove => 'Mantenga pulsado para quitar esta carpeta';
	@override String get clearProgress => 'Borrar el historial de reproducción local';
	@override String clearProgressCount({required Object count}) => '${count} entradas';
	@override String get clearProgressEmpty => 'Aún no hay historial de reproducción local';
	@override String get clearProgressTitle => '¿Borrar el historial de reproducción local?';
	@override String get clearProgressBody => 'Solo se eliminan las posiciones de reproducción y las marcas de visto. Sus archivos y carpetas permanecen exactamente igual.';
	@override String clearProgressDone({required Object count}) => 'Se borraron ${count} entradas del historial de reproducción local';
	@override String get clearAction => 'Borrar';
	@override String get iosManualRescanNotice => 'iOS no detecta automáticamente los archivos nuevos. Deberá volver a escanear manualmente después de añadir o eliminar archivos.';
}

// Path: historyPage
class _TranslationsHistoryPageEs extends TranslationsHistoryPageEn {
	_TranslationsHistoryPageEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get removeFromHistory => 'Quitar del historial';
	@override String get removed => 'Quitado del historial';
	@override String watchedTo({required Object time}) => 'Visto hasta ${time}';
	@override String get finished => 'Visto';
	@override String clearTabTitle({required Object tab}) => 'Borrar «${tab}»';
	@override String clearTabConfirm({required Object tab}) => 'Se eliminará todo el historial de «${tab}», junto con el progreso de reproducción de esos vídeos. No se puede deshacer.';
	@override String get rangeByLastViewed => 'Filtrado por última visualización';
}

// Path: common.pagination
class _TranslationsCommonPaginationEs extends TranslationsCommonPaginationEn {
	_TranslationsCommonPaginationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String totalItems({required Object num}) => 'Total: ${num} elementos';
	@override String get jumpToPage => 'Ir a la página';
	@override String pleaseEnterPageNumber({required Object max}) => 'Introduzca el número de página (1-${max})';
	@override String get pageNumber => 'Número de página';
	@override String get jump => 'Ir';
	@override String invalidPageNumber({required Object max}) => 'Introduzca un número de página válido (1-${max})';
	@override String get invalidInput => 'Introduzca un número de página válido';
	@override String get waterfall => 'Cascada';
	@override String get pagination => 'Paginación';
}

// Path: errors.network
class _TranslationsErrorsNetworkEs extends TranslationsErrorsNetworkEn {
	_TranslationsErrorsNetworkEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get basicPrefix => 'Error de red: ';
	@override String get failedToConnectToServer => 'No se pudo conectar con el servidor';
	@override String get serverNotAvailable => 'Servidor no disponible';
	@override String get requestTimeout => 'Se agotó el tiempo de la solicitud';
	@override String get unexpectedError => 'Error inesperado';
	@override String get invalidResponse => 'Respuesta no válida';
	@override String get invalidRequest => 'Solicitud no válida';
	@override String get invalidUrl => 'URL no válida';
	@override String get invalidMethod => 'Método no válido';
	@override String get invalidHeader => 'Encabezado no válido';
	@override String get invalidBody => 'Cuerpo no válido';
	@override String get invalidStatusCode => 'Código de estado no válido';
	@override String get serverError => 'Error del servidor';
	@override String get requestCanceled => 'Solicitud cancelada';
	@override String get invalidPort => 'Puerto no válido';
	@override String get proxyPortError => 'Error del puerto del proxy';
	@override String get connectionRefused => 'Conexión rechazada';
	@override String get networkUnreachable => 'Red inaccesible';
	@override String get noRouteToHost => 'No hay ruta al host';
	@override String get connectionFailed => 'No se pudo conectar';
	@override String get sslConnectionFailed => 'Falló la conexión SSL; compruebe la configuración de red';
}

// Path: settings.keybinding
class _TranslationsSettingsKeybindingEs extends TranslationsSettingsKeybindingEn {
	_TranslationsSettingsKeybindingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Atajos de teclado';
	@override String get entryLabel => 'Atajos de teclado';
	@override String get entryDesc => 'Personalice los atajos de teclado de la aplicación (principalmente para escritorio)';
	@override String get desktopHint => 'Los atajos se aplican principalmente a los teclados de escritorio; en móvil suelen usarse gestos.';
	@override String get resetAll => 'Restablecer todo a los valores predeterminados';
	@override String get resetAllConfirm => '¿Restablecer todos los atajos de la aplicación a sus valores predeterminados?';
	@override String get resetToDefault => 'Restablecer valores predeterminados';
	@override String get resetScope => 'Restablecer esta sección';
	@override String get notSet => 'Sin asignar';
	@override String get addShortcut => 'Añadir atajo';
	@override String get removeShortcut => 'Eliminar este atajo';
	@override String get pressNewShortcut => 'Pulse el nuevo atajo…';
	@override String get recordingCancelHint => 'Pulse Esc para cancelar';
	@override String get mouseHint => 'También puede vincular los botones laterales del ratón (atrás / avance) o el botón central';
	@override String get mouseNotSupportedInScope => 'Esta zona no admite botones del ratón; use el teclado en su lugar';
	@override String get capabilityKeyboardOnly => 'Esta zona solo acepta teclas del teclado';
	@override String get capabilityKeyboardAndMouse => 'Esta zona acepta teclas del teclado y los botones central y laterales del ratón';
	@override String get capabilityKeyboardAndMouseMobile => 'Esta zona acepta teclas del teclado y los botones central y de avance del ratón (el botón de retroceso lo usa el sistema)';
	@override String get rejectMultipleButtons => 'Pulse un botón del ratón a la vez';
	@override String get rejectPlatformBack => 'El sistema ya lo usa para Atrás; si lo vincula, se retrocedería dos veces';
	@override String get detectedLabel => 'Detectado';
	@override String get reservedKey => 'Esta tecla está reservada por el sistema y no se puede vincular';
	@override String reservedForGlobalBack({required Object action}) => 'Esta tecla está vinculada a "${action}"; permanece reservada aquí para que aún pueda salir de esta pantalla';
	@override String get conflictTitle => 'Conflicto de atajos';
	@override String conflictMessage({required Object action}) => 'Esta combinación ya está vinculada a "${action}". Si continúa, se eliminará la vinculación existente.';
	@override String get conflictContinue => 'Vincular de todos modos';
	@override String get shadowWarningTitle => 'Solapamiento con atajos globales';
	@override String shadowWarningMessage({required Object action}) => 'Esta combinación está vinculada a "${action}" globalmente. Vincularla aquí anulará esa acción solo dentro de esta sección.';
	@override String globalShadowedMessage({required Object action, required Object scope}) => 'Esta combinación ya está vinculada a "${action}" en ${scope}. Dentro de esa sección, este atajo global será anulado por ella.';
	@override String get searchHint => 'Buscar atajos…';
	@override String get scopeGlobal => 'Global';
	@override String get scopeGallery => 'Galería';
	@override String get scopeVideo => 'Vídeo';
	@override String get categoryNavigation => 'Navegación';
	@override String get categoryZoom => 'Zoom';
	@override String get categoryPlayback => 'Reproducción';
	@override String get categorySeek => 'Búsqueda';
	@override String get categoryVolume => 'Volumen';
	@override String get categoryDisplay => 'Pantalla';
	@override String get actionGlobalBack => 'Volver';
	@override String get actionGalleryNext => 'Foto siguiente';
	@override String get actionGalleryPrevious => 'Foto anterior';
	@override String get actionGalleryZoomIn => 'Ampliar';
	@override String get actionGalleryZoomOut => 'Reducir';
	@override String get actionGalleryResetZoom => 'Restablecer el zoom';
	@override String get actionGalleryPlayPause => 'Reproducir / Pausar';
	@override String get actionGallerySeekBackward => 'Retroceder';
	@override String get actionGallerySeekForward => 'Avanzar rápido';
	@override String get actionGalleryToggleMute => 'Activar o desactivar el silencio';
	@override String get actionPlayPause => 'Reproducir / Pausar';
	@override String get actionSpeedUp => 'Aumentar la velocidad';
	@override String get actionSpeedDown => 'Reducir la velocidad';
	@override String get actionSeekForward => 'Avanzar';
	@override String get actionSeekBackward => 'Retroceder';
	@override String get actionVolumeUp => 'Subir el volumen';
	@override String get actionVolumeDown => 'Bajar el volumen';
	@override String get actionToggleMute => 'Activar o desactivar el silencio';
	@override String get actionToggleFullscreen => 'Alternar pantalla completa';
	@override String get seekLongPressHint => 'Mantenga pulsada la tecla de avance o retroceso para activar el modo de velocidad por pulsación larga';
	@override String get zoomSectionTitle => 'Zoom de imagen (fijo)';
	@override String get zoomFixedNote => 'Los atajos siguientes son fijos y no se pueden cambiar';
	@override String get zoomScaleLabel => 'Ampliar la imagen';
	@override String get zoomScaleHint => 'Ctrl + rueda';
	@override String get zoomRotateLabel => 'Girar la imagen';
	@override String get zoomRotateHint => 'Mayús + rueda';
	@override String get zoomPinchGesture => 'Pellizcar';
	@override String get zoomTwoFingerRotateGesture => 'Rotación con dos dedos';
}

// Path: settings.forumSettings
class _TranslationsSettingsForumSettingsEs extends TranslationsSettingsForumSettingsEn {
	_TranslationsSettingsForumSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Foro';
	@override String get configureYourForumSettings => 'Configure los ajustes de su foro';
}

// Path: settings.gallerySettings
class _TranslationsSettingsGallerySettingsEs extends TranslationsSettingsGallerySettingsEn {
	_TranslationsSettingsGallerySettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get gallerySettingsTitle => 'Ajustes de la galería';
	@override String get gallerySettingsSubtitle => 'Configure las preferencias del visor de galería';
	@override String get defaultViewerQuality => 'Calidad predeterminada del visor';
	@override String get defaultViewerQualityDesc => 'Elija qué calidad de imagen mostrar de forma predeterminada al abrir el visor de la galería.';
}

// Path: settings.blockSettings
class _TranslationsSettingsBlockSettingsEs extends TranslationsSettingsBlockSettingsEn {
	_TranslationsSettingsBlockSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bloqueo de contenido';
	@override String get subtitle => 'Ocultar automáticamente los videos y galerías cuyo título coincida con una palabra clave o un patrón, o que provengan de un usuario bloqueado. Toda la coincidencia se realiza en su dispositivo; no se sube nada.';
	@override String get blocked => 'Bloqueado';
	@override String get reveal => 'Mostrar';
	@override String get reblock => 'Bloquear de nuevo';
	@override String get why => '¿Por qué está bloqueado?';
	@override String get manageRules => 'Gestionar reglas';
	@override String reasonKeyword({required Object value}) => 'El título contiene "${value}"';
	@override String reasonRegex({required Object value}) => 'El título coincide con "${value}"';
	@override String get reasonUser => 'De un usuario bloqueado';
	@override String get addRule => 'Añadir regla';
	@override String get editRule => 'Editar regla';
	@override String get deleteRule => 'Eliminar regla';
	@override String get ruleType => 'Tipo de regla';
	@override String get keyword => 'Palabra clave';
	@override String get regex => 'Regex';
	@override String get userId => 'Usuario';
	@override String get value => 'Texto que debe coincidir';
	@override String get caseSensitive => 'Sensible a mayúsculas';
	@override String get regexHint => 'p. ej. trailer|teaser';
	@override String get valueRequired => 'Introduzca el texto que debe coincidir';
	@override String get invalidRegex => 'Esa no es una expresión regular válida';
	@override String get noRules => 'Aún no hay reglas. Toque + para añadir una.';
	@override String get blockUser => 'Bloquear';
	@override String get unblockUser => 'Desbloquear';
	@override String blockUserConfirm({required Object name}) => '¿Bloquear a "${name}"? Sus videos y galerías se ocultarán de las listas y la búsqueda.';
	@override String get userBlocked => 'Usuario bloqueado';
	@override String get userUnblocked => 'Usuario desbloqueado';
	@override String get exportRules => 'Exportar';
	@override String get importRules => 'Importar';
	@override String get importExport => 'Importar / Exportar';
	@override String get exportSuccess => 'Reglas exportadas';
	@override String get exportFailed => 'No se pudieron exportar las reglas';
	@override String importSuccess({required Object count}) => 'Se importaron ${count} regla(s)';
	@override String get importFailed => 'No se pudieron importar las reglas';
	@override String get regexHelp => 'Ayuda de patrones';
	@override String get regexHelpTitle => 'Referencia de expresiones regulares';
	@override String get regexHelpIntro => 'Una expresión regular coincide con los títulos de forma más flexible que una palabra clave simple. Algunos ejemplos comunes:';
	@override String get regexHelpTapHint => 'Toque un ejemplo para rellenarlo.';
	@override String get regexEx1Pattern => 'tráiler|avance|extra';
	@override String get regexEx1Desc => 'Coincide con cualquiera de estas palabras ("|" significa "o")';
	@override String get regexEx2Pattern => '^\\[.*\\]';
	@override String get regexEx2Desc => 'Títulos que empiezan con [corchetes]';
	@override String get regexEx3Pattern => 'Colección\$';
	@override String get regexEx3Desc => 'Títulos que terminan con "Colección"';
	@override String get regexEx4Pattern => 'Ep.[0-9]+';
	@override String get regexEx4Desc => '[0-9]+ es uno o más dígitos — coincide con "Ep.12"';
	@override String get regexEx5Pattern => '\\d{4}';
	@override String get regexEx5Desc => '[0-9] es un dígito y {4} significa cuatro seguidos (p. ej., un año)';
	@override String get regexEx1Sample => 'Avance del nuevo juego ya disponible';
	@override String get regexEx2Sample => '[Remux] Película completa';
	@override String get regexEx3Sample => 'Colección de arte primaveral';
	@override String get regexEx4Sample => 'Resumen del Ep.12 de mi serie';
	@override String get regexEx5Sample => 'Lo mejor de 2024';
	@override String get regexHelpSampleLabel => 'Título de ejemplo';
	@override String get regexHelpMatchedTag => 'Bloqueado';
	@override String get regexHelpNoMatch => 'Sin coincidencia';
	@override String get regexEx6Pattern => '[Tt]emporada';
	@override String get regexEx6Desc => '[Tt] coincide con la T mayúscula o minúscula — aquí detecta "Temporada"';
	@override String get regexEx6Sample => 'Tráiler de la temporada final';
	@override String get regexEx7Pattern => 'la (película|serie)';
	@override String get regexEx7Desc => 'Los paréntesis () agrupan alternativas — coincide con "la película" o "la serie"';
	@override String get regexEx7Sample => 'Ver la serie ahora';
	@override String get regexEx8Pattern => 'temporadas?';
	@override String get regexEx8Desc => 'La s? hace opcional la letra anterior — coincide con "temporada" y "temporadas"';
	@override String get regexEx8Sample => 'Paquete de dos temporadas';
	@override String get regexEx9Pattern => '!+';
	@override String get regexEx9Desc => '+ significa uno o más — coincide con !, !!, !!! ...';
	@override String get regexEx9Sample => '¡¡¡Increíble!!! Hay que verlo';
	@override String get regexEx10Pattern => 'extra.*escena';
	@override String get regexEx10Desc => '.* coincide con cualquier texto intermedio — "extra … escena"';
	@override String get regexEx10Sample => 'Escena extra eliminada';
}

// Path: settings.chatSettings
class _TranslationsSettingsChatSettingsEs extends TranslationsSettingsChatSettingsEn {
	_TranslationsSettingsChatSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Chat';
	@override String get configureYourChatSettings => 'Configure los ajustes de su chat';
}

// Path: settings.downloadSettings
class _TranslationsSettingsDownloadSettingsEs extends TranslationsSettingsDownloadSettingsEn {
	_TranslationsSettingsDownloadSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get downloadSettings => 'Ajustes de descarga';
	@override String get enableDownloadNotifications => 'Notificaciones de descarga';
	@override String get enableDownloadNotificationsDescription => 'Mostrar una notificación del sistema cuando una descarga individual finaliza o falla';
	@override String get notificationPermissionDenied => 'Permiso de notificaciones denegado. Las notificaciones dentro de la aplicación siguen funcionando; active las notificaciones del sistema en los ajustes.';
	@override String get storagePermissionStatus => 'Estado del permiso de almacenamiento';
	@override String get accessPublicDirectoryNeedStoragePermission => 'Acceder al directorio público requiere permiso de almacenamiento';
	@override String get checkingPermissionStatus => 'Comprobando el estado de los permisos...';
	@override String get storagePermissionGranted => 'Permiso de almacenamiento concedido';
	@override String get storagePermissionNotGranted => 'Permiso de almacenamiento no concedido';
	@override String get storagePermissionGrantSuccess => 'Permiso de almacenamiento concedido correctamente';
	@override String get storagePermissionGrantFailedButSomeFeaturesMayBeLimited => 'Error al conceder el permiso de almacenamiento, pero algunas funciones pueden verse limitadas';
	@override String get storagePermissionRationale => 'Para guardar las descargas en la carpeta que elija, la aplicación necesita acceso al almacenamiento.\n\nEn Android 11 y versiones posteriores, esto implica el permiso "acceso a todos los archivos"; sin él, los archivos se guardan en la carpeta privada de la aplicación.';
	@override String get storagePermissionRationaleLegacy => 'Para guardar las descargas en la carpeta que elija, la aplicación necesita acceso al almacenamiento.\n\nSin él, los archivos se guardan en la carpeta privada de la aplicación.';
	@override String get grantStoragePermission => 'Conceder permiso de almacenamiento';
	@override String get customDownloadPath => 'Ruta de descarga personalizada';
	@override String get customDownloadPathDescription => 'Cuando está activado, puede elegir una ubicación de guardado personalizada para los archivos descargados';
	@override String get customDownloadPathTip => '💡 Consejo: seleccionar directorios públicos (como la carpeta Descargas) requiere permiso de almacenamiento; se recomienda usar primero las rutas recomendadas';
	@override String get androidWarning => 'Nota para Android: evite seleccionar directorios públicos (como la carpeta Descargas); se recomienda usar directorios específicos de la aplicación para garantizar los permisos de acceso.';
	@override String get publicDirectoryPermissionTip => '⚠️ Aviso: ha seleccionado un directorio público; se requiere permiso de almacenamiento para descargar archivos con normalidad';
	@override String get permissionRequiredForPublicDirectory => 'Se requiere permiso de almacenamiento para los directorios públicos';
	@override String get currentDownloadPath => 'Ruta de descarga actual';
	@override String get actualDownloadPath => 'Ruta de descarga real';
	@override String get defaultAppDirectory => 'Directorio predeterminado de la aplicación';
	@override String get permissionGranted => 'Concedido';
	@override String get permissionRequired => 'Permiso necesario';
	@override String get enableCustomDownloadPath => 'Activar la ruta de descarga personalizada';
	@override String get disableCustomDownloadPath => 'Usar la ruta predeterminada de la aplicación cuando está desactivado';
	@override String get customDownloadPathLabel => 'Ruta de descarga personalizada';
	@override String get selectDownloadFolder => 'Seleccionar carpeta de descarga';
	@override String get recommendedPath => 'Ruta recomendada';
	@override String get selectFolder => 'Seleccionar carpeta';
	@override String get filenameTemplate => 'Plantilla de nombre de archivo';
	@override String get filenameTemplateDescription => 'Personalice las reglas de nomenclatura de los archivos descargados; admite sustitución de variables';
	@override String get videoFilenameTemplate => 'Plantilla de nombre de archivo de video';
	@override String get galleryFolderTemplate => 'Plantilla de carpeta de galería';
	@override String get imageFilenameTemplate => 'Plantilla de nombre de archivo de imagen';
	@override String get resetToDefault => 'Restablecer valores predeterminados';
	@override String get supportedVariables => 'Variables admitidas';
	@override String get supportedVariablesDescription => 'Las siguientes variables pueden usarse en las plantillas de nombre de archivo:';
	@override String get copyVariable => 'Copiar variable';
	@override String get variableCopied => 'Variable copiada';
	@override String get warningPublicDirectory => 'Advertencia: es posible que no se pueda acceder al directorio público seleccionado. Se recomienda seleccionar un directorio específico de la aplicación.';
	@override String get downloadPathUpdated => 'Ruta de descarga actualizada';
	@override String get selectPathFailed => 'No se pudo seleccionar la ruta';
	@override String get pickerAlreadyActive => 'El selector de carpetas ya está abierto';
	@override String get unsupportedStorageVolume => 'Ubicación de almacenamiento no admitida. Elija una carpeta en el almacenamiento del dispositivo o en la tarjeta SD.';
	@override String get recommendedPathSet => 'Establecida en la ruta recomendada';
	@override String get setRecommendedPathFailed => 'No se pudo establecer la ruta recomendada';
	@override String get templateResetToDefault => 'Restablecer la plantilla predeterminada';
	@override String get functionalTest => 'Prueba funcional';
	@override String get testInProgress => 'Probando...';
	@override String get runTest => 'Ejecutar prueba';
	@override String get testDownloadPathAndPermissions => 'Comprobar si la ruta de descarga y la configuración de permisos funcionan correctamente';
	@override String get testResults => 'Resultados de la prueba';
	@override String get testCompleted => 'Prueba completada';
	@override String get testMultisegmentDomain => 'Validación de dominio (multi-segmento / exceso / formas de escape)';
	@override String get testMultisegmentPaths => 'Render de estructura multi-segmento (issue #126)';
	@override String get testPassed => 'elementos correctos';
	@override String get testFailed => 'Prueba fallida';
	@override String get testStoragePermissionCheck => 'Comprobación del permiso de almacenamiento';
	@override String get testStoragePermissionGranted => 'Permiso de almacenamiento concedido';
	@override String get testStoragePermissionMissing => 'Falta el permiso de almacenamiento; algunas funciones pueden verse limitadas';
	@override String get testPermissionCheckFailed => 'Error al comprobar el permiso';
	@override String get testDownloadPathValidation => 'Validación de la ruta de descarga';
	@override String get testPathValidationFailed => 'Error al validar la ruta';
	@override String get testFilenameTemplateValidation => 'Validación de la plantilla de nombre de archivo';
	@override String get testAllTemplatesValid => 'Todas las plantillas son válidas';
	@override String get testSomeTemplatesInvalid => 'Algunas plantillas contienen caracteres no válidos';
	@override String get testTemplateValidationFailed => 'Error al validar la plantilla';
	@override String get testDirectoryOperationTest => 'Prueba de operación de directorios';
	@override String get testDirectoryOperationNormal => 'La creación de directorios y la escritura de archivos funcionan correctamente';
	@override String get testDirectoryOperationFailed => 'Error en la operación de directorio';
	@override String get testVideoTemplate => 'Plantilla de video';
	@override String get testGalleryTemplate => 'Plantilla de galería';
	@override String get testImageTemplate => 'Plantilla de imagen';
	@override String get testValid => 'Válido';
	@override String get testInvalid => 'No válido';
	@override String get testSuccess => 'Correcto';
	@override String get testCorrect => 'Correcto';
	@override String get testError => 'Error';
	@override String get testPath => 'Ruta de prueba';
	@override String get testBasePath => 'Ruta base';
	@override String get testDirectoryCreation => 'Creación de directorios';
	@override String get testFileWriting => 'Escritura de archivos';
	@override String get testFileContent => 'Contenido del archivo';
	@override String get checkingPathStatus => 'Comprobando el estado de la ruta...';
	@override String get unableToGetPathStatus => 'No se puede obtener el estado de la ruta';
	@override String get actualPathDifferentFromSelected => 'Nota: la ruta real difiere de la ruta seleccionada';
	@override String get grantPermission => 'Conceder permiso';
	@override String get fixIssue => 'Solucionar problema';
	@override String get issueFixed => 'Problema solucionado';
	@override String get fixFailed => 'No se pudo solucionar; hágalo manualmente';
	@override String get lackStoragePermission => 'Falta el permiso de almacenamiento';
	@override String get cannotAccessPublicDirectory => 'No se puede acceder al directorio público; se necesita el permiso "acceso a todos los archivos"';
	@override String get cannotCreateDirectory => 'No se puede crear el directorio';
	@override String get directoryNotWritable => 'El directorio no permite escritura';
	@override String get insufficientSpace => 'Espacio disponible insuficiente';
	@override String get pathValid => 'La ruta es válida';
	@override String get validationFailed => 'Error de validación';
	@override String get usingDefaultAppDirectory => 'Usando el directorio predeterminado de la aplicación';
	@override String get appPrivateDirectory => 'Directorio privado de la aplicación';
	@override String get appPrivateDirectoryDesc => 'Seguro y fiable; no requiere permisos adicionales';
	@override String get downloadDirectory => 'Directorio de descargas';
	@override String get downloadDirectoryDesc => 'Ubicación de descarga predeterminada del sistema; fácil de gestionar';
	@override String get moviesDirectory => 'Directorio de películas';
	@override String get moviesDirectoryDesc => 'Directorio de películas del sistema; reconocible por las aplicaciones multimedia';
	@override String get documentsDirectory => 'Directorio de documentos';
	@override String get documentsDirectoryDesc => 'Directorio de documentos de la aplicación iOS';
	@override String get requiresStoragePermission => 'Requiere permiso de almacenamiento para acceder';
	@override String get recommendedPaths => 'Rutas recomendadas';
	@override String get externalAppPrivateDirectory => 'Directorio privado de la aplicación en almacenamiento externo';
	@override String get externalAppPrivateDirectoryDesc => 'Directorio privado de la aplicación en almacenamiento externo; accesible para el usuario y con más espacio';
	@override String get internalAppPrivateDirectory => 'Directorio privado interno de la aplicación';
	@override String get internalAppPrivateDirectoryDesc => 'Almacenamiento interno de la aplicación; no requiere permisos y tiene menos espacio';
	@override String get appDocumentsDirectory => 'Directorio de documentos de la aplicación';
	@override String get appDocumentsDirectoryDesc => 'Directorio de documentos específico de la aplicación; seguro y fiable';
	@override String get downloadsFolder => 'Carpeta Descargas';
	@override String get downloadsFolderDesc => 'Directorio de descargas predeterminado del sistema';
	@override String get selectRecommendedDownloadLocation => 'Seleccione una ubicación de descarga recomendada';
	@override String get noRecommendedPaths => 'No hay rutas recomendadas disponibles';
	@override String get recommended => 'Recomendado';
	@override String get requiresPermission => 'Requiere permiso';
	@override String get authorizeAndSelect => 'Autorizar y seleccionar';
	@override String get select => 'Seleccionar';
	@override String get permissionAuthorizationFailed => 'Error al autorizar el permiso; no se puede seleccionar esta ruta';
	@override String get pathValidationFailed => 'Error al validar la ruta';
	@override String get downloadPathSetTo => 'Ruta de descarga establecida en';
	@override String get setPathFailed => 'No se pudo establecer la ruta';
	@override String get variableTitle => 'Título';
	@override String get variableAuthorcache => 'Primer nombre visto del autor (estable aunque cambie el nombre)';
	@override String get variableAuthor => 'Nombre del autor';
	@override String get variableUsername => 'Nombre de usuario del autor';
	@override String get variableQuality => 'Calidad del video';
	@override String get variableFilename => 'Nombre de archivo original';
	@override String get variableId => 'ID del contenido';
	@override String get variableCount => 'Cantidad de imágenes de la galería';
	@override String get variableDate => 'Fecha actual (YYYY-MM-DD)';
	@override String get variableTime => 'Hora actual (HH-MM-SS)';
	@override String get variableDatetime => 'Fecha y hora actuales (YYYY-MM-DD_HH-MM-SS)';
	@override String get downloadSettingsTitle => 'Ajustes de descarga';
	@override String get downloadSettingsSubtitle => 'Configure la ruta de descarga y las reglas de nomenclatura de archivos';
	@override String get suchAsTitleQuality => 'Por ejemplo: %title_%quality';
	@override String get suchAsTitleId => 'Por ejemplo: %title_%id';
	@override String get suchAsTitleFilename => 'Por ejemplo: %title_%filename';
	@override String get structureSection => 'Estructura de guardado y nombres';
	@override String get structureSectionDescription => 'Los archivos descargados se organizan en subcarpetas según el esquema elegido. Solo afecta a descargas futuras; los archivos existentes no se tocan.';
	@override String get structureNoticeTitle => 'Novedad: archivar automáticamente por autor';
	@override String get structureNoticeBody => 'Elige abajo · solo afecta a las descargas nuevas, los archivos existentes no se tocan.';
	@override String get presetFlat => 'Plano';
	@override String get presetFlatDesc => 'Todos los archivos van directo a la raíz de descargas';
	@override String get presetAuthor => 'Por autor';
	@override String get presetAuthorBadge => 'Recomendado';
	@override String get presetAuthorDesc => 'Una carpeta por autor · no se divide aunque cambie el nombre';
	@override String get presetDate => 'Por fecha';
	@override String get presetDateDesc => 'Agrupado por fecha de descarga';
	@override String get presetCustomActive => 'En uso';
	@override String get structurePreviewLabel => 'Vista previa';
	@override String get structurePreviewNote => 'Los segmentos de color son los niveles de organización, cambian con el esquema elegido.';
	@override String get pathTooLongWarning => 'La ruta relativa supera los 200 caracteres: puede fallar al guardar en algunos dispositivos';
	@override String get pathTemplateEditorEntry => 'Plantilla de ruta personalizada';
	@override String get pathTemplateEditorEntryDesc => 'Decide tú la estructura de carpetas y el nombre de los archivos';
	@override late final _TranslationsSettingsDownloadSettingsPathTemplateEditorEs pathTemplateEditor = _TranslationsSettingsDownloadSettingsPathTemplateEditorEs._(_root);
}

// Path: oreno3d.sortTypes
class _TranslationsOreno3dSortTypesEs extends TranslationsOreno3dSortTypesEn {
	_TranslationsOreno3dSortTypesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get hot => 'Popular';
	@override String get favorites => 'Favoritos';
	@override String get latest => 'Recientes';
	@override String get popularity => 'Popularidad';
}

// Path: oreno3d.errors
class _TranslationsOreno3dErrorsEs extends TranslationsOreno3dErrorsEn {
	_TranslationsOreno3dErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get requestFailed => 'Error en la solicitud; código de estado';
	@override String get connectionTimeout => 'Tiempo de conexión agotado; compruebe la conexión de red';
	@override String get sendTimeout => 'Tiempo de espera para enviar la solicitud agotado';
	@override String get receiveTimeout => 'Tiempo de espera para recibir la respuesta agotado';
	@override String get badCertificate => 'Error al verificar el certificado';
	@override String get resourceNotFound => 'No se encontró el recurso solicitado';
	@override String get accessDenied => 'Acceso denegado; puede requerir autenticación o permiso';
	@override String get serverError => 'Error interno del servidor';
	@override String get serviceUnavailable => 'Servicio no disponible temporalmente';
	@override String get requestCancelled => 'Solicitud cancelada';
	@override String get connectionError => 'Error de conexión de red; compruebe la configuración de red';
	@override String get networkRequestFailed => 'Error en la solicitud de red';
	@override String get searchVideoError => 'Ocurrió un error desconocido al buscar videos';
	@override String get getPopularVideoError => 'Ocurrió un error desconocido al obtener los videos populares';
	@override String get getVideoDetailError => 'Ocurrió un error desconocido al obtener los detalles del video';
	@override String get parseVideoDetailError => 'Ocurrió un error desconocido al obtener y analizar los detalles del video';
	@override String get downloadFileError => 'Ocurrió un error desconocido al descargar el archivo';
}

// Path: oreno3d.loading
class _TranslationsOreno3dLoadingEs extends TranslationsOreno3dLoadingEn {
	_TranslationsOreno3dLoadingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get gettingVideoInfo => 'Obteniendo la información del video...';
	@override String get cancel => 'Cancelar';
}

// Path: oreno3d.messages
class _TranslationsOreno3dMessagesEs extends TranslationsOreno3dMessagesEn {
	_TranslationsOreno3dMessagesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get videoNotFoundOrDeleted => 'Video no encontrado o eliminado';
	@override String get unableToGetVideoPlayLink => 'No se pudo obtener el enlace de reproducción del video';
	@override String get getVideoDetailFailed => 'No se pudieron obtener los detalles del video';
}

// Path: videoDetail.localInfo
class _TranslationsVideoDetailLocalInfoEs extends TranslationsVideoDetailLocalInfoEn {
	_TranslationsVideoDetailLocalInfoEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get videoInfo => 'Información del video';
	@override String get currentQuality => 'Calidad actual';
	@override String get duration => 'Duración';
	@override String get resolution => 'Resolución';
	@override String get fileInfo => 'Información del archivo';
	@override String get fileName => 'Nombre del archivo';
	@override String get fileSize => 'Tamaño del archivo';
	@override String get filePath => 'Ruta del archivo';
	@override String get copyPath => 'Copiar ruta';
	@override String get openFolder => 'Abrir carpeta';
	@override String get pathCopiedToClipboard => 'Ruta copiada al portapapeles';
	@override String get openFolderFailed => 'No se pudo abrir la carpeta';
}

// Path: videoDetail.gestureGuide
class _TranslationsVideoDetailGestureGuideEs extends TranslationsVideoDetailGestureGuideEn {
	_TranslationsVideoDetailGestureGuideEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get sampleVideo => 'Vídeo de ejemplo';
	@override String get title => 'Guía de gestos e interacción';
	@override String get viewGuide => 'Guía de gestos e interacción';
	@override String get firstTimeIntro => 'Dedique unos segundos a aprender los gestos del reproductor. Puede volver a abrir esta guía en cualquier momento desde los ajustes del reproductor.';
	@override String get startWatching => 'Entendido, empezar a ver';
	@override String get basicTitle => 'Controles básicos';
	@override String get zoomTitle => 'Zoom / Girar / Desplazar';
	@override String get restoreTip => 'Toque el botón "Restaurar" en la esquina inferior derecha para restablecer el zoom, la rotación y la posición.';
	@override String get mTap => 'Toque único: mostrar/ocultar los controles';
	@override String get mDoubleTap => 'Doble toque: retroceder (izquierda) / pausar (centro) / avanzar rápido (derecha)';
	@override String get mHorizontalDrag => 'Deslizamiento horizontal: buscar';
	@override String get mVerticalDrag => 'Deslizamiento vertical: brillo (izquierda) / volumen (derecha)';
	@override String get mLongPress => 'Pulsación larga: aceleración temporal';
	@override String get mPinch => 'Pellizco con dos dedos: ampliar la imagen';
	@override String get mRotate => 'Rotación con dos dedos: girar la imagen';
	@override String get dTap => 'Clic: mostrar/ocultar los controles';
	@override String get dDoubleTap => 'Doble clic: retroceder (izquierda) / pausar (centro) / avanzar rápido (derecha)';
	@override String get dKeys => 'Teclas de búsqueda: pulse para saltar atrás/adelante, mantenga para acelerar; teclas de velocidad: ajustan la velocidad de reproducción durante la reproducción normal; Espacio: reproducir/pausar';
	@override String get dTrackpadPinch => 'Pellizco en el panel táctil: ampliar la imagen';
	@override String get dTrackpadRotate => 'Rotación en el panel táctil: girar la imagen';
	@override String get dCtrlWheel => 'Ctrl + rueda: ampliar alrededor del cursor';
	@override String get dShiftWheel => 'Mayús + rueda: girar alrededor del cursor';
	@override late final _TranslationsVideoDetailGestureGuideQuestEs quest = _TranslationsVideoDetailGestureGuideQuestEs._(_root);
}

// Path: videoDetail.player
class _TranslationsVideoDetailPlayerEs extends TranslationsVideoDetailPlayerEn {
	_TranslationsVideoDetailPlayerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get errorWhileLoadingVideoSource => 'Error al cargar la fuente de video';
	@override String get errorWhileSettingUpListeners => 'Error al configurar los receptores';
	@override String get serverFaultDetectedAutoSwitched => 'Se detectó un fallo del servidor; se cambió de ruta automáticamente y se está reintentando';
}

// Path: videoDetail.skeleton
class _TranslationsVideoDetailSkeletonEs extends TranslationsVideoDetailSkeletonEn {
	_TranslationsVideoDetailSkeletonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get fetchingVideoInfo => 'Obteniendo la información del video...';
	@override String get fetchingVideoSources => 'Obteniendo las fuentes de video...';
	@override String get loadingVideo => 'Cargando el video...';
	@override String get applyingSolution => 'Aplicando la solución...';
	@override String get addingListeners => 'Añadiendo receptores...';
	@override String get successFecthVideoDurationInfo => 'Se obtuvo la duración del video correctamente; empezando a cargar el video...';
	@override String get successFecthVideoHeightInfo => 'Carga completada';
}

// Path: videoDetail.cast
class _TranslationsVideoDetailCastEs extends TranslationsVideoDetailCastEn {
	_TranslationsVideoDetailCastEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get dlnaCast => 'Transmitir';
	@override String unableToStartCastingSearch({required Object error}) => 'No se pudo iniciar la búsqueda de transmisión: ${error}';
	@override String startCastingTo({required Object deviceName}) => 'Empezar a transmitir a ${deviceName}';
	@override String castFailed({required Object error}) => 'Error al transmitir: ${error}\nIntente volver a buscar dispositivos o cambiar de red';
	@override String get castStopped => 'Transmisión detenida';
	@override late final _TranslationsVideoDetailCastDeviceTypesEs deviceTypes = _TranslationsVideoDetailCastDeviceTypesEs._(_root);
	@override String get currentPlatformNotSupported => 'La plataforma actual no admite la transmisión';
	@override String get unableToGetVideoUrl => 'No se pudo obtener la URL del video; inténtelo de nuevo más tarde';
	@override String get stopCasting => 'Detener la transmisión';
	@override late final _TranslationsVideoDetailCastDlnaCastSheetEs dlnaCastSheet = _TranslationsVideoDetailCastDlnaCastSheetEs._(_root);
}

// Path: videoDetail.likeAvatars
class _TranslationsVideoDetailLikeAvatarsEs extends TranslationsVideoDetailLikeAvatarsEn {
	_TranslationsVideoDetailLikeAvatarsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get dialogTitle => 'Quién da me gusta en secreto';
	@override String get dialogDescription => '¿Tiene curiosidad por saber quiénes son? Hojee este "álbum de me gusta"~';
	@override String get closeTooltip => 'Cerrar';
	@override String get retry => 'Reintentar';
	@override String get noLikesYet => 'Aún no ha aparecido nadie aquí. ¡Sea el primero!';
	@override String pageInfo({required Object page, required Object totalPages, required Object totalCount}) => 'Página ${page} / ${totalPages} · Total: ${totalCount} personas';
	@override String get prevPage => 'Página anterior';
	@override String get nextPage => 'Página siguiente';
}

// Path: forum.sitewide
class _TranslationsForumSitewideEs extends TranslationsForumSitewideEn {
	_TranslationsForumSitewideEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get badge => 'Todo el sitio';
	@override String get title => 'Anuncio para todo el sitio';
	@override String get readMore => 'Leer más';
}

// Path: forum.errors
class _TranslationsForumErrorsEs extends TranslationsForumErrorsEn {
	_TranslationsForumErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectCategory => 'Seleccione una categoría';
	@override String get threadLocked => 'Este hilo está cerrado; no se puede responder';
}

// Path: forum.groups
class _TranslationsForumGroupsEs extends TranslationsForumGroupsEn {
	_TranslationsForumGroupsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get administration => 'Administración';
	@override String get global => 'Global';
	@override String get chinese => 'Chino';
	@override String get japanese => 'Japonés';
	@override String get korean => 'Coreano';
	@override String get other => 'Otros';
}

// Path: forum.leafNames
class _TranslationsForumLeafNamesEs extends TranslationsForumLeafNamesEn {
	_TranslationsForumLeafNamesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Anuncios';
	@override String get feedback => 'Comentarios';
	@override String get support => 'Soporte';
	@override String get general => 'General';
	@override String get guides => 'Guías';
	@override String get questions => 'Preguntas';
	@override String get requests => 'Peticiones';
	@override String get sharing => 'Compartir';
	@override String get general_zh => 'General';
	@override String get questions_zh => 'Preguntas';
	@override String get requests_zh => 'Peticiones';
	@override String get support_zh => 'Soporte';
	@override String get general_ja => 'General';
	@override String get questions_ja => 'Preguntas';
	@override String get requests_ja => 'Peticiones';
	@override String get support_ja => 'Soporte';
	@override String get korean => 'Coreano';
	@override String get other => 'Otros';
}

// Path: forum.leafDescriptions
class _TranslationsForumLeafDescriptionsEs extends TranslationsForumLeafDescriptionsEn {
	_TranslationsForumLeafDescriptionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get announcements => 'Notificaciones y anuncios oficiales importantes';
	@override String get feedback => 'Comentarios sobre las funciones y los servicios del sitio web';
	@override String get support => 'Ayuda para resolver problemas relacionados con el sitio web';
	@override String get general => 'Debata sobre cualquier tema';
	@override String get guides => 'Comparta sus experiencias y tutoriales';
	@override String get questions => 'Plantee sus dudas';
	@override String get requests => 'Publique sus peticiones';
	@override String get sharing => 'Comparta contenido interesante';
	@override String get general_zh => 'Debata sobre cualquier tema';
	@override String get questions_zh => 'Plantee sus dudas';
	@override String get requests_zh => 'Publique sus peticiones';
	@override String get support_zh => 'Ayuda para resolver problemas relacionados con el sitio web';
	@override String get general_ja => 'Debata sobre cualquier tema';
	@override String get questions_ja => 'Plantee sus dudas';
	@override String get requests_ja => 'Publique sus peticiones';
	@override String get support_ja => 'Ayuda para resolver problemas relacionados con el sitio web';
	@override String get korean => 'Debates relacionados con el coreano';
	@override String get other => 'Otro contenido sin clasificar';
}

// Path: notifications.errors
class _TranslationsNotificationsErrorsEs extends TranslationsNotificationsErrorsEn {
	_TranslationsNotificationsErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get unsupportedNotificationType => 'Tipo de notificación no admitido';
	@override String get unknownUser => 'Usuario desconocido';
	@override String unsupportedNotificationTypeWithType({required Object type}) => 'Tipo de notificación no admitido: ${type}';
	@override String get unknownNotificationType => 'Tipo de notificación desconocido';
}

// Path: conversation.errors
class _TranslationsConversationErrorsEs extends TranslationsConversationErrorsEn {
	_TranslationsConversationErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pleaseSelectAUser => 'Seleccione un usuario';
	@override String get pleaseEnterATitle => 'Introduzca un título';
	@override String get clickToSelectAUser => 'Pulse para seleccionar un usuario';
	@override String get loadFailedClickToRetry => 'No se pudo cargar; pulse para reintentar';
	@override String get loadFailed => 'No se pudo cargar';
	@override String get clickToRetry => 'Pulse para reintentar';
	@override String get noMoreConversations => 'No hay más conversaciones';
}

// Path: splash.errors
class _TranslationsSplashErrorsEs extends TranslationsSplashErrorsEn {
	_TranslationsSplashErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get initializationFailed => 'Error de inicialización; reinicie la aplicación';
}

// Path: download.errors
class _TranslationsDownloadErrorsEs extends TranslationsDownloadErrorsEn {
	_TranslationsDownloadErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get imageModelNotFound => 'No se encontró el modelo de imagen';
	@override String get downloadFailed => 'No se pudo descargar';
	@override String get videoInfoNotFound => 'No se encontró la información del vídeo';
	@override String get downloadTaskAlreadyExists => 'La tarea de descarga ya existe';
	@override String get downloadTaskSavePathConflict => 'La ruta de guardado ya está en uso por otra tarea';
	@override String get videoAlreadyDownloaded => 'El vídeo ya se descargó';
	@override String downloadFailedForMessage({required Object errorInfo}) => 'No se pudo añadir la tarea de descarga: ${errorInfo}';
	@override String get userPausedDownload => 'El usuario pausó la descarga';
	@override String get unknown => 'Desconocido';
	@override String fileSystemError({required Object errorInfo}) => 'Error del sistema de archivos: ${errorInfo}';
	@override String unknownError({required Object errorInfo}) => 'Error desconocido: ${errorInfo}';
	@override String writeFileFailedForMessage({required Object errorInfo}) => 'No se pudo escribir el archivo: ${errorInfo}';
	@override String get connectionTimeout => 'Se agotó el tiempo de conexión';
	@override String get sendTimeout => 'Se agotó el tiempo de envío';
	@override String get receiveTimeout => 'Se agotó el tiempo de recepción';
	@override String serverError({required Object errorInfo}) => 'Error del servidor: ${errorInfo}';
	@override String get unknownNetworkError => 'Error de red desconocido';
	@override String get sslHandshakeFailed => 'Falló el protocolo de enlace SSL; compruebe su red';
	@override String get connectionFailed => 'No se pudo conectar; compruebe su red';
	@override String get serviceIsClosing => 'El servicio de descarga se está cerrando';
	@override String get partialDownloadFailed => 'No se pudo descargar el contenido parcial';
	@override String get noDownloadTask => 'No hay tarea de descarga';
	@override String get taskNotFoundOrDataError => 'No se encontró la tarea o hay un error en los datos';
	@override String get fileNotFound => 'No se encontró el archivo';
	@override String get openFolderFailed => 'No se pudo abrir la carpeta';
	@override String get copyDownloadUrlFailed => 'No se pudo copiar la URL de descarga';
	@override String openFolderFailedWithMessage({required Object message}) => 'No se pudo abrir la carpeta: ${message}';
	@override String get directoryNotFound => 'No se encontró el directorio';
	@override String get copyFailed => 'No se pudo copiar';
	@override String get openFileFailed => 'No se pudo abrir el archivo';
	@override String openFileFailedWithMessage({required Object message}) => 'No se pudo abrir el archivo: ${message}';
	@override String get playLocallyFailed => 'No se pudo reproducir localmente';
	@override String playLocallyFailedWithMessage({required Object message}) => 'No se pudo reproducir localmente: ${message}';
	@override String get noDownloadSource => 'No hay fuente de descarga';
	@override String get noDownloadSourceNowPleaseWaitInfoLoaded => 'No hay fuente de descarga; espere a que termine de cargarse la información e inténtelo de nuevo';
	@override String get noActiveDownloadTask => 'No hay tareas de descarga activas';
	@override String get noFailedDownloadTask => 'No hay tareas de descarga fallidas';
	@override String get noCompletedDownloadTask => 'No hay tareas de descarga completadas';
	@override String get taskAlreadyCompletedDoNotAdd => 'La tarea ya se completó; no la añada de nuevo';
	@override String get linkExpiredTryAgain => 'El enlace caducó; intentando obtener un nuevo enlace de descarga';
	@override String get linkExpiredTryAgainSuccess => 'El enlace caducó; se obtuvo un nuevo enlace de descarga';
	@override String get linkExpiredTryAgainFailed => 'El enlace caducó; no se pudo obtener un nuevo enlace de descarga';
	@override String get taskDeleted => 'Tarea eliminada';
	@override String unsupportedImageFormat({required Object format}) => 'Formato de imagen no compatible: ${format}';
	@override String get deleteFileError => 'No se pudo eliminar el archivo; quizá lo esté usando otro proceso';
	@override String get deleteTaskError => 'No se pudo eliminar la tarea';
	@override String get canNotRefreshVideoTask => 'No se pudo actualizar la tarea de vídeo';
	@override String get videoRemovedCanNotRefresh => 'Este vídeo se eliminó o ya no existe, por lo que no se puede actualizar el enlace de descarga';
	@override String get videoInaccessibleCanNotRefresh => 'No se puede acceder a este vídeo; puede ser privado o es posible que deba iniciar sesión de nuevo';
	@override String get videoQualityGone => 'Esta calidad ya no se ofrece; añada la descarga de nuevo';
	@override String get refreshLinkNetworkFailed => 'Error de red; ahora mismo no se puede actualizar el enlace de descarga. Inténtelo de nuevo más tarde';
	@override String get taskAlreadyProcessing => 'La tarea ya está en proceso';
	@override String get taskNotFound => 'No se encontró la tarea';
	@override String get failedToLoadTasks => 'No se pudieron cargar las tareas';
	@override String partialDownloadFailedWithMessage({required Object message}) => 'No se pudo completar la descarga parcial: ${message}';
	@override String unsupportedImageFormatWithMessage({required Object extension}) => 'Formato de imagen no compatible: ${extension}; puede intentar descargarla en su dispositivo para verla';
	@override String get imageLoadFailed => 'No se pudo cargar la imagen';
	@override String get pleaseTryOtherViewer => 'Intente abrirlo con otro visor';
}

// Path: download.timeline
class _TranslationsDownloadTimelineEs extends TranslationsDownloadTimelineEn {
	_TranslationsDownloadTimelineEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get today => 'Hoy';
	@override String get yesterday => 'Ayer';
	@override String get thisWeek => 'Esta semana';
	@override String get thisMonth => 'Este mes';
}

// Path: download.errorTypes
class _TranslationsDownloadErrorTypesEs extends TranslationsDownloadErrorTypesEn {
	_TranslationsDownloadErrorTypesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get network => 'Problema de red; reintentar puede ayudar';
	@override String get serverRejected => 'Rechazado por el servidor; es posible que deba iniciar sesión de nuevo';
	@override String get notFound => 'El recurso ya no existe o se eliminó';
	@override String get diskFull => 'No hay suficiente espacio de almacenamiento';
	@override String get fileInUse => 'El archivo está en uso por otro programa';
	@override String get permission => 'Sin permiso de escritura';
	@override String get cancelled => 'Cancelado';
	@override String get unknown => 'Error desconocido';
}

// Path: download.restoredPaused
class _TranslationsDownloadRestoredPausedEs extends TranslationsDownloadRestoredPausedEn {
	_TranslationsDownloadRestoredPausedEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String banner({required Object num}) => 'Se pausaron ${num} tareas sin terminar de la sesión anterior';
	@override String get resume => 'Reanudar todo';
	@override String get dismiss => 'Descartar';
}

// Path: download.actions
class _TranslationsDownloadActionsEs extends TranslationsDownloadActionsEn {
	_TranslationsDownloadActionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsDownloadNoticeEs extends TranslationsDownloadNoticeEn {
	_TranslationsDownloadNoticeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsDownloadDeleteByDateEs extends TranslationsDownloadDeleteByDateEn {
	_TranslationsDownloadDeleteByDateEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get menuTitle => 'Eliminar por fecha';
	@override String get dialogTitle => 'Eliminar por fecha';
	@override String get description => 'Elimine tareas de descarga en bloque según su fecha de creación. Las tareas cuyos archivos estén en uso se omiten; las tareas cuyos archivos ya no existan se limpian.';
	@override String get modeRange => 'Intervalo de fechas';
	@override String get modeDays => 'Más antiguas que';
	@override String get startDate => 'Fecha de inicio';
	@override String get endDate => 'Fecha de fin';
	@override String get notSet => 'Sin establecer';
	@override String get daysUnit => 'días';
	@override String olderThanDaysHint({required Object days}) => 'Eliminar las tareas creadas hace más de ${days} día(s)';
	@override String get noMatch => 'Ninguna tarea coincide con la condición seleccionada';
	@override String get invalidRange => 'La fecha de inicio debe ser anterior o igual a la fecha de fin';
	@override String get confirmTitle => 'Confirmar eliminación';
	@override String confirmContent({required Object count}) => '¿Eliminar ${count} tareas de descarga y sus archivos? Esta acción no se puede deshacer.';
	@override String deleting({required Object done, required Object total}) => 'Eliminando ${done}/${total}…';
	@override String resultSuccess({required Object count}) => 'Se eliminaron ${count} tarea(s)';
	@override String resultPartial({required Object deleted, required Object skipped}) => 'Se eliminaron ${deleted} tarea(s); ${skipped} omitidas (en uso)';
}

// Path: download.relocation
class _TranslationsDownloadRelocationEs extends TranslationsDownloadRelocationEn {
	_TranslationsDownloadRelocationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsDownloadCategoryEs extends TranslationsDownloadCategoryEn {
	_TranslationsDownloadCategoryEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get manageTitle => 'Gestionar categorías';
	@override String get label => 'Categorías';
	@override String get uncategorized => 'Sin categoría';
	@override String get manage => 'Gestionar';
	@override String get createShortcut => 'Nueva';
	@override String get newCategoryHint => 'Nombre de la nueva categoría';
	@override String get createSuccess => 'Categoría creada';
	@override String get createFailed => 'No se pudo crear la categoría';
	@override String get nameEmpty => 'El nombre de la categoría no puede estar vacío';
	@override String get emptyHint => 'Aún no hay categorías. Cree una para organizar sus descargas.';
	@override String get moveTo => 'Mover a categoría';
	@override String moveToWithCount({required Object count}) => 'Mover ${count} elemento(s) a…';
	@override String moveSuccess({required Object title}) => 'Movido a ${title}';
	@override String get moveToUncategorizedSuccess => 'Movido a Sin categoría';
	@override String get moveFailed => 'No se pudo mover';
	@override String get renameTitle => 'Cambiar nombre de la categoría';
	@override String get renameHint => 'Introduzca el nombre de la categoría';
	@override String get renameSuccess => 'Se cambió el nombre de la categoría';
	@override String get renameFailed => 'No se pudo cambiar el nombre de la categoría';
	@override String get deleteTitle => 'Eliminar categoría';
	@override String deleteConfirm({required Object title, required Object count}) => '¿Eliminar la categoría "${title}"? Los ${count} elementos que contiene pasarán a Sin categoría. No se elimina ningún archivo.';
	@override String get deleteSuccess => 'Categoría eliminada';
	@override String get deleteFailed => 'No se pudo eliminar la categoría';
}

// Path: download.location
class _TranslationsDownloadLocationEs extends TranslationsDownloadLocationEn {
	_TranslationsDownloadLocationEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsDownloadBatchDownloadEs extends TranslationsDownloadBatchDownloadEn {
	_TranslationsDownloadBatchDownloadEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Descarga por lotes';
	@override String get downloadTaskAlreadyRunning => 'Ya hay una tarea en curso; espere, por favor.';
	@override String get userCancelled => 'Cancelado por el usuario';
	@override String get failedToGetVideoInfo => 'No se pudo obtener la información del vídeo';
	@override String get failedToGetVideoSource => 'No se pudo obtener la fuente del vídeo';
	@override String get failedToGetGalleryInfo => 'No se pudo obtener la información de la galería';
	@override String get galleryNoImages => 'La galería no tiene imágenes';
	@override String get failedToGetSavePath => 'No se pudo obtener la ruta de guardado';
	@override String batchDownloadFailedWithException({required Object exception}) => 'Error en la descarga por lotes: ${exception}';
	@override String get selectQuality => 'Seleccionar calidad';
	@override String get downloading => 'Descargando';
	@override String get downloadResult => 'Resultado de la descarga';
	@override String selectedVideosCount({required Object count}) => '${count} vídeos seleccionados';
	@override String selectedGalleriesCount({required Object count}) => '${count} galerías seleccionadas';
	@override String get qualityNote => 'Si la calidad seleccionada no está disponible, se usará la mejor calidad disponible';
	@override String progress({required Object current, required Object total}) => 'Procesando ${current}/${total}';
	@override String get queued => 'En cola';
	@override String get success => 'Correcto';
	@override String get skipped => 'Omitido';
	@override String get failed => 'Fallido';
	@override String get failureDetails => 'Detalles del fallo';
	@override String get reasonPrivateVideo => 'Vídeo privado';
	@override String get reasonAlreadyExists => 'Ya existe';
	@override String get reasonNoSource => 'No hay fuente de descarga';
	@override String get reasonNoSavePath => 'No se puede obtener la ruta de guardado';
	@override String get reasonOther => 'Otro error';
	@override String get startDownload => 'Iniciar descarga';
}

// Path: favorite.errors
class _TranslationsFavoriteErrorsEs extends TranslationsFavoriteErrorsEn {
	_TranslationsFavoriteErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get addFailed => 'No se pudo añadir';
	@override String get addSuccess => 'Añadido correctamente';
	@override String get deleteFolderFailed => 'No se pudo eliminar la carpeta';
	@override String get deleteFolderSuccess => 'Carpeta eliminada correctamente';
	@override String get folderNameCannotBeEmpty => 'El nombre de la carpeta no puede estar vacío';
}

// Path: translation.presetNames
class _TranslationsTranslationPresetNamesEs extends TranslationsTranslationPresetNamesEn {
	_TranslationsTranslationPresetNamesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get openai => 'OpenAI (GPT-4o / GPT-4.1)';
	@override String get openaiReasoning => 'Razonamiento de OpenAI (o1 / o3 / o4)';
	@override String get anthropic => 'Anthropic Claude';
	@override String get anthropicReasoning => 'Razonamiento de Anthropic Claude (pensamiento extendido)';
	@override String get gemini => 'Google Gemini (nativo)';
	@override String get geminiReasoning => 'Razonamiento de Google Gemini (pensamiento)';
	@override String get deepseek => 'DeepSeek (deepseek-chat)';
	@override String get deepseekReasoner => 'Razonamiento de DeepSeek (deepseek-reasoner / R1)';
	@override String get siliconflow => 'SiliconFlow';
	@override String get zhipu => 'Zhipu GLM';
}

// Path: mediaPlayer.notice
class _TranslationsMediaPlayerNoticeEs extends TranslationsMediaPlayerNoticeEn {
	_TranslationsMediaPlayerNoticeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String semanticsPrefix({required Object message}) => 'Aviso de reproducción: ${message}';
	@override String get networkUnstable => 'Compruebe su red; la reproducción puede entrecortarse';
	@override String get audioTrackUnavailable => 'No hay sonido disponible; el vídeo sigue reproduciéndose';
	@override String get hardwareDecodeFellBack => 'Se cambió a la decodificación por software; puede consumir más energía';
	@override String get videoDecodeProblem => 'Pruebe otra calidad; la imagen puede presentar fallos';
	@override String get repeatedPlaybackProblems => 'Exporte los registros para informar de problemas de reproducción repetidos';
	@override String get issuesSheetTitle => 'Problemas de reproducción';
	@override String issueOccurrences({required Object count}) => 'Ocurrió ${count} veces';
	@override String issueAtPosition({required Object position}) => 'En ${position}';
	@override String get noIssuesRecorded => 'No se registraron problemas';
	@override String get exportLogsAction => 'Exportar registros';
}

// Path: diagnostics.healthAlert
class _TranslationsDiagnosticsHealthAlertEs extends TranslationsDiagnosticsHealthAlertEn {
	_TranslationsDiagnosticsHealthAlertEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get flushFailureTitle => 'Fallos de vaciado';
	@override String get sinkDegradedTitle => 'Escritura de registros degradada';
	@override String get sinkDegradedDetail => 'El destino de archivo está en estado degradado';
	@override String get queueBacklogTitle => 'Acumulación en la cola de escritura';
	@override String queueBacklogDetail({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (umbral=${threshold}, puede aumentar el uso de memoria)';
	@override String get highFlushLatencyTitle => 'Latencia de vaciado alta';
	@override String get droppedTooManyTitle => 'Demasiados registros descartados';
	@override String droppedTooManyDetail({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (umbral=${threshold})';
	@override String get rateLimitedTitle => 'Se activó la limitación de frecuencia';
	@override String get exportFailedTitle => 'Fallos al exportar registros';
	@override String get fileNearLimitTitle => 'El archivo de registro se acerca al límite de tamaño';
	@override String fileNearLimitDetail({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (mayor presión de rotación de E/S)';
}

// Path: diagnostics.toast
class _TranslationsDiagnosticsToastEs extends TranslationsDiagnosticsToastEn {
	_TranslationsDiagnosticsToastEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get logServiceNotInitialized => 'El servicio de registros no está inicializado';
	@override String get exportSuccess => 'Registros exportados. Revise los datos privados antes de enviarlos por correo.';
	@override String exportFailed({required Object error}) => 'No se pudo exportar: ${error}';
	@override String get supportEmailCopied => 'Correo de soporte copiado. Péguelo en su cliente de correo y adjunte los registros.';
}

// Path: searchFilter.sortTypes
class _TranslationsSearchFilterSortTypesEs extends TranslationsSearchFilterSortTypesEn {
	_TranslationsSearchFilterSortTypesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get relevance => 'Relevancia';
	@override String get latest => 'Recientes';
	@override String get views => 'Visualizaciones';
	@override String get likes => 'Me gusta';
}

// Path: firstTimeSetup.welcome
class _TranslationsFirstTimeSetupWelcomeEs extends TranslationsFirstTimeSetupWelcomeEn {
	_TranslationsFirstTimeSetupWelcomeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bienvenido';
	@override String get subtitle => 'Comencemos con su configuración personalizada';
	@override String get description => 'Solo unos pocos pasos para adaptar la mejor experiencia a sus necesidades';
}

// Path: firstTimeSetup.basic
class _TranslationsFirstTimeSetupBasicEs extends TranslationsFirstTimeSetupBasicEn {
	_TranslationsFirstTimeSetupBasicEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes básicos';
	@override String get subtitle => 'Personalice su experiencia';
	@override String get description => 'Elija las preferencias que más le convengan';
}

// Path: firstTimeSetup.network
class _TranslationsFirstTimeSetupNetworkEs extends TranslationsFirstTimeSetupNetworkEn {
	_TranslationsFirstTimeSetupNetworkEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes de red';
	@override String get subtitle => 'Configure las opciones de red';
	@override String get description => 'Ajústelo según su entorno de red';
	@override String get tip => 'Es necesario reiniciar tras configurarlo correctamente para que surta efecto';
}

// Path: firstTimeSetup.theme
class _TranslationsFirstTimeSetupThemeEs extends TranslationsFirstTimeSetupThemeEn {
	_TranslationsFirstTimeSetupThemeEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes de tema';
	@override String get subtitle => 'Elija el aspecto que prefiera';
	@override String get description => 'Personalice su experiencia visual';
}

// Path: firstTimeSetup.player
class _TranslationsFirstTimeSetupPlayerEs extends TranslationsFirstTimeSetupPlayerEn {
	_TranslationsFirstTimeSetupPlayerEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes del reproductor';
	@override String get subtitle => 'Configure los controles de reproducción';
	@override String get description => 'Configure rápidamente las preferencias de reproducción más habituales';
}

// Path: firstTimeSetup.spatial
class _TranslationsFirstTimeSetupSpatialEs extends TranslationsFirstTimeSetupSpatialEn {
	_TranslationsFirstTimeSetupSpatialEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Reproducción espacial';
	@override String get subtitle => 'Ver y explorar contenido en el visor';
	@override String get description => 'En el visor, los vídeos y las galerías aparecen en el espacio que le rodea en lugar de dentro de este panel flotante';
}

// Path: firstTimeSetup.completion
class _TranslationsFirstTimeSetupCompletionEs extends TranslationsFirstTimeSetupCompletionEn {
	_TranslationsFirstTimeSetupCompletionEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Completar configuración';
	@override String get subtitle => 'Ya está listo para comenzar';
	@override String get description => 'Lea y acepte los acuerdos correspondientes';
	@override String get agreementTitle => 'Acuerdo de usuario y normas de la comunidad';
	@override String get agreementDesc => 'Antes de usar esta aplicación, lea atentamente y acepte nuestro acuerdo de usuario y las normas de la comunidad. Estas condiciones ayudan a mantener un buen ambiente.';
	@override String get checkboxTitle => 'He leído y acepto el acuerdo de usuario y las normas de la comunidad';
	@override String get checkboxSubtitle => 'No podrá usar la aplicación si no está de acuerdo';
}

// Path: firstTimeSetup.common
class _TranslationsFirstTimeSetupCommonEs extends TranslationsFirstTimeSetupCommonEn {
	_TranslationsFirstTimeSetupCommonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get settingsChangeableTip => 'Estos ajustes se pueden cambiar en cualquier momento en Ajustes';
	@override String get previousStep => 'Paso anterior';
	@override String get nextStep => 'Siguiente paso';
	@override String get finishSetup => 'Finalizar configuración';
	@override String get agreeAgreementSnackbar => 'Acepte primero el acuerdo de usuario y las normas de la comunidad';
}

// Path: anime4k.presetGroups
class _TranslationsAnime4kPresetGroupsEs extends TranslationsAnime4kPresetGroupsEn {
	_TranslationsAnime4kPresetGroupsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get highQuality => 'Alta calidad';
	@override String get fast => 'Rápido';
	@override String get lite => 'Ligero';
	@override String get moreLite => 'Más ligero';
	@override String get custom => 'Personalizado';
}

// Path: anime4k.presetDescriptions
class _TranslationsAnime4kPresetDescriptionsEs extends TranslationsAnime4kPresetDescriptionsEn {
	_TranslationsAnime4kPresetDescriptionsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get mode_a_hq => 'Adecuado para la mayoría de animaciones en 1080p, sobre todo las que presentan desenfoque, remuestreo y artefactos de compresión. Ofrece la mayor calidad percibida.';
	@override String get mode_b_hq => 'Adecuado para animaciones con un ligero desenfoque o efecto de anillo causado por el escalado. Reduce eficazmente el efecto de anillo y el aliasing.';
	@override String get mode_c_hq => 'Adecuado para fuentes de alta calidad (como animaciones o películas nativas en 1080p). Elimina el ruido y ofrece el PSNR más alto.';
	@override String get mode_a_a_hq => 'Versión mejorada del modo A que ofrece la máxima calidad percibida y puede reconstruir casi todas las líneas degradadas. Puede provocar un exceso de nitidez o efecto de anillo.';
	@override String get mode_b_b_hq => 'Versión mejorada del modo B, que ofrece mayor calidad percibida, optimiza aún más las líneas y reduce los artefactos.';
	@override String get mode_c_a_hq => 'Versión del modo C con calidad percibida mejorada, que mantiene un PSNR alto y trata de reconstruir parte del detalle de las líneas.';
	@override String get mode_a_fast => 'Versión rápida del modo A que equilibra calidad y rendimiento; adecuada para la mayoría de animaciones en 1080p.';
	@override String get mode_b_fast => 'Versión rápida del modo B para tratar artefactos leves y efecto de anillo con un menor consumo.';
	@override String get mode_c_fast => 'Versión rápida del modo C, para eliminar ruido y escalar rápidamente fuentes de alta calidad.';
	@override String get mode_a_a_fast => 'Versión rápida del modo A+A, que busca una mayor calidad percibida en dispositivos con rendimiento limitado.';
	@override String get mode_b_b_fast => 'Versión rápida del modo B+B, que ofrece una reparación de líneas y un procesamiento de artefactos mejorados para dispositivos con rendimiento limitado.';
	@override String get mode_c_a_fast => 'Versión rápida del modo C+A, que procesa rápidamente fuentes de alta calidad y aporta una reparación ligera de líneas.';
	@override String get upscale_only_s => 'Escalado x2 ultrarrápido usando solo el modelo CNN más rápido, sin reparación ni eliminación de ruido y con un consumo mínimo.';
	@override String get upscale_deblur_fast => 'Escalado y reducción de desenfoque rápidos mediante algoritmos tradicionales sin CNN; mejores que los del reproductor predeterminado y con un consumo muy bajo.';
	@override String get restore_s_only => 'Solo reparación con el modelo CNN más rápido, sin escalado. Adecuado para reproducir en resolución nativa cuando se desea mejorar la calidad.';
	@override String get denoise_bilateral_fast => 'Eliminación de ruido rápida mediante filtrado bilateral tradicional; muy veloz y adecuada para tratar ruido leve.';
	@override String get upscale_non_cnn => 'Escalado rápido con algoritmos tradicionales, con un consumo muy bajo y mejor que los ajustes predeterminados del reproductor.';
	@override String get mode_a_fast_darken => 'Modo A (rápido) + oscurecimiento de líneas, que añade este efecto sobre el modo A rápido para lograr líneas más marcadas y estilizadas.';
	@override String get mode_a_hq_thin => 'Modo A (alta calidad) + adelgazamiento de líneas, que añade este efecto sobre el modo A de alta calidad para un aspecto más fino.';
}

// Path: anime4k.presetNames
class _TranslationsAnime4kPresetNamesEs extends TranslationsAnime4kPresetNamesEn {
	_TranslationsAnime4kPresetNamesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
	@override String get upscale_only_s => 'Escalado con CNN (ultrarrápido)';
	@override String get upscale_deblur_fast => 'Escalado y reducción de desenfoque (rápido)';
	@override String get restore_s_only => 'Restauración (ultrarrápida)';
	@override String get denoise_bilateral_fast => 'Eliminación de ruido bilateral (ultrarrápida)';
	@override String get upscale_non_cnn => 'Escalado sin CNN (ultrarrápido)';
	@override String get mode_a_fast_darken => 'Modo A (rápido) + oscurecimiento de líneas';
	@override String get mode_a_hq_thin => 'Modo A (alta calidad) + adelgazamiento de líneas';
}

// Path: localMedia.browse
class _TranslationsLocalMediaBrowseEs extends TranslationsLocalMediaBrowseEn {
	_TranslationsLocalMediaBrowseEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pinnedSection => 'Acceso rápido';
	@override String get sourcesSection => 'Carpetas';
	@override String get pin => 'Añadir a acceso rápido';
	@override String get unpin => 'Quitar del acceso rápido';
	@override String get pinned => 'Añadido a acceso rápido';
	@override String get unpinned => 'Quitado del acceso rápido';
	@override String folderCount({required Object count}) => '${count} carpetas';
	@override String videoCount({required Object count}) => '${count} vídeos';
	@override String imageCount({required Object count}) => '${count} imágenes';
	@override String get emptyFolder => 'Esta carpeta está vacía';
	@override String get videosSection => 'Vídeos';
	@override String get imagesSection => 'Imágenes';
	@override String get galleriesSection => 'Galerías';
	@override String get filterAll => 'Todo';
	@override String get searchInFolder => 'Buscar en esta carpeta';
	@override String get searchHint => 'Buscar por nombre';
	@override String get clearSearch => 'Borrar búsqueda';
	@override String searchNoResult({required Object query}) => 'No hay coincidencias con «${query}»';
	@override String viewAllFolders({required Object count}) => 'Ver las ${count} carpetas';
	@override String viewAllVideos({required Object count}) => 'Ver los ${count} vídeos';
	@override String viewAllImages({required Object count}) => 'Ver las ${count} imágenes';
	@override String viewAllGalleries({required Object count}) => 'Ver las ${count} galerías';
	@override String get location => 'Ubicación';
	@override String get sourceMissing => 'Esta fuente ya no existe';
	@override String get notScannedYet => 'Esta carpeta aún no se ha escaneado';
	@override String get scanning => 'Leyendo esta carpeta…';
	@override String get deleteFileTitle => '¿Eliminar este archivo?';
	@override String deleteFileBody({required Object name}) => '"${name}" se eliminará permanentemente de este dispositivo. Esta acción no se puede deshacer.';
	@override String get hideFolder => 'Ocultar esta carpeta';
	@override String get unhideFolder => 'Mostrar de nuevo';
	@override String get showHiddenFolders => 'Mostrar carpetas ocultas';
	@override String get includeDotFolders => 'Escanear carpetas que empiezan por .';
	@override String get dotFoldersIncluded => 'Ahora se escanean las carpetas que empiezan por .';
	@override String get dotFoldersExcluded => 'Ya no se escanean las carpetas que empiezan por .';
	@override String get showDotFolders => 'Mostrar carpetas que empiezan por .';
	@override String dotFoldersSkipped({required Object count}) => 'Aquí hay ${count} carpetas que empiezan por . sin escanear';
	@override String get scanDotFoldersAction => 'Activar para esta fuente';
	@override String get otherAppsPrivateNotice => 'Desde Android 11 ninguna app puede leer los archivos de otras apps en Android/data o Android/obb, y esta app no puede evitarlo. Descarga o exporta los vídeos a una carpeta pública como Download en la app original y luego añade esa carpeta aquí. Las cachés de reproducción suelen estar fragmentadas y no se pueden reproducir aunque se lean.';
	@override String get folderHidden => 'Oculta; el escaneo también la omitirá';
	@override String get folderUnhidden => 'Ya no está oculta';
	@override String get hiddenFolderBadge => 'Oculta';
	@override String get deleteFolder => 'Eliminar carpeta';
	@override String get deleteFolderTitle => '¿Eliminar esta carpeta?';
	@override String deleteFolderBody({required Object name}) => '«${name}» y todo su contenido se eliminarán definitivamente de este dispositivo. No se puede deshacer.';
	@override String get deleteFolderIncludesOthers => 'Los demás archivos que contenga también se eliminarán';
	@override String get folderDeleted => 'Carpeta eliminada';
	@override String get deleteFolderFailed => 'No se pudo eliminar: sin permisos o hay un archivo en uso';
	@override String get deleteGalleryTitle => '¿Eliminar esta galería?';
	@override String deleteGalleryBody({required Object name}) => 'Se eliminarán el registro de descarga y los archivos de imagen locales de "${name}". Esta acción no se puede deshacer.';
	@override String get galleryResourceMissing => 'Los archivos locales ya no existen. Se limpió el registro.';
	@override String get viewDownloadDetail => 'Ver los detalles de la descarga';
	@override String get viewOnlineGallery => 'Ver en el sitio web';
	@override String get pickFolderTitle => 'Elija una carpeta';
	@override String get useThisFolder => 'Usar esta carpeta';
	@override String get noSubfolders => 'Aquí no hay subcarpetas';
	@override String get storageRoot => 'Almacenamiento del dispositivo';
	@override String get homeFolder => 'Inicio';
	@override String get filesystemRoot => 'Raíz del sistema de archivos';
	@override String get folderUnreadable => 'No se puede leer esta carpeta';
	@override String get setCover => 'Establecer portada';
	@override String get setAsFolderCover => 'Usar como portada de la carpeta';
	@override String get folderCoverSet => 'Portada de la carpeta actualizada';
	@override String get setFolderCoverPick => 'Establecer portada…';
	@override String get restoreAutoCover => 'Restaurar la portada automática';
	@override String get autoCoverRestored => 'Se restauró la portada automática';
	@override String get rescanFolder => 'Volver a escanear esta carpeta';
	@override String get coverPickerTitle => 'Elegir un fotograma';
	@override String get folderCoverPickerTitle => 'Elegir portada';
	@override String get coverPickerEmpty => 'Aún no hay imágenes disponibles en esta carpeta. Es posible que las miniaturas de vídeo se sigan generando en segundo plano.';
	@override String get coverSaved => 'Portada actualizada';
	@override String get coverSaveFailed => 'No se pudo guardar la portada';
	@override String get coverUnavailable => 'No se pudo leer ningún fotograma de vídeo de este archivo';
	@override String get deleted => 'Eliminado';
	@override String get deleteFailed => 'No se pudo eliminar: puede que el archivo esté en uso o que no se pueda escribir en él';
	@override String get openFolder => 'Abrir';
	@override String get favorite => 'Añadir a favoritos';
	@override String get unfavorite => 'Quitar de favoritos';
	@override String get favorited => 'Añadido a favoritos';
	@override String get unfavorited => 'Quitado de favoritos';
	@override String get sortBy => 'Ordenar por';
	@override String get sortAscending => 'Ascendente';
	@override String get sortDescending => 'Descendente';
	@override String get sortFieldName => 'Nombre';
	@override String get sortFieldModified => 'Fecha de modificación';
	@override String get sortFieldDuration => 'Duración';
	@override String get sortFieldSize => 'Tamaño';
	@override String get sortFieldResolution => 'Resolución';
	@override String get sortFieldFileType => 'Tipo de archivo';
	@override String get sortFieldFps => 'Frecuencia de fotogramas';
	@override String get sortFieldFavorited => 'Fecha de añadido a favoritos';
	@override String get emptyAllVideos => 'Aún no se han encontrado vídeos. Para empezar, añada una carpeta en Carpetas.';
	@override String get emptyAllImages => 'Aún no se han encontrado imágenes. Para empezar, añada una carpeta en Carpetas.';
	@override String get emptyFavorites => 'Aún no hay favoritos. Añada uno desde el menú ⋮ de un vídeo.';
	@override String get emptyPinned => 'Aún no hay carpetas fijadas. Mantenga pulsada una carpeta en Carpetas y elija Fijar.';
	@override String get emptyDownloadedVideos => 'Aún no hay descargas de vídeos finalizadas.';
	@override String get emptyDownloadedGalleries => 'Aún no hay descargas de galerías finalizadas.';
	@override String get folderInfo => 'Información de la carpeta';
	@override String get folderInfoName => 'Nombre';
	@override String get folderInfoPath => 'Ruta';
	@override String get folderInfoSource => 'Fuente';
	@override String get folderInfoContents => 'Contenido';
	@override String get folderInfoSize => 'Tamaño en disco';
	@override String get folderInfoScannedAt => 'Último escaneo';
	@override String get folderInfoNeverScanned => 'Sin escanear todavía';
	@override String get folderInfoNoPath => 'Esta fuente no tiene ninguna carpeta que abrir';
	@override String get copyPath => 'Copiar ruta';
	@override String get pathCopied => 'Ruta copiada';
}

// Path: localMedia.itemInfoLabels
class _TranslationsLocalMediaItemInfoLabelsEs extends TranslationsLocalMediaItemInfoLabelsEn {
	_TranslationsLocalMediaItemInfoLabelsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsLocalMediaMissingEs extends TranslationsLocalMediaMissingEn {
	_TranslationsLocalMediaMissingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsLocalMediaWebdavEs extends TranslationsLocalMediaWebdavEn {
	_TranslationsLocalMediaWebdavEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

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
class _TranslationsSettingsDownloadSettingsPathTemplateEditorEs extends TranslationsSettingsDownloadSettingsPathTemplateEditorEn {
	_TranslationsSettingsDownloadSettingsPathTemplateEditorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Plantilla de ruta';
	@override String get subtitle => 'Organiza automáticamente las descargas en subcarpetas';
	@override String get tabVideo => 'Vídeo';
	@override String get tabGallery => 'Galería';
	@override String get tabImage => 'Imagen individual';
	@override String get previewLabel => 'Vista previa · resultado real tras la limpieza';
	@override String get galleryPreviewLabel => 'Vista previa · la plantilla de galería nombra la carpeta (las imágenes internas usan el ID)';
	@override String get addFolder => 'Añadir un nivel de carpeta';
	@override String get folderCapReached => 'Límite de niveles de carpeta alcanzado';
	@override String get folderSegmentHint => '%authorcache, una variable o texto fijo';
	@override String get fileSegmentHint => 'p. ej. %title_%quality';
	@override String videoCapNote({required Object max}) => 'La extensión .mp4 se añade sola · escribir / en un segmento lo divide en dos niveles · hasta ${max} niveles';
	@override String imageCapNote({required Object max}) => 'La extensión original se añade sola · escribir / en un segmento lo divide en dos niveles · hasta ${max} niveles';
	@override String galleryCapNote({required Object max}) => 'La plantilla de galería son solo carpetas, hasta ${max} niveles · las imágenes internas se nombran con el ID de imagen';
	@override String get trayHint => 'Toca para insertar en el cursor · mantén pulsado para detalles';
	@override String get emptySegment => 'Segmento vacío';
	@override String get emptySegmentSaveBlocked => 'No se puede guardar: hay segmentos vacíos, rellénalos o elimínalos';
	@override String get tooManySegmentsSaveBlocked => 'No se puede guardar: demasiados segmentos de ruta (máx. 4). Combínalos o elimínalos';
	@override String get templateInvalidSaveBlocked => 'No se puede guardar: la plantilla contiene caracteres no válidos';
	@override String get variableInserted => 'Variable insertada';
	@override String get savedToast => 'Guardado · solo afecta a descargas futuras';
	@override String get trayCategoryContent => 'Contenido';
	@override String get trayCategoryAuthor => 'Autor';
	@override String get trayCategoryTime => 'Tiempo';
	@override String get chipAuthorcache => 'Nombre del autor·fijo';
	@override String get chipDate => 'Fecha';
	@override String get chipTime => 'Hora';
	@override String get chipDatetime => 'Fecha y hora';
	@override String get chipCount => 'Índice';
}

// Path: videoDetail.gestureGuide.quest
class _TranslationsVideoDetailGestureGuideQuestEs extends TranslationsVideoDetailGestureGuideQuestEn {
	_TranslationsVideoDetailGestureGuideQuestEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Familiarícese con Quest';
	@override String get intro => 'Vea qué hace cada control y luego pruébelo en su espacio.';
	@override String get videoTab => 'Video espacial';
	@override String get galleryTab => 'Galería espacial';
	@override String get scopeNote => 'Para pantallas y ventanas en su espacio de Quest. Vuelva a abrirla cuando quiera desde los ajustes del reproductor.';
	@override String get catalog => 'Explorar los controles';
	@override String lessonCount({required Object current, required Object total}) => '${current} de ${total}';
	@override String get previous => 'Anterior';
	@override String get next => 'Siguiente control';
	@override String get replay => 'Repetir la demostración';
	@override String get pauseDemo => 'Pausar la demostración';
	@override String get resumeDemo => 'Reanudar la demostración';
	@override String get looping => 'Demostración de control';
	@override String get still => 'Ilustración fija';
	@override String get done => 'Entendido, continuar';
	@override String get leftController => 'Mano izquierda';
	@override String get rightController => 'Mano derecha';
	@override String get trigger => 'Gatillo índice';
	@override String get grip => 'Botón de agarre';
	@override String get bothGrips => 'Ambos botones de agarre';
	@override String get stick => 'Joystick';
	@override String get handTracking => 'Seguimiento de manos';
	@override String get ready => 'Listo';
	@override String get press => 'Pulsar';
	@override String get hold => 'Mantener';
	@override String get release => 'Soltar';
	@override String get result => 'Ver el resultado';
	@override String get pinch => 'Pellizcar';
	@override String get selectTitle => 'Apuntar y seleccionar';
	@override String get selectBody => 'Apunte el rayo a un botón y luego pulse y suelte el gatillo índice. Úselo para reproducir, ajustes y controles deslizantes en el panel de control.';
	@override String get selectHint => 'El gatillo índice está detrás de la cara del botón. El botón de agarre del asa interior agarra ventanas.';
	@override String get panelTitle => 'Mostrar u ocultar el panel';
	@override String get panelBody => 'Apunte fuera del panel de control y pulse el gatillo índice para mostrarlo u ocultarlo. Con el seguimiento de manos, un pellizco rápido fuera del panel hace lo mismo.';
	@override String get panelHint => 'Use un toque corto sin arrastrar. Mantener y mover es un arrastre, no un cambio del panel.';
	@override String get playTitle => 'Reproducir y pausar';
	@override String get playBody => 'Apunte fuera del panel de control y pulse A en el derecho o X en el izquierdo para reproducir o pausar. También puede seleccionar el botón de reproducir del panel.';
	@override String get playHint => 'Este atajo predeterminado puede desactivarse en los ajustes del reproductor espacial. Al apuntar al panel, la entrada va al panel.';
	@override String get seekTitle => 'Desplazarse con el joystick';
	@override String get seekBody => 'Mueva cualquiera de los joysticks a izquierda o derecha para un salto de 5 segundos. Manténgalo para desplazarse más rápido mientras previsualiza el tiempo objetivo. Suelte para confirmar la búsqueda.';
	@override String get seekHint => 'Mantenga el rayo de ese controlador fuera del panel de control. Un joystick que apunta al panel desplaza el panel en su lugar.';
	@override String get browseTitle => 'Navegar con el joystick';
	@override String get browseBody => 'Mueva cualquiera de los joysticks a izquierda o derecha para el elemento anterior o siguiente; mantenga para seguir navegando. También puede seleccionar una miniatura en la tira de película.';
	@override String get browseHint => 'Los videos de una galería también son elementos. Apuntar al panel de control hace que el joystick desplace el panel.';
	@override String get swipeTitle => 'Arrastrar a lo ancho para pasar de página';
	@override String get swipeBody => 'Apunte a la imagen, mantenga el gatillo índice y arrastre a la izquierda. Suelte tras la señal de cambio de página para avanzar; arrastre a la derecha para retroceder. También funciona pellizcar y arrastrar.';
	@override String get swipeHint => 'Las imágenes deben estar a 1× para pasar páginas arrastrando. Los videos de galería también lo admiten. El escenario permanece inmóvil hasta que suelte.';
	@override String get zoomTitle => 'Ampliar la imagen';
	@override String get zoomBody => 'Apunte a un detalle de la imagen, mantenga el gatillo índice y luego empuje el joystick hacia arriba para ampliar o hacia abajo para reducir. El zoom se fija donde pulsó.';
	@override String get zoomHint => 'Esto amplía la imagen dentro de su ventana. Sin mantener la imagen, arriba/abajo ajusta la distancia de visualización.';
	@override String get panTitle => 'Desplazar y restaurar la imagen';
	@override String get panBody => 'Una vez ampliada, mantenga el gatillo índice y arrastre para mirar alrededor. Toque dos veces la imagen para ampliarla a 2,5× o restaurarla. Con las manos, pellizque dos veces rápido.';
	@override String get panHint => 'Arrastrar desplaza una imagen ampliada. Restaure a 1× antes de arrastrar para pasar páginas.';
	@override String get slideshowTitle => 'Iniciar una presentación';
	@override String get slideshowBody => 'En una imagen, A / X inicia o pausa la presentación. El panel ofrece intervalos de 3, 5, 10 o 20 segundos y calidad de imagen estándar u original.';
	@override String get slideshowHint => 'En un video de galería, A / X controla la reproducción de ese video. El atajo del controlador debe estar activado en los ajustes.';
	@override String get moveTitle => 'Agarrar y mover la pantalla';
	@override String get moveBody => 'Mantenga el botón de agarre en el asa interior, mueva el controlador para colocar la pantalla y suelte. Mientras ve, puede agarrar la pantalla sin apuntar a ella.';
	@override String get moveHint => 'Apuntar a la ventana de la aplicación o al panel de control agarra esa ventana primero. En video panorámico, agarrar ajusta la orientación.';
	@override String get scaleTitle => 'Redimensionar con ambas manos';
	@override String get scaleBody => 'Mantenga ambos botones de agarre. Separe las manos para ampliar la pantalla o júntelas para reducirla. Con el seguimiento de manos, mantenga un pellizco en ambas manos.';
	@override String get scaleHint => 'Para pantallas planas o curvas, incluido el escenario de la galería. Mantenga los rayos fuera del panel de control. Esto redimensiona toda la pantalla.';
	@override String get distanceTitle => 'Ajustar la distancia de visualización';
	@override String get distanceBody => 'Empuje el joystick hacia arriba para alejar la pantalla o hacia abajo para acercarla. Mientras agarra una ventana, arriba/abajo mueve esa ventana. Ajuste el volumen en el panel.';
	@override String get distanceHint => 'Apunte fuera del panel de control. Mantener una imagen cambia arriba/abajo a zoom de imagen; los videos panorámicos ajustan la vista.';
	@override String get resizeTitle => 'Usar los bordes y las esquinas';
	@override String get resizeBody => 'El marco se ilumina a medida que el rayo se acerca a un borde. Mantenga el gatillo o pellizque en un borde para mover la ventana; arrastre una esquina para redimensionarla.';
	@override String get resizeHint => 'Funciona en la ventana de la aplicación, el panel de control y la pantalla. La ventana de la aplicación cambia de ancho y alto; las pantallas conservan su relación de aspecto.';
	@override String get navigationTitle => 'Volver y abrir los ajustes';
	@override String get navigationBody => 'B / Y retrocede un nivel: cierra una ventana emergente o vuelve al inicio del panel, oculta el panel y luego vuelve a la aplicación. El botón Menú izquierdo abre los ajustes espaciales.';
	@override String get navigationHint => 'El botón Meta derecho pertenece al sistema. El recentrado del sistema devuelve la vista al frente conservando el tamaño y la distancia de la pantalla.';
	@override String get handsTitle => 'Use las manos';
	@override String get handsBody => 'Con el seguimiento de manos activado, apunte el rayo del sistema a un botón, pellizque con el pulgar y el índice y suelte. Use el panel para la reproducción, la búsqueda y la navegación por la galería.';
	@override String get handsHint => 'Pellizque fuera para mostrar u ocultar el panel. Pellizque un borde para moverlo, una esquina para redimensionarlo, o pellizque con ambas manos y separe para ampliar la pantalla.';
}

// Path: videoDetail.cast.deviceTypes
class _TranslationsVideoDetailCastDeviceTypesEs extends TranslationsVideoDetailCastDeviceTypesEn {
	_TranslationsVideoDetailCastDeviceTypesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get mediaRenderer => 'Reproductor multimedia';
	@override String get mediaServer => 'Servidor multimedia';
	@override String get internetGatewayDevice => 'Router';
	@override String get basicDevice => 'Dispositivo básico';
	@override String get dimmableLight => 'Luz inteligente';
	@override String get wlanAccessPoint => 'Punto de acceso WLAN';
	@override String get wlanConnectionDevice => 'Dispositivo de conexión WLAN';
	@override String get printer => 'Impresora';
	@override String get scanner => 'Escáner';
	@override String get digitalSecurityCamera => 'Cámara de seguridad digital';
	@override String get unknownDevice => 'Dispositivo desconocido';
}

// Path: videoDetail.cast.dlnaCastSheet
class _TranslationsVideoDetailCastDlnaCastSheetEs extends TranslationsVideoDetailCastDlnaCastSheetEn {
	_TranslationsVideoDetailCastDlnaCastSheetEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Transmisión remota';
	@override String get close => 'Cerrar';
	@override String get searchingDevices => 'Buscando dispositivos...';
	@override String get searchPrompt => 'Pulse el botón de búsqueda para volver a buscar dispositivos de transmisión';
	@override String get searching => 'Buscando';
	@override String get searchAgain => 'Buscar de nuevo';
	@override String get noDevicesFound => 'No se encontraron dispositivos de transmisión\nAsegúrese de que los dispositivos estén en la misma red';
	@override String get searchingDevicesPrompt => 'Buscando dispositivos; espere...';
	@override String get cast => 'Transmitir';
	@override String connectedTo({required Object deviceName}) => 'Conectado a: ${deviceName}';
	@override String get notConnected => 'Ningún dispositivo conectado';
	@override String get stopCasting => 'Detener transmisión';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'personalProfile.personalProfile' => 'Perfil personal',
			'personalProfile.editPersonalProfile' => 'Editar perfil personal',
			'personalProfile.avatar' => 'Avatar',
			'personalProfile.background' => 'Fondo',
			'personalProfile.fetchUserProfileFailed' => ({required Object error}) => 'No se pudo obtener el perfil del usuario: ${error}',
			'personalProfile.suggestedResolution' => ({required Object resolution, required Object size}) => 'Resolución sugerida: ${resolution}, tamaño de archivo < ${size}',
			'personalProfile.supportedFormats' => ({required Object formats}) => 'Formatos admitidos: ${formats}',
			'personalProfile.premiumBenefit' => ({required Object type, required Object formats}) => 'Los usuarios premium pueden usar ${type} dinámico (${formats})',
			'personalProfile.homepageBackground' => 'Fondo de la página de inicio',
			'personalProfile.basicInfo' => 'Información básica',
			'personalProfile.nickname' => 'Apodo',
			'personalProfile.username' => 'Nombre de usuario',
			'personalProfile.copyUsername' => 'Copiar nombre de usuario',
			'personalProfile.usernameCopied' => 'Nombre de usuario copiado',
			'personalProfile.personalIntroduction' => 'Presentación personal',
			'personalProfile.noPersonalIntroduction' => 'Sin presentación personal',
			'personalProfile.clickToEdit' => 'Toque para editar',
			'personalProfile.privacySettings' => 'Configuración de privacidad',
			'personalProfile.hideSensitiveContent' => 'Ocultar contenido sensible',
			'personalProfile.hideSensitiveContentDesc' => 'Ocultar cualquier video o imagen con etiquetas sensibles.',
			'personalProfile.notificationSettings' => 'Configuración de notificaciones',
			'personalProfile.contentCommentNotification' => 'Notificación de comentarios en contenido',
			'personalProfile.contentCommentNotificationDesc' => 'Notificar cuando alguien comente en su contenido.',
			'personalProfile.commentReplyNotification' => 'Notificación de respuestas a comentarios',
			'personalProfile.commentReplyNotificationDesc' => 'Notificar cuando alguien responda a su comentario.',
			'personalProfile.mentionNotification' => 'Notificación de menciones',
			'personalProfile.mentionNotificationDesc' => 'Notificar cuando alguien lo mencione en contenido.',
			'personalProfile.accountInfo' => 'Información de la cuenta',
			'personalProfile.registrationTime' => 'Fecha de registro',
			'personalProfile.updateSettingsFailed' => ({required Object error}) => 'No se pudo actualizar la configuración: ${error}',
			'personalProfile.updateNotificationSettingsFailed' => ({required Object error}) => 'No se pudo actualizar la configuración de notificaciones: ${error}',
			'personalProfile.editNickname' => 'Editar apodo',
			'personalProfile.nicknameCannotBeEmpty' => 'El apodo no puede estar vacío',
			'personalProfile.changeSuccess' => 'Cambio realizado correctamente',
			'personalProfile.unsupportedFileFormat' => 'Formato de archivo no admitido',
			'personalProfile.fileTooLarge' => ({required Object size}) => 'El tamaño del archivo no puede superar ${size}',
			'personalProfile.uploadFailed' => 'Error al subir',
			'personalProfile.avatarUpdatedSuccessfully' => 'Avatar actualizado correctamente',
			'personalProfile.updateAvatarFailed' => ({required Object error}) => 'No se pudo actualizar el avatar: ${error}',
			'personalProfile.backgroundUpdatedSuccessfully' => 'Fondo actualizado correctamente',
			'personalProfile.updateBackgroundFailed' => ({required Object error}) => 'No se pudo actualizar el fondo: ${error}',
			'personalProfile.editPersonalIntroduction' => 'Editar presentación personal',
			'personalProfile.enterPersonalIntroduction' => 'Introduzca su presentación personal',
			'tutorial.specialFollowFeature' => 'Seguido especial',
			'tutorial.specialFollowDescription' => 'Marque como seguidos especiales a los autores que más ve y acceda directamente a sus últimas subidas desde aquí.',
			'tutorial.stepsTitle' => 'Tres pasos',
			'tutorial.stepFollowAuthor' => 'Toque Seguir en el video, la galería o la página de perfil del autor.',
			'tutorial.stepPickSpecial' => 'Toque Seguido de nuevo y elija Seguido especial en el menú.',
			'tutorial.stepSwitchHere' => 'Vuelva aquí y cambie a ese autor con el selector de avatar de arriba.',
			'tutorial.specialFollowManagementTip' => 'Gestione la lista de seguidos especiales en Barra lateral → Lista de seguidos → Seguidos especiales.',
			'tutorial.gotIt' => 'Entendido',
			'common.sort' => 'Ordenar',
			'common.filter' => 'Filtrar',
			'common.appName' => 'Love Iwara',
			'common.ok' => 'OK',
			'common.cancel' => 'Cancelar',
			'common.select' => 'Seleccionar',
			'common.save' => 'Guardar',
			'common.delete' => 'Eliminar',
			'common.visit' => 'Visitar',
			'common.loading' => 'Cargando...',
			'common.scrollToTop' => 'Ir arriba',
			'common.privacyHint' => 'El modo privacidad está activado; el contenido está oculto',
			'common.latest' => 'Recientes',
			'common.likesCount' => 'Me gusta',
			'common.viewsCount' => 'Visualizaciones',
			'common.popular' => 'Popular',
			'common.trending' => 'Tendencias',
			'common.commentList' => 'Lista de comentarios',
			'common.sendComment' => 'Enviar comentario',
			'common.send' => 'Enviar',
			'common.retry' => 'Reintentar',
			'common.premium' => 'Premium',
			'common.follower' => 'Seguidor',
			'common.friend' => 'Amigo',
			'common.video' => 'Vídeo',
			'common.following' => 'Siguiendo',
			'common.expand' => 'Expandir',
			'common.collapse' => 'Contraer',
			'common.cancelFriendRequest' => 'Cancelar solicitud',
			'common.cancelSpecialFollow' => 'Cancelar seguimiento especial',
			'common.addFriend' => 'Añadir amigo',
			'common.removeFriend' => 'Eliminar amigo',
			'common.followed' => 'Siguiendo',
			'common.follow' => 'Seguir',
			'common.unfollow' => 'Dejar de seguir',
			'common.specialFollow' => 'Seguimiento especial',
			'common.specialFollowed' => 'Con seguimiento especial',
			'common.gallery' => 'Galería',
			'common.playlist' => 'Lista de reproducción',
			'common.commentPostedSuccessfully' => 'Comentario publicado',
			'common.commentPostedFailed' => 'No se pudo publicar el comentario',
			'common.success' => 'Correcto',
			'common.commentDeletedSuccessfully' => 'Comentario eliminado',
			'common.commentUpdatedSuccessfully' => 'Comentario actualizado',
			'common.totalComments' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: '${n} comentario', other: '${n} comentarios', ), 
			'common.writeYourCommentHere' => 'Escriba aquí su comentario...',
			'common.tmpNoReplies' => 'Aún no hay respuestas',
			'common.loadMore' => 'Cargar más',
			'common.loadingMore' => 'Cargando más...',
			'common.noMoreDatas' => 'No hay más datos',
			'common.selectTranslationLanguage' => 'Seleccionar idioma de traducción',
			'common.translate' => 'Traducir',
			'common.translateFailedPleaseTryAgainLater' => 'No se pudo traducir; inténtelo de nuevo más tarde',
			'common.translationResult' => 'Resultado de la traducción',
			'common.justNow' => 'Ahora mismo',
			'common.minutesAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: 'hace ${n} minuto', other: 'hace ${n} minutos', ), 
			'common.hoursAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: 'hace ${n} hora', other: 'hace ${n} horas', ), 
			'common.daysAgo' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: 'hace ${n} día', other: 'hace ${n} días', ), 
			'common.editedAt' => ({required Object num}) => 'editado ${num} veces',
			'common.editComment' => 'Editar comentario',
			'common.commentUpdated' => 'Comentario actualizado',
			'common.replyComment' => 'Responder al comentario',
			'common.reply' => 'Responder',
			'common.edit' => 'Editar',
			'common.unknownUser' => 'Usuario desconocido',
			'common.me' => 'Yo',
			'common.author' => 'Autor',
			'common.admin' => 'Administrador',
			'common.viewReplies' => ({required Object num}) => 'Ver respuestas (${num})',
			'common.hideReplies' => 'Ocultar respuestas',
			'common.confirmDelete' => 'Confirmar eliminación',
			'common.areYouSureYouWantToDeleteThisItem' => '¿Seguro que quiere eliminar este elemento?',
			'common.tmpNoComments' => 'Aún no hay comentarios',
			'common.refresh' => 'Actualizar',
			'common.back' => 'Atrás',
			'common.tips' => 'Consejos',
			'common.linkIsEmpty' => 'El enlace está vacío',
			'common.linkCopiedToClipboard' => 'Enlace copiado al portapapeles',
			'common.imageCopiedToClipboard' => 'Imagen copiada al portapapeles',
			'common.copyImageFailed' => 'No se pudo copiar la imagen',
			'common.mobileSaveImageIsUnderDevelopment' => 'La función de guardar imágenes en el móvil está en desarrollo',
			'common.imageSavedTo' => 'Imagen guardada en',
			'common.saveImageFailed' => 'No se pudo guardar la imagen',
			'common.close' => 'Cerrar',
			'common.more' => 'Más',
			'common.unknownError' => 'Error desconocido',
			'common.moreFeaturesToBeDeveloped' => 'Más funciones en desarrollo',
			'common.all' => 'Todos',
			'common.selectedRecords' => ({required Object num}) => '${num} registros seleccionados',
			'common.cancelSelectAll' => 'Cancelar selección',
			'common.selectAll' => 'Seleccionar todo',
			'common.invertSelection' => 'Invertir selección',
			'common.exitEditMode' => 'Salir del modo de edición',
			'common.areYouSureYouWantToDeleteSelectedItems' => ({required Object num}) => '¿Seguro que quiere eliminar los ${num} elementos seleccionados?',
			'common.searchHistoryRecords' => 'Buscar en el historial...',
			'common.settings' => 'Ajustes',
			'common.subscriptions' => 'Suscripciones',
			'common.videoCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: '${n} vídeo', other: '${n} vídeos', ), 
			'common.share' => 'Compartir',
			'common.areYouSureYouWantToShareThisPlaylist' => '¿Seguro que quiere compartir esta lista de reproducción?',
			'common.editTitle' => 'Editar título',
			'common.editMode' => 'Modo de edición',
			'common.pleaseEnterNewTitle' => 'Introduzca el nuevo título',
			'common.createPlayList' => 'Crear lista de reproducción',
			'common.create' => 'Crear',
			'common.checkNetworkSettings' => 'Comprobar la configuración de red',
			'common.general' => 'General',
			'common.r18' => 'R18',
			'common.sensitive' => 'Sensible',
			'common.year' => 'Año',
			'common.month' => 'Mes',
			'common.tag' => 'Etiqueta',
			'common.private' => 'Privado',
			'common.noTitle' => 'Sin título',
			'common.search' => 'Buscar',
			'common.noContent' => 'Sin contenido',
			'common.recording' => 'Grabando',
			'common.paused' => 'En pausa',
			'common.clear' => 'Borrar',
			'common.clearSelection' => 'Borrar selección',
			'common.selectItemsToContinue' => 'Seleccione elementos para continuar',
			'common.andMoreItems' => ({required Object num}) => 'y ${num} más',
			'common.batchDelete' => 'Eliminación por lotes',
			'common.user' => 'Usuario',
			'common.post' => 'Publicación',
			'common.seconds' => 'Segundos',
			'common.comingSoon' => 'Próximamente',
			'common.confirm' => 'Confirmar',
			'common.hour' => 'Hora',
			'common.minute' => 'Minuto',
			'common.clickToRefresh' => 'Pulse para actualizar',
			'common.history' => 'Historial',
			'common.favorites' => 'Favoritos',
			'common.friends' => 'Amigos',
			'common.playList' => 'Lista de reproducción',
			'common.checkLicense' => 'Comprobar licencia',
			'common.logout' => 'Cerrar sesión',
			'common.fensi' => 'Seguidores',
			'common.accept' => 'Aceptar',
			'common.reject' => 'Rechazar',
			'common.clearAllHistory' => 'Borrar todo el historial',
			'common.clearAllHistoryConfirm' => '¿Seguro que quiere borrar todo el historial?',
			'common.followingList' => 'Lista de seguidos',
			'common.followersList' => 'Lista de seguidores',
			'common.follows' => 'Seguidos',
			'common.fans' => 'Seguidores',
			'common.followsAndFans' => 'Seguidos y seguidores',
			'common.numViews' => 'Visualizaciones',
			'common.updatedAt' => 'Actualizado el',
			'common.publishedAt' => 'Publicado el',
			'common.externalVideo' => 'Vídeo externo',
			'common.originalText' => 'Texto original',
			'common.showOriginalText' => 'Mostrar texto original',
			'common.showProcessedText' => 'Mostrar texto procesado',
			'common.preview' => 'Vista previa',
			'common.rules' => 'Normas',
			'common.agree' => 'Acepto',
			'common.disagree' => 'No acepto',
			'common.agreeToRules' => 'Aceptar las normas',
			'common.markdownSyntaxHelp' => 'Ayuda de sintaxis de Markdown',
			'common.previewContent' => 'Vista previa del contenido',
			'common.characterCount' => ({required Object current, required Object max}) => '${current}/${max}',
			'common.exceedsMaxLengthLimit' => ({required Object max}) => 'Supera el límite máximo de longitud (${max})',
			'common.agreeToCommunityRules' => 'Aceptar las normas de la comunidad',
			'common.createPost' => 'Crear publicación',
			'common.title' => 'Título',
			'common.enterTitle' => 'Introduzca el título',
			'common.content' => 'Contenido',
			'common.enterContent' => 'Introduzca el contenido',
			'common.writeYourContentHere' => 'Introduzca el contenido...',
			'common.tagBlacklist' => 'Lista negra de etiquetas',
			'common.noData' => 'Sin datos',
			'common.tagLimit' => 'Límite de etiquetas',
			'common.enableFloatingButtons' => 'Activar botones flotantes',
			'common.disableFloatingButtons' => 'Desactivar botones flotantes',
			'common.enabledFloatingButtons' => 'Botones flotantes activados',
			'common.disabledFloatingButtons' => 'Botones flotantes desactivados',
			'common.pendingCommentCount' => 'Comentarios pendientes',
			'common.joined' => ({required Object str}) => 'Se unió el ${str}',
			'common.lastSeenAt' => ({required Object str}) => 'Visto por última vez el ${str}',
			'common.download' => 'Descargar',
			'common.selectQuality' => 'Seleccionar calidad',
			'common.videoQualitySource' => 'Origen',
			'common.selectImageQuality' => 'Seleccione la calidad de imagen',
			'common.imageQualityStandard' => 'Estándar',
			'common.imageQualityOriginal' => 'Original',
			'common.selectDateRange' => 'Seleccionar intervalo de fechas',
			'common.selectDateRangeHint' => 'Seleccione un intervalo de fechas; por defecto, los últimos 30 días',
			'common.clearDateRange' => 'Borrar intervalo de fechas',
			'common.deleteRecordsInDateRange' => 'Eliminar los registros de este intervalo',
			'common.deleteRecordsInDateRangeConfirm' => ({required Object num}) => '¿Seguro que quiere eliminar ${num} registros del historial en este intervalo de fechas? Esta acción no se puede deshacer.',
			'common.noHistoryRecordsInRange' => 'No hay registros del historial en este intervalo de fechas',
			'common.followSuccessClickAgainToSpecialFollow' => 'Seguido correctamente; pulse de nuevo para seguimiento especial',
			'common.specialFollowTip' => 'Añadido a los seguimientos especiales: selecciónelos desde el selector de la esquina superior derecha de la página Suscripciones para acceder rápidamente',
			'common.exitConfirmTip' => '¿Seguro que quiere salir?',
			'common.error' => 'Error',
			'common.taskRunning' => 'Ya hay una tarea en curso; espere, por favor.',
			'common.operationCancelled' => 'Operación cancelada.',
			'common.unsavedChanges' => 'Tiene cambios sin guardar',
			'common.specialFollowsManagementTip' => 'Arrastre el tirador para reordenar • Pulse el botón para quitar',
			'common.specialFollowsManagement' => 'Gestión de seguimientos especiales',
			'common.removeSpecialFollow' => 'Quitar seguimiento especial',
			'common.removeSpecialFollowConfirm' => ({required Object name}) => '¿Quitar a ${name} de los seguimientos especiales?',
			'common.noSpecialFollows' => 'Aún no hay seguimientos especiales',
			'common.createTimeDesc' => 'Fecha de creación descendente',
			'common.createTimeAsc' => 'Fecha de creación ascendente',
			'common.pagination.totalItems' => ({required Object num}) => 'Total: ${num} elementos',
			'common.pagination.jumpToPage' => 'Ir a la página',
			'common.pagination.pleaseEnterPageNumber' => ({required Object max}) => 'Introduzca el número de página (1-${max})',
			'common.pagination.pageNumber' => 'Número de página',
			'common.pagination.jump' => 'Ir',
			'common.pagination.invalidPageNumber' => ({required Object max}) => 'Introduzca un número de página válido (1-${max})',
			'common.pagination.invalidInput' => 'Introduzca un número de página válido',
			'common.pagination.waterfall' => 'Cascada',
			'common.pagination.pagination' => 'Paginación',
			'common.notice' => 'Aviso',
			'common.detail' => 'Detalle',
			'common.parseExceptionDestopHint' => ' - Los usuarios de escritorio pueden configurar un proxy en los ajustes',
			'common.iwaraTags' => 'Etiquetas de Iwara',
			'common.tagInfo' => 'Información de la etiqueta',
			'common.tagOriginalKey' => 'Etiqueta original',
			'common.tagTranslation' => 'Traducción',
			'common.copy' => 'Copiar',
			'common.selectCopy' => 'Seleccionar y copiar',
			'common.copiedToClipboard' => 'Copiado al portapapeles',
			'common.showOriginalTag' => 'Mostrar etiqueta original',
			'common.showTranslatedTag' => 'Mostrar traducción',
			'common.tagTranslationFeedback' => '¿Tiene dudas sobre una traducción? Envíe sus comentarios',
			'common.tagLocalizationGuideTitle' => 'Acerca de la traducción de etiquetas',
			'common.tagLocalizationGuideContent' => 'La aplicación muestra las etiquetas originales de Iwara (p. ej. mother) con el nombre en su idioma actual.\n\n• Al buscar etiquetas, coinciden tanto la traducción como la etiqueta original.\n• Mantenga pulsada o haga clic derecho sobre una etiqueta para ver y copiar su clave original y su traducción.\n• Las traducciones las mantiene la comunidad y se hacen con el mejor esfuerzo posible; pueden contener errores.',
			'common.likeThisVideo' => 'Me gusta este vídeo',
			'common.likeThisGallery' => 'Me gusta esta galería',
			'common.operation' => 'Acción',
			'common.replies' => 'Respuestas',
			'common.externalLinkWarning' => 'Aviso de enlace externo',
			'common.externalLinkWarningMessage' => 'Está a punto de abrir un enlace externo que no forma parte de iwara.tv. Tenga cuidado y asegúrese de que el enlace sea seguro antes de continuar.',
			'common.continueToExternalLink' => 'Continuar',
			'common.cancelExternalLink' => 'Cancelar',
			'auth.login' => 'Iniciar sesión',
			'auth.logout' => 'Cerrar sesión',
			'auth.email' => 'Correo electrónico',
			'auth.password' => 'Contraseña',
			'auth.loginOrRegister' => 'Iniciar sesión / Registrarse',
			'auth.register' => 'Registrarse',
			'auth.pleaseEnterEmail' => 'Introduzca el correo electrónico',
			'auth.pleaseEnterPassword' => 'Introduzca la contraseña',
			'auth.passwordMustBeAtLeast6Characters' => 'La contraseña debe tener al menos 6 caracteres',
			'auth.pleaseEnterCaptcha' => 'Introduzca el captcha',
			'auth.captcha' => 'Captcha',
			'auth.refreshCaptcha' => 'Actualizar captcha',
			'auth.captchaNotLoaded' => 'Captcha no cargado',
			'auth.loginSuccess' => 'Sesión iniciada',
			'auth.loginSuccessProfilePending' => 'Sesión iniciada. Cargando su perfil…',
			'auth.emailVerificationSent' => 'Verificación de correo enviada',
			'auth.notLoggedIn' => 'No ha iniciado sesión',
			'auth.clickToLogin' => 'Pulse para iniciar sesión',
			'auth.logoutConfirmation' => '¿Seguro que quiere cerrar sesión?',
			'auth.logoutSuccess' => 'Sesión cerrada',
			'auth.logoutFailed' => 'No se pudo cerrar sesión',
			'auth.usernameOrEmail' => 'Nombre de usuario o correo electrónico',
			'auth.pleaseEnterUsernameOrEmail' => 'Introduzca el nombre de usuario o el correo electrónico',
			'auth.rememberMe' => 'Recordar nombre de usuario',
			'auth.registerNoticeTitle' => 'Regístrese en el sitio web oficial',
			'auth.registerNoticeDescription' => 'El registro en la aplicación ya no está disponible. Vaya al sitio web oficial de Iwara, cree su cuenta y luego vuelva aquí para iniciar sesión.',
			'auth.registerNoticeReturnTip' => 'Cuando se haya registrado, vuelva aquí e inicie sesión con su cuenta.',
			'auth.goToOfficialWebsite' => 'Ir al sitio web oficial',
			'errors.error' => 'Error',
			'errors.required' => 'Este campo es obligatorio',
			'errors.invalidEmail' => 'Dirección de correo electrónico no válida',
			'errors.networkError' => 'Error de red; inténtelo de nuevo',
			'errors.errorWhileFetching' => 'Error al obtener los datos',
			'errors.commentCanNotBeEmpty' => 'El contenido del comentario no puede estar vacío',
			'errors.errorWhileFetchingReplies' => 'Error al obtener las respuestas; compruebe la conexión de red',
			'errors.canNotFindCommentController' => 'No se encuentra el controlador de comentarios',
			'errors.errorWhileLoadingGallery' => 'Error al cargar la galería',
			'errors.howCouldThereBeNoDataItCantBePossible' => '¿Cómo no va a haber datos? Es imposible :<',
			'errors.unsupportedImageFormat' => ({required Object str}) => 'Formato de imagen no compatible: ${str}',
			'errors.invalidGalleryId' => 'ID de galería no válido',
			'errors.translationFailedPleaseTryAgainLater' => 'No se pudo traducir; inténtelo de nuevo más tarde',
			'errors.errorOccurred' => 'Se produjo un error; inténtelo de nuevo más tarde.',
			'errors.errorOccurredWhileProcessingRequest' => 'Se produjo un error al procesar la solicitud',
			'errors.errorWhileFetchingDatas' => 'Error al obtener los datos; inténtelo de nuevo más tarde',
			'errors.serviceNotInitialized' => 'Servicio no inicializado',
			'errors.unknownType' => 'Tipo desconocido',
			'errors.errorWhileOpeningLink' => ({required Object link}) => 'Error al abrir el enlace: ${link}',
			'errors.invalidUrl' => 'URL no válida',
			'errors.failedToOperate' => 'No se pudo completar la operación',
			'errors.permissionDenied' => 'Permiso denegado',
			'errors.youDoNotHavePermissionToAccessThisResource' => 'No tiene permiso para acceder a este recurso',
			'errors.loginFailed' => 'No se pudo iniciar sesión',
			'errors.unknownError' => 'Error desconocido',
			'errors.sessionExpired' => 'Sesión caducada',
			'errors.failedToFetchCaptcha' => 'No se pudo obtener el captcha',
			'errors.emailAlreadyExists' => 'El correo electrónico ya existe',
			'errors.invalidCaptcha' => 'Captcha no válido',
			'errors.registerFailed' => 'No se pudo registrar',
			'errors.failedToFetchComments' => 'No se pudieron obtener los comentarios',
			'errors.failedToFetchImageDetail' => 'No se pudieron obtener los detalles de la imagen',
			'errors.failedToFetchImageList' => 'No se pudo obtener la lista de imágenes',
			'errors.failedToFetchData' => 'No se pudieron obtener los datos',
			'errors.invalidParameter' => 'Parámetro no válido',
			'errors.pleaseLoginFirst' => 'Inicie sesión primero',
			'errors.errorWhileLoadingPost' => 'Error al cargar la publicación',
			'errors.errorWhileLoadingPostDetail' => 'Error al cargar los detalles de la publicación',
			'errors.invalidPostId' => 'ID de publicación no válido',
			'errors.forceUpdateNotPermittedToGoBack' => 'La aplicación está en estado de actualización obligatoria; no se puede volver atrás',
			'errors.pleaseLoginAgain' => 'Inicie sesión de nuevo',
			'errors.invalidLogin' => 'Inicio de sesión no válido; compruebe su correo electrónico y su contraseña',
			'errors.tooManyRequests' => 'Demasiadas solicitudes; inténtelo de nuevo más tarde',
			'errors.exceedsMaxLength' => ({required Object max}) => 'Supera la longitud máxima: ${max}',
			'errors.contentCanNotBeEmpty' => 'El contenido no puede estar vacío',
			'errors.titleCanNotBeEmpty' => 'El título no puede estar vacío',
			'errors.tooManyRequestsPleaseTryAgainLaterText' => 'Demasiadas solicitudes; inténtelo de nuevo más tarde. Restante',
			'errors.remainingHours' => ({required Object num}) => '${num} horas',
			'errors.remainingMinutes' => ({required Object num}) => '${num} minutos',
			'errors.remainingSeconds' => ({required Object num}) => '${num} segundos',
			'errors.tagLimitExceeded' => ({required Object limit}) => 'Se superó el límite de etiquetas; límite: ${limit}',
			'errors.failedToRefresh' => 'No se pudo actualizar',
			'errors.noPermission' => 'Sin permiso',
			'errors.resourceNotFound' => 'Recurso no encontrado',
			'errors.failedToSaveCredentials' => 'No se pudieron guardar las credenciales de inicio de sesión',
			'errors.failedToLoadSavedCredentials' => 'No se pudieron cargar las credenciales guardadas',
			'errors.notFound' => 'El contenido no se encontró o se ha eliminado',
			'errors.network.basicPrefix' => 'Error de red: ',
			'errors.network.failedToConnectToServer' => 'No se pudo conectar con el servidor',
			'errors.network.serverNotAvailable' => 'Servidor no disponible',
			'errors.network.requestTimeout' => 'Se agotó el tiempo de la solicitud',
			'errors.network.unexpectedError' => 'Error inesperado',
			'errors.network.invalidResponse' => 'Respuesta no válida',
			'errors.network.invalidRequest' => 'Solicitud no válida',
			'errors.network.invalidUrl' => 'URL no válida',
			'errors.network.invalidMethod' => 'Método no válido',
			'errors.network.invalidHeader' => 'Encabezado no válido',
			'errors.network.invalidBody' => 'Cuerpo no válido',
			'errors.network.invalidStatusCode' => 'Código de estado no válido',
			'errors.network.serverError' => 'Error del servidor',
			'errors.network.requestCanceled' => 'Solicitud cancelada',
			'errors.network.invalidPort' => 'Puerto no válido',
			'errors.network.proxyPortError' => 'Error del puerto del proxy',
			'errors.network.connectionRefused' => 'Conexión rechazada',
			'errors.network.networkUnreachable' => 'Red inaccesible',
			'errors.network.noRouteToHost' => 'No hay ruta al host',
			'errors.network.connectionFailed' => 'No se pudo conectar',
			'errors.network.sslConnectionFailed' => 'Falló la conexión SSL; compruebe la configuración de red',
			'friends.clickToRestoreFriend' => 'Pulse para restaurar el amigo',
			'friends.friendsList' => 'Lista de amigos',
			'friends.friendRequests' => 'Solicitudes de amistad',
			'friends.friendRequestsList' => 'Lista de solicitudes de amistad',
			'friends.removingFriend' => 'Eliminando al amigo...',
			'friends.failedToRemoveFriend' => 'No se pudo eliminar al amigo',
			'friends.cancelingRequest' => 'Cancelando la solicitud de amistad...',
			'friends.failedToCancelRequest' => 'No se pudo cancelar la solicitud de amistad',
			'authorProfile.noMoreDatas' => 'No hay más datos',
			'authorProfile.userProfile' => 'Perfil del usuario',
			'favorites.clickToRestoreFavorite' => 'Pulse para restaurar el favorito',
			'favorites.myFavorites' => 'Mis favoritos',
			'favorites.batchCancelFavorite' => 'Quitar los favoritos seleccionados',
			'favorites.batchCancelFavoriteConfirm' => ({required Object count}) => '¿Quitar los ${count} elementos seleccionados de favoritos? Puede restaurarlos tocando las tarjetas después.',
			'favorites.batchCancelFavoriteSuccess' => ({required Object count}) => 'Se quitaron ${count} elemento(s) de favoritos',
			'favorites.batchCancelFavoriteResult' => ({required Object success, required Object failed}) => 'Se quitaron ${success} elemento(s); ${failed} fallaron',
			'galleryDetail.browseInSpace' => 'Explorar en el espacio',
			'galleryDetail.galleryDetail' => 'Detalles de la galería',
			'galleryDetail.viewGalleryDetail' => 'Ver los detalles de la galería',
			'galleryDetail.zoomReset' => 'Restablecer el zoom',
			'galleryDetail.copyLink' => 'Copiar enlace',
			'galleryDetail.copyImage' => 'Copiar imagen',
			'galleryDetail.saveAs' => 'Guardar como',
			'galleryDetail.saveToAlbum' => 'Guardar en el álbum',
			'galleryDetail.publishedAt' => 'Publicado el',
			'galleryDetail.viewsCount' => 'Número de visualizaciones',
			'galleryDetail.imageLibraryFunctionIntroduction' => 'Presentación de las funciones de la biblioteca de imágenes',
			'galleryDetail.rightClickToSaveSingleImage' => 'Clic derecho para guardar una sola imagen',
			'galleryDetail.batchSave' => 'Guardado por lotes',
			'galleryDetail.keyboardLeftAndRightToSwitch' => 'Flechas izquierda y derecha del teclado para cambiar',
			'galleryDetail.keyboardUpAndDownToZoom' => 'Flechas arriba y abajo del teclado para ampliar',
			'galleryDetail.mouseWheelToSwitch' => 'Rueda del ratón para cambiar',
			'galleryDetail.ctrlAndMouseWheelToZoom' => 'CTRL + rueda del ratón para ampliar',
			'galleryDetail.moreFeaturesToBeDiscovered' => 'Más funciones por descubrir...',
			'galleryDetail.authorOtherGalleries' => 'Otras galerías del autor',
			'galleryDetail.relatedGalleries' => 'Galerías relacionadas',
			'galleryDetail.authorNoOtherGalleries' => 'No hay otras galerías de este autor',
			'galleryDetail.noRelatedGalleries' => 'No hay galerías relacionadas',
			'galleryDetail.scrollLeft' => 'Desplazar a la izquierda',
			'galleryDetail.scrollRight' => 'Desplazar a la derecha',
			'galleryDetail.clickLeftAndRightEdgeToSwitchImage' => 'Pulse los bordes izquierdo y derecho para cambiar de imagen',
			'galleryDetail.rotateToLandscape' => 'Pantalla completa horizontal',
			'galleryDetail.backToPortrait' => 'Volver a vertical',
			'playList.myPlayList' => 'Mi lista de reproducción',
			'playList.friendlyTips' => 'Consejo amistoso',
			'playList.dearUser' => 'Estimado usuario',
			'playList.iwaraPlayListSystemIsNotPerfectYet' => 'El sistema de listas de reproducción de Iwara aún no es perfecto',
			'playList.notSupportSetCover' => 'No se admite establecer portada',
			'playList.notSupportDeleteList' => 'No se admite eliminar la lista',
			'playList.notSupportSetPrivate' => 'No se admite establecer como privada',
			'playList.yesCreateListWillAlwaysExistAndVisibleToEveryone' => 'Sí... las listas creadas siempre existirán y serán visibles para todos',
			'playList.smallSuggestion' => 'Pequeña sugerencia',
			'playList.useLikeToCollectContent' => 'Si le preocupa más la privacidad, se recomienda usar la función de "me gusta" para guardar contenido',
			'playList.welcomeToDiscussOnGitHub' => 'Si tiene otras sugerencias o ideas, ¡le invitamos a comentarlas en GitHub!',
			'playList.iUnderstand' => 'Entendido',
			'playList.searchPlaylists' => 'Buscar listas de reproducción...',
			'playList.newPlaylistName' => 'Nombre de la nueva lista',
			'playList.createNewPlaylist' => 'Crear nueva lista de reproducción',
			'playList.videos' => 'Vídeos',
			'search.googleSearchScope' => 'Ámbito de búsqueda',
			'search.searchTags' => 'Buscar etiquetas...',
			'search.contentRating' => 'Clasificación de contenido',
			'search.removeTag' => 'Quitar etiqueta',
			'search.pleaseEnterSearchContent' => 'Introduzca el contenido de búsqueda',
			'search.searchHistory' => 'Historial de búsqueda',
			'search.searchSuggestion' => 'Sugerencia de búsqueda',
			'search.usedTimes' => 'Veces usado',
			'search.lastUsed' => 'Usado por última vez',
			'search.noSearchHistoryRecords' => 'Sin historial de búsqueda',
			'search.clearSearchHistoryConfirm' => '¿Seguro que desea borrar todo el historial de búsqueda? Esta acción no se puede deshacer.',
			'search.notSupportCurrentSearchType' => ({required Object searchType}) => 'Tipo de búsqueda actual no admitido ${searchType}; espere la actualización',
			'search.searchResult' => 'Resultado de búsqueda',
			'search.unsupportedSearchType' => ({required Object searchType}) => 'Tipo de búsqueda no admitido: ${searchType}',
			'search.googleSearch' => 'Búsqueda de Google',
			'search.googleSearchHint' => ({required Object webName}) => '¿La función de búsqueda de ${webName} no es fácil de usar? ¡Pruebe la Búsqueda de Google!',
			'search.googleSearchDescription' => 'Use el operador de búsqueda :site de Búsqueda de Google para buscar contenido en el sitio. Es muy útil para buscar videos, galerías, listas de reproducción y usuarios.',
			'search.googleSearchKeywordsHint' => 'Introduzca palabras clave para buscar',
			'search.openLinkJump' => 'Abrir enlace',
			'search.googleSearchButton' => 'Búsqueda de Google',
			'search.pleaseEnterSearchKeywords' => 'Introduzca las palabras clave de búsqueda',
			'search.googleSearchQueryCopied' => 'Consulta de búsqueda copiada al portapapeles',
			'search.googleSearchBrowserOpenFailed' => ({required Object error}) => 'No se pudo abrir el navegador: ${error}',
			'search.searchRequestTimeout' => 'La solicitud agotó el tiempo de espera; inténtelo de nuevo más tarde',
			'search.searchCannotConnectToServer' => 'No se puede conectar al servidor; compruebe su conexión de red',
			'search.searchNetworkError' => 'Error de conexión de red; compruebe la configuración de red o inténtelo de nuevo más tarde',
			'search.searchFailedPleaseRetry' => 'La búsqueda falló; inténtelo de nuevo más tarde',
			'mediaList.personalIntroduction' => 'Presentación',
			'settings.listViewMode' => 'Modo de vista de lista',
			'settings.previewEffect' => 'Vista previa del efecto',
			'settings.useTraditionalPaginationMode' => 'Usar el modo de paginación tradicional',
			'settings.useTraditionalPaginationModeDesc' => 'Activar el modo de paginación tradicional y desactivar el modo cascada. Surte efecto tras volver a renderizar la página o reiniciar la aplicación',
			'settings.showVideoProgressBottomBarWhenToolbarHidden' => 'Mostrar la barra inferior de progreso del video cuando la barra de herramientas está oculta',
			'settings.showVideoProgressBottomBarWhenToolbarHiddenDesc' => 'Esta configuración determina si se mostrará la barra inferior de progreso del video cuando la barra de herramientas esté oculta.',
			'settings.seekPreviewSize' => 'Tamaño de la vista previa de búsqueda',
			'settings.seekPreviewSizeDesc' => 'Tamaño de la ventana de vista previa situada sobre la barra de progreso. Ya sigue el tamaño del reproductor y la relación de aspecto del video; esto solo la ajusta ligeramente.',
			'settings.seekPreviewSizeSmall' => 'Pequeño',
			'settings.seekPreviewSizeStandard' => 'Estándar',
			'settings.seekPreviewSizeLarge' => 'Grande',
			'settings.seekPreviewSizeStandardDesc' => 'El tamaño derivado del reproductor y del video',
			'settings.showFullscreenUpNextHint' => 'Mostrar el asa de "A continuación"',
			'settings.showFullscreenUpNextHintDesc' => 'Muestra un asa pequeña en el borde derecho del reproductor que abre el panel de la cola (origen / lista de reproducción / ver más tarde). Una vez desactivada, no hay otra forma de acceder.',
			'settings.basicSettings' => 'Ajustes básicos',
			'settings.personalizedSettings' => 'Ajustes personalizados',
			'settings.otherSettings' => 'Otros ajustes',
			'settings.searchConfig' => 'Configuración de búsqueda',
			'settings.thisConfigurationDeterminesWhetherThePreviousConfigurationWillBeUsedWhenPlayingVideosAgain' => 'Esta configuración determina si se usará la configuración anterior al reproducir videos de nuevo.',
			'settings.playControl' => 'Control de reproducción',
			'settings.playbackSpeedSettings' => 'Reproducción y velocidad',
			'settings.playbackBehaviorSettings' => 'Comportamiento de reproducción',
			'settings.enhancementSettings' => 'Cine y mejoras',
			'settings.fastForwardTime' => 'Tiempo de avance rápido',
			'settings.fastForwardTimeMustBeAPositiveInteger' => 'El tiempo de avance rápido debe ser un número entero positivo.',
			'settings.rewindTime' => 'Tiempo de retroceso',
			'settings.rewindTimeMustBeAPositiveInteger' => 'El tiempo de retroceso debe ser un número entero positivo.',
			'settings.longPressPlaybackSpeed' => 'Velocidad de reproducción con pulsación larga',
			'settings.longPressPlaybackSpeedMustBeAPositiveNumber' => 'La velocidad de reproducción con pulsación larga debe ser un número positivo.',
			'settings.defaultPlaybackSpeed' => 'Velocidad de reproducción predeterminada',
			_ => null,
		} ?? switch (path) {
			'settings.rememberPlaybackSpeed' => 'Recordar la velocidad de reproducción',
			'settings.rememberPlaybackSpeedDesc' => 'Cuando está activado, la velocidad que ajuste en el reproductor se guarda como predeterminada y se aplica automáticamente a los videos nuevos.',
			'settings.repeat' => 'Repetir',
			'settings.renderVerticalVideoInVerticalScreen' => 'Mostrar el video vertical en pantalla vertical',
			'settings.thisConfigurationDeterminesWhetherTheVideoWillBeRenderedInVerticalScreenWhenPlayingInFullScreen' => 'Esta configuración determina si el video se mostrará en pantalla vertical al reproducirse en pantalla completa.',
			'settings.rememberVolume' => 'Recordar el volumen',
			'settings.thisConfigurationDeterminesWhetherTheVolumeWillBeKeptWhenPlayingVideosAgain' => 'Esta configuración determina si el volumen se mantendrá al reproducir videos de nuevo.',
			'settings.rememberBrightness' => 'Recordar el brillo',
			'settings.thisConfigurationDeterminesWhetherTheBrightnessWillBeKeptWhenPlayingVideosAgain' => 'Esta configuración determina si el brillo se mantendrá al reproducir videos de nuevo.',
			'settings.playControlArea' => 'Área de control de reproducción',
			'settings.leftAndRightControlAreaWidth' => 'Ancho de las áreas de control izquierda y derecha',
			'settings.thisConfigurationDeterminesTheWidthOfTheControlAreasOnTheLeftAndRightSidesOfThePlayer' => 'Esta configuración determina el ancho de las áreas de control situadas a la izquierda y a la derecha del reproductor.',
			'settings.proxyAddressCannotBeEmpty' => 'La dirección del proxy no puede estar vacía.',
			'settings.invalidProxyAddressFormatPleaseUseTheFormatOfIpPortOrDomainNamePort' => 'Formato de dirección de proxy no válido. Use el formato IP:puerto o nombre de dominio:puerto.',
			'settings.proxyNormalWork' => 'El proxy funciona correctamente.',
			'settings.testProxyFailedWithStatusCode' => ({required Object code}) => 'Error al probar el proxy; código de estado: ${code}',
			'settings.testProxyFailedWithException' => ({required Object exception}) => 'Error al probar el proxy; excepción: ${exception}',
			'settings.proxyConfig' => 'Configuración del proxy',
			'settings.thisIsHttpProxyAddress' => 'Esta es la dirección del proxy HTTP',
			'settings.checkProxy' => 'Comprobar proxy',
			'settings.proxyAddress' => 'Dirección del proxy',
			'settings.pleaseEnterTheUrlOfTheProxyServerForExample1270018080' => 'Introduzca la URL del servidor proxy; por ejemplo, 127.0.0.1:8080',
			'settings.enableProxy' => 'Activar proxy',
			'settings.left' => 'Izquierda',
			'settings.middle' => 'Centro',
			'settings.right' => 'Derecha',
			'settings.playerSettings' => 'Ajustes del reproductor',
			'settings.networkSettings' => 'Ajustes de red',
			'settings.customizeYourPlaybackExperience' => 'Personalice su experiencia de reproducción',
			'settings.chooseYourFavoriteAppAppearance' => 'Elija el aspecto que prefiera para la aplicación',
			'settings.configureYourProxyServer' => 'Configure su servidor proxy',
			'settings.settings' => 'Ajustes',
			'settings.themeSettings' => 'Ajustes de tema',
			'settings.followSystem' => 'Seguir el sistema',
			'settings.lightMode' => 'Modo claro',
			'settings.darkMode' => 'Modo oscuro',
			'settings.presetTheme' => 'Tema predefinido',
			'settings.basicTheme' => 'Tema básico',
			'settings.needRestartToApply' => 'Reinicie la aplicación para aplicar los ajustes',
			'settings.themeNeedRestartDescription' => 'Los ajustes de tema requieren reiniciar la aplicación para aplicarse',
			'settings.about' => 'Acerca de',
			'settings.diagnosticsAndFeedback' => 'Diagnóstico y comentarios',
			'settings.currentVersion' => 'Versión actual',
			'settings.latestVersion' => 'Última versión',
			'settings.checkForUpdates' => 'Buscar actualizaciones',
			'settings.update' => 'Actualizar',
			'settings.newVersionAvailable' => 'Nueva versión disponible',
			'settings.projectHome' => 'Página del proyecto',
			'settings.release' => 'Versión',
			'settings.issueReport' => 'Informe de problema',
			'settings.openSourceLicense' => 'Licencia de código abierto',
			'settings.checkForUpdatesFailed' => 'No se pudieron buscar actualizaciones; inténtelo de nuevo más tarde',
			'settings.autoCheckUpdate' => 'Buscar actualizaciones automáticamente',
			'settings.updateContent' => 'Contenido de la actualización',
			'settings.releaseDate' => 'Fecha de publicación',
			'settings.ignoreThisVersion' => 'Ignorar esta versión',
			'settings.forceUpdateTip' => 'Esta es una actualización obligatoria. Actualice a la última versión lo antes posible',
			'settings.viewChangelog' => 'Ver el registro de cambios',
			'settings.alreadyLatestVersion' => 'Ya está en la última versión',
			'settings.appSettings' => 'Configuración de la aplicación',
			'settings.configureYourAppSettings' => 'Configure los ajustes de su aplicación',
			'settings.history' => 'Historial',
			'settings.autoRecordHistory' => 'Registrar el historial automáticamente',
			'settings.autoRecordHistoryDesc' => 'Registrar automáticamente los videos e imágenes que ha visto',
			'settings.autoDeleteHistory' => 'Limpiar el historial automáticamente',
			'settings.autoDeleteHistoryDesc' => 'Eliminar automáticamente al inicio el historial de navegación anterior a los días de conservación (desactivado de forma predeterminada)',
			'settings.autoDeleteHistoryDays' => 'Días de conservación',
			'settings.autoDeleteHistoryDaysValue' => ({required Object num}) => 'Conservar los últimos ${num} días',
			'settings.autoDeleteHistoryDaysInvalid' => 'Introduzca un número de días válido (al menos 1)',
			'settings.showUnprocessedMarkdownText' => 'Mostrar el texto Markdown sin procesar',
			'settings.showUnprocessedMarkdownTextDesc' => 'Mostrar el texto original del markdown',
			'settings.markdown' => 'Markdown',
			'settings.activeBackgroundPrivacyMode' => 'Modo privacidad',
			'settings.activeBackgroundPrivacyModeDesc' => 'Bloquea las capturas de pantalla y la grabación de pantalla, y oculta la pantalla en segundo plano',
			'settings.activeBackgroundPrivacyModeDescNonAndroid' => 'Oculta la pantalla cuando la aplicación pasa a segundo plano (esta plataforma no puede bloquear las capturas de pantalla)',
			'settings.activeBackgroundPrivacyModeDescScreenshotOnly' => 'Bloquea las capturas de pantalla y la grabación de pantalla',
			'settings.privacy' => 'Privacidad',
			'settings.appLock' => 'Bloqueo de la aplicación',
			'settings.appLockEnabled' => 'Activar el bloqueo de la aplicación',
			'settings.appLockEnabledDesc' => 'Exigir un PIN o datos biométricos para abrir la aplicación; la vista previa en segundo plano se oculta automáticamente',
			'settings.appLockEnabledSummary' => 'Activado · Protegido con PIN',
			'settings.appLockDisabledSummary' => 'Desactivado',
			'settings.appLockTimeout' => 'Bloquear al salir de la aplicación',
			'settings.appLockTimeoutDesc' => 'Tiempo permitido en segundo plano antes de exigir autenticación',
			'settings.appLockAfterScreenOff' => 'Bloquear tras bloquear la pantalla',
			'settings.appLockAfterScreenOffDesc' => 'Exigir autenticación una vez bloqueada la pantalla del dispositivo',
			'settings.appLockTimeoutDisabled' => 'Desactivado',
			'settings.appLockImmediately' => 'Inmediatamente',
			'settings.appLockSeconds' => ({required Object seconds}) => '${seconds} segundos',
			'settings.appLockMinutes' => ({required Object minutes}) => '${minutes} minutos',
			'settings.appLockUseBiometrics' => 'Usar datos biométricos',
			'settings.appLockUseBiometricsDesc' => 'Desbloquear con huella digital o reconocimiento facial',
			'settings.appLockBiometricsUnavailable' => 'No hay datos biométricos registrados en este dispositivo',
			'settings.appLockSetPin' => 'Establecer PIN',
			'settings.appLockEnterPin' => 'Introduzca el PIN',
			'settings.appLockConfirmPin' => 'Confirmar PIN',
			'settings.appLockCurrentPin' => 'Introduzca el PIN actual',
			'settings.appLockNewPin' => 'Introduzca el PIN nuevo',
			'settings.appLockPinRequirements' => 'El PIN debe contener de 4 a 8 dígitos',
			'settings.appLockPinsDoNotMatch' => 'Los PIN no coinciden',
			'settings.appLockInvalidPin' => 'PIN incorrecto',
			'settings.appLockSetupFailed' => 'No se pudo guardar el PIN de forma segura',
			'settings.appLockDisable' => 'Introduzca el PIN para desactivar el bloqueo de la aplicación',
			'settings.appLockChangePin' => 'Cambiar PIN',
			'settings.appLockNow' => 'Bloquear ahora',
			'settings.appLockUnlock' => 'Desbloquear',
			'settings.appLockLockedTitle' => 'Bloqueado',
			'settings.appLockLockedDesc' => 'Autentíquese para continuar',
			'settings.appLockAuthenticateReason' => 'Autentíquese para desbloquear',
			'settings.appLockEnableBiometricsReason' => 'Autentíquese para activar el desbloqueo biométrico',
			'settings.appLockBiometricFailed' => 'No se completó la autenticación biométrica',
			'settings.appLockTooManyAttempts' => ({required Object seconds}) => 'Demasiados intentos. Vuelva a intentarlo en ${seconds} s',
			'settings.appLockCredentialUnavailableTitle' => 'No se puede leer la credencial del bloqueo de la aplicación',
			'settings.appLockCredentialUnavailableDesc' => 'El almacenamiento seguro del sistema no está disponible temporalmente, o la credencial está dañada. La aplicación permanece bloqueada. Inténtelo de nuevo primero; si sigue fallando, puede restablecer el bloqueo de la aplicación, lo que lo desactiva y borra el PIN guardado.',
			'settings.appLockRetry' => 'Reintentar',
			'settings.appLockReset' => 'Restablecer el bloqueo de la aplicación',
			'settings.appLockResetAction' => 'Restablecer',
			'settings.appLockResetConfirmTitle' => '¿Restablecer el bloqueo de la aplicación?',
			'settings.appLockResetConfirmDesc' => 'Esto desactiva el bloqueo de la aplicación y borra el PIN guardado y la configuración biométrica. Puede configurarlo de nuevo después.',
			'settings.appLockRetrySucceeded' => 'Credencial leída correctamente. Introduzca su PIN.',
			'settings.appLockRetryFailed' => 'Aún no se puede leer la credencial',
			'settings.forum' => 'Foro',
			'settings.news' => 'Noticias',
			'settings.community' => 'Comunidad',
			'settings.disableForumReplyQuote' => 'Desactivar la cita en las respuestas del foro',
			'settings.disableForumReplyQuoteDesc' => 'Desactivar la inclusión de la información del piso citado al responder en el foro',
			'settings.theaterMode' => 'Modo cine',
			'settings.theaterModeDesc' => 'Al activarlo, el fondo del reproductor se establecerá como la versión desenfocada de la portada del video',
			'settings.appLinks' => 'Enlaces de la aplicación',
			'settings.defaultBrowser' => 'Navegador predeterminado',
			'settings.defaultBrowserDesc' => 'Abra el elemento de configuración de enlace predeterminado en los ajustes del sistema y añada el enlace del sitio web iwara.tv',
			'settings.themeMode' => 'Modo de tema',
			'settings.themeModeDesc' => 'Esta configuración determina el modo de tema de la aplicación',
			'settings.glassEffect' => 'Material de la interfaz',
			'settings.glassEffectDesc' => 'Elige el material usado en toda la aplicación: cápsulas de encabezado, menús, botones de diálogo y la barra de navegación inferior',
			'settings.liquidGlassEffect' => 'Vidrio líquido',
			'settings.liquidGlassEffectDesc' => 'Desenfoque y refracción reales. El mejor aspecto, pero puede perder fotogramas y consumir algo más de batería en dispositivos de gama baja',
			'settings.plainGlassEffect' => 'Material',
			'settings.plainGlassEffectDesc' => 'Superficies estándar de Material 3: opacas, sin desenfoque ni sombras. El mejor rendimiento y la mejor autonomía',
			'settings.glassEffectIntroTitle' => 'Elija el material de su interfaz',
			'settings.glassEffectIntroContent' => 'Los encabezados, la barra de pestañas y los menús usan vidrio líquido: desenfoque y refracción reales. Si le parece lento en su dispositivo, o prefiere algo más sencillo, cambie a Material ahora (superficies opacas, sin desenfoque ni sombras).',
			'settings.glassEffectIntroHint' => 'Puede cambiarlo cuando quiera en Ajustes → Tema → Material de la interfaz.',
			'settings.glassEffectIntroDone' => 'Mantenerlo',
			'settings.dynamicColor' => 'Color dinámico',
			'settings.dynamicColorDesc' => 'Esta configuración determina si la aplicación usa el color dinámico',
			'settings.useDynamicColor' => 'Usar color dinámico',
			'settings.useDynamicColorDesc' => 'Esta configuración determina si la aplicación usa el color dinámico',
			'settings.presetColors' => 'Colores predefinidos',
			'settings.customColors' => 'Colores personalizados',
			'settings.customColorsDisabledByDynamicColor' => 'El color dinámico está activado, por lo que los colores predefinidos y personalizados no están disponibles. Desactive primero el color dinámico.',
			'settings.pickColor' => 'Elegir color',
			'settings.cancel' => 'Cancelar',
			'settings.confirm' => 'Confirmar',
			'settings.noCustomColors' => 'Sin colores personalizados',
			'settings.recordAndRestorePlaybackProgress' => 'Registrar y restaurar el progreso de reproducción',
			'settings.autoPlayVideoOnFirstEnter' => 'Reproducir el video automáticamente al entrar por primera vez',
			'settings.autoPlayVideoOnFirstEnterDesc' => 'Esta opción determina si el video empieza a reproducirse automáticamente al entrar por primera vez en la página del video.',
			'settings.autoEnterFullscreen' => 'Entrar en pantalla completa automáticamente',
			'settings.autoEnterFullscreenDesc' => 'Cuándo debe pasar el reproductor a pantalla completa por sí solo. Los videos privados, eliminados y externos siempre se dejan igual, al igual que el modo imagen en imagen.',
			'settings.autoEnterFullscreenOff' => 'Desactivado',
			'settings.autoEnterFullscreenOffDesc' => 'No entrar nunca en pantalla completa por sí solo',
			'settings.autoEnterFullscreenOnPlaybackStart' => 'Al iniciar la reproducción',
			'settings.autoEnterFullscreenOnPlaybackStartDesc' => 'Pasar a pantalla completa en el momento en que la reproducción comienza de verdad',
			'settings.autoEnterFullscreenOnDetailPageEnter' => 'Al abrir el video',
			'settings.autoEnterFullscreenOnDetailPageEnterDesc' => 'Pasar a pantalla completa en cuanto se abre la página del video, sin esperar a la reproducción',
			'settings.autoEnterFullscreenKind' => 'Tipo de pantalla completa',
			'settings.autoEnterFullscreenKindDesc' => 'Qué tipo de pantalla completa entrar automáticamente. Solo en escritorio.',
			'settings.autoEnterFullscreenKindSystem' => 'Pantalla completa del sistema',
			'settings.autoEnterFullscreenKindSystemDesc' => 'Dejar que el gestor de ventanas ponga la ventana en pantalla completa',
			'settings.autoEnterFullscreenKindApp' => 'Pantalla completa de la aplicación',
			'settings.autoEnterFullscreenKindAppDesc' => 'Mantener la ventana tal cual y convertir toda la aplicación en el reproductor',
			'settings.signature' => 'Firma',
			'settings.enableSignature' => 'Activar firma',
			'settings.enableSignatureDesc' => 'Esta configuración determina si la aplicación añade la firma al responder',
			'settings.enterSignature' => 'Introducir firma',
			'settings.editSignature' => 'Editar firma',
			'settings.signatureContent' => 'Contenido de la firma',
			'settings.exportConfig' => 'Exportar la configuración de la aplicación',
			'settings.exportConfigDesc' => 'Exporte los ajustes y el historial (historial de navegación, progreso de reproducción, favoritos, etc.) a un archivo para hacer una copia de seguridad o transferirlo a otro dispositivo. Las tareas de descarga no se incluyen.',
			'settings.importConfig' => 'Importar la configuración de la aplicación',
			'settings.importConfigDesc' => 'Importar la configuración de la aplicación desde un archivo',
			'settings.exportConfigSuccess' => '¡Configuración exportada correctamente!',
			'settings.exportConfigFailed' => 'No se pudo exportar la configuración',
			'settings.importConfigSuccess' => '¡Configuración importada correctamente!',
			'settings.importConfigFailed' => 'No se pudo importar la configuración',
			'settings.exportIncludeSensitive' => 'Incluir información sensible',
			'settings.exportIncludeSensitiveDesc' => 'Incluye claves de API, tokens de sesión y la dirección del proxy. Actívelo solo al hacer una copia de seguridad en su propio dispositivo.',
			'settings.importConfigOverwriteWarning' => 'La importación sobrescribirá sus ajustes e historial actuales (historial de navegación, progreso de reproducción, favoritos, etc.). ¿Continuar?',
			'settings.importConfigRestartTitle' => 'Importación correcta',
			'settings.importConfigRestartContent' => 'Su configuración se ha importado. Cierre por completo la aplicación y vuelva a abrirla para que todos los cambios surtan efecto.',
			'settings.historyUpdateLogs' => 'Registros de actualización del historial',
			'settings.noUpdateLogs' => 'No hay registros de actualización disponibles',
			'settings.versionLabel' => 'Versión: {version}',
			'settings.releaseDateLabel' => 'Fecha de publicación: {date}',
			'settings.noChanges' => 'No hay contenido de actualización disponible',
			'settings.interaction' => 'Interacción',
			'settings.enableVibration' => 'Activar vibración',
			'settings.enableVibrationDesc' => 'Activar la respuesta por vibración al interactuar con la aplicación',
			'settings.defaultKeepVideoToolbarVisible' => 'Mantener visible la barra de herramientas del video',
			'settings.defaultKeepVideoToolbarVisibleDesc' => 'Esta opción determina si la barra de herramientas del video permanece visible al entrar por primera vez en la página del video.',
			'settings.theaterModelHasPerformanceIssuesAndIDontKnowHowToFixItNowIfYouRRuningOnDeskTopYouCanOpenIt' => 'Activar el modo cine en dispositivos móviles puede causar problemas de rendimiento. Puede elegir activarlo.',
			'settings.fullscreenOrientation' => 'Orientación de la pantalla tras entrar en pantalla completa',
			'settings.fullscreenOrientationDesc' => 'Esta opción determina la orientación de pantalla predeterminada al entrar en pantalla completa (solo móvil)',
			'settings.fullscreenOrientationLeftLandscape' => 'Horizontal izquierda',
			'settings.fullscreenOrientationRightLandscape' => 'Horizontal derecha',
			'settings.screenFit' => 'Tamaño de pantalla',
			'settings.screenFitDesc' => 'Elija cómo rellena el video el área del reproductor.',
			'settings.rememberScreenFit' => 'Recordar el tamaño de pantalla',
			'settings.rememberScreenFitDesc' => 'Aplicar el tamaño seleccionado a los videos que se abran después.',
			'settings.screenFitFit' => 'Ajustar',
			'settings.screenFitFitDesc' => 'Muestra el fotograma completo manteniendo la relación de aspecto',
			'settings.screenFitStretch' => 'Estirar',
			'settings.screenFitStretchDesc' => 'Rellena el área del reproductor; la imagen puede verse distorsionada',
			'settings.screenFitCover' => 'Rellenar',
			'settings.screenFitCoverDesc' => 'Rellena el área del reproductor manteniendo la relación de aspecto; el sobrante se recorta',
			'settings.screenFitRatioDesc' => 'Forzar esta relación de aspecto; la imagen puede verse distorsionada',
			'settings.jumpLink' => 'Enlace de salto',
			'settings.language' => 'Idioma',
			'settings.languageNativeName' => 'Español',
			'settings.followSystemLanguage' => 'Seguir el sistema',
			'settings.languageChangedMessage' => 'Idioma cambiado correctamente; algunas funciones requieren reiniciar la aplicación.',
			'settings.languageChanged' => 'El idioma se ha cambiado. Reinicie la aplicación para que surta efecto.',
			'settings.keybinding.title' => 'Atajos de teclado',
			'settings.keybinding.entryLabel' => 'Atajos de teclado',
			'settings.keybinding.entryDesc' => 'Personalice los atajos de teclado de la aplicación (principalmente para escritorio)',
			'settings.keybinding.desktopHint' => 'Los atajos se aplican principalmente a los teclados de escritorio; en móvil suelen usarse gestos.',
			'settings.keybinding.resetAll' => 'Restablecer todo a los valores predeterminados',
			'settings.keybinding.resetAllConfirm' => '¿Restablecer todos los atajos de la aplicación a sus valores predeterminados?',
			'settings.keybinding.resetToDefault' => 'Restablecer valores predeterminados',
			'settings.keybinding.resetScope' => 'Restablecer esta sección',
			'settings.keybinding.notSet' => 'Sin asignar',
			'settings.keybinding.addShortcut' => 'Añadir atajo',
			'settings.keybinding.removeShortcut' => 'Eliminar este atajo',
			'settings.keybinding.pressNewShortcut' => 'Pulse el nuevo atajo…',
			'settings.keybinding.recordingCancelHint' => 'Pulse Esc para cancelar',
			'settings.keybinding.mouseHint' => 'También puede vincular los botones laterales del ratón (atrás / avance) o el botón central',
			'settings.keybinding.mouseNotSupportedInScope' => 'Esta zona no admite botones del ratón; use el teclado en su lugar',
			'settings.keybinding.capabilityKeyboardOnly' => 'Esta zona solo acepta teclas del teclado',
			'settings.keybinding.capabilityKeyboardAndMouse' => 'Esta zona acepta teclas del teclado y los botones central y laterales del ratón',
			'settings.keybinding.capabilityKeyboardAndMouseMobile' => 'Esta zona acepta teclas del teclado y los botones central y de avance del ratón (el botón de retroceso lo usa el sistema)',
			'settings.keybinding.rejectMultipleButtons' => 'Pulse un botón del ratón a la vez',
			'settings.keybinding.rejectPlatformBack' => 'El sistema ya lo usa para Atrás; si lo vincula, se retrocedería dos veces',
			'settings.keybinding.detectedLabel' => 'Detectado',
			'settings.keybinding.reservedKey' => 'Esta tecla está reservada por el sistema y no se puede vincular',
			'settings.keybinding.reservedForGlobalBack' => ({required Object action}) => 'Esta tecla está vinculada a "${action}"; permanece reservada aquí para que aún pueda salir de esta pantalla',
			'settings.keybinding.conflictTitle' => 'Conflicto de atajos',
			'settings.keybinding.conflictMessage' => ({required Object action}) => 'Esta combinación ya está vinculada a "${action}". Si continúa, se eliminará la vinculación existente.',
			'settings.keybinding.conflictContinue' => 'Vincular de todos modos',
			'settings.keybinding.shadowWarningTitle' => 'Solapamiento con atajos globales',
			'settings.keybinding.shadowWarningMessage' => ({required Object action}) => 'Esta combinación está vinculada a "${action}" globalmente. Vincularla aquí anulará esa acción solo dentro de esta sección.',
			'settings.keybinding.globalShadowedMessage' => ({required Object action, required Object scope}) => 'Esta combinación ya está vinculada a "${action}" en ${scope}. Dentro de esa sección, este atajo global será anulado por ella.',
			'settings.keybinding.searchHint' => 'Buscar atajos…',
			'settings.keybinding.scopeGlobal' => 'Global',
			'settings.keybinding.scopeGallery' => 'Galería',
			'settings.keybinding.scopeVideo' => 'Vídeo',
			'settings.keybinding.categoryNavigation' => 'Navegación',
			'settings.keybinding.categoryZoom' => 'Zoom',
			'settings.keybinding.categoryPlayback' => 'Reproducción',
			'settings.keybinding.categorySeek' => 'Búsqueda',
			'settings.keybinding.categoryVolume' => 'Volumen',
			'settings.keybinding.categoryDisplay' => 'Pantalla',
			'settings.keybinding.actionGlobalBack' => 'Volver',
			'settings.keybinding.actionGalleryNext' => 'Foto siguiente',
			'settings.keybinding.actionGalleryPrevious' => 'Foto anterior',
			'settings.keybinding.actionGalleryZoomIn' => 'Ampliar',
			'settings.keybinding.actionGalleryZoomOut' => 'Reducir',
			'settings.keybinding.actionGalleryResetZoom' => 'Restablecer el zoom',
			'settings.keybinding.actionGalleryPlayPause' => 'Reproducir / Pausar',
			'settings.keybinding.actionGallerySeekBackward' => 'Retroceder',
			'settings.keybinding.actionGallerySeekForward' => 'Avanzar rápido',
			'settings.keybinding.actionGalleryToggleMute' => 'Activar o desactivar el silencio',
			'settings.keybinding.actionPlayPause' => 'Reproducir / Pausar',
			'settings.keybinding.actionSpeedUp' => 'Aumentar la velocidad',
			'settings.keybinding.actionSpeedDown' => 'Reducir la velocidad',
			'settings.keybinding.actionSeekForward' => 'Avanzar',
			'settings.keybinding.actionSeekBackward' => 'Retroceder',
			'settings.keybinding.actionVolumeUp' => 'Subir el volumen',
			'settings.keybinding.actionVolumeDown' => 'Bajar el volumen',
			'settings.keybinding.actionToggleMute' => 'Activar o desactivar el silencio',
			'settings.keybinding.actionToggleFullscreen' => 'Alternar pantalla completa',
			'settings.keybinding.seekLongPressHint' => 'Mantenga pulsada la tecla de avance o retroceso para activar el modo de velocidad por pulsación larga',
			'settings.keybinding.zoomSectionTitle' => 'Zoom de imagen (fijo)',
			'settings.keybinding.zoomFixedNote' => 'Los atajos siguientes son fijos y no se pueden cambiar',
			'settings.keybinding.zoomScaleLabel' => 'Ampliar la imagen',
			'settings.keybinding.zoomScaleHint' => 'Ctrl + rueda',
			'settings.keybinding.zoomRotateLabel' => 'Girar la imagen',
			'settings.keybinding.zoomRotateHint' => 'Mayús + rueda',
			'settings.keybinding.zoomPinchGesture' => 'Pellizcar',
			'settings.keybinding.zoomTwoFingerRotateGesture' => 'Rotación con dos dedos',
			'settings.gestureControl' => 'Control por gestos',
			'settings.leftDoubleTapRewind' => 'Doble toque a la izquierda para retroceder',
			'settings.rightDoubleTapFastForward' => 'Doble toque a la derecha para avanzar rápido',
			'settings.doubleTapPause' => 'Pausa con doble toque',
			'settings.rightVerticalSwipeVolume' => 'Volumen con deslizamiento vertical a la derecha (efectivo al entrar en una página nueva)',
			'settings.leftVerticalSwipeBrightness' => 'Brillo con deslizamiento vertical a la izquierda (efectivo al entrar en una página nueva)',
			'settings.longPressFastForward' => 'Avance rápido con pulsación larga',
			'settings.enableMouseHoverShowToolbar' => 'Mostrar la barra de herramientas al pasar el ratón',
			'settings.enableMouseHoverShowToolbarInfo' => 'Cuando está activado, la barra de herramientas del video se muestra al pasar el ratón sobre el reproductor. Se oculta automáticamente tras 3 segundos de inactividad.',
			'settings.enableHorizontalDragSeek' => 'Deslizamiento horizontal para buscar',
			'settings.enableVideoGestureZoom' => 'Pellizcar para ampliar el fotograma del video',
			'settings.enableVideoGestureZoomInfo' => 'Pellizque con dos dedos (o Ctrl + rueda del ratón en escritorio) para ampliar la imagen del video y luego arrastre para moverla.',
			'settings.showCenterPlayPauseButton' => 'Botón de reproducir/pausar central',
			'settings.showCenterPlayPauseButtonDesc' => 'Mostrar el botón grande de reproducir/pausar en el centro del reproductor.',
			'settings.audioVideoConfig' => 'Configuración de audio y video',
			'settings.expandBuffer' => 'Ampliar el búfer',
			'settings.expandBufferInfo' => 'Cuando está activado, el tamaño del búfer aumenta: el tiempo de carga se alarga, pero la reproducción es más fluida',
			'settings.videoSyncMode' => 'Modo de sincronización de video',
			'settings.videoSyncModeSubtitle' => 'Estrategia de sincronización de audio y video',
			'settings.hardwareDecodingMode' => 'Modo de decodificación por hardware',
			'settings.hardwareDecodingModeSubtitle' => 'Ajustes de decodificación por hardware',
			'settings.enableHardwareAcceleration' => 'Activar la aceleración por hardware',
			'settings.enableHardwareAccelerationInfo' => 'Activar la aceleración por hardware puede mejorar el rendimiento de decodificación, pero algunos dispositivos pueden no ser compatibles',
			'settings.useOpenSLESAudioOutput' => 'Usar salida de audio OpenSLES',
			'settings.useOpenSLESAudioOutputInfo' => 'Usar salida de audio de baja latencia; puede mejorar el rendimiento del audio',
			'settings.videoSyncAudio' => 'Sincronización de audio',
			'settings.videoSyncDisplayResample' => 'Mostrar remuestreo',
			'settings.videoSyncDisplayResampleVdrop' => 'Mostrar remuestreo (pérdida de fotogramas)',
			'settings.videoSyncDisplayResampleDesync' => 'Mostrar remuestreo (desincronización)',
			'settings.videoSyncDisplayTempo' => 'Mostrar tempo',
			'settings.videoSyncDisplayVdrop' => 'Mostrar caída de fotogramas de video',
			'settings.videoSyncDisplayAdrop' => 'Mostrar caída de fotogramas de audio',
			'settings.videoSyncDisplayDesync' => 'Mostrar desincronización',
			'settings.videoSyncDesync' => 'Desincronización',
			'settings.forumSettings.name' => 'Foro',
			'settings.forumSettings.configureYourForumSettings' => 'Configure los ajustes de su foro',
			'settings.gallerySettings.gallerySettingsTitle' => 'Ajustes de la galería',
			'settings.gallerySettings.gallerySettingsSubtitle' => 'Configure las preferencias del visor de galería',
			'settings.gallerySettings.defaultViewerQuality' => 'Calidad predeterminada del visor',
			'settings.gallerySettings.defaultViewerQualityDesc' => 'Elija qué calidad de imagen mostrar de forma predeterminada al abrir el visor de la galería.',
			'settings.blockSettings.title' => 'Bloqueo de contenido',
			'settings.blockSettings.subtitle' => 'Ocultar automáticamente los videos y galerías cuyo título coincida con una palabra clave o un patrón, o que provengan de un usuario bloqueado. Toda la coincidencia se realiza en su dispositivo; no se sube nada.',
			'settings.blockSettings.blocked' => 'Bloqueado',
			'settings.blockSettings.reveal' => 'Mostrar',
			'settings.blockSettings.reblock' => 'Bloquear de nuevo',
			'settings.blockSettings.why' => '¿Por qué está bloqueado?',
			'settings.blockSettings.manageRules' => 'Gestionar reglas',
			'settings.blockSettings.reasonKeyword' => ({required Object value}) => 'El título contiene "${value}"',
			'settings.blockSettings.reasonRegex' => ({required Object value}) => 'El título coincide con "${value}"',
			'settings.blockSettings.reasonUser' => 'De un usuario bloqueado',
			'settings.blockSettings.addRule' => 'Añadir regla',
			'settings.blockSettings.editRule' => 'Editar regla',
			'settings.blockSettings.deleteRule' => 'Eliminar regla',
			'settings.blockSettings.ruleType' => 'Tipo de regla',
			'settings.blockSettings.keyword' => 'Palabra clave',
			'settings.blockSettings.regex' => 'Regex',
			'settings.blockSettings.userId' => 'Usuario',
			'settings.blockSettings.value' => 'Texto que debe coincidir',
			'settings.blockSettings.caseSensitive' => 'Sensible a mayúsculas',
			'settings.blockSettings.regexHint' => 'p. ej. trailer|teaser',
			'settings.blockSettings.valueRequired' => 'Introduzca el texto que debe coincidir',
			'settings.blockSettings.invalidRegex' => 'Esa no es una expresión regular válida',
			'settings.blockSettings.noRules' => 'Aún no hay reglas. Toque + para añadir una.',
			'settings.blockSettings.blockUser' => 'Bloquear',
			'settings.blockSettings.unblockUser' => 'Desbloquear',
			'settings.blockSettings.blockUserConfirm' => ({required Object name}) => '¿Bloquear a "${name}"? Sus videos y galerías se ocultarán de las listas y la búsqueda.',
			'settings.blockSettings.userBlocked' => 'Usuario bloqueado',
			'settings.blockSettings.userUnblocked' => 'Usuario desbloqueado',
			'settings.blockSettings.exportRules' => 'Exportar',
			'settings.blockSettings.importRules' => 'Importar',
			'settings.blockSettings.importExport' => 'Importar / Exportar',
			'settings.blockSettings.exportSuccess' => 'Reglas exportadas',
			'settings.blockSettings.exportFailed' => 'No se pudieron exportar las reglas',
			'settings.blockSettings.importSuccess' => ({required Object count}) => 'Se importaron ${count} regla(s)',
			'settings.blockSettings.importFailed' => 'No se pudieron importar las reglas',
			'settings.blockSettings.regexHelp' => 'Ayuda de patrones',
			'settings.blockSettings.regexHelpTitle' => 'Referencia de expresiones regulares',
			'settings.blockSettings.regexHelpIntro' => 'Una expresión regular coincide con los títulos de forma más flexible que una palabra clave simple. Algunos ejemplos comunes:',
			'settings.blockSettings.regexHelpTapHint' => 'Toque un ejemplo para rellenarlo.',
			'settings.blockSettings.regexEx1Pattern' => 'tráiler|avance|extra',
			'settings.blockSettings.regexEx1Desc' => 'Coincide con cualquiera de estas palabras ("|" significa "o")',
			'settings.blockSettings.regexEx2Pattern' => '^\\[.*\\]',
			'settings.blockSettings.regexEx2Desc' => 'Títulos que empiezan con [corchetes]',
			'settings.blockSettings.regexEx3Pattern' => 'Colección\$',
			'settings.blockSettings.regexEx3Desc' => 'Títulos que terminan con "Colección"',
			'settings.blockSettings.regexEx4Pattern' => 'Ep.[0-9]+',
			'settings.blockSettings.regexEx4Desc' => '[0-9]+ es uno o más dígitos — coincide con "Ep.12"',
			'settings.blockSettings.regexEx5Pattern' => '\\d{4}',
			'settings.blockSettings.regexEx5Desc' => '[0-9] es un dígito y {4} significa cuatro seguidos (p. ej., un año)',
			'settings.blockSettings.regexEx1Sample' => 'Avance del nuevo juego ya disponible',
			'settings.blockSettings.regexEx2Sample' => '[Remux] Película completa',
			'settings.blockSettings.regexEx3Sample' => 'Colección de arte primaveral',
			'settings.blockSettings.regexEx4Sample' => 'Resumen del Ep.12 de mi serie',
			'settings.blockSettings.regexEx5Sample' => 'Lo mejor de 2024',
			'settings.blockSettings.regexHelpSampleLabel' => 'Título de ejemplo',
			'settings.blockSettings.regexHelpMatchedTag' => 'Bloqueado',
			'settings.blockSettings.regexHelpNoMatch' => 'Sin coincidencia',
			'settings.blockSettings.regexEx6Pattern' => '[Tt]emporada',
			'settings.blockSettings.regexEx6Desc' => '[Tt] coincide con la T mayúscula o minúscula — aquí detecta "Temporada"',
			'settings.blockSettings.regexEx6Sample' => 'Tráiler de la temporada final',
			'settings.blockSettings.regexEx7Pattern' => 'la (película|serie)',
			'settings.blockSettings.regexEx7Desc' => 'Los paréntesis () agrupan alternativas — coincide con "la película" o "la serie"',
			'settings.blockSettings.regexEx7Sample' => 'Ver la serie ahora',
			'settings.blockSettings.regexEx8Pattern' => 'temporadas?',
			'settings.blockSettings.regexEx8Desc' => 'La s? hace opcional la letra anterior — coincide con "temporada" y "temporadas"',
			'settings.blockSettings.regexEx8Sample' => 'Paquete de dos temporadas',
			'settings.blockSettings.regexEx9Pattern' => '!+',
			'settings.blockSettings.regexEx9Desc' => '+ significa uno o más — coincide con !, !!, !!! ...',
			'settings.blockSettings.regexEx9Sample' => '¡¡¡Increíble!!! Hay que verlo',
			'settings.blockSettings.regexEx10Pattern' => 'extra.*escena',
			'settings.blockSettings.regexEx10Desc' => '.* coincide con cualquier texto intermedio — "extra … escena"',
			'settings.blockSettings.regexEx10Sample' => 'Escena extra eliminada',
			'settings.chatSettings.name' => 'Chat',
			'settings.chatSettings.configureYourChatSettings' => 'Configure los ajustes de su chat',
			'settings.hardwareDecodingAuto' => 'Automático',
			'settings.hardwareDecodingAutoCopy' => 'Copia automática',
			'settings.hardwareDecodingAutoSafe' => 'Seguro automático',
			'settings.hardwareDecodingNo' => 'Desactivado',
			'settings.hardwareDecodingYes' => 'Forzar activación',
			'settings.cdnDistributionStrategy' => 'Estrategia de distribución de contenido',
			'settings.cdnDistributionStrategyDesc' => 'Seleccione la estrategia de distribución del servidor de origen del video para optimizar la velocidad de carga',
			'settings.cdnDistributionStrategyLabel' => 'Estrategia de distribución',
			'settings.cdnDistributionStrategyNoChange' => 'Sin cambios (usar el servidor original)',
			'settings.cdnDistributionStrategyAuto' => 'Selección automática (servidor más rápido)',
			'settings.cdnDistributionStrategySpecial' => 'Especificar servidor',
			'settings.cdnSpecialServer' => 'Especificar servidor',
			'settings.cdnRefreshServerListHint' => 'Pulse el botón de abajo para actualizar la lista de servidores',
			'settings.cdnRefreshButton' => 'Actualizar',
			'settings.cdnFastRingServers' => 'Servidores de anillo rápido',
			'settings.cdnRefreshServerListTooltip' => 'Actualizar la lista de servidores',
			'settings.cdnSpeedTestButton' => 'Prueba de velocidad',
			'settings.cdnSpeedTestingButton' => ({required Object count}) => 'Probando (${count})',
			'settings.cdnNoServerDataHint' => 'No hay datos de servidores disponibles; pulse el botón de actualizar',
			'settings.cdnTestingStatus' => 'Probando',
			'settings.cdnUnreachableStatus' => 'Inaccesible',
			'settings.cdnNotTestedStatus' => 'Sin probar',
			'settings.downloadSettings.downloadSettings' => 'Ajustes de descarga',
			'settings.downloadSettings.enableDownloadNotifications' => 'Notificaciones de descarga',
			'settings.downloadSettings.enableDownloadNotificationsDescription' => 'Mostrar una notificación del sistema cuando una descarga individual finaliza o falla',
			'settings.downloadSettings.notificationPermissionDenied' => 'Permiso de notificaciones denegado. Las notificaciones dentro de la aplicación siguen funcionando; active las notificaciones del sistema en los ajustes.',
			'settings.downloadSettings.storagePermissionStatus' => 'Estado del permiso de almacenamiento',
			'settings.downloadSettings.accessPublicDirectoryNeedStoragePermission' => 'Acceder al directorio público requiere permiso de almacenamiento',
			'settings.downloadSettings.checkingPermissionStatus' => 'Comprobando el estado de los permisos...',
			'settings.downloadSettings.storagePermissionGranted' => 'Permiso de almacenamiento concedido',
			'settings.downloadSettings.storagePermissionNotGranted' => 'Permiso de almacenamiento no concedido',
			'settings.downloadSettings.storagePermissionGrantSuccess' => 'Permiso de almacenamiento concedido correctamente',
			'settings.downloadSettings.storagePermissionGrantFailedButSomeFeaturesMayBeLimited' => 'Error al conceder el permiso de almacenamiento, pero algunas funciones pueden verse limitadas',
			'settings.downloadSettings.storagePermissionRationale' => 'Para guardar las descargas en la carpeta que elija, la aplicación necesita acceso al almacenamiento.\n\nEn Android 11 y versiones posteriores, esto implica el permiso "acceso a todos los archivos"; sin él, los archivos se guardan en la carpeta privada de la aplicación.',
			'settings.downloadSettings.storagePermissionRationaleLegacy' => 'Para guardar las descargas en la carpeta que elija, la aplicación necesita acceso al almacenamiento.\n\nSin él, los archivos se guardan en la carpeta privada de la aplicación.',
			'settings.downloadSettings.grantStoragePermission' => 'Conceder permiso de almacenamiento',
			'settings.downloadSettings.customDownloadPath' => 'Ruta de descarga personalizada',
			'settings.downloadSettings.customDownloadPathDescription' => 'Cuando está activado, puede elegir una ubicación de guardado personalizada para los archivos descargados',
			'settings.downloadSettings.customDownloadPathTip' => '💡 Consejo: seleccionar directorios públicos (como la carpeta Descargas) requiere permiso de almacenamiento; se recomienda usar primero las rutas recomendadas',
			'settings.downloadSettings.androidWarning' => 'Nota para Android: evite seleccionar directorios públicos (como la carpeta Descargas); se recomienda usar directorios específicos de la aplicación para garantizar los permisos de acceso.',
			'settings.downloadSettings.publicDirectoryPermissionTip' => '⚠️ Aviso: ha seleccionado un directorio público; se requiere permiso de almacenamiento para descargar archivos con normalidad',
			'settings.downloadSettings.permissionRequiredForPublicDirectory' => 'Se requiere permiso de almacenamiento para los directorios públicos',
			'settings.downloadSettings.currentDownloadPath' => 'Ruta de descarga actual',
			'settings.downloadSettings.actualDownloadPath' => 'Ruta de descarga real',
			'settings.downloadSettings.defaultAppDirectory' => 'Directorio predeterminado de la aplicación',
			'settings.downloadSettings.permissionGranted' => 'Concedido',
			'settings.downloadSettings.permissionRequired' => 'Permiso necesario',
			'settings.downloadSettings.enableCustomDownloadPath' => 'Activar la ruta de descarga personalizada',
			'settings.downloadSettings.disableCustomDownloadPath' => 'Usar la ruta predeterminada de la aplicación cuando está desactivado',
			'settings.downloadSettings.customDownloadPathLabel' => 'Ruta de descarga personalizada',
			'settings.downloadSettings.selectDownloadFolder' => 'Seleccionar carpeta de descarga',
			'settings.downloadSettings.recommendedPath' => 'Ruta recomendada',
			'settings.downloadSettings.selectFolder' => 'Seleccionar carpeta',
			'settings.downloadSettings.filenameTemplate' => 'Plantilla de nombre de archivo',
			'settings.downloadSettings.filenameTemplateDescription' => 'Personalice las reglas de nomenclatura de los archivos descargados; admite sustitución de variables',
			'settings.downloadSettings.videoFilenameTemplate' => 'Plantilla de nombre de archivo de video',
			'settings.downloadSettings.galleryFolderTemplate' => 'Plantilla de carpeta de galería',
			'settings.downloadSettings.imageFilenameTemplate' => 'Plantilla de nombre de archivo de imagen',
			'settings.downloadSettings.resetToDefault' => 'Restablecer valores predeterminados',
			'settings.downloadSettings.supportedVariables' => 'Variables admitidas',
			'settings.downloadSettings.supportedVariablesDescription' => 'Las siguientes variables pueden usarse en las plantillas de nombre de archivo:',
			'settings.downloadSettings.copyVariable' => 'Copiar variable',
			'settings.downloadSettings.variableCopied' => 'Variable copiada',
			'settings.downloadSettings.warningPublicDirectory' => 'Advertencia: es posible que no se pueda acceder al directorio público seleccionado. Se recomienda seleccionar un directorio específico de la aplicación.',
			'settings.downloadSettings.downloadPathUpdated' => 'Ruta de descarga actualizada',
			'settings.downloadSettings.selectPathFailed' => 'No se pudo seleccionar la ruta',
			'settings.downloadSettings.pickerAlreadyActive' => 'El selector de carpetas ya está abierto',
			'settings.downloadSettings.unsupportedStorageVolume' => 'Ubicación de almacenamiento no admitida. Elija una carpeta en el almacenamiento del dispositivo o en la tarjeta SD.',
			'settings.downloadSettings.recommendedPathSet' => 'Establecida en la ruta recomendada',
			'settings.downloadSettings.setRecommendedPathFailed' => 'No se pudo establecer la ruta recomendada',
			'settings.downloadSettings.templateResetToDefault' => 'Restablecer la plantilla predeterminada',
			'settings.downloadSettings.functionalTest' => 'Prueba funcional',
			'settings.downloadSettings.testInProgress' => 'Probando...',
			'settings.downloadSettings.runTest' => 'Ejecutar prueba',
			'settings.downloadSettings.testDownloadPathAndPermissions' => 'Comprobar si la ruta de descarga y la configuración de permisos funcionan correctamente',
			'settings.downloadSettings.testResults' => 'Resultados de la prueba',
			'settings.downloadSettings.testCompleted' => 'Prueba completada',
			'settings.downloadSettings.testMultisegmentDomain' => 'Validación de dominio (multi-segmento / exceso / formas de escape)',
			'settings.downloadSettings.testMultisegmentPaths' => 'Render de estructura multi-segmento (issue #126)',
			'settings.downloadSettings.testPassed' => 'elementos correctos',
			'settings.downloadSettings.testFailed' => 'Prueba fallida',
			'settings.downloadSettings.testStoragePermissionCheck' => 'Comprobación del permiso de almacenamiento',
			'settings.downloadSettings.testStoragePermissionGranted' => 'Permiso de almacenamiento concedido',
			'settings.downloadSettings.testStoragePermissionMissing' => 'Falta el permiso de almacenamiento; algunas funciones pueden verse limitadas',
			'settings.downloadSettings.testPermissionCheckFailed' => 'Error al comprobar el permiso',
			'settings.downloadSettings.testDownloadPathValidation' => 'Validación de la ruta de descarga',
			'settings.downloadSettings.testPathValidationFailed' => 'Error al validar la ruta',
			'settings.downloadSettings.testFilenameTemplateValidation' => 'Validación de la plantilla de nombre de archivo',
			'settings.downloadSettings.testAllTemplatesValid' => 'Todas las plantillas son válidas',
			'settings.downloadSettings.testSomeTemplatesInvalid' => 'Algunas plantillas contienen caracteres no válidos',
			'settings.downloadSettings.testTemplateValidationFailed' => 'Error al validar la plantilla',
			'settings.downloadSettings.testDirectoryOperationTest' => 'Prueba de operación de directorios',
			'settings.downloadSettings.testDirectoryOperationNormal' => 'La creación de directorios y la escritura de archivos funcionan correctamente',
			'settings.downloadSettings.testDirectoryOperationFailed' => 'Error en la operación de directorio',
			'settings.downloadSettings.testVideoTemplate' => 'Plantilla de video',
			'settings.downloadSettings.testGalleryTemplate' => 'Plantilla de galería',
			'settings.downloadSettings.testImageTemplate' => 'Plantilla de imagen',
			'settings.downloadSettings.testValid' => 'Válido',
			'settings.downloadSettings.testInvalid' => 'No válido',
			'settings.downloadSettings.testSuccess' => 'Correcto',
			'settings.downloadSettings.testCorrect' => 'Correcto',
			'settings.downloadSettings.testError' => 'Error',
			'settings.downloadSettings.testPath' => 'Ruta de prueba',
			'settings.downloadSettings.testBasePath' => 'Ruta base',
			'settings.downloadSettings.testDirectoryCreation' => 'Creación de directorios',
			'settings.downloadSettings.testFileWriting' => 'Escritura de archivos',
			'settings.downloadSettings.testFileContent' => 'Contenido del archivo',
			'settings.downloadSettings.checkingPathStatus' => 'Comprobando el estado de la ruta...',
			'settings.downloadSettings.unableToGetPathStatus' => 'No se puede obtener el estado de la ruta',
			_ => null,
		} ?? switch (path) {
			'settings.downloadSettings.actualPathDifferentFromSelected' => 'Nota: la ruta real difiere de la ruta seleccionada',
			'settings.downloadSettings.grantPermission' => 'Conceder permiso',
			'settings.downloadSettings.fixIssue' => 'Solucionar problema',
			'settings.downloadSettings.issueFixed' => 'Problema solucionado',
			'settings.downloadSettings.fixFailed' => 'No se pudo solucionar; hágalo manualmente',
			'settings.downloadSettings.lackStoragePermission' => 'Falta el permiso de almacenamiento',
			'settings.downloadSettings.cannotAccessPublicDirectory' => 'No se puede acceder al directorio público; se necesita el permiso "acceso a todos los archivos"',
			'settings.downloadSettings.cannotCreateDirectory' => 'No se puede crear el directorio',
			'settings.downloadSettings.directoryNotWritable' => 'El directorio no permite escritura',
			'settings.downloadSettings.insufficientSpace' => 'Espacio disponible insuficiente',
			'settings.downloadSettings.pathValid' => 'La ruta es válida',
			'settings.downloadSettings.validationFailed' => 'Error de validación',
			'settings.downloadSettings.usingDefaultAppDirectory' => 'Usando el directorio predeterminado de la aplicación',
			'settings.downloadSettings.appPrivateDirectory' => 'Directorio privado de la aplicación',
			'settings.downloadSettings.appPrivateDirectoryDesc' => 'Seguro y fiable; no requiere permisos adicionales',
			'settings.downloadSettings.downloadDirectory' => 'Directorio de descargas',
			'settings.downloadSettings.downloadDirectoryDesc' => 'Ubicación de descarga predeterminada del sistema; fácil de gestionar',
			'settings.downloadSettings.moviesDirectory' => 'Directorio de películas',
			'settings.downloadSettings.moviesDirectoryDesc' => 'Directorio de películas del sistema; reconocible por las aplicaciones multimedia',
			'settings.downloadSettings.documentsDirectory' => 'Directorio de documentos',
			'settings.downloadSettings.documentsDirectoryDesc' => 'Directorio de documentos de la aplicación iOS',
			'settings.downloadSettings.requiresStoragePermission' => 'Requiere permiso de almacenamiento para acceder',
			'settings.downloadSettings.recommendedPaths' => 'Rutas recomendadas',
			'settings.downloadSettings.externalAppPrivateDirectory' => 'Directorio privado de la aplicación en almacenamiento externo',
			'settings.downloadSettings.externalAppPrivateDirectoryDesc' => 'Directorio privado de la aplicación en almacenamiento externo; accesible para el usuario y con más espacio',
			'settings.downloadSettings.internalAppPrivateDirectory' => 'Directorio privado interno de la aplicación',
			'settings.downloadSettings.internalAppPrivateDirectoryDesc' => 'Almacenamiento interno de la aplicación; no requiere permisos y tiene menos espacio',
			'settings.downloadSettings.appDocumentsDirectory' => 'Directorio de documentos de la aplicación',
			'settings.downloadSettings.appDocumentsDirectoryDesc' => 'Directorio de documentos específico de la aplicación; seguro y fiable',
			'settings.downloadSettings.downloadsFolder' => 'Carpeta Descargas',
			'settings.downloadSettings.downloadsFolderDesc' => 'Directorio de descargas predeterminado del sistema',
			'settings.downloadSettings.selectRecommendedDownloadLocation' => 'Seleccione una ubicación de descarga recomendada',
			'settings.downloadSettings.noRecommendedPaths' => 'No hay rutas recomendadas disponibles',
			'settings.downloadSettings.recommended' => 'Recomendado',
			'settings.downloadSettings.requiresPermission' => 'Requiere permiso',
			'settings.downloadSettings.authorizeAndSelect' => 'Autorizar y seleccionar',
			'settings.downloadSettings.select' => 'Seleccionar',
			'settings.downloadSettings.permissionAuthorizationFailed' => 'Error al autorizar el permiso; no se puede seleccionar esta ruta',
			'settings.downloadSettings.pathValidationFailed' => 'Error al validar la ruta',
			'settings.downloadSettings.downloadPathSetTo' => 'Ruta de descarga establecida en',
			'settings.downloadSettings.setPathFailed' => 'No se pudo establecer la ruta',
			'settings.downloadSettings.variableTitle' => 'Título',
			'settings.downloadSettings.variableAuthorcache' => 'Primer nombre visto del autor (estable aunque cambie el nombre)',
			'settings.downloadSettings.variableAuthor' => 'Nombre del autor',
			'settings.downloadSettings.variableUsername' => 'Nombre de usuario del autor',
			'settings.downloadSettings.variableQuality' => 'Calidad del video',
			'settings.downloadSettings.variableFilename' => 'Nombre de archivo original',
			'settings.downloadSettings.variableId' => 'ID del contenido',
			'settings.downloadSettings.variableCount' => 'Cantidad de imágenes de la galería',
			'settings.downloadSettings.variableDate' => 'Fecha actual (YYYY-MM-DD)',
			'settings.downloadSettings.variableTime' => 'Hora actual (HH-MM-SS)',
			'settings.downloadSettings.variableDatetime' => 'Fecha y hora actuales (YYYY-MM-DD_HH-MM-SS)',
			'settings.downloadSettings.downloadSettingsTitle' => 'Ajustes de descarga',
			'settings.downloadSettings.downloadSettingsSubtitle' => 'Configure la ruta de descarga y las reglas de nomenclatura de archivos',
			'settings.downloadSettings.suchAsTitleQuality' => 'Por ejemplo: %title_%quality',
			'settings.downloadSettings.suchAsTitleId' => 'Por ejemplo: %title_%id',
			'settings.downloadSettings.suchAsTitleFilename' => 'Por ejemplo: %title_%filename',
			'settings.downloadSettings.structureSection' => 'Estructura de guardado y nombres',
			'settings.downloadSettings.structureSectionDescription' => 'Los archivos descargados se organizan en subcarpetas según el esquema elegido. Solo afecta a descargas futuras; los archivos existentes no se tocan.',
			'settings.downloadSettings.structureNoticeTitle' => 'Novedad: archivar automáticamente por autor',
			'settings.downloadSettings.structureNoticeBody' => 'Elige abajo · solo afecta a las descargas nuevas, los archivos existentes no se tocan.',
			'settings.downloadSettings.presetFlat' => 'Plano',
			'settings.downloadSettings.presetFlatDesc' => 'Todos los archivos van directo a la raíz de descargas',
			'settings.downloadSettings.presetAuthor' => 'Por autor',
			'settings.downloadSettings.presetAuthorBadge' => 'Recomendado',
			'settings.downloadSettings.presetAuthorDesc' => 'Una carpeta por autor · no se divide aunque cambie el nombre',
			'settings.downloadSettings.presetDate' => 'Por fecha',
			'settings.downloadSettings.presetDateDesc' => 'Agrupado por fecha de descarga',
			'settings.downloadSettings.presetCustomActive' => 'En uso',
			'settings.downloadSettings.structurePreviewLabel' => 'Vista previa',
			'settings.downloadSettings.structurePreviewNote' => 'Los segmentos de color son los niveles de organización, cambian con el esquema elegido.',
			'settings.downloadSettings.pathTooLongWarning' => 'La ruta relativa supera los 200 caracteres: puede fallar al guardar en algunos dispositivos',
			'settings.downloadSettings.pathTemplateEditorEntry' => 'Plantilla de ruta personalizada',
			'settings.downloadSettings.pathTemplateEditorEntryDesc' => 'Decide tú la estructura de carpetas y el nombre de los archivos',
			'settings.downloadSettings.pathTemplateEditor.title' => 'Plantilla de ruta',
			'settings.downloadSettings.pathTemplateEditor.subtitle' => 'Organiza automáticamente las descargas en subcarpetas',
			'settings.downloadSettings.pathTemplateEditor.tabVideo' => 'Vídeo',
			'settings.downloadSettings.pathTemplateEditor.tabGallery' => 'Galería',
			'settings.downloadSettings.pathTemplateEditor.tabImage' => 'Imagen individual',
			'settings.downloadSettings.pathTemplateEditor.previewLabel' => 'Vista previa · resultado real tras la limpieza',
			'settings.downloadSettings.pathTemplateEditor.galleryPreviewLabel' => 'Vista previa · la plantilla de galería nombra la carpeta (las imágenes internas usan el ID)',
			'settings.downloadSettings.pathTemplateEditor.addFolder' => 'Añadir un nivel de carpeta',
			'settings.downloadSettings.pathTemplateEditor.folderCapReached' => 'Límite de niveles de carpeta alcanzado',
			'settings.downloadSettings.pathTemplateEditor.folderSegmentHint' => '%authorcache, una variable o texto fijo',
			'settings.downloadSettings.pathTemplateEditor.fileSegmentHint' => 'p. ej. %title_%quality',
			'settings.downloadSettings.pathTemplateEditor.videoCapNote' => ({required Object max}) => 'La extensión .mp4 se añade sola · escribir / en un segmento lo divide en dos niveles · hasta ${max} niveles',
			'settings.downloadSettings.pathTemplateEditor.imageCapNote' => ({required Object max}) => 'La extensión original se añade sola · escribir / en un segmento lo divide en dos niveles · hasta ${max} niveles',
			'settings.downloadSettings.pathTemplateEditor.galleryCapNote' => ({required Object max}) => 'La plantilla de galería son solo carpetas, hasta ${max} niveles · las imágenes internas se nombran con el ID de imagen',
			'settings.downloadSettings.pathTemplateEditor.trayHint' => 'Toca para insertar en el cursor · mantén pulsado para detalles',
			'settings.downloadSettings.pathTemplateEditor.emptySegment' => 'Segmento vacío',
			'settings.downloadSettings.pathTemplateEditor.emptySegmentSaveBlocked' => 'No se puede guardar: hay segmentos vacíos, rellénalos o elimínalos',
			'settings.downloadSettings.pathTemplateEditor.tooManySegmentsSaveBlocked' => 'No se puede guardar: demasiados segmentos de ruta (máx. 4). Combínalos o elimínalos',
			'settings.downloadSettings.pathTemplateEditor.templateInvalidSaveBlocked' => 'No se puede guardar: la plantilla contiene caracteres no válidos',
			'settings.downloadSettings.pathTemplateEditor.variableInserted' => 'Variable insertada',
			'settings.downloadSettings.pathTemplateEditor.savedToast' => 'Guardado · solo afecta a descargas futuras',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryContent' => 'Contenido',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryAuthor' => 'Autor',
			'settings.downloadSettings.pathTemplateEditor.trayCategoryTime' => 'Tiempo',
			'settings.downloadSettings.pathTemplateEditor.chipAuthorcache' => 'Nombre del autor·fijo',
			'settings.downloadSettings.pathTemplateEditor.chipDate' => 'Fecha',
			'settings.downloadSettings.pathTemplateEditor.chipTime' => 'Hora',
			'settings.downloadSettings.pathTemplateEditor.chipDatetime' => 'Fecha y hora',
			'settings.downloadSettings.pathTemplateEditor.chipCount' => 'Índice',
			'favoriteTags.title' => 'Etiquetas favoritas',
			'favoriteTags.emptyIwara' => 'Aún no hay etiquetas de Iwara favoritas',
			'favoriteTags.emptyOreno3d' => 'Aún no hay favoritos',
			'favoriteTags.addIwaraTag' => 'Añadir etiqueta de Iwara',
			'favoriteTags.quickPickHint' => 'Los elementos marcados como favoritos aparecen como selecciones rápidas en la búsqueda.',
			'favoriteTags.pickerTitle' => 'Seleccionar Oreno3D',
			'favoriteTags.searchHint' => 'Buscar por nombre u original',
			'favoriteTags.worksCount' => ({required num n}) => (_root.$meta.cardinalResolver ?? PluralResolvers.cardinal('es'))(n, one: '${n} obra', other: '${n} obras', ), 
			'favoriteTags.browseEntry' => 'Explorar origen / personaje / etiqueta',
			'favoriteTags.favoritesSection' => 'Favoritos',
			'favoriteTags.addFavorite' => 'Añadir',
			'favoriteTags.iwaraTitle' => 'Etiquetas de Iwara favoritas',
			'favoriteTags.oreno3dTitle' => 'Etiquetas de Oreno3D favoritas',
			'favoriteTags.changeTag' => 'Cambiar etiqueta',
			'favoriteTags.switchToText' => 'Búsqueda de texto',
			'oreno3d.name' => 'Oreno3D',
			'oreno3d.tags' => 'Etiquetas',
			'oreno3d.characters' => 'Personajes',
			'oreno3d.origin' => 'Origen',
			'oreno3d.thirdPartyTagsExplanation' => 'La información de **etiquetas**, **personajes** y **origen** que se muestra aquí la proporciona el sitio de terceros **Oreno3D** únicamente como referencia.\n\nComo esta fuente de información solo está disponible en japonés, por ahora no cuenta con adaptación de internacionalización.\n\nSi te interesa contribuir a la internacionalización, visita el repositorio para ayudar a mejorarla.',
			'oreno3d.sortTypes.hot' => 'Popular',
			'oreno3d.sortTypes.favorites' => 'Favoritos',
			'oreno3d.sortTypes.latest' => 'Recientes',
			'oreno3d.sortTypes.popularity' => 'Popularidad',
			'oreno3d.errors.requestFailed' => 'Error en la solicitud; código de estado',
			'oreno3d.errors.connectionTimeout' => 'Tiempo de conexión agotado; compruebe la conexión de red',
			'oreno3d.errors.sendTimeout' => 'Tiempo de espera para enviar la solicitud agotado',
			'oreno3d.errors.receiveTimeout' => 'Tiempo de espera para recibir la respuesta agotado',
			'oreno3d.errors.badCertificate' => 'Error al verificar el certificado',
			'oreno3d.errors.resourceNotFound' => 'No se encontró el recurso solicitado',
			'oreno3d.errors.accessDenied' => 'Acceso denegado; puede requerir autenticación o permiso',
			'oreno3d.errors.serverError' => 'Error interno del servidor',
			'oreno3d.errors.serviceUnavailable' => 'Servicio no disponible temporalmente',
			'oreno3d.errors.requestCancelled' => 'Solicitud cancelada',
			'oreno3d.errors.connectionError' => 'Error de conexión de red; compruebe la configuración de red',
			'oreno3d.errors.networkRequestFailed' => 'Error en la solicitud de red',
			'oreno3d.errors.searchVideoError' => 'Ocurrió un error desconocido al buscar videos',
			'oreno3d.errors.getPopularVideoError' => 'Ocurrió un error desconocido al obtener los videos populares',
			'oreno3d.errors.getVideoDetailError' => 'Ocurrió un error desconocido al obtener los detalles del video',
			'oreno3d.errors.parseVideoDetailError' => 'Ocurrió un error desconocido al obtener y analizar los detalles del video',
			'oreno3d.errors.downloadFileError' => 'Ocurrió un error desconocido al descargar el archivo',
			'oreno3d.loading.gettingVideoInfo' => 'Obteniendo la información del video...',
			'oreno3d.loading.cancel' => 'Cancelar',
			'oreno3d.messages.videoNotFoundOrDeleted' => 'Video no encontrado o eliminado',
			'oreno3d.messages.unableToGetVideoPlayLink' => 'No se pudo obtener el enlace de reproducción del video',
			'oreno3d.messages.getVideoDetailFailed' => 'No se pudieron obtener los detalles del video',
			'signIn.pleaseLoginFirst' => 'Inicie sesión primero',
			'signIn.alreadySignedInToday' => '¡Ya se ha registrado hoy!',
			'signIn.youDidNotStickToTheSignIn' => 'No ha sido constante con el registro diario.',
			'signIn.signInSuccess' => '¡Registro correcto!',
			'signIn.signInFailed' => 'No se pudo registrar; inténtelo de nuevo más tarde',
			'signIn.consecutiveSignIns' => 'Registros consecutivos',
			'signIn.failureReason' => 'Motivo del fallo',
			'signIn.selectDateRange' => 'Seleccionar rango de fechas',
			'signIn.startDate' => 'Fecha de inicio',
			'signIn.endDate' => 'Fecha de fin',
			'signIn.invalidDate' => 'Fecha no válida',
			'signIn.invalidDateRange' => 'Rango de fechas no válido',
			'signIn.errorFormatText' => 'Error de formato de fecha',
			'signIn.errorInvalidText' => 'Rango de fechas no válido',
			'signIn.errorInvalidRangeText' => 'Rango de fechas no válido',
			'signIn.dateRangeCantBeMoreThanOneYear' => 'El rango de fechas no puede superar un año',
			'signIn.signIn' => 'Registrarse',
			'signIn.signInRecord' => 'Historial de registros',
			'signIn.totalSignIns' => 'Total de registros',
			'signIn.pleaseSelectSignInStatus' => 'Seleccione el estado de registro',
			'subscriptions.pleaseLoginFirstToViewYourSubscriptions' => 'Inicie sesión primero para ver sus suscripciones.',
			'subscriptions.selectUser' => 'Seleccionar usuario',
			'subscriptions.noSubscribedUsers' => 'No hay usuarios suscritos',
			'subscriptions.showAllSubscribedUsersContent' => 'Mostrar el contenido de todos los usuarios suscritos',
			'videoDetail.pipMode' => 'Modo PiP',
			'videoDetail.resumeFromLastPosition' => ({required Object position}) => 'Reanudar desde la última posición: ${position}',
			'videoDetail.resumedFromHistoryTip' => ({required Object position}) => 'Reanudado desde ${position}',
			'videoDetail.restartFromBeginning' => 'Empezar de nuevo',
			'videoDetail.dismissResumeTip' => 'Descartar',
			'videoDetail.localInfo.videoInfo' => 'Información del video',
			'videoDetail.localInfo.currentQuality' => 'Calidad actual',
			'videoDetail.localInfo.duration' => 'Duración',
			'videoDetail.localInfo.resolution' => 'Resolución',
			'videoDetail.localInfo.fileInfo' => 'Información del archivo',
			'videoDetail.localInfo.fileName' => 'Nombre del archivo',
			'videoDetail.localInfo.fileSize' => 'Tamaño del archivo',
			'videoDetail.localInfo.filePath' => 'Ruta del archivo',
			'videoDetail.localInfo.copyPath' => 'Copiar ruta',
			'videoDetail.localInfo.openFolder' => 'Abrir carpeta',
			'videoDetail.localInfo.pathCopiedToClipboard' => 'Ruta copiada al portapapeles',
			'videoDetail.localInfo.openFolderFailed' => 'No se pudo abrir la carpeta',
			'videoDetail.videoIdIsEmpty' => 'El ID del video está vacío',
			'videoDetail.videoInfoIsEmpty' => 'La información del video está vacía',
			'videoDetail.thisIsAPrivateVideo' => 'Este es un video privado',
			'videoDetail.getVideoInfoFailed' => 'No se pudo obtener la información del video; inténtelo de nuevo más tarde',
			'videoDetail.noVideoSourceFound' => 'No se encontró ninguna fuente de video',
			'videoDetail.tagCopiedToClipboard' => ({required Object tagId}) => 'Etiqueta "${tagId}" copiada al portapapeles',
			'videoDetail.errorLoadingVideo' => 'Error al cargar el video',
			'videoDetail.play' => 'Reproducir',
			'videoDetail.pause' => 'Pausar',
			'videoDetail.exitAppFullscreen' => 'Salir de pantalla completa de la aplicación',
			'videoDetail.enterAppFullscreen' => 'Entrar en pantalla completa de la aplicación',
			'videoDetail.exitSystemFullscreen' => 'Salir de pantalla completa del sistema',
			'videoDetail.enterSystemFullscreen' => 'Entrar en pantalla completa del sistema',
			'videoDetail.seekTo' => 'Buscar hasta',
			'videoDetail.switchResolution' => 'Cambiar la resolución',
			'videoDetail.switchPlaybackSpeed' => 'Cambiar la velocidad de reproducción',
			'videoDetail.rewindSeconds' => ({required Object num}) => 'Retroceder ${num} segundos',
			'videoDetail.fastForwardSeconds' => ({required Object num}) => 'Avanzar ${num} segundos',
			'videoDetail.playbackSpeedIng' => ({required Object rate}) => 'Reproduciendo a velocidad ${rate}x',
			'videoDetail.brightness' => 'Brillo',
			'videoDetail.brightnessLowest' => 'El brillo está al mínimo',
			'videoDetail.volume' => 'Volumen',
			'videoDetail.volumeMuted' => 'El volumen está silenciado',
			'videoDetail.restoreDefaultZoom' => 'Restaurar',
			'videoDetail.gestureGuide.sampleVideo' => 'Vídeo de ejemplo',
			'videoDetail.gestureGuide.title' => 'Guía de gestos e interacción',
			'videoDetail.gestureGuide.viewGuide' => 'Guía de gestos e interacción',
			'videoDetail.gestureGuide.firstTimeIntro' => 'Dedique unos segundos a aprender los gestos del reproductor. Puede volver a abrir esta guía en cualquier momento desde los ajustes del reproductor.',
			'videoDetail.gestureGuide.startWatching' => 'Entendido, empezar a ver',
			'videoDetail.gestureGuide.basicTitle' => 'Controles básicos',
			'videoDetail.gestureGuide.zoomTitle' => 'Zoom / Girar / Desplazar',
			'videoDetail.gestureGuide.restoreTip' => 'Toque el botón "Restaurar" en la esquina inferior derecha para restablecer el zoom, la rotación y la posición.',
			'videoDetail.gestureGuide.mTap' => 'Toque único: mostrar/ocultar los controles',
			'videoDetail.gestureGuide.mDoubleTap' => 'Doble toque: retroceder (izquierda) / pausar (centro) / avanzar rápido (derecha)',
			'videoDetail.gestureGuide.mHorizontalDrag' => 'Deslizamiento horizontal: buscar',
			'videoDetail.gestureGuide.mVerticalDrag' => 'Deslizamiento vertical: brillo (izquierda) / volumen (derecha)',
			'videoDetail.gestureGuide.mLongPress' => 'Pulsación larga: aceleración temporal',
			'videoDetail.gestureGuide.mPinch' => 'Pellizco con dos dedos: ampliar la imagen',
			'videoDetail.gestureGuide.mRotate' => 'Rotación con dos dedos: girar la imagen',
			'videoDetail.gestureGuide.dTap' => 'Clic: mostrar/ocultar los controles',
			'videoDetail.gestureGuide.dDoubleTap' => 'Doble clic: retroceder (izquierda) / pausar (centro) / avanzar rápido (derecha)',
			'videoDetail.gestureGuide.dKeys' => 'Teclas de búsqueda: pulse para saltar atrás/adelante, mantenga para acelerar; teclas de velocidad: ajustan la velocidad de reproducción durante la reproducción normal; Espacio: reproducir/pausar',
			'videoDetail.gestureGuide.dTrackpadPinch' => 'Pellizco en el panel táctil: ampliar la imagen',
			'videoDetail.gestureGuide.dTrackpadRotate' => 'Rotación en el panel táctil: girar la imagen',
			'videoDetail.gestureGuide.dCtrlWheel' => 'Ctrl + rueda: ampliar alrededor del cursor',
			'videoDetail.gestureGuide.dShiftWheel' => 'Mayús + rueda: girar alrededor del cursor',
			'videoDetail.gestureGuide.quest.title' => 'Familiarícese con Quest',
			'videoDetail.gestureGuide.quest.intro' => 'Vea qué hace cada control y luego pruébelo en su espacio.',
			'videoDetail.gestureGuide.quest.videoTab' => 'Video espacial',
			'videoDetail.gestureGuide.quest.galleryTab' => 'Galería espacial',
			'videoDetail.gestureGuide.quest.scopeNote' => 'Para pantallas y ventanas en su espacio de Quest. Vuelva a abrirla cuando quiera desde los ajustes del reproductor.',
			'videoDetail.gestureGuide.quest.catalog' => 'Explorar los controles',
			'videoDetail.gestureGuide.quest.lessonCount' => ({required Object current, required Object total}) => '${current} de ${total}',
			'videoDetail.gestureGuide.quest.previous' => 'Anterior',
			'videoDetail.gestureGuide.quest.next' => 'Siguiente control',
			'videoDetail.gestureGuide.quest.replay' => 'Repetir la demostración',
			'videoDetail.gestureGuide.quest.pauseDemo' => 'Pausar la demostración',
			'videoDetail.gestureGuide.quest.resumeDemo' => 'Reanudar la demostración',
			'videoDetail.gestureGuide.quest.looping' => 'Demostración de control',
			'videoDetail.gestureGuide.quest.still' => 'Ilustración fija',
			'videoDetail.gestureGuide.quest.done' => 'Entendido, continuar',
			'videoDetail.gestureGuide.quest.leftController' => 'Mano izquierda',
			'videoDetail.gestureGuide.quest.rightController' => 'Mano derecha',
			'videoDetail.gestureGuide.quest.trigger' => 'Gatillo índice',
			'videoDetail.gestureGuide.quest.grip' => 'Botón de agarre',
			'videoDetail.gestureGuide.quest.bothGrips' => 'Ambos botones de agarre',
			'videoDetail.gestureGuide.quest.stick' => 'Joystick',
			'videoDetail.gestureGuide.quest.handTracking' => 'Seguimiento de manos',
			'videoDetail.gestureGuide.quest.ready' => 'Listo',
			'videoDetail.gestureGuide.quest.press' => 'Pulsar',
			'videoDetail.gestureGuide.quest.hold' => 'Mantener',
			'videoDetail.gestureGuide.quest.release' => 'Soltar',
			'videoDetail.gestureGuide.quest.result' => 'Ver el resultado',
			'videoDetail.gestureGuide.quest.pinch' => 'Pellizcar',
			'videoDetail.gestureGuide.quest.selectTitle' => 'Apuntar y seleccionar',
			'videoDetail.gestureGuide.quest.selectBody' => 'Apunte el rayo a un botón y luego pulse y suelte el gatillo índice. Úselo para reproducir, ajustes y controles deslizantes en el panel de control.',
			'videoDetail.gestureGuide.quest.selectHint' => 'El gatillo índice está detrás de la cara del botón. El botón de agarre del asa interior agarra ventanas.',
			'videoDetail.gestureGuide.quest.panelTitle' => 'Mostrar u ocultar el panel',
			'videoDetail.gestureGuide.quest.panelBody' => 'Apunte fuera del panel de control y pulse el gatillo índice para mostrarlo u ocultarlo. Con el seguimiento de manos, un pellizco rápido fuera del panel hace lo mismo.',
			'videoDetail.gestureGuide.quest.panelHint' => 'Use un toque corto sin arrastrar. Mantener y mover es un arrastre, no un cambio del panel.',
			'videoDetail.gestureGuide.quest.playTitle' => 'Reproducir y pausar',
			'videoDetail.gestureGuide.quest.playBody' => 'Apunte fuera del panel de control y pulse A en el derecho o X en el izquierdo para reproducir o pausar. También puede seleccionar el botón de reproducir del panel.',
			'videoDetail.gestureGuide.quest.playHint' => 'Este atajo predeterminado puede desactivarse en los ajustes del reproductor espacial. Al apuntar al panel, la entrada va al panel.',
			'videoDetail.gestureGuide.quest.seekTitle' => 'Desplazarse con el joystick',
			'videoDetail.gestureGuide.quest.seekBody' => 'Mueva cualquiera de los joysticks a izquierda o derecha para un salto de 5 segundos. Manténgalo para desplazarse más rápido mientras previsualiza el tiempo objetivo. Suelte para confirmar la búsqueda.',
			'videoDetail.gestureGuide.quest.seekHint' => 'Mantenga el rayo de ese controlador fuera del panel de control. Un joystick que apunta al panel desplaza el panel en su lugar.',
			'videoDetail.gestureGuide.quest.browseTitle' => 'Navegar con el joystick',
			'videoDetail.gestureGuide.quest.browseBody' => 'Mueva cualquiera de los joysticks a izquierda o derecha para el elemento anterior o siguiente; mantenga para seguir navegando. También puede seleccionar una miniatura en la tira de película.',
			'videoDetail.gestureGuide.quest.browseHint' => 'Los videos de una galería también son elementos. Apuntar al panel de control hace que el joystick desplace el panel.',
			'videoDetail.gestureGuide.quest.swipeTitle' => 'Arrastrar a lo ancho para pasar de página',
			'videoDetail.gestureGuide.quest.swipeBody' => 'Apunte a la imagen, mantenga el gatillo índice y arrastre a la izquierda. Suelte tras la señal de cambio de página para avanzar; arrastre a la derecha para retroceder. También funciona pellizcar y arrastrar.',
			'videoDetail.gestureGuide.quest.swipeHint' => 'Las imágenes deben estar a 1× para pasar páginas arrastrando. Los videos de galería también lo admiten. El escenario permanece inmóvil hasta que suelte.',
			'videoDetail.gestureGuide.quest.zoomTitle' => 'Ampliar la imagen',
			'videoDetail.gestureGuide.quest.zoomBody' => 'Apunte a un detalle de la imagen, mantenga el gatillo índice y luego empuje el joystick hacia arriba para ampliar o hacia abajo para reducir. El zoom se fija donde pulsó.',
			'videoDetail.gestureGuide.quest.zoomHint' => 'Esto amplía la imagen dentro de su ventana. Sin mantener la imagen, arriba/abajo ajusta la distancia de visualización.',
			'videoDetail.gestureGuide.quest.panTitle' => 'Desplazar y restaurar la imagen',
			'videoDetail.gestureGuide.quest.panBody' => 'Una vez ampliada, mantenga el gatillo índice y arrastre para mirar alrededor. Toque dos veces la imagen para ampliarla a 2,5× o restaurarla. Con las manos, pellizque dos veces rápido.',
			'videoDetail.gestureGuide.quest.panHint' => 'Arrastrar desplaza una imagen ampliada. Restaure a 1× antes de arrastrar para pasar páginas.',
			'videoDetail.gestureGuide.quest.slideshowTitle' => 'Iniciar una presentación',
			'videoDetail.gestureGuide.quest.slideshowBody' => 'En una imagen, A / X inicia o pausa la presentación. El panel ofrece intervalos de 3, 5, 10 o 20 segundos y calidad de imagen estándar u original.',
			'videoDetail.gestureGuide.quest.slideshowHint' => 'En un video de galería, A / X controla la reproducción de ese video. El atajo del controlador debe estar activado en los ajustes.',
			'videoDetail.gestureGuide.quest.moveTitle' => 'Agarrar y mover la pantalla',
			'videoDetail.gestureGuide.quest.moveBody' => 'Mantenga el botón de agarre en el asa interior, mueva el controlador para colocar la pantalla y suelte. Mientras ve, puede agarrar la pantalla sin apuntar a ella.',
			'videoDetail.gestureGuide.quest.moveHint' => 'Apuntar a la ventana de la aplicación o al panel de control agarra esa ventana primero. En video panorámico, agarrar ajusta la orientación.',
			'videoDetail.gestureGuide.quest.scaleTitle' => 'Redimensionar con ambas manos',
			'videoDetail.gestureGuide.quest.scaleBody' => 'Mantenga ambos botones de agarre. Separe las manos para ampliar la pantalla o júntelas para reducirla. Con el seguimiento de manos, mantenga un pellizco en ambas manos.',
			'videoDetail.gestureGuide.quest.scaleHint' => 'Para pantallas planas o curvas, incluido el escenario de la galería. Mantenga los rayos fuera del panel de control. Esto redimensiona toda la pantalla.',
			'videoDetail.gestureGuide.quest.distanceTitle' => 'Ajustar la distancia de visualización',
			'videoDetail.gestureGuide.quest.distanceBody' => 'Empuje el joystick hacia arriba para alejar la pantalla o hacia abajo para acercarla. Mientras agarra una ventana, arriba/abajo mueve esa ventana. Ajuste el volumen en el panel.',
			'videoDetail.gestureGuide.quest.distanceHint' => 'Apunte fuera del panel de control. Mantener una imagen cambia arriba/abajo a zoom de imagen; los videos panorámicos ajustan la vista.',
			'videoDetail.gestureGuide.quest.resizeTitle' => 'Usar los bordes y las esquinas',
			'videoDetail.gestureGuide.quest.resizeBody' => 'El marco se ilumina a medida que el rayo se acerca a un borde. Mantenga el gatillo o pellizque en un borde para mover la ventana; arrastre una esquina para redimensionarla.',
			'videoDetail.gestureGuide.quest.resizeHint' => 'Funciona en la ventana de la aplicación, el panel de control y la pantalla. La ventana de la aplicación cambia de ancho y alto; las pantallas conservan su relación de aspecto.',
			'videoDetail.gestureGuide.quest.navigationTitle' => 'Volver y abrir los ajustes',
			'videoDetail.gestureGuide.quest.navigationBody' => 'B / Y retrocede un nivel: cierra una ventana emergente o vuelve al inicio del panel, oculta el panel y luego vuelve a la aplicación. El botón Menú izquierdo abre los ajustes espaciales.',
			'videoDetail.gestureGuide.quest.navigationHint' => 'El botón Meta derecho pertenece al sistema. El recentrado del sistema devuelve la vista al frente conservando el tamaño y la distancia de la pantalla.',
			'videoDetail.gestureGuide.quest.handsTitle' => 'Use las manos',
			'videoDetail.gestureGuide.quest.handsBody' => 'Con el seguimiento de manos activado, apunte el rayo del sistema a un botón, pellizque con el pulgar y el índice y suelte. Use el panel para la reproducción, la búsqueda y la navegación por la galería.',
			'videoDetail.gestureGuide.quest.handsHint' => 'Pellizque fuera para mostrar u ocultar el panel. Pellizque un borde para moverlo, una esquina para redimensionarlo, o pellizque con ambas manos y separe para ampliar la pantalla.',
			'videoDetail.home' => 'Inicio',
			'videoDetail.videoPlayer' => 'Reproductor de video',
			'videoDetail.videoPlayerInfo' => 'Información del reproductor de video',
			'videoDetail.moreSettings' => 'Más ajustes',
			'videoDetail.videoPlayerFeatureInfo' => 'Información de funciones del reproductor de video',
			'videoDetail.autoRewind' => 'Retroceso automático',
			'videoDetail.rewindAndFastForward' => 'Retroceder y avanzar',
			'videoDetail.volumeAndBrightness' => 'Volumen y brillo',
			'videoDetail.centerAreaDoubleTapPauseOrPlay' => 'Doble toque en el área central para pausar o reproducir',
			'videoDetail.showVerticalVideoInFullScreen' => 'Mostrar el video vertical en pantalla completa',
			'videoDetail.keepLastVolumeAndBrightness' => 'Mantener el último volumen y brillo',
			'videoDetail.setProxy' => 'Configurar proxy',
			'videoDetail.moreFeaturesToBeDiscovered' => 'Más funciones por descubrir...',
			'videoDetail.videoPlayerSettings' => 'Ajustes del reproductor de video',
			'videoDetail.commentCount' => ({required Object num}) => '${num} comentarios',
			'videoDetail.writeYourCommentHere' => 'Escriba su comentario aquí...',
			'videoDetail.authorOtherVideos' => 'Otros videos del autor',
			'videoDetail.relatedVideos' => 'Videos relacionados',
			'videoDetail.privateVideo' => 'Este es un video privado',
			'videoDetail.externalVideo' => 'Este es un video externo',
			'videoDetail.openInBrowser' => 'Abrir en el navegador',
			'videoDetail.resourceDeleted' => 'Parece que este video se ha eliminado :/',
			'videoDetail.noDownloadUrl' => 'No hay URL de descarga',
			'videoDetail.startDownloading' => 'Empezar a descargar',
			'videoDetail.downloadFailed' => 'La descarga falló; inténtelo de nuevo más tarde',
			'videoDetail.downloadSuccess' => 'Descarga correcta',
			'videoDetail.download' => 'Descargar',
			'videoDetail.downloadManager' => 'Gestor de descargas',
			'videoDetail.resourceNotFound' => 'Recurso no encontrado',
			'videoDetail.videoLoadError' => 'Error al cargar el video',
			'videoDetail.authorNoOtherVideos' => 'El autor no tiene otros videos',
			'videoDetail.noRelatedVideos' => 'No hay videos relacionados',
			'videoDetail.player.errorWhileLoadingVideoSource' => 'Error al cargar la fuente de video',
			'videoDetail.player.errorWhileSettingUpListeners' => 'Error al configurar los receptores',
			'videoDetail.player.serverFaultDetectedAutoSwitched' => 'Se detectó un fallo del servidor; se cambió de ruta automáticamente y se está reintentando',
			'videoDetail.skeleton.fetchingVideoInfo' => 'Obteniendo la información del video...',
			'videoDetail.skeleton.fetchingVideoSources' => 'Obteniendo las fuentes de video...',
			'videoDetail.skeleton.loadingVideo' => 'Cargando el video...',
			'videoDetail.skeleton.applyingSolution' => 'Aplicando la solución...',
			'videoDetail.skeleton.addingListeners' => 'Añadiendo receptores...',
			'videoDetail.skeleton.successFecthVideoDurationInfo' => 'Se obtuvo la duración del video correctamente; empezando a cargar el video...',
			'videoDetail.skeleton.successFecthVideoHeightInfo' => 'Carga completada',
			'videoDetail.cast.dlnaCast' => 'Transmitir',
			'videoDetail.cast.unableToStartCastingSearch' => ({required Object error}) => 'No se pudo iniciar la búsqueda de transmisión: ${error}',
			'videoDetail.cast.startCastingTo' => ({required Object deviceName}) => 'Empezar a transmitir a ${deviceName}',
			'videoDetail.cast.castFailed' => ({required Object error}) => 'Error al transmitir: ${error}\nIntente volver a buscar dispositivos o cambiar de red',
			'videoDetail.cast.castStopped' => 'Transmisión detenida',
			'videoDetail.cast.deviceTypes.mediaRenderer' => 'Reproductor multimedia',
			'videoDetail.cast.deviceTypes.mediaServer' => 'Servidor multimedia',
			'videoDetail.cast.deviceTypes.internetGatewayDevice' => 'Router',
			'videoDetail.cast.deviceTypes.basicDevice' => 'Dispositivo básico',
			'videoDetail.cast.deviceTypes.dimmableLight' => 'Luz inteligente',
			'videoDetail.cast.deviceTypes.wlanAccessPoint' => 'Punto de acceso WLAN',
			'videoDetail.cast.deviceTypes.wlanConnectionDevice' => 'Dispositivo de conexión WLAN',
			'videoDetail.cast.deviceTypes.printer' => 'Impresora',
			'videoDetail.cast.deviceTypes.scanner' => 'Escáner',
			'videoDetail.cast.deviceTypes.digitalSecurityCamera' => 'Cámara de seguridad digital',
			'videoDetail.cast.deviceTypes.unknownDevice' => 'Dispositivo desconocido',
			'videoDetail.cast.currentPlatformNotSupported' => 'La plataforma actual no admite la transmisión',
			'videoDetail.cast.unableToGetVideoUrl' => 'No se pudo obtener la URL del video; inténtelo de nuevo más tarde',
			'videoDetail.cast.stopCasting' => 'Detener la transmisión',
			'videoDetail.cast.dlnaCastSheet.title' => 'Transmisión remota',
			'videoDetail.cast.dlnaCastSheet.close' => 'Cerrar',
			'videoDetail.cast.dlnaCastSheet.searchingDevices' => 'Buscando dispositivos...',
			'videoDetail.cast.dlnaCastSheet.searchPrompt' => 'Pulse el botón de búsqueda para volver a buscar dispositivos de transmisión',
			'videoDetail.cast.dlnaCastSheet.searching' => 'Buscando',
			'videoDetail.cast.dlnaCastSheet.searchAgain' => 'Buscar de nuevo',
			'videoDetail.cast.dlnaCastSheet.noDevicesFound' => 'No se encontraron dispositivos de transmisión\nAsegúrese de que los dispositivos estén en la misma red',
			'videoDetail.cast.dlnaCastSheet.searchingDevicesPrompt' => 'Buscando dispositivos; espere...',
			'videoDetail.cast.dlnaCastSheet.cast' => 'Transmitir',
			'videoDetail.cast.dlnaCastSheet.connectedTo' => ({required Object deviceName}) => 'Conectado a: ${deviceName}',
			'videoDetail.cast.dlnaCastSheet.notConnected' => 'Ningún dispositivo conectado',
			'videoDetail.cast.dlnaCastSheet.stopCasting' => 'Detener transmisión',
			'videoDetail.likeAvatars.dialogTitle' => 'Quién da me gusta en secreto',
			'videoDetail.likeAvatars.dialogDescription' => '¿Tiene curiosidad por saber quiénes son? Hojee este "álbum de me gusta"~',
			'videoDetail.likeAvatars.closeTooltip' => 'Cerrar',
			'videoDetail.likeAvatars.retry' => 'Reintentar',
			'videoDetail.likeAvatars.noLikesYet' => 'Aún no ha aparecido nadie aquí. ¡Sea el primero!',
			'videoDetail.likeAvatars.pageInfo' => ({required Object page, required Object totalPages, required Object totalCount}) => 'Página ${page} / ${totalPages} · Total: ${totalCount} personas',
			'videoDetail.likeAvatars.prevPage' => 'Página anterior',
			'videoDetail.likeAvatars.nextPage' => 'Página siguiente',
			'share.sharePlayList' => 'Compartir lista de reproducción',
			'share.wowDidYouSeeThis' => '¡Vaya, ha visto esto?',
			'share.nameIs' => 'El nombre es',
			'share.clickLinkToView' => 'Pulse el enlace para verlo',
			'share.iReallyLikeThis' => 'Me gusta mucho esto',
			'share.shareFailed' => 'No se pudo compartir; inténtelo de nuevo más tarde',
			'share.share' => 'Compartir',
			'share.shareAsImage' => 'Compartir como imagen',
			'share.shareAsText' => 'Compartir como texto',
			'share.shareAsImageDesc' => 'Compartir la portada del video como imagen',
			'share.shareAsTextDesc' => 'Compartir los detalles del video como texto',
			'share.shareAsImageFailed' => 'No se pudo compartir la portada del video como imagen; inténtelo de nuevo más tarde',
			'share.shareAsTextFailed' => 'No se pudieron compartir los detalles del video como texto; inténtelo de nuevo más tarde',
			'share.shareVideo' => 'Compartir video',
			'share.authorIs' => 'El autor es',
			'share.shareGallery' => 'Compartir galería',
			'share.galleryTitleIs' => 'El título de la galería es',
			'share.galleryAuthorIs' => 'El autor de la galería es',
			'share.shareUser' => 'Compartir usuario',
			'share.userNameIs' => 'El nombre del usuario es',
			'share.userAuthorIs' => 'El autor del usuario es',
			'share.comments' => 'Comentarios',
			'share.shareThread' => 'Compartir hilo',
			'share.views' => 'Visualizaciones',
			'share.sharePost' => 'Compartir publicación',
			'share.postTitleIs' => 'El título de la publicación es',
			'share.postAuthorIs' => 'El autor de la publicación es',
			'markdown.markdownSyntax' => 'Sintaxis de Markdown',
			'markdown.iwaraSpecialMarkdownSyntax' => 'Sintaxis especial de Markdown de Iwara',
			'markdown.internalLink' => 'Enlace interno',
			'markdown.supportAutoConvertLinkBelow' => 'Se admite la conversión automática de los siguientes enlaces:',
			'markdown.convertLinkExample' => '🎬 Enlace de vídeo\n🖼️ Enlace de imagen\n👤 Enlace de usuario\n📌 Enlace del foro\n🎵 Enlace de lista de reproducción\n💬 Enlace de hilo',
			'markdown.mentionUser' => 'Mencionar usuario',
			'markdown.mentionUserDescription' => 'Escriba @ seguido del nombre de usuario; se convertirá automáticamente en un enlace al usuario',
			'markdown.markdownBasicSyntax' => 'Sintaxis básica de Markdown',
			'markdown.paragraphAndLineBreak' => 'Párrafo y salto de línea',
			'markdown.paragraphAndLineBreakDescription' => 'Los párrafos se separan con una línea, y dos espacios al final de la línea se convertirán en un salto de línea',
			'markdown.paragraphAndLineBreakSyntax' => 'Este es el primer párrafo\n\nEste es el segundo párrafo\nEsta línea termina con dos espacios  \nse convertirá en un salto de línea',
			'markdown.textStyle' => 'Estilo de texto',
			'markdown.textStyleDescription' => 'Use símbolos especiales alrededor del texto para cambiar su estilo',
			'markdown.textStyleSyntax' => '**Texto en negrita**\n*Texto en cursiva*\n~~Texto tachado~~\n`Texto de código`',
			'markdown.quote' => 'Cita',
			'markdown.quoteDescription' => 'Use el símbolo > para crear una cita y varios > para crear una cita de varios niveles',
			'markdown.quoteSyntax' => '> Esta es una cita de primer nivel\n>> Esta es una cita de segundo nivel',
			'markdown.list' => 'Lista',
			'markdown.listDescription' => 'Cree una lista ordenada con número+punto y una lista sin orden con -',
			'markdown.listSyntax' => '1. Primer elemento\n2. Segundo elemento\n\n- Elemento sin orden\n  - Subelemento\n  - Otro subelemento',
			'markdown.linkAndImage' => 'Enlace e imagen',
			'markdown.linkAndImageDescription' => 'Formato de enlace: [texto](URL)\nFormato de imagen: ![descripción](URL)',
			'markdown.linkAndImageSyntax' => ({required Object link, required Object imgUrl}) => '[texto del enlace](${link})\n![descripción de la imagen](${imgUrl})',
			'markdown.title' => 'Título',
			'markdown.titleDescription' => 'Use el símbolo # para crear un título y más # para indicar el nivel',
			'markdown.titleSyntax' => '# Título de primer nivel\n## Título de segundo nivel\n### Título de tercer nivel',
			'markdown.separator' => 'Separador',
			'markdown.separatorDescription' => 'Cree un separador con tres o más símbolos -',
			'markdown.separatorSyntax' => '---',
			'markdown.syntax' => 'Sintaxis',
			'forum.recent' => 'Recientes',
			'forum.category' => 'Categoría',
			'forum.lastReply' => 'Última respuesta',
			'forum.sitewide.badge' => 'Todo el sitio',
			'forum.sitewide.title' => 'Anuncio para todo el sitio',
			'forum.sitewide.readMore' => 'Leer más',
			'forum.errors.pleaseSelectCategory' => 'Seleccione una categoría',
			'forum.errors.threadLocked' => 'Este hilo está cerrado; no se puede responder',
			'forum.createPost' => 'Crear publicación',
			'forum.title' => 'Título',
			'forum.enterTitle' => 'Introducir título',
			'forum.content' => 'Contenido',
			'forum.enterContent' => 'Introducir contenido',
			'forum.writeYourContentHere' => 'Escriba aquí su contenido...',
			'forum.posts' => 'Publicaciones',
			'forum.threads' => 'Hilos',
			'forum.forum' => 'Foro',
			'forum.createThread' => 'Crear hilo',
			'forum.selectCategory' => 'Seleccionar categoría',
			'forum.cooldownRemaining' => ({required Object minutes, required Object seconds}) => 'Tiempo de espera restante: ${minutes} minutos ${seconds} segundos',
			'forum.groups.administration' => 'Administración',
			'forum.groups.global' => 'Global',
			'forum.groups.chinese' => 'Chino',
			'forum.groups.japanese' => 'Japonés',
			'forum.groups.korean' => 'Coreano',
			'forum.groups.other' => 'Otros',
			'forum.leafNames.announcements' => 'Anuncios',
			'forum.leafNames.feedback' => 'Comentarios',
			'forum.leafNames.support' => 'Soporte',
			'forum.leafNames.general' => 'General',
			'forum.leafNames.guides' => 'Guías',
			'forum.leafNames.questions' => 'Preguntas',
			'forum.leafNames.requests' => 'Peticiones',
			'forum.leafNames.sharing' => 'Compartir',
			'forum.leafNames.general_zh' => 'General',
			'forum.leafNames.questions_zh' => 'Preguntas',
			'forum.leafNames.requests_zh' => 'Peticiones',
			'forum.leafNames.support_zh' => 'Soporte',
			'forum.leafNames.general_ja' => 'General',
			'forum.leafNames.questions_ja' => 'Preguntas',
			'forum.leafNames.requests_ja' => 'Peticiones',
			'forum.leafNames.support_ja' => 'Soporte',
			'forum.leafNames.korean' => 'Coreano',
			'forum.leafNames.other' => 'Otros',
			'forum.leafDescriptions.announcements' => 'Notificaciones y anuncios oficiales importantes',
			'forum.leafDescriptions.feedback' => 'Comentarios sobre las funciones y los servicios del sitio web',
			'forum.leafDescriptions.support' => 'Ayuda para resolver problemas relacionados con el sitio web',
			'forum.leafDescriptions.general' => 'Debata sobre cualquier tema',
			'forum.leafDescriptions.guides' => 'Comparta sus experiencias y tutoriales',
			'forum.leafDescriptions.questions' => 'Plantee sus dudas',
			'forum.leafDescriptions.requests' => 'Publique sus peticiones',
			'forum.leafDescriptions.sharing' => 'Comparta contenido interesante',
			'forum.leafDescriptions.general_zh' => 'Debata sobre cualquier tema',
			'forum.leafDescriptions.questions_zh' => 'Plantee sus dudas',
			'forum.leafDescriptions.requests_zh' => 'Publique sus peticiones',
			'forum.leafDescriptions.support_zh' => 'Ayuda para resolver problemas relacionados con el sitio web',
			'forum.leafDescriptions.general_ja' => 'Debata sobre cualquier tema',
			'forum.leafDescriptions.questions_ja' => 'Plantee sus dudas',
			'forum.leafDescriptions.requests_ja' => 'Publique sus peticiones',
			'forum.leafDescriptions.support_ja' => 'Ayuda para resolver problemas relacionados con el sitio web',
			'forum.leafDescriptions.korean' => 'Debates relacionados con el coreano',
			'forum.leafDescriptions.other' => 'Otro contenido sin clasificar',
			'forum.reply' => 'Responder',
			'forum.pendingReview' => 'Pendiente de revisión',
			'forum.editedAt' => 'Editado el',
			_ => null,
		} ?? switch (path) {
			'forum.copySuccess' => 'Copiado al portapapeles',
			'forum.copySuccessForMessage' => ({required Object str}) => 'Copiado al portapapeles: ${str}',
			'forum.editReply' => 'Editar respuesta',
			'forum.editTitle' => 'Editar título',
			'forum.submit' => 'Enviar',
			'notifications.errors.unsupportedNotificationType' => 'Tipo de notificación no admitido',
			'notifications.errors.unknownUser' => 'Usuario desconocido',
			'notifications.errors.unsupportedNotificationTypeWithType' => ({required Object type}) => 'Tipo de notificación no admitido: ${type}',
			'notifications.errors.unknownNotificationType' => 'Tipo de notificación desconocido',
			'notifications.notifications' => 'Notificaciones',
			'notifications.profile' => 'Perfil',
			'notifications.postedNewComment' => 'Publicó un comentario nuevo',
			'notifications.inYour' => 'En su',
			'notifications.video' => 'Vídeo',
			'notifications.repliedYourVideoComment' => 'Respondió a su comentario del video',
			'notifications.copyInfoToClipboard' => 'Copiar la información de la notificación al portapapeles',
			'notifications.copySuccess' => 'Copiado al portapapeles',
			'notifications.copySuccessForMessage' => ({required Object str}) => 'Copiado al portapapeles: ${str}',
			'notifications.markAllAsRead' => 'Marcar todo como leído',
			'notifications.markAllAsReadSuccess' => 'Todas las notificaciones se marcaron como leídas',
			'notifications.markAllAsReadFailed' => 'No se pudo marcar todo como leído',
			'notifications.markSelectedAsRead' => 'Marcar seleccionadas como leídas',
			'notifications.markSelectedAsReadSuccess' => 'Las notificaciones seleccionadas se marcaron como leídas',
			'notifications.markSelectedAsReadFailed' => 'No se pudieron marcar las seleccionadas como leídas',
			'notifications.markAsRead' => 'Marcar como leído',
			'notifications.markAsReadSuccess' => 'La notificación se marcó como leída',
			'notifications.markAsReadFailed' => 'No se pudo marcar la notificación como leída',
			'notifications.notificationTypeHelp' => 'Ayuda sobre los tipos de notificación',
			'notifications.dueToLackOfNotificationTypeDetails' => 'Debido a la falta de detalles del tipo de notificación, los tipos admitidos pueden no cubrir los mensajes que recibe actualmente',
			'notifications.helpUsImproveNotificationTypeSupport' => 'Si desea ayudarnos a mejorar la compatibilidad con los tipos de notificación',
			'notifications.helpUsImproveNotificationTypeSupportLongText' => '1. 📋 Copie la información de la notificación\n2. 🐞 Envíe un informe de problema al repositorio del proyecto\n\n⚠️ Nota: la información de la notificación puede contener datos personales privados; si no desea hacerla pública, también puede enviarla al autor del proyecto por correo electrónico.',
			'notifications.goToRepository' => 'Ir al repositorio',
			'notifications.copy' => 'Copiar',
			'notifications.commentApproved' => 'Comentario aprobado',
			'notifications.repliedYourProfileComment' => 'Respondió a su comentario del perfil',
			'notifications.kReplied' => 'respondió a su comentario en',
			'notifications.kCommented' => 'comentó en su',
			'notifications.kVideo' => 'Vídeo',
			'notifications.kGallery' => 'galería',
			'notifications.kProfile' => 'perfil',
			'notifications.kThread' => 'hilo',
			'notifications.kPost' => 'publicación',
			'notifications.kCommentSection' => 'sección de comentarios',
			'notifications.kApprovedComment' => 'Comentario aprobado',
			'notifications.kApprovedVideo' => 'Video aprobado',
			'notifications.kApprovedGallery' => 'Galería aprobada',
			'notifications.kApprovedThread' => 'Hilo aprobado',
			'notifications.kApprovedPost' => 'Publicación aprobada',
			'notifications.kApprovedForumPost' => 'Publicación del foro aprobada',
			'notifications.kRejectedContent' => 'Revisión de contenido rechazada',
			'notifications.kUnknownType' => 'Tipo de notificación desconocido',
			'conversation.errors.pleaseSelectAUser' => 'Seleccione un usuario',
			'conversation.errors.pleaseEnterATitle' => 'Introduzca un título',
			'conversation.errors.clickToSelectAUser' => 'Pulse para seleccionar un usuario',
			'conversation.errors.loadFailedClickToRetry' => 'No se pudo cargar; pulse para reintentar',
			'conversation.errors.loadFailed' => 'No se pudo cargar',
			'conversation.errors.clickToRetry' => 'Pulse para reintentar',
			'conversation.errors.noMoreConversations' => 'No hay más conversaciones',
			'conversation.conversation' => 'Conversación',
			'conversation.startConversation' => 'Iniciar conversación',
			'conversation.noConversation' => 'Sin conversación',
			'conversation.selectFromLeftListAndStartConversation' => 'Seleccione un usuario de la lista de la izquierda e inicie una conversación',
			'conversation.title' => 'Título',
			'conversation.body' => 'Cuerpo',
			'conversation.selectAUser' => 'Seleccione un usuario',
			'conversation.searchUsers' => 'Buscar usuarios...',
			'conversation.tmpNoConversions' => 'No hay conversaciones',
			'conversation.deleteThisMessage' => 'Eliminar este mensaje',
			'conversation.deleteThisMessageSubtitle' => 'Esta operación no se puede deshacer',
			'conversation.writeMessageHere' => 'Escriba aquí el mensaje...',
			'conversation.lastMessageFromMe' => 'Yo: ',
			'conversation.sendMessage' => 'Enviar mensaje',
			'splash.errors.initializationFailed' => 'Error de inicialización; reinicie la aplicación',
			'splash.preparing' => 'Preparando...',
			'splash.initializing' => 'Inicializando...',
			'splash.loading' => 'Cargando...',
			'splash.ready' => 'Listo',
			'splash.initializingMessageService' => 'Inicializando el servicio de mensajes...',
			'download.errors.imageModelNotFound' => 'No se encontró el modelo de imagen',
			'download.errors.downloadFailed' => 'No se pudo descargar',
			'download.errors.videoInfoNotFound' => 'No se encontró la información del vídeo',
			'download.errors.downloadTaskAlreadyExists' => 'La tarea de descarga ya existe',
			'download.errors.downloadTaskSavePathConflict' => 'La ruta de guardado ya está en uso por otra tarea',
			'download.errors.videoAlreadyDownloaded' => 'El vídeo ya se descargó',
			'download.errors.downloadFailedForMessage' => ({required Object errorInfo}) => 'No se pudo añadir la tarea de descarga: ${errorInfo}',
			'download.errors.userPausedDownload' => 'El usuario pausó la descarga',
			'download.errors.unknown' => 'Desconocido',
			'download.errors.fileSystemError' => ({required Object errorInfo}) => 'Error del sistema de archivos: ${errorInfo}',
			'download.errors.unknownError' => ({required Object errorInfo}) => 'Error desconocido: ${errorInfo}',
			'download.errors.writeFileFailedForMessage' => ({required Object errorInfo}) => 'No se pudo escribir el archivo: ${errorInfo}',
			'download.errors.connectionTimeout' => 'Se agotó el tiempo de conexión',
			'download.errors.sendTimeout' => 'Se agotó el tiempo de envío',
			'download.errors.receiveTimeout' => 'Se agotó el tiempo de recepción',
			'download.errors.serverError' => ({required Object errorInfo}) => 'Error del servidor: ${errorInfo}',
			'download.errors.unknownNetworkError' => 'Error de red desconocido',
			'download.errors.sslHandshakeFailed' => 'Falló el protocolo de enlace SSL; compruebe su red',
			'download.errors.connectionFailed' => 'No se pudo conectar; compruebe su red',
			'download.errors.serviceIsClosing' => 'El servicio de descarga se está cerrando',
			'download.errors.partialDownloadFailed' => 'No se pudo descargar el contenido parcial',
			'download.errors.noDownloadTask' => 'No hay tarea de descarga',
			'download.errors.taskNotFoundOrDataError' => 'No se encontró la tarea o hay un error en los datos',
			'download.errors.fileNotFound' => 'No se encontró el archivo',
			'download.errors.openFolderFailed' => 'No se pudo abrir la carpeta',
			'download.errors.copyDownloadUrlFailed' => 'No se pudo copiar la URL de descarga',
			'download.errors.openFolderFailedWithMessage' => ({required Object message}) => 'No se pudo abrir la carpeta: ${message}',
			'download.errors.directoryNotFound' => 'No se encontró el directorio',
			'download.errors.copyFailed' => 'No se pudo copiar',
			'download.errors.openFileFailed' => 'No se pudo abrir el archivo',
			'download.errors.openFileFailedWithMessage' => ({required Object message}) => 'No se pudo abrir el archivo: ${message}',
			'download.errors.playLocallyFailed' => 'No se pudo reproducir localmente',
			'download.errors.playLocallyFailedWithMessage' => ({required Object message}) => 'No se pudo reproducir localmente: ${message}',
			'download.errors.noDownloadSource' => 'No hay fuente de descarga',
			'download.errors.noDownloadSourceNowPleaseWaitInfoLoaded' => 'No hay fuente de descarga; espere a que termine de cargarse la información e inténtelo de nuevo',
			'download.errors.noActiveDownloadTask' => 'No hay tareas de descarga activas',
			'download.errors.noFailedDownloadTask' => 'No hay tareas de descarga fallidas',
			'download.errors.noCompletedDownloadTask' => 'No hay tareas de descarga completadas',
			'download.errors.taskAlreadyCompletedDoNotAdd' => 'La tarea ya se completó; no la añada de nuevo',
			'download.errors.linkExpiredTryAgain' => 'El enlace caducó; intentando obtener un nuevo enlace de descarga',
			'download.errors.linkExpiredTryAgainSuccess' => 'El enlace caducó; se obtuvo un nuevo enlace de descarga',
			'download.errors.linkExpiredTryAgainFailed' => 'El enlace caducó; no se pudo obtener un nuevo enlace de descarga',
			'download.errors.taskDeleted' => 'Tarea eliminada',
			'download.errors.unsupportedImageFormat' => ({required Object format}) => 'Formato de imagen no compatible: ${format}',
			'download.errors.deleteFileError' => 'No se pudo eliminar el archivo; quizá lo esté usando otro proceso',
			'download.errors.deleteTaskError' => 'No se pudo eliminar la tarea',
			'download.errors.canNotRefreshVideoTask' => 'No se pudo actualizar la tarea de vídeo',
			'download.errors.videoRemovedCanNotRefresh' => 'Este vídeo se eliminó o ya no existe, por lo que no se puede actualizar el enlace de descarga',
			'download.errors.videoInaccessibleCanNotRefresh' => 'No se puede acceder a este vídeo; puede ser privado o es posible que deba iniciar sesión de nuevo',
			'download.errors.videoQualityGone' => 'Esta calidad ya no se ofrece; añada la descarga de nuevo',
			'download.errors.refreshLinkNetworkFailed' => 'Error de red; ahora mismo no se puede actualizar el enlace de descarga. Inténtelo de nuevo más tarde',
			'download.errors.taskAlreadyProcessing' => 'La tarea ya está en proceso',
			'download.errors.taskNotFound' => 'No se encontró la tarea',
			'download.errors.failedToLoadTasks' => 'No se pudieron cargar las tareas',
			'download.errors.partialDownloadFailedWithMessage' => ({required Object message}) => 'No se pudo completar la descarga parcial: ${message}',
			'download.errors.unsupportedImageFormatWithMessage' => ({required Object extension}) => 'Formato de imagen no compatible: ${extension}; puede intentar descargarla en su dispositivo para verla',
			'download.errors.imageLoadFailed' => 'No se pudo cargar la imagen',
			'download.errors.pleaseTryOtherViewer' => 'Intente abrirlo con otro visor',
			'download.downloadList' => 'Lista de descargas',
			'download.viewDownloadList' => 'Ver la lista de descargas',
			'download.download' => 'Descargar',
			'download.selectDownloadTitle' => 'Seleccionar descarga',
			'download.qualitySectionLabel' => 'Calidad',
			'download.categorySectionLabel' => 'Categoría',
			'download.saveToPreviewLabel' => 'Se guardará en',
			'download.saveToPreviewSuggested' => ({required Object name}) => 'Nombre sugerido: ${name} (editable en el diálogo del sistema)',
			'download.lastUsedBadge' => 'Último uso',
			'download.pickedBadge' => 'Seleccionado',
			'download.startDownloading' => 'Iniciar descarga',
			'download.clearAllFailedTasks' => 'Borrar todas las tareas fallidas',
			'download.clearAllFailedTasksConfirmation' => '¿Seguro que quiere borrar todas las tareas de descarga fallidas? También se eliminarán los archivos de estas tareas.',
			'download.clearAllFailedTasksSuccess' => 'Se borraron todas las tareas fallidas',
			'download.clearAllFailedTasksError' => 'Se produjo un error al borrar las tareas fallidas',
			'download.downloadStatus' => 'Estado de la descarga',
			'download.imageList' => 'Lista de imágenes',
			'download.retryDownload' => 'Reintentar descarga',
			'download.notDownloaded' => 'Sin descargar',
			'download.downloaded' => 'Descargado',
			'download.waitingForDownload' => 'En espera de descarga',
			'download.downloadingProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'Descargando (${downloaded}/${total} imágenes ${progress}%)',
			'download.downloadingSingleImageProgress' => ({required Object downloaded}) => 'Descargando (${downloaded} imágenes)',
			'download.pausedProgressForImageProgress' => ({required Object downloaded, required Object total, required Object progress}) => 'En pausa (${downloaded}/${total} imágenes ${progress}%)',
			'download.pausedSingleImageProgress' => ({required Object downloaded}) => 'En pausa (${downloaded} imágenes)',
			'download.downloadedProgressForImageProgress' => ({required Object total}) => 'Descargado (${total} imágenes en total)',
			'download.viewVideoDetail' => 'Ver los detalles del vídeo',
			'download.viewGalleryDetail' => 'Ver los detalles de la galería',
			'download.moreOptions' => 'Más opciones',
			'download.openFile' => 'Abrir archivo',
			'download.playLocally' => 'Reproducir localmente',
			'download.pause' => 'Pausar',
			'download.resume' => 'Reanudar',
			'download.copyDownloadUrl' => 'Copiar URL de descarga',
			'download.showInFolder' => 'Mostrar en la carpeta',
			'download.deleteTask' => 'Eliminar tarea',
			'download.deleteTaskConfirmation' => '¿Seguro que quiere eliminar esta tarea de descarga?\nTambién se eliminará el archivo de la tarea.',
			'download.forceDeleteTask' => 'Forzar eliminación de la tarea',
			'download.forceDeleteTaskConfirmation' => '¿Seguro que quiere forzar la eliminación de esta tarea de descarga?\nTambién se eliminará el archivo de la tarea, aunque esté en uso.',
			'download.downloadingProgressForVideoTask' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Descargando ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloadingOnlyDownloadedAndSpeed' => ({required Object downloaded, required Object speed}) => 'Descargando ${downloaded} • ${speed}MB/s',
			'download.pausedForDownloadedAndTotal' => ({required Object downloaded, required Object total, required Object progress}) => 'En pausa ${downloaded}/${total} (${progress}%)',
			'download.pausedAndDownloaded' => ({required Object downloaded}) => 'En pausa • Descargado ${downloaded}',
			'download.downloadedWithSize' => ({required Object size}) => 'Descargado • ${size}',
			'download.copyDownloadUrlSuccess' => 'URL de descarga copiada',
			'download.totalImageNums' => ({required Object num}) => '${num} imágenes',
			'download.downloadingDownloadedTotalProgressSpeed' => ({required Object downloaded, required Object total, required Object progress, required Object speed}) => 'Descargando ${downloaded}/${total} (${progress}%) • ${speed}MB/s',
			'download.downloading' => 'Descargando',
			'download.failed' => 'Fallido',
			'download.completed' => 'Completado',
			'download.downloadDetail' => 'Detalles de la descarga',
			'download.copy' => 'Copiar',
			'download.copySuccess' => 'Copiado',
			'download.waiting' => 'En espera',
			'download.paused' => 'En pausa',
			'download.downloadingOnlyDownloaded' => ({required Object downloaded}) => 'Descargando ${downloaded}',
			'download.galleryDownloadCompletedWithName' => ({required Object galleryName}) => 'Descarga de la galería completada: ${galleryName}',
			'download.downloadCompletedWithName' => ({required Object fileName}) => 'Descarga completada: ${fileName}',
			'download.searchTasks' => 'Buscar tareas...',
			'download.statusLabel' => ({required Object label}) => 'Estado: ${label}',
			'download.allStatus' => 'Todos los estados',
			'download.typeLabel' => ({required Object label}) => 'Tipo: ${label}',
			'download.allTypes' => 'Todos los tipos',
			'download.taskType' => 'Tipo',
			'download.video' => 'Vídeo',
			'download.gallery' => 'Galería',
			'download.other' => 'Otro',
			'download.clearFilters' => 'Borrar filtros',
			'download.pauseAll' => 'Pausar todo',
			'download.resumeAll' => 'Iniciar todo',
			'download.remainingTime' => ({required Object time}) => 'quedan ${time}',
			'download.timeline.today' => 'Hoy',
			'download.timeline.yesterday' => 'Ayer',
			'download.timeline.thisWeek' => 'Esta semana',
			'download.timeline.thisMonth' => 'Este mes',
			'download.errorTypes.network' => 'Problema de red; reintentar puede ayudar',
			'download.errorTypes.serverRejected' => 'Rechazado por el servidor; es posible que deba iniciar sesión de nuevo',
			'download.errorTypes.notFound' => 'El recurso ya no existe o se eliminó',
			'download.errorTypes.diskFull' => 'No hay suficiente espacio de almacenamiento',
			'download.errorTypes.fileInUse' => 'El archivo está en uso por otro programa',
			'download.errorTypes.permission' => 'Sin permiso de escritura',
			'download.errorTypes.cancelled' => 'Cancelado',
			'download.errorTypes.unknown' => 'Error desconocido',
			'download.errorDetailCopied' => 'Detalles del error copiados',
			'download.errorDetailCopyHint' => 'Mantenga pulsado para copiar los detalles del error',
			'download.restoredPaused.banner' => ({required Object num}) => 'Se pausaron ${num} tareas sin terminar de la sesión anterior',
			'download.restoredPaused.resume' => 'Reanudar todo',
			'download.restoredPaused.dismiss' => 'Descartar',
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
			'download.emptyTaskList' => 'Aún no hay tareas de descarga',
			'download.noMatchingTasks' => 'Ninguna tarea coincide',
			'download.deleteByDate.menuTitle' => 'Eliminar por fecha',
			'download.deleteByDate.dialogTitle' => 'Eliminar por fecha',
			'download.deleteByDate.description' => 'Elimine tareas de descarga en bloque según su fecha de creación. Las tareas cuyos archivos estén en uso se omiten; las tareas cuyos archivos ya no existan se limpian.',
			'download.deleteByDate.modeRange' => 'Intervalo de fechas',
			'download.deleteByDate.modeDays' => 'Más antiguas que',
			'download.deleteByDate.startDate' => 'Fecha de inicio',
			'download.deleteByDate.endDate' => 'Fecha de fin',
			'download.deleteByDate.notSet' => 'Sin establecer',
			'download.deleteByDate.daysUnit' => 'días',
			'download.deleteByDate.olderThanDaysHint' => ({required Object days}) => 'Eliminar las tareas creadas hace más de ${days} día(s)',
			'download.deleteByDate.noMatch' => 'Ninguna tarea coincide con la condición seleccionada',
			'download.deleteByDate.invalidRange' => 'La fecha de inicio debe ser anterior o igual a la fecha de fin',
			'download.deleteByDate.confirmTitle' => 'Confirmar eliminación',
			'download.deleteByDate.confirmContent' => ({required Object count}) => '¿Eliminar ${count} tareas de descarga y sus archivos? Esta acción no se puede deshacer.',
			'download.deleteByDate.deleting' => ({required Object done, required Object total}) => 'Eliminando ${done}/${total}…',
			'download.deleteByDate.resultSuccess' => ({required Object count}) => 'Se eliminaron ${count} tarea(s)',
			'download.deleteByDate.resultPartial' => ({required Object deleted, required Object skipped}) => 'Se eliminaron ${deleted} tarea(s); ${skipped} omitidas (en uso)',
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
			'download.category.manageTitle' => 'Gestionar categorías',
			'download.category.label' => 'Categorías',
			'download.category.uncategorized' => 'Sin categoría',
			'download.category.manage' => 'Gestionar',
			'download.category.createShortcut' => 'Nueva',
			'download.category.newCategoryHint' => 'Nombre de la nueva categoría',
			'download.category.createSuccess' => 'Categoría creada',
			'download.category.createFailed' => 'No se pudo crear la categoría',
			'download.category.nameEmpty' => 'El nombre de la categoría no puede estar vacío',
			'download.category.emptyHint' => 'Aún no hay categorías. Cree una para organizar sus descargas.',
			'download.category.moveTo' => 'Mover a categoría',
			'download.category.moveToWithCount' => ({required Object count}) => 'Mover ${count} elemento(s) a…',
			'download.category.moveSuccess' => ({required Object title}) => 'Movido a ${title}',
			'download.category.moveToUncategorizedSuccess' => 'Movido a Sin categoría',
			'download.category.moveFailed' => 'No se pudo mover',
			'download.category.renameTitle' => 'Cambiar nombre de la categoría',
			'download.category.renameHint' => 'Introduzca el nombre de la categoría',
			'download.category.renameSuccess' => 'Se cambió el nombre de la categoría',
			'download.category.renameFailed' => 'No se pudo cambiar el nombre de la categoría',
			'download.category.deleteTitle' => 'Eliminar categoría',
			'download.category.deleteConfirm' => ({required Object title, required Object count}) => '¿Eliminar la categoría "${title}"? Los ${count} elementos que contiene pasarán a Sin categoría. No se elimina ningún archivo.',
			'download.category.deleteSuccess' => 'Categoría eliminada',
			'download.category.deleteFailed' => 'No se pudo eliminar la categoría',
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
			'download.maxConcurrentDownloads' => 'Descargas simultáneas máximas',
			_ => null,
		} ?? switch (path) {
			'download.maxConcurrentDownloadsDesc' => 'Número de tareas que se descargan a la vez (1-5)',
			'download.stillInDevelopment' => 'Aún en desarrollo',
			'download.saveToAppDirectory' => 'Guardar en el directorio de la aplicación',
			'download.alreadyDownloadedWithQuality' => 'Ya se descargó con la misma calidad. ¿Continuar con la descarga?',
			'download.alreadyDownloadedWithQualities' => ({required Object qualities}) => 'Ya se descargó con las calidades: ${qualities}. ¿Continuar con la descarga?',
			'download.otherQualities' => 'Otras calidades',
			'download.batchDownload.title' => 'Descarga por lotes',
			'download.batchDownload.downloadTaskAlreadyRunning' => 'Ya hay una tarea en curso; espere, por favor.',
			'download.batchDownload.userCancelled' => 'Cancelado por el usuario',
			'download.batchDownload.failedToGetVideoInfo' => 'No se pudo obtener la información del vídeo',
			'download.batchDownload.failedToGetVideoSource' => 'No se pudo obtener la fuente del vídeo',
			'download.batchDownload.failedToGetGalleryInfo' => 'No se pudo obtener la información de la galería',
			'download.batchDownload.galleryNoImages' => 'La galería no tiene imágenes',
			'download.batchDownload.failedToGetSavePath' => 'No se pudo obtener la ruta de guardado',
			'download.batchDownload.batchDownloadFailedWithException' => ({required Object exception}) => 'Error en la descarga por lotes: ${exception}',
			'download.batchDownload.selectQuality' => 'Seleccionar calidad',
			'download.batchDownload.downloading' => 'Descargando',
			'download.batchDownload.downloadResult' => 'Resultado de la descarga',
			'download.batchDownload.selectedVideosCount' => ({required Object count}) => '${count} vídeos seleccionados',
			'download.batchDownload.selectedGalleriesCount' => ({required Object count}) => '${count} galerías seleccionadas',
			'download.batchDownload.qualityNote' => 'Si la calidad seleccionada no está disponible, se usará la mejor calidad disponible',
			'download.batchDownload.progress' => ({required Object current, required Object total}) => 'Procesando ${current}/${total}',
			'download.batchDownload.queued' => 'En cola',
			'download.batchDownload.success' => 'Correcto',
			'download.batchDownload.skipped' => 'Omitido',
			'download.batchDownload.failed' => 'Fallido',
			'download.batchDownload.failureDetails' => 'Detalles del fallo',
			'download.batchDownload.reasonPrivateVideo' => 'Vídeo privado',
			'download.batchDownload.reasonAlreadyExists' => 'Ya existe',
			'download.batchDownload.reasonNoSource' => 'No hay fuente de descarga',
			'download.batchDownload.reasonNoSavePath' => 'No se puede obtener la ruta de guardado',
			'download.batchDownload.reasonOther' => 'Otro error',
			'download.batchDownload.startDownload' => 'Iniciar descarga',
			'downloadNotifications.completedTitle' => 'Descarga completada',
			'downloadNotifications.failedTitle' => 'No se pudo descargar',
			'downloadNotifications.completedBody' => ({required Object name}) => '${name} se descargó correctamente',
			'downloadNotifications.failedBody' => ({required Object name}) => 'No se pudo descargar ${name}',
			'downloadNotifications.completedToast' => ({required Object name}) => '${name} descargado',
			'downloadNotifications.failedToast' => ({required Object name}) => 'No se pudo descargar ${name}',
			'downloadNotifications.savedToFolder' => ({required Object dir}) => 'Guardado en ${dir}',
			'downloadNotifications.savedAsRenamed' => ({required Object name}) => 'Guardado como ${name} (ya existía un archivo con el mismo nombre)',
			'downloadNotifications.savedToAppFolder' => ({required Object target, required Object reason}) => 'Guardado en la carpeta de la app — no se pudo escribir en ${target} (${reason})',
			'downloadNotifications.viewFolder' => 'Ver carpeta',
			'downloadNotifications.fixInSettings' => 'Corregir en Ajustes',
			'downloadNotifications.channelName' => 'Estado de las descargas',
			'downloadNotifications.channelDescription' => 'Notificaciones de descargas completadas y fallidas',
			'favorite.errors.addFailed' => 'No se pudo añadir',
			'favorite.errors.addSuccess' => 'Añadido correctamente',
			'favorite.errors.deleteFolderFailed' => 'No se pudo eliminar la carpeta',
			'favorite.errors.deleteFolderSuccess' => 'Carpeta eliminada correctamente',
			'favorite.errors.folderNameCannotBeEmpty' => 'El nombre de la carpeta no puede estar vacío',
			'favorite.add' => 'Añadir',
			'favorite.addSuccess' => 'Añadido correctamente',
			'favorite.addFailed' => 'No se pudo añadir',
			'favorite.remove' => 'Quitar',
			'favorite.removeSuccess' => 'Quitado correctamente',
			'favorite.removeFailed' => 'No se pudo quitar',
			'favorite.removeConfirmation' => '¿Seguro que quiere quitar este elemento de favoritos?',
			'favorite.removeConfirmationSuccess' => 'Elemento quitado de favoritos',
			'favorite.removeConfirmationFailed' => 'No se pudo quitar el elemento de favoritos',
			'favorite.createFolderSuccess' => 'Carpeta creada correctamente',
			'favorite.createFolderFailed' => 'No se pudo crear la carpeta',
			'favorite.createFolder' => 'Crear carpeta',
			'favorite.enterFolderName' => 'Introduzca el nombre de la carpeta',
			'favorite.enterFolderNameHere' => 'Introduzca aquí el nombre de la carpeta...',
			'favorite.create' => 'Crear',
			'favorite.items' => 'Elementos',
			'favorite.newFolderName' => 'Nueva carpeta',
			'favorite.searchFolders' => 'Buscar carpetas...',
			'favorite.searchItems' => 'Buscar elementos...',
			'favorite.createdAt' => 'Creado el',
			'favorite.myFavorites' => 'Mis favoritos',
			'favorite.deleteFolderTitle' => 'Eliminar carpeta',
			'favorite.deleteFolderConfirmWithTitle' => ({required Object title}) => '¿Seguro que quiere eliminar la carpeta ${title}?',
			'favorite.removeItemTitle' => 'Quitar elemento',
			'favorite.removeItemConfirmWithTitle' => ({required Object title}) => '¿Seguro que quiere eliminar el elemento ${title}?',
			'favorite.removeItemSuccess' => 'Elemento quitado de favoritos',
			'favorite.removeItemFailed' => 'No se pudo quitar el elemento de favoritos',
			'favorite.localizeFavorite' => 'Favorito local',
			'favorite.editFolderTitle' => 'Editar carpeta',
			'favorite.editFolderSuccess' => 'Carpeta actualizada correctamente',
			'favorite.editFolderFailed' => 'No se pudo actualizar la carpeta',
			'favorite.searchTags' => 'Buscar etiquetas',
			'favorite.noTagsInFolder' => 'Aún no hay etiquetas en los elementos de esta carpeta',
			'favorite.tagFilterMatchAll' => 'Muestra solo los elementos que tienen todas las etiquetas seleccionadas',
			'favorite.clearSelectedTags' => 'Borrar las etiquetas seleccionadas',
			'favorite.selectedTagCount' => ({required Object count}) => '${count} seleccionadas',
			'favorite.noMatchingTags' => 'No hay etiquetas coincidentes',
			'translation.currentService' => 'Servicio actual',
			'translation.testConnection' => 'Probar conexión',
			'translation.testConnectionSuccess' => 'Conexión probada correctamente',
			'translation.testConnectionFailed' => 'La prueba de conexión falló',
			'translation.testConnectionFailedWithMessage' => ({required Object message}) => 'La prueba de conexión falló: ${message}',
			'translation.translation' => 'Traducción',
			'translation.needVerification' => 'Requiere verificación',
			'translation.needVerificationContent' => 'Pruebe la conexión antes de activar la traducción con IA',
			'translation.confirm' => 'Confirmar',
			'translation.disclaimer' => 'Aviso legal',
			'translation.riskWarning' => 'Advertencia de riesgo',
			'translation.dureToRisk1' => 'Como el texto lo generan los usuarios, puede contener contenido que infrinja la política de contenido del proveedor del servicio de IA',
			'translation.dureToRisk2' => 'El contenido inapropiado puede provocar la suspensión de la clave de API o la cancelación del servicio',
			'translation.operationSuggestion' => 'Sugerencia de uso',
			'translation.operationSuggestion1' => '1. Úselo tras revisar estrictamente el contenido que se va a traducir',
			'translation.operationSuggestion2' => '2. Evite traducir contenido que implique violencia, contenido para adultos, etc.',
			'translation.apiConfig' => 'Configuración de la API',
			'translation.modifyConfigWillAutoCloseAITranslation' => 'Modificar la configuración cerrará automáticamente la traducción con IA; deberá probarla de nuevo tras activarla',
			'translation.apiAddress' => 'Dirección de la API',
			'translation.modelName' => 'Nombre del modelo',
			'translation.modelNameHintText' => 'Por ejemplo: gpt-4-turbo',
			'translation.maxTokens' => 'Tokens máximos',
			'translation.maxTokensHintText' => 'Por ejemplo: 32000',
			'translation.temperature' => 'Temperatura',
			'translation.temperatureHintText' => '0.0-2.0',
			'translation.clickTestButtonToVerifyAPIConnection' => 'Pulse el botón de prueba para verificar la validez de la conexión con la API',
			'translation.requestPreview' => 'Vista previa de la solicitud',
			'translation.enableAITranslation' => 'Activar IA',
			'translation.enabled' => 'Activado',
			'translation.disabled' => 'Desactivado',
			'translation.testing' => 'Probando...',
			'translation.testNow' => 'Probar ahora',
			'translation.connectionStatus' => 'Estado de la conexión',
			'translation.success' => 'Correcto',
			'translation.failed' => 'Fallido',
			'translation.information' => 'Información',
			'translation.viewRawResponse' => 'Ver la respuesta sin procesar',
			'translation.pleaseCheckInputParametersFormat' => 'Compruebe el formato de los parámetros de entrada',
			'translation.pleaseFillInAPIAddressModelNameAndKey' => 'Rellene la dirección de la API, el nombre del modelo y la clave',
			'translation.pleaseFillInValidConfigurationParameters' => 'Rellene parámetros de configuración válidos',
			'translation.pleaseCompleteConnectionTest' => 'Complete la prueba de conexión',
			'translation.notConfigured' => 'Sin configurar',
			'translation.apiEndpoint' => 'Punto de conexión de la API',
			'translation.configuredKey' => 'Clave configurada',
			'translation.notConfiguredKey' => 'Clave sin configurar',
			'translation.authenticationStatus' => 'Estado de autenticación',
			'translation.thisFieldCannotBeEmpty' => 'Este campo no puede estar vacío',
			'translation.apiKey' => 'Clave de API',
			'translation.apiKeyCannotBeEmpty' => 'La clave de API no puede estar vacía',
			'translation.pleaseEnterValidNumber' => 'Introduzca un número válido',
			'translation.range' => 'Rango',
			'translation.mustBeGreaterThan' => 'Debe ser mayor que',
			'translation.invalidAPIResponse' => 'Respuesta de API no válida',
			'translation.connectionFailedForMessage' => ({required Object message}) => 'Error de conexión: ${message}',
			'translation.aiTranslationNotEnabledHint' => 'La traducción con IA no está activada; actívela en los ajustes',
			'translation.goToSettings' => 'Ir a los ajustes',
			'translation.disableAITranslation' => 'Desactivar la traducción con IA',
			'translation.currentValue' => 'Valor actual',
			'translation.configureTranslationStrategy' => 'Configurar la estrategia de traducción',
			'translation.advancedSettings' => 'Ajustes avanzados',
			'translation.translationPrompt' => 'Mensaje de traducción',
			'translation.promptHint' => 'Introduzca el mensaje de traducción; use [TL] como marcador de posición para el idioma de destino',
			'translation.promptHelperText' => 'El mensaje debe contener [TL] como marcador de posición para el idioma de destino',
			'translation.promptMustContainTargetLang' => 'El mensaje debe contener el marcador de posición [TL]',
			'translation.aiTranslationWillBeDisabled' => 'La traducción con IA se desactivará',
			'translation.aiTranslationWillBeDisabledDueToConfigChange' => 'Debido al cambio de la configuración básica, la traducción con IA se desactivará',
			'translation.aiTranslationWillBeDisabledDueToPromptChange' => 'Debido al cambio del mensaje de traducción, la traducción con IA se desactivará',
			'translation.aiTranslationWillBeDisabledDueToParamChange' => 'Debido al cambio de la configuración de parámetros, la traducción con IA se desactivará',
			'translation.onlyOpenAIAPISupported' => 'Actualmente solo se admite el formato de API compatible con OpenAI (cuerpo de solicitud application/json)',
			'translation.streamingTranslation' => 'Traducción en flujo',
			'translation.streamingTranslationSupported' => 'Traducción en flujo admitida',
			'translation.streamingTranslationNotSupported' => 'Traducción en flujo no admitida',
			'translation.streamingTranslationDescription' => 'La traducción en flujo puede mostrar los resultados en tiempo real durante el proceso de traducción, ofreciendo una mejor experiencia de usuario',
			'translation.usingFullUrlWithHash' => 'Usando la URL completa (termina con #)',
			'translation.baseUrlInputHelperText' => 'Si termina con #, se usará como dirección de solicitud real',
			'translation.currentActualUrl' => ({required Object url}) => 'URL real actual: ${url}',
			'translation.urlEndingWithHashTip' => 'La URL que termina con # se usará directamente sin añadir ningún sufijo',
			'translation.streamingTranslationWarning' => 'Nota: esta función requiere que el servicio de API admita la transmisión en flujo; algunos modelos pueden no admitirlo',
			'translation.translationService' => 'Servicio de traducción',
			'translation.translationServiceDescription' => 'Seleccione el servicio de traducción que prefiera',
			'translation.googleTranslation' => 'Traducción de Google',
			'translation.googleTranslationDescription' => 'Servicio de traducción en línea gratuito compatible con varios idiomas',
			'translation.aiTranslation' => 'Traducción con IA',
			'translation.aiTranslationDescription' => 'Servicio de traducción inteligente basado en modelos de lenguaje grandes',
			'translation.deeplxTranslation' => 'Traducción con DeepLX',
			'translation.deeplxTranslationDescription' => 'Implementación de código abierto de la traducción DeepL, con traducción de alta calidad',
			'translation.googleTranslationFeatures' => 'Funciones',
			'translation.freeToUse' => 'Uso gratuito',
			'translation.freeToUseDescription' => 'No requiere configuración; listo para usar',
			'translation.fastResponse' => 'Respuesta rápida',
			'translation.fastResponseDescription' => 'Velocidad de traducción rápida y baja latencia',
			'translation.stableAndReliable' => 'Estable y fiable',
			'translation.stableAndReliableDescription' => 'Basado en la API oficial de Google',
			'translation.enabledDefaultService' => 'Activado: servicio de traducción predeterminado',
			'translation.notEnabled' => 'No activado',
			'translation.deeplxTranslationService' => 'Servicio de traducción DeepLX',
			'translation.deeplxDescription' => 'DeepLX es una implementación de código abierto de la traducción DeepL; admite los modos de punto de conexión Free, Pro y Official',
			'translation.serverAddress' => 'Dirección del servidor',
			'translation.serverAddressHint' => 'https://api.deeplx.org',
			'translation.serverAddressHelperText' => 'Dirección base del servidor DeepLX',
			'translation.endpointType' => 'Tipo de punto de conexión',
			'translation.freeEndpoint' => 'Free: punto de conexión gratuito, puede tener límites de velocidad',
			'translation.proEndpoint' => 'Pro: requiere dl_session, más estable',
			'translation.officialEndpoint' => 'Official: formato de API oficial',
			'translation.finalRequestUrl' => 'URL de solicitud final',
			'translation.apiKeyOptional' => 'Clave de API (opcional)',
			'translation.apiKeyOptionalHint' => 'Para acceder a servicios DeepLX protegidos',
			'translation.apiKeyOptionalHelperText' => 'Algunos servicios DeepLX requieren una clave de API para la autenticación',
			'translation.dlSession' => 'DL Session',
			'translation.dlSessionHint' => 'El modo Pro requiere el parámetro dl_session',
			'translation.dlSessionHelperText' => 'Parámetro de sesión requerido para el punto de conexión Pro, obtenido de la cuenta DeepL Pro',
			'translation.proModeRequiresDlSession' => 'El modo Pro requiere dl_session',
			'translation.clickTestButtonToVerifyDeepLXAPI' => 'Pulse el botón de prueba para verificar la conexión con la API de DeepLX',
			'translation.enableDeepLXTranslation' => 'Activar la traducción con DeepLX',
			'translation.deepLXTranslationWillBeDisabled' => 'La traducción con DeepLX se desactivará debido a cambios en la configuración',
			'translation.translatedResult' => 'Resultado de la traducción',
			'translation.testSuccess' => 'Prueba correcta',
			'translation.pleaseFillInDeepLXServerAddress' => 'Rellene la dirección del servidor DeepLX',
			'translation.invalidAPIResponseFormat' => 'Formato de respuesta de API no válido',
			'translation.translationServiceReturnedError' => 'El servicio de traducción devolvió un error o un resultado vacío',
			'translation.connectionFailed' => 'Error de conexión',
			'translation.translationFailed' => 'La traducción falló',
			'translation.aiTranslationFailed' => 'La traducción con IA falló',
			'translation.deeplxTranslationFailed' => 'La traducción con DeepLX falló',
			'translation.aiTranslationTestFailed' => 'La prueba de traducción con IA falló',
			'translation.deeplxTranslationTestFailed' => 'La prueba de traducción con DeepLX falló',
			'translation.streamingTranslationTimeout' => 'Se agotó el tiempo de espera de la traducción en flujo; forzando la limpieza de recursos',
			'translation.translationRequestTimeout' => 'Se agotó el tiempo de espera de la solicitud de traducción',
			'translation.streamingTranslationDataTimeout' => 'Tiempo de espera de recepción de datos de la traducción en flujo agotado',
			'translation.dataReceptionTimeout' => 'Tiempo de espera de recepción de datos agotado',
			'translation.streamDataParseError' => 'Error al analizar los datos del flujo',
			'translation.streamingTranslationFailed' => 'La traducción en flujo falló',
			'translation.fallbackTranslationFailed' => 'La alternativa a la traducción normal también falló',
			'translation.translationSettings' => 'Ajustes de traducción',
			'translation.enableGoogleTranslation' => 'Activar la traducción de Google',
			'translation.thinking' => 'Pensando...',
			'translation.thoughtProcess' => 'Proceso de razonamiento',
			'translation.modelCompatibility' => 'Compatibilidad de modelos',
			'translation.modelCompatibilityDescription' => 'Adapta los parámetros de solicitud para modelos modernos como los modelos de razonamiento (o1/o3, DeepSeek-R1, QwQ)',
			'translation.reasoningModel' => 'Modelo de razonamiento',
			'translation.reasoningModelDescription' => 'Para o1/o3, DeepSeek-R1, QwQ, etc. Integra el mensaje en el mensaje del usuario, omite la temperatura y usa max_completion_tokens',
			'translation.useMaxCompletionTokens' => 'Usar max_completion_tokens',
			'translation.useMaxCompletionTokensDescription' => 'Los puntos de conexión más recientes de OpenAI requieren max_completion_tokens en lugar del obsoleto max_tokens',
			'translation.sendTemperature' => 'Enviar temperatura',
			'translation.sendTemperatureDescription' => 'Desactívelo para los modelos que rechazan el parámetro de temperatura (la mayoría de los modelos de razonamiento)',
			'translation.showReasoningProcess' => 'Mostrar el proceso de razonamiento',
			'translation.showReasoningProcessDescription' => 'Mostrar el razonamiento plegable de los modelos de razonamiento en el diálogo de traducción',
			'translation.provider' => 'Proveedor',
			'translation.providerOpenAI' => 'OpenAI (y compatibles)',
			'translation.providerAnthropic' => 'Anthropic (Claude)',
			'translation.providerGoogle' => 'Google (Gemini)',
			'translation.multiProviderHint' => 'Admite OpenAI (y cualquier punto de conexión compatible con OpenAI), Anthropic y Google mediante el SDK dartantic_ai',
			'translation.baseUrlOptionalHelperText' => 'Opcional. Déjelo vacío para usar el punto de conexión predeterminado del proveedor; rellénelo para puntos de conexión compatibles con OpenAI o de retransmisión',
			'translation.defaultEndpoint' => 'Punto de conexión predeterminado',
			'translation.providerPreset' => 'Predefinición de proveedor',
			'translation.selectProviderPreset' => 'Seleccione una predefinición',
			'translation.presetCustom' => 'Personalizado',
			'translation.presetApplied' => ({required Object name}) => 'Predefinición aplicada: ${name}',
			'translation.presetNames.openai' => 'OpenAI (GPT-4o / GPT-4.1)',
			'translation.presetNames.openaiReasoning' => 'Razonamiento de OpenAI (o1 / o3 / o4)',
			'translation.presetNames.anthropic' => 'Anthropic Claude',
			'translation.presetNames.anthropicReasoning' => 'Razonamiento de Anthropic Claude (pensamiento extendido)',
			'translation.presetNames.gemini' => 'Google Gemini (nativo)',
			'translation.presetNames.geminiReasoning' => 'Razonamiento de Google Gemini (pensamiento)',
			'translation.presetNames.deepseek' => 'DeepSeek (deepseek-chat)',
			'translation.presetNames.deepseekReasoner' => 'Razonamiento de DeepSeek (deepseek-reasoner / R1)',
			'translation.presetNames.siliconflow' => 'SiliconFlow',
			'translation.presetNames.zhipu' => 'Zhipu GLM',
			'translation.fetchModelList' => 'Obtener la lista de modelos',
			'translation.fetchingModels' => 'Obteniendo...',
			'translation.selectModel' => 'Seleccionar modelo',
			'translation.searchModel' => 'Buscar modelo',
			'translation.noModelsFound' => 'No se encontraron modelos',
			'bottomNav.video' => 'Vídeo',
			'bottomNav.gallery' => 'Galería',
			'bottomNav.subscription' => 'Feed',
			'bottomNav.community' => 'Foro',
			'bottomNav.localMedia' => 'Local',
			'navigationOrderSettings.title' => 'Ajustes del orden de navegación',
			'navigationOrderSettings.customNavigationOrder' => 'Orden de navegación personalizado',
			'navigationOrderSettings.customNavigationOrderDesc' => 'Arrastre para ajustar el orden de visualización de las páginas en la barra de navegación inferior y la barra lateral',
			'navigationOrderSettings.restartRequired' => 'Es necesario reiniciar la aplicación',
			'navigationOrderSettings.navigationItemSorting' => 'Ordenación de los elementos de navegación',
			'navigationOrderSettings.done' => 'Listo',
			'navigationOrderSettings.edit' => 'Editar',
			'navigationOrderSettings.reset' => 'Restablecer',
			'navigationOrderSettings.previewEffect' => 'Efecto de vista previa',
			'navigationOrderSettings.bottomNavigationPreview' => 'Vista previa de la navegación inferior:',
			'navigationOrderSettings.sidebarPreview' => 'Vista previa de la barra lateral:',
			'navigationOrderSettings.confirmResetNavigationOrder' => 'Confirmar el restablecimiento del orden de navegación',
			'navigationOrderSettings.confirmResetNavigationOrderDesc' => '¿Seguro que quiere restablecer el orden de navegación a los ajustes predeterminados?',
			'navigationOrderSettings.cancel' => 'Cancelar',
			'navigationOrderSettings.show' => 'Mostrar',
			'navigationOrderSettings.hide' => 'Ocultar',
			'navigationOrderSettings.hidden' => 'Oculto',
			'navigationOrderSettings.hideHint' => 'Toque el icono del ojo para mostrar u ocultar el foro y los archivos locales',
			'navigationOrderSettings.videoDescription' => 'Explore contenido de vídeo popular',
			'navigationOrderSettings.galleryDescription' => 'Explore imágenes y galerías',
			'navigationOrderSettings.subscriptionDescription' => 'Vea el contenido más reciente de los usuarios a los que sigue',
			'navigationOrderSettings.forumDescription' => 'Participe en los debates de la comunidad',
			'navigationOrderSettings.newsDescription' => 'Explore noticias, artículos y emisiones oficiales',
			'navigationOrderSettings.communityDescription' => 'Debates del foro, además de noticias, artículos y emisiones oficiales',
			'navigationOrderSettings.localMediaDescription' => 'Explore los vídeos e imágenes almacenados en este dispositivo',
			'news.title' => 'Noticias',
			'news.newsUpdates' => 'Novedades',
			'news.articles' => 'Artículos',
			'news.broadcast' => 'Difusión',
			'news.openInBrowser' => 'Abrir en el navegador',
			'displaySettings.title' => 'Ajustes de pantalla',
			'displaySettings.layoutSettings' => 'Ajustes de diseño',
			'displaySettings.layoutSettingsDesc' => 'Personalice el número de columnas y la configuración de puntos de corte',
			'displaySettings.gridLayout' => 'Diseño de cuadrícula',
			'displaySettings.navigationOrderSettings' => 'Ajustes del orden de navegación',
			'displaySettings.customNavigationOrder' => 'Orden de navegación personalizado',
			'displaySettings.customNavigationOrderDesc' => 'Ajuste el orden de visualización de las páginas en la barra de navegación inferior y la barra lateral',
			'layoutSettings.title' => 'Ajustes de diseño',
			'layoutSettings.descriptionTitle' => 'Descripción de la configuración de diseño',
			'layoutSettings.descriptionContent' => 'La configuración de aquí determina el número de columnas que se muestran en las páginas de lista de vídeos y galerías. Puede elegir el modo automático para que el sistema se ajuste según el ancho de pantalla, o el modo manual para fijar el número de columnas.',
			'layoutSettings.layoutMode' => 'Modo de diseño',
			'layoutSettings.reset' => 'Restablecer',
			'layoutSettings.autoMode' => 'Modo automático',
			'layoutSettings.autoModeDesc' => 'Ajustar automáticamente según el ancho de pantalla',
			'layoutSettings.manualMode' => 'Modo manual',
			'layoutSettings.manualModeDesc' => 'Usar un número fijo de columnas',
			'layoutSettings.manualSettings' => 'Ajustes manuales',
			'layoutSettings.fixedColumns' => 'Columnas fijas',
			'layoutSettings.columns' => 'columnas',
			'layoutSettings.breakpointConfig' => 'Configuración de puntos de corte',
			'layoutSettings.add' => 'Añadir',
			'layoutSettings.defaultColumns' => 'Columnas predeterminadas',
			'layoutSettings.defaultColumnsDesc' => 'Visualización predeterminada para pantallas grandes',
			'layoutSettings.previewEffect' => 'Efecto de vista previa',
			'layoutSettings.screenWidth' => 'Ancho de pantalla',
			'layoutSettings.addBreakpoint' => 'Añadir punto de corte',
			'layoutSettings.editBreakpoint' => 'Editar punto de corte',
			'layoutSettings.deleteBreakpoint' => 'Eliminar punto de corte',
			'layoutSettings.screenWidthLabel' => 'Ancho de pantalla',
			'layoutSettings.screenWidthHint' => '600',
			'layoutSettings.columnsLabel' => 'Columnas',
			'layoutSettings.columnsHint' => '3',
			'layoutSettings.enterWidth' => 'Introduzca el ancho',
			'layoutSettings.enterValidWidth' => 'Introduzca un ancho válido',
			'layoutSettings.widthCannotExceed9999' => 'El ancho no puede superar 9999',
			'layoutSettings.breakpointAlreadyExists' => 'El punto de corte ya existe',
			'layoutSettings.enterColumns' => 'Introduzca el número de columnas',
			'layoutSettings.enterValidColumns' => 'Introduzca un número de columnas válido',
			'layoutSettings.columnsCannotExceed12' => 'Las columnas no pueden superar 12',
			'layoutSettings.breakpointConflict' => 'El punto de corte ya existe',
			'layoutSettings.confirmResetLayoutSettings' => 'Restablecer los ajustes de diseño',
			'layoutSettings.confirmResetLayoutSettingsDesc' => '¿Seguro que quiere restablecer todos los ajustes de diseño a sus valores predeterminados?\n\nSe restaurará a:\n• Modo automático\n• Configuración de puntos de corte predeterminada',
			'layoutSettings.resetToDefaults' => 'Restablecer valores predeterminados',
			'layoutSettings.confirmDeleteBreakpoint' => 'Eliminar punto de corte',
			'layoutSettings.confirmDeleteBreakpointDesc' => ({required Object width}) => '¿Seguro que quiere eliminar el punto de corte de ${width}px?',
			'layoutSettings.noCustomBreakpoints' => 'No hay puntos de corte personalizados; se usan las columnas predeterminadas',
			'layoutSettings.breakpointRange' => 'Intervalo del punto de corte',
			'layoutSettings.breakpointRangeDesc' => ({required Object range}) => '${range}px',
			'layoutSettings.breakpointRangeDescFirst' => ({required Object width}) => '≤${width}px',
			'layoutSettings.breakpointRangeDescMiddle' => ({required Object start, required Object end}) => '${start}-${end}px',
			'layoutSettings.edit' => 'Editar',
			'layoutSettings.delete' => 'Eliminar',
			'layoutSettings.cancel' => 'Cancelar',
			'layoutSettings.save' => 'Guardar',
			'mediaPlayer.videoPlayerError' => 'Error del reproductor de vídeo',
			'mediaPlayer.videoLoadFailed' => 'No se pudo cargar el vídeo',
			'mediaPlayer.videoCodecNotSupported' => 'Códec de vídeo no compatible',
			'mediaPlayer.networkConnectionIssue' => 'Problema de conexión de red',
			'mediaPlayer.insufficientPermission' => 'Permisos insuficientes',
			'mediaPlayer.unsupportedVideoFormat' => 'Formato de vídeo no compatible',
			'mediaPlayer.retry' => 'Reintentar',
			'mediaPlayer.externalPlayer' => 'Reproductor externo',
			'mediaPlayer.detailedErrorInfo' => 'Información detallada del error',
			'mediaPlayer.format' => 'Formato',
			'mediaPlayer.suggestion' => 'Sugerencia',
			'mediaPlayer.androidWebmCompatibilityIssue' => 'Los dispositivos Android tienen una compatibilidad limitada con el formato WEBM. Se recomienda usar un reproductor externo o descargar una aplicación de reproducción compatible con WEBM',
			'mediaPlayer.currentDeviceCodecNotSupported' => 'El dispositivo actual no admite el códec de este formato de vídeo',
			'mediaPlayer.checkNetworkConnection' => 'Compruebe su conexión de red e inténtelo de nuevo',
			'mediaPlayer.appMayLackMediaPermission' => 'Es posible que la aplicación no tenga los permisos necesarios para la reproducción multimedia',
			'mediaPlayer.tryOtherVideoPlayer' => 'Pruebe con otros reproductores de vídeo',
			'mediaPlayer.unrecognizedVideoFormat' => 'Archivo de vídeo no reconocido',
			'mediaPlayer.unrecognizedVideoFormatSuggestion' => 'Es posible que el enlace haya caducado o que la respuesta no fuera un vídeo. Inténtelo de nuevo o ábralo con otra aplicación.',
			'mediaPlayer.accessDenied' => 'El servidor rechazó esta solicitud (403)',
			'mediaPlayer.accessDeniedSuggestion' => 'Es muy probable que el enlace de reproducción haya caducado. Pulse Reintentar para obtenerlo de nuevo o ábralo con otra aplicación.',
			'mediaPlayer.mute' => 'Silenciar',
			'mediaPlayer.unmute' => 'Activar sonido',
			'mediaPlayer.video' => 'VÍDEO',
			'mediaPlayer.serverSelector' => 'Selección de servidor CDN',
			'mediaPlayer.serverSelectorDescription' => 'Seleccione el servidor con la latencia más baja para obtener la mejor experiencia de reproducción',
			'mediaPlayer.retestSpeed' => 'Volver a medir la velocidad',
			'mediaPlayer.waitingForSpeedTest' => 'En espera de la prueba de velocidad',
			'mediaPlayer.testingSpeed' => 'Midiendo la velocidad...',
			'mediaPlayer.testFailed' => 'Prueba fallida',
			'mediaPlayer.loadingServerList' => 'Cargando la lista de servidores...',
			'mediaPlayer.noAvailableServers' => 'No hay servidores disponibles',
			'mediaPlayer.refreshServerList' => 'Actualizar la lista de servidores',
			'mediaPlayer.cannotGetSource' => 'No se puede obtener la fuente del vídeo actual',
			'mediaPlayer.switchedToServer' => ({required Object serverName}) => 'Se cambió al servidor: ${serverName}',
			'mediaPlayer.serverCount' => ({required Object count}) => '${count} servidores en total',
			'mediaPlayer.statusCode' => ({required Object code}) => 'Código de estado: ${code}',
			'mediaPlayer.connectionFailed' => 'No se pudo conectar',
			'mediaPlayer.connectionTimeout' => 'Se agotó el tiempo de conexión',
			'mediaPlayer.networkError' => 'Error de red',
			'mediaPlayer.sslError' => 'Error de certificado SSL',
			'mediaPlayer.testCompleted' => 'Prueba completada',
			'mediaPlayer.local' => 'Local',
			'mediaPlayer.unknown' => 'Desconocido',
			'mediaPlayer.localVideoPathEmpty' => 'La ruta del vídeo local está vacía',
			'mediaPlayer.localVideoFileNotExists' => ({required Object path}) => 'El archivo de vídeo local no existe: ${path}',
			'mediaPlayer.unableToPlayLocalVideo' => ({required Object error}) => 'No se puede reproducir el vídeo local: ${error}',
			'mediaPlayer.unableToPlayNasVideo' => ({required Object error}) => 'Unable to play the NAS video: ${error}',
			'mediaPlayer.dropVideoFileHere' => 'Suelte aquí un archivo de vídeo para reproducirlo',
			'mediaPlayer.supportedFormats' => 'Formatos compatibles: MP4, MKV, AVI, MOV, WEBM, etc.',
			'mediaPlayer.noSupportedVideoFile' => 'No se encontró ningún archivo de vídeo compatible',
			'mediaPlayer.retryingOpenVideoLink' => 'No se pudo abrir el enlace del vídeo; reintentando',
			'mediaPlayer.decoderOpenFailedWithSuggestion' => ({required Object event}) => 'No se pudo cargar el decodificador: ${event}. Pruebe a cambiar a la decodificación por software en los ajustes del reproductor y vuelva a entrar en la página',
			'mediaPlayer.videoLoadErrorWithDetail' => ({required Object event}) => 'Error al cargar el vídeo: ${event}',
			'mediaPlayer.playbackFailureDiagnosticsHint' => 'Se detectaron fallos de reproducción repetidos. Vaya a Ajustes > Diagnóstico y comentarios para exportar los registros.',
			'mediaPlayer.openSettingsAction' => 'Ver',
			'mediaPlayer.notice.semanticsPrefix' => ({required Object message}) => 'Aviso de reproducción: ${message}',
			'mediaPlayer.notice.networkUnstable' => 'Compruebe su red; la reproducción puede entrecortarse',
			'mediaPlayer.notice.audioTrackUnavailable' => 'No hay sonido disponible; el vídeo sigue reproduciéndose',
			'mediaPlayer.notice.hardwareDecodeFellBack' => 'Se cambió a la decodificación por software; puede consumir más energía',
			'mediaPlayer.notice.videoDecodeProblem' => 'Pruebe otra calidad; la imagen puede presentar fallos',
			'mediaPlayer.notice.repeatedPlaybackProblems' => 'Exporte los registros para informar de problemas de reproducción repetidos',
			'mediaPlayer.notice.issuesSheetTitle' => 'Problemas de reproducción',
			'mediaPlayer.notice.issueOccurrences' => ({required Object count}) => 'Ocurrió ${count} veces',
			'mediaPlayer.notice.issueAtPosition' => ({required Object position}) => 'En ${position}',
			'mediaPlayer.notice.noIssuesRecorded' => 'No se registraron problemas',
			'mediaPlayer.notice.exportLogsAction' => 'Exportar registros',
			'mediaPlayer.imageLoadFailed' => 'No se pudo cargar la imagen',
			'mediaPlayer.unsupportedImageFormat' => 'Formato de imagen no compatible',
			'mediaPlayer.tryOtherViewer' => 'Pruebe con otros visores',
			'diagnostics.infoSectionTitle' => 'Información de diagnóstico',
			'diagnostics.appVersionLabel' => 'Versión de la aplicación',
			'diagnostics.memoryUsage' => ({required Object memMB}) => 'Uso de memoria: ${memMB}MB',
			'diagnostics.deviceInfoUnavailable' => 'No se pudo obtener la información del dispositivo',
			'diagnostics.secureStorageLabel' => 'Almacenamiento seguro',
			'diagnostics.secureStorageHealthy' => 'Disponible',
			'diagnostics.secureStorageRecovered' => 'Se autorreparó mediante un restablecimiento (se borraron los datos anteriores)',
			'diagnostics.secureStorageUnavailable' => 'No disponible (el inicio de sesión se guardó con cifrado alternativo)',
			'diagnostics.secureStoragePlatformOptOut' => 'Cifrado local por política de la plataforma (no se usa el llavero del sistema en macOS)',
			'diagnostics.secureStorageDualWrite' => ' (protección de escritura doble activada)',
			'diagnostics.schemaHealthLabel' => 'Esquema de la base de datos',
			'diagnostics.schemaHealthOk' => 'OK',
			'diagnostics.schemaHealthRepairedNow' => 'Se reparó mediante la red de seguridad en este inicio (la migración no surtió efecto)',
			'diagnostics.schemaHealthRepairedBefore' => 'Ya se reparó antes mediante la red de seguridad',
			'diagnostics.logPolicySectionTitle' => 'Política de registros',
			'diagnostics.configServiceUnavailable' => 'El servicio de configuración no está inicializado. No se puede ajustar la política de registros.',
			'diagnostics.enableLoggingTitle' => 'Activar el registro',
			'diagnostics.enableLoggingSubtitle' => 'Desactívelo para dejar de escribir nuevos registros',
			'diagnostics.enableLogPersistenceTitle' => 'Activar la persistencia de registros',
			'diagnostics.enableLogPersistenceSubtitle' => 'Desactívelo para mantener los registros solo en memoria y dejar de escribir en el disco',
			'diagnostics.minLogLevelTitle' => 'Nivel mínimo de registro',
			'diagnostics.minLogLevelSubtitle' => 'Los registros por debajo de este nivel se filtrarán',
			'diagnostics.maxFileSizeTitle' => 'Límite de tamaño de un solo archivo',
			'diagnostics.maxFileSizeSubtitle' => 'Rota al alcanzar el umbral',
			'diagnostics.rotatedFileCountTitle' => 'Número de archivos rotados del registro principal',
			'diagnostics.rotatedFileCountSubtitle' => 'Número de archivos conservados sin contar el archivo actual',
			'diagnostics.hangFileSizeTitle' => 'Límite de tamaño del registro de bloqueos',
			'diagnostics.hangFileSizeSubtitle' => 'Controla el crecimiento del archivo hang_events',
			'diagnostics.hangRotatedFileCountTitle' => 'Número de archivos rotados del registro de bloqueos',
			'diagnostics.hangRotatedFileCountSubtitle' => 'Controla el historial conservado de hang_events',
			'diagnostics.healthSectionTitle' => 'Estado de los registros',
			'diagnostics.refreshMetrics' => 'Actualizar métricas',
			'diagnostics.toolsSectionTitle' => 'Herramientas',
			'diagnostics.privacyNotice' => 'Los registros pueden contener información sensible, como datos de la cuenta y parámetros de las solicitudes. No publique los registros completos en incidencias; revíselos primero y envíelos por correo.',
			'diagnostics.exportLogsTitle' => 'Exportar registros',
			'diagnostics.exportLogsSubtitle' => 'Revise los datos privados antes de enviarlos a los desarrolladores',
			'diagnostics.viewLogsTitle' => 'Ver registros',
			'diagnostics.viewLogsSubtitle' => 'Consulte los registros de ejecución en tiempo real',
			'diagnostics.copySupportEmailTitle' => 'Copiar correo de soporte',
			'diagnostics.reportIssueTitle' => 'Informar de un problema',
			'diagnostics.reportIssueSubtitle' => 'Indique los pasos para reproducirlo en GitHub (no adjunte los registros completos)',
			'diagnostics.healthSummaryUnavailable' => 'Aún no hay datos de estado de los registros',
			'diagnostics.healthMetricsUnavailable' => 'Aún no se han recopilado métricas de estado',
			'diagnostics.healthNoRiskIndicators' => 'No se detectaron indicadores de riesgo',
			'diagnostics.healthAlert.flushFailureTitle' => 'Fallos de vaciado',
			'diagnostics.healthAlert.sinkDegradedTitle' => 'Escritura de registros degradada',
			'diagnostics.healthAlert.sinkDegradedDetail' => 'El destino de archivo está en estado degradado',
			'diagnostics.healthAlert.queueBacklogTitle' => 'Acumulación en la cola de escritura',
			'diagnostics.healthAlert.queueBacklogDetail' => ({required Object queueDepth, required Object threshold}) => 'queueDepth=${queueDepth} (umbral=${threshold}, puede aumentar el uso de memoria)',
			'diagnostics.healthAlert.highFlushLatencyTitle' => 'Latencia de vaciado alta',
			'diagnostics.healthAlert.droppedTooManyTitle' => 'Demasiados registros descartados',
			'diagnostics.healthAlert.droppedTooManyDetail' => ({required Object droppedCount, required Object threshold}) => 'droppedCount=${droppedCount} (umbral=${threshold})',
			'diagnostics.healthAlert.rateLimitedTitle' => 'Se activó la limitación de frecuencia',
			'diagnostics.healthAlert.exportFailedTitle' => 'Fallos al exportar registros',
			'diagnostics.healthAlert.fileNearLimitTitle' => 'El archivo de registro se acerca al límite de tamaño',
			'diagnostics.healthAlert.fileNearLimitDetail' => ({required Object usagePercent}) => 'currentFileUsage=${usagePercent}% (mayor presión de rotación de E/S)',
			'diagnostics.toast.logServiceNotInitialized' => 'El servicio de registros no está inicializado',
			'diagnostics.toast.exportSuccess' => 'Registros exportados. Revise los datos privados antes de enviarlos por correo.',
			'diagnostics.toast.exportFailed' => ({required Object error}) => 'No se pudo exportar: ${error}',
			'diagnostics.toast.supportEmailCopied' => 'Correo de soporte copiado. Péguelo en su cliente de correo y adjunte los registros.',
			'diagnostics.shareSubject' => 'Registros de diagnóstico de LoveIwara (contienen datos sensibles; compártalos con cuidado)',
			'logViewer.title' => 'Visor de registros',
			'logViewer.searchHint' => 'Buscar en los registros...',
			'logViewer.emptyState' => 'Sin registros',
			'logViewer.copiedToClipboard' => 'Copiado al portapapeles',
			'crashRecoveryDialog.title' => 'La aplicación se cerró de forma inesperada',
			'crashRecoveryDialog.description' => 'Se detectó un cierre anómalo en la última sesión. Exporte los registros de diagnóstico y envíelos por correo al desarrollador para ayudarnos a solucionar el problema.',
			'crashRecoveryDialog.previousVersion' => ({required Object version}) => 'Última versión: ${version}',
			'crashRecoveryDialog.previousStart' => ({required Object time}) => 'Último inicio: ${time}',
			'crashRecoveryDialog.lastException' => ({required Object message}) => 'Última excepción: ${message}',
			'crashRecoveryDialog.lastHangRecovered' => 'La última vez se detectó un bloqueo de la interfaz y se recuperó automáticamente',
			'crashRecoveryDialog.lastHangStalled' => ({required Object stalledMs}) => 'La última vez se detectó un posible bloqueo de la interfaz que duró unos ${stalledMs}ms',
			'crashRecoveryDialog.exportGuide' => 'Vaya a Ajustes > Diagnóstico y comentarios > Exportar registros.',
			'crashRecoveryDialog.privacyHint' => 'Los registros pueden contener datos privados. Revíselos antes de enviarlos por correo a:',
			'crashRecoveryDialog.issueWarning' => 'No adjunte los registros completos en las incidencias públicas de GitHub',
			'crashRecoveryDialog.acknowledge' => 'Entendido',
			'crashRecoveryDialog.supportEmailCopied' => 'Correo copiado',
			'linkInputDialog.title' => 'Introducir enlace',
			'linkInputDialog.supportedLinksHint' => ({required Object webName}) => 'Permite detectar de forma inteligente varios enlaces de ${webName} y saltar rápidamente a la página correspondiente en la aplicación (separe los enlaces del resto del texto con espacios)',
			'linkInputDialog.inputHint' => ({required Object webName}) => 'Introduzca el enlace de ${webName}',
			'linkInputDialog.validatorEmptyLink' => 'Introduzca un enlace',
			'linkInputDialog.validatorNoIwaraLink' => ({required Object webName}) => 'No se detectó ningún enlace válido de ${webName}',
			'linkInputDialog.multipleLinksDetected' => 'Se detectaron varios enlaces; seleccione uno:',
			'linkInputDialog.notIwaraLink' => ({required Object webName}) => 'No es un enlace válido de ${webName}',
			'linkInputDialog.linkParseError' => ({required Object error}) => 'Error al analizar el enlace: ${error}',
			'linkInputDialog.unsupportedLinkDialogTitle' => 'Enlace no compatible',
			'linkInputDialog.unsupportedLinkDialogContent' => 'Este tipo de enlace no se puede abrir directamente en la aplicación y debe abrirse con un navegador externo.\n\n¿Quiere abrir este enlace en un navegador?',
			'linkInputDialog.openInBrowser' => 'Abrir en el navegador',
			'linkInputDialog.confirmOpenBrowserDialogTitle' => 'Confirmar apertura del navegador',
			'linkInputDialog.confirmOpenBrowserDialogContent' => 'El siguiente enlace está a punto de abrirse en un navegador externo:',
			'linkInputDialog.confirmContinueBrowserOpen' => '¿Seguro que quiere continuar?',
			'linkInputDialog.browserOpenFailed' => 'No se pudo abrir el enlace',
			'linkInputDialog.unsupportedLink' => 'Enlace no compatible',
			_ => null,
		} ?? switch (path) {
			'linkInputDialog.cancel' => 'Cancelar',
			'linkInputDialog.confirm' => 'Abrir en el navegador',
			'log.logManagement' => 'Gestión de registros',
			'log.enableLogPersistence' => 'Activar la persistencia de registros',
			'log.enableLogPersistenceDesc' => 'Guarda los registros en la base de datos para su análisis',
			'log.logDatabaseSizeLimit' => 'Límite de tamaño de la base de datos de registros',
			'log.logDatabaseSizeLimitDesc' => ({required Object size}) => 'Actual: ${size}',
			'log.exportCurrentLogs' => 'Exportar los registros actuales',
			'log.exportCurrentLogsDesc' => 'Exporte los registros actuales de la aplicación para ayudar a los desarrolladores a diagnosticar problemas',
			'log.exportHistoryLogs' => 'Exportar registros del historial',
			'log.exportHistoryLogsDesc' => 'Exporte los registros de un intervalo de fechas concreto',
			'log.exportMergedLogs' => 'Exportar registros combinados',
			'log.exportMergedLogsDesc' => 'Exporte los registros combinados de un intervalo de fechas concreto',
			'log.showLogStats' => 'Mostrar estadísticas de registros',
			'log.logExportSuccess' => 'Registros exportados correctamente',
			'log.logExportFailed' => ({required Object error}) => 'No se pudieron exportar los registros: ${error}',
			'log.showLogStatsDesc' => 'Consulte las estadísticas de los distintos tipos de registros',
			'log.logExtractFailed' => ({required Object error}) => 'No se pudieron obtener las estadísticas de los registros: ${error}',
			'log.clearAllLogs' => 'Borrar todos los registros',
			'log.clearAllLogsDesc' => 'Borrar todos los datos de registro',
			'log.confirmClearAllLogs' => 'Confirmar borrado',
			'log.confirmClearAllLogsDesc' => '¿Seguro que quiere borrar todos los datos de registro? Esta operación no se puede deshacer.',
			'log.clearAllLogsSuccess' => 'Registros borrados correctamente',
			'log.clearAllLogsFailed' => ({required Object error}) => 'No se pudieron borrar los registros: ${error}',
			'log.unableToGetLogSizeInfo' => 'No se pudo obtener la información del tamaño de los registros',
			'log.currentLogSize' => 'Tamaño actual del registro:',
			'log.logCount' => 'Número de registros:',
			'log.logCountUnit' => 'registros',
			'log.logSizeLimit' => 'Límite de tamaño de los registros:',
			'log.usageRate' => 'Tasa de uso:',
			'log.exceedLimit' => 'Supera el límite',
			'log.remaining' => 'Restante',
			'log.currentLogSizeExceededPleaseCleanOldLogsOrIncreaseLogSizeLimit' => 'Se superó el tamaño del registro; limpie los registros antiguos o aumente el límite de tamaño',
			'log.currentLogSizeAlmostExceededPleaseCleanOldLogs' => 'El tamaño del registro está a punto de superarse; limpie los registros antiguos',
			'log.cleaningOldLogs' => 'Limpiando registros antiguos...',
			'log.logCleaningCompleted' => 'Limpieza de registros completada',
			'log.logCleaningProcessMayNotBeCompleted' => 'Es posible que el proceso de limpieza de registros no se haya completado',
			'log.cleanExceededLogs' => 'Limpiar los registros excedentes',
			'log.noLogsToExport' => 'No hay registros que exportar',
			'log.exportingLogs' => 'Exportando registros...',
			'log.noHistoryLogsToExport' => 'No hay registros del historial que exportar; use la aplicación durante un tiempo primero',
			'log.selectLogDate' => 'Seleccionar fecha del registro',
			'log.today' => 'Hoy',
			'log.selectMergeRange' => 'Seleccionar intervalo para combinar',
			'log.selectMergeRangeHint' => 'Seleccione el intervalo de tiempo de los registros que quiere combinar',
			'log.selectMergeRangeDays' => ({required Object days}) => 'Últimos ${days} días',
			'log.logStats' => 'Estadísticas de registros',
			'log.todayLogs' => ({required Object count}) => 'Registros de hoy: ${count} registros',
			'log.recent7DaysLogs' => ({required Object count}) => 'Registros de los últimos 7 días: ${count} registros',
			'log.totalLogs' => ({required Object count}) => 'Total de registros: ${count} registros',
			'log.setLogDatabaseSizeLimit' => 'Establecer el límite de tamaño de la base de datos de registros',
			'log.currentLogSizeWithSize' => ({required Object size}) => 'Tamaño actual del registro: ${size}',
			'log.warning' => 'Advertencia',
			'log.newSizeLimit' => ({required Object size}) => 'Nuevo límite de tamaño: ${size}',
			'log.confirmToContinue' => 'Confirme para continuar',
			'log.logSizeLimitSetSuccess' => ({required Object size}) => 'Límite de tamaño de los registros establecido en ${size}',
			'emoji.name' => 'Emoji',
			'emoji.size' => 'Tamaño',
			'emoji.small' => 'Pequeño',
			'emoji.medium' => 'Mediano',
			'emoji.large' => 'Grande',
			'emoji.extraLarge' => 'Extragrande',
			'emoji.copyEmojiLinkSuccess' => 'Enlace del emoji copiado',
			'emoji.preview' => 'Vista previa del emoji',
			'emoji.library' => 'Biblioteca de emojis',
			'emoji.noEmojis' => 'Sin emojis',
			'emoji.clickToAddEmojis' => 'Pulse el botón de la esquina superior derecha para añadir emojis',
			'emoji.addEmojis' => 'Añadir emojis',
			'emoji.imagePreview' => 'Vista previa de la imagen',
			'emoji.imageLoadFailed' => 'No se pudo cargar la imagen',
			'emoji.loading' => 'Cargando...',
			'emoji.delete' => 'Eliminar',
			'emoji.close' => 'Cerrar',
			'emoji.deleteImage' => 'Eliminar imagen',
			'emoji.confirmDeleteImage' => '¿Seguro que quiere eliminar esta imagen?',
			'emoji.cancel' => 'Cancelar',
			'emoji.batchDelete' => 'Eliminación por lotes',
			'emoji.confirmBatchDelete' => ({required Object count}) => '¿Seguro que quiere eliminar las ${count} imágenes seleccionadas? Esta operación no se puede deshacer.',
			'emoji.deleteSuccess' => 'Eliminado correctamente',
			'emoji.addImage' => 'Añadir imagen',
			'emoji.addImageByUrl' => 'Añadir por URL',
			'emoji.addImageUrl' => 'Añadir URL de imagen',
			'emoji.imageUrl' => 'URL de la imagen',
			'emoji.enterImageUrl' => 'Introduzca la URL de la imagen',
			'emoji.add' => 'Añadir',
			'emoji.batchImport' => 'Importación por lotes',
			'emoji.enterJsonUrlArray' => 'Introduzca una matriz de URL en formato JSON:',
			'emoji.formatExample' => 'Ejemplo de formato:\n["url1", "url2", "url3"]',
			'emoji.pasteJsonUrlArray' => 'Pegue una matriz de URL en formato JSON',
			'emoji.import' => 'Importar',
			'emoji.importSuccess' => ({required Object count}) => 'Se importaron ${count} imágenes correctamente',
			'emoji.jsonFormatError' => 'Error de formato JSON; revise lo introducido',
			'emoji.createGroup' => 'Crear grupo de emojis',
			'emoji.groupName' => 'Nombre del grupo',
			'emoji.enterGroupName' => 'Introduzca el nombre del grupo',
			'emoji.create' => 'Crear',
			'emoji.editGroupName' => 'Editar el nombre del grupo',
			'emoji.save' => 'Guardar',
			'emoji.deleteGroup' => 'Eliminar grupo',
			'emoji.confirmDeleteGroup' => '¿Seguro que quiere eliminar este grupo de emojis? También se eliminarán todas las imágenes del grupo.',
			'emoji.imageCount' => ({required Object count}) => '${count} imágenes',
			'emoji.selectEmoji' => 'Seleccionar emoji',
			'emoji.noEmojisInGroup' => 'No hay emojis en este grupo',
			'emoji.goToSettingsToAddEmojis' => 'Vaya a los ajustes para añadir emojis',
			'emoji.emojiManagement' => 'Gestión de emojis',
			'emoji.manageEmojiGroupsAndImages' => 'Gestione grupos e imágenes de emojis',
			'emoji.uploadLocalImages' => 'Subir imágenes locales',
			'emoji.uploadingImages' => 'Subiendo imágenes',
			'emoji.uploadingImagesProgress' => ({required Object count}) => 'Subiendo ${count} imágenes; espere, por favor...',
			'emoji.doNotCloseDialog' => 'No cierre este cuadro de diálogo',
			'emoji.uploadSuccess' => ({required Object count}) => 'Se subieron ${count} imágenes correctamente',
			'emoji.uploadFailed' => ({required Object count}) => 'Fallaron ${count}',
			'emoji.uploadFailedMessage' => 'No se pudieron subir las imágenes; compruebe la conexión de red o el formato del archivo',
			'emoji.uploadErrorMessage' => ({required Object error}) => 'Se produjo un error durante la carga: ${error}',
			'searchFilter.selectField' => 'Seleccionar campo',
			'searchFilter.add' => 'Añadir',
			'searchFilter.clear' => 'Borrar',
			'searchFilter.clearAll' => 'Borrar todo',
			'searchFilter.generatedQuery' => 'Consulta generada',
			'searchFilter.copyToClipboard' => 'Copiar al portapapeles',
			'searchFilter.copied' => 'Copiado',
			'searchFilter.filterCount' => ({required Object count}) => '${count} filtros',
			'searchFilter.filterSettings' => 'Configuración de filtros',
			'searchFilter.field' => 'Campo',
			'searchFilter.operator' => 'Operador',
			'searchFilter.language' => 'Idioma',
			'searchFilter.value' => 'Valor',
			'searchFilter.dateRange' => 'Rango de fechas',
			'searchFilter.numberRange' => 'Rango numérico',
			'searchFilter.from' => 'Desde',
			'searchFilter.to' => 'Hasta',
			'searchFilter.date' => 'Fecha',
			'searchFilter.number' => 'Número',
			'searchFilter.boolean' => 'Booleano',
			'searchFilter.tags' => 'Etiquetas',
			'searchFilter.select' => 'Seleccionar',
			'searchFilter.clickToSelectDate' => 'Toque para seleccionar la fecha',
			'searchFilter.pleaseEnterValidNumber' => 'Introduzca un número válido',
			'searchFilter.pleaseEnterValidDate' => 'Introduzca un formato de fecha válido (YYYY-MM-DD)',
			'searchFilter.startValueMustBeLessThanEndValue' => 'El valor inicial debe ser menor que el valor final',
			'searchFilter.startDateMustBeBeforeEndDate' => 'La fecha de inicio debe ser anterior a la fecha de fin',
			'searchFilter.pleaseFillStartValue' => 'Complete el valor inicial',
			'searchFilter.pleaseFillEndValue' => 'Complete el valor final',
			'searchFilter.rangeValueFormatError' => 'Error de formato del valor del rango',
			'searchFilter.contains' => 'Contiene',
			'searchFilter.equals' => 'Igual a',
			'searchFilter.notEquals' => 'No igual a',
			'searchFilter.greaterThan' => '>',
			'searchFilter.greaterEqual' => '>=',
			'searchFilter.lessThan' => '<',
			'searchFilter.lessEqual' => '<=',
			'searchFilter.range' => 'Rango',
			'searchFilter.kIn' => 'Contiene alguno',
			'searchFilter.notIn' => 'No contiene ninguno',
			'searchFilter.username' => 'Nombre de usuario',
			'searchFilter.nickname' => 'Apodo',
			'searchFilter.registrationDate' => 'Fecha de registro',
			'searchFilter.description' => 'Descripción',
			'searchFilter.title' => 'Título',
			'searchFilter.body' => 'Cuerpo',
			'searchFilter.author' => 'Autor',
			'searchFilter.publishDate' => 'Fecha de publicación',
			'searchFilter.private' => 'Privado',
			'searchFilter.duration' => 'Duración (segundos)',
			'searchFilter.likes' => 'Me gusta',
			'searchFilter.views' => 'Visualizaciones',
			'searchFilter.comments' => 'Comentarios',
			'searchFilter.rating' => 'Clasificación',
			'searchFilter.imageCount' => 'Cantidad de imágenes',
			'searchFilter.videoCount' => 'Cantidad de videos',
			'searchFilter.createDate' => 'Fecha de creación',
			'searchFilter.content' => 'Contenido',
			'searchFilter.all' => 'Todo',
			'searchFilter.adult' => 'Adulto',
			'searchFilter.general' => 'General',
			'searchFilter.yes' => 'Sí',
			'searchFilter.no' => 'No',
			'searchFilter.users' => 'Usuarios',
			'searchFilter.videos' => 'Vídeos',
			'searchFilter.images' => 'Imágenes',
			'searchFilter.posts' => 'Publicaciones',
			'searchFilter.forumThreads' => 'Hilos del foro',
			'searchFilter.forumPosts' => 'Publicaciones del foro',
			'searchFilter.playlists' => 'Listas de reproducción',
			'searchFilter.sortTypes.relevance' => 'Relevancia',
			'searchFilter.sortTypes.latest' => 'Recientes',
			'searchFilter.sortTypes.views' => 'Visualizaciones',
			'searchFilter.sortTypes.likes' => 'Me gusta',
			'searchFilter.drawerSubtitle' => 'Los cambios se aplican al instante',
			'firstTimeSetup.welcome.title' => 'Bienvenido',
			'firstTimeSetup.welcome.subtitle' => 'Comencemos con su configuración personalizada',
			'firstTimeSetup.welcome.description' => 'Solo unos pocos pasos para adaptar la mejor experiencia a sus necesidades',
			'firstTimeSetup.basic.title' => 'Ajustes básicos',
			'firstTimeSetup.basic.subtitle' => 'Personalice su experiencia',
			'firstTimeSetup.basic.description' => 'Elija las preferencias que más le convengan',
			'firstTimeSetup.network.title' => 'Ajustes de red',
			'firstTimeSetup.network.subtitle' => 'Configure las opciones de red',
			'firstTimeSetup.network.description' => 'Ajústelo según su entorno de red',
			'firstTimeSetup.network.tip' => 'Es necesario reiniciar tras configurarlo correctamente para que surta efecto',
			'firstTimeSetup.theme.title' => 'Ajustes de tema',
			'firstTimeSetup.theme.subtitle' => 'Elija el aspecto que prefiera',
			'firstTimeSetup.theme.description' => 'Personalice su experiencia visual',
			'firstTimeSetup.player.title' => 'Ajustes del reproductor',
			'firstTimeSetup.player.subtitle' => 'Configure los controles de reproducción',
			'firstTimeSetup.player.description' => 'Configure rápidamente las preferencias de reproducción más habituales',
			'firstTimeSetup.spatial.title' => 'Reproducción espacial',
			'firstTimeSetup.spatial.subtitle' => 'Ver y explorar contenido en el visor',
			'firstTimeSetup.spatial.description' => 'En el visor, los vídeos y las galerías aparecen en el espacio que le rodea en lugar de dentro de este panel flotante',
			'firstTimeSetup.completion.title' => 'Completar configuración',
			'firstTimeSetup.completion.subtitle' => 'Ya está listo para comenzar',
			'firstTimeSetup.completion.description' => 'Lea y acepte los acuerdos correspondientes',
			'firstTimeSetup.completion.agreementTitle' => 'Acuerdo de usuario y normas de la comunidad',
			'firstTimeSetup.completion.agreementDesc' => 'Antes de usar esta aplicación, lea atentamente y acepte nuestro acuerdo de usuario y las normas de la comunidad. Estas condiciones ayudan a mantener un buen ambiente.',
			'firstTimeSetup.completion.checkboxTitle' => 'He leído y acepto el acuerdo de usuario y las normas de la comunidad',
			'firstTimeSetup.completion.checkboxSubtitle' => 'No podrá usar la aplicación si no está de acuerdo',
			'firstTimeSetup.common.settingsChangeableTip' => 'Estos ajustes se pueden cambiar en cualquier momento en Ajustes',
			'firstTimeSetup.common.previousStep' => 'Paso anterior',
			'firstTimeSetup.common.nextStep' => 'Siguiente paso',
			'firstTimeSetup.common.finishSetup' => 'Finalizar configuración',
			'firstTimeSetup.common.agreeAgreementSnackbar' => 'Acepte primero el acuerdo de usuario y las normas de la comunidad',
			'proxyHelper.systemProxyDetected' => 'Proxy del sistema detectado',
			'proxyHelper.copied' => 'Copiado',
			'proxyHelper.copy' => 'Copiar',
			'tagSelector.selectTags' => 'Seleccionar etiquetas',
			'tagSelector.clickToSelectTags' => 'Toque para seleccionar etiquetas',
			'tagSelector.addTag' => 'Añadir etiqueta',
			'tagSelector.removeTag' => 'Quitar etiqueta',
			'tagSelector.deleteTag' => 'Eliminar etiqueta',
			'tagSelector.usageInstructions' => 'Primero añada etiquetas y luego pulse para seleccionar entre las etiquetas existentes',
			'tagSelector.usageInstructionsTooltip' => 'Instrucciones de uso',
			'tagSelector.addTagTooltip' => 'Añadir etiqueta',
			'tagSelector.removeTagTooltip' => 'Quitar etiqueta',
			'tagSelector.cancelSelection' => 'Cancelar selección',
			'tagSelector.selectAll' => 'Seleccionar todo',
			'tagSelector.cancelSelectAll' => 'Anular la selección de todo',
			'tagSelector.delete' => 'Eliminar',
			'anime4k.realTimeVideoUpscalingAndDenoising' => 'Escalado y eliminación de ruido de vídeo en tiempo real, mejorando la calidad del vídeo de animación',
			'anime4k.settings' => 'Ajustes de Anime4K',
			'anime4k.preset' => 'Preajuste de Anime4K',
			'anime4k.disable' => 'Desactivar Anime4K',
			'anime4k.disableDescription' => 'Desactivar los efectos de mejora de vídeo',
			'anime4k.highQualityPresets' => 'Preajustes de alta calidad',
			'anime4k.fastPresets' => 'Preajustes rápidos',
			'anime4k.litePresets' => 'Preajustes ligeros',
			'anime4k.moreLitePresets' => 'Preajustes más ligeros',
			'anime4k.customPresets' => 'Preajustes personalizados',
			'anime4k.presetGroups.highQuality' => 'Alta calidad',
			'anime4k.presetGroups.fast' => 'Rápido',
			'anime4k.presetGroups.lite' => 'Ligero',
			'anime4k.presetGroups.moreLite' => 'Más ligero',
			'anime4k.presetGroups.custom' => 'Personalizado',
			'anime4k.presetDescriptions.mode_a_hq' => 'Adecuado para la mayoría de animaciones en 1080p, sobre todo las que presentan desenfoque, remuestreo y artefactos de compresión. Ofrece la mayor calidad percibida.',
			'anime4k.presetDescriptions.mode_b_hq' => 'Adecuado para animaciones con un ligero desenfoque o efecto de anillo causado por el escalado. Reduce eficazmente el efecto de anillo y el aliasing.',
			'anime4k.presetDescriptions.mode_c_hq' => 'Adecuado para fuentes de alta calidad (como animaciones o películas nativas en 1080p). Elimina el ruido y ofrece el PSNR más alto.',
			'anime4k.presetDescriptions.mode_a_a_hq' => 'Versión mejorada del modo A que ofrece la máxima calidad percibida y puede reconstruir casi todas las líneas degradadas. Puede provocar un exceso de nitidez o efecto de anillo.',
			'anime4k.presetDescriptions.mode_b_b_hq' => 'Versión mejorada del modo B, que ofrece mayor calidad percibida, optimiza aún más las líneas y reduce los artefactos.',
			'anime4k.presetDescriptions.mode_c_a_hq' => 'Versión del modo C con calidad percibida mejorada, que mantiene un PSNR alto y trata de reconstruir parte del detalle de las líneas.',
			'anime4k.presetDescriptions.mode_a_fast' => 'Versión rápida del modo A que equilibra calidad y rendimiento; adecuada para la mayoría de animaciones en 1080p.',
			'anime4k.presetDescriptions.mode_b_fast' => 'Versión rápida del modo B para tratar artefactos leves y efecto de anillo con un menor consumo.',
			'anime4k.presetDescriptions.mode_c_fast' => 'Versión rápida del modo C, para eliminar ruido y escalar rápidamente fuentes de alta calidad.',
			'anime4k.presetDescriptions.mode_a_a_fast' => 'Versión rápida del modo A+A, que busca una mayor calidad percibida en dispositivos con rendimiento limitado.',
			'anime4k.presetDescriptions.mode_b_b_fast' => 'Versión rápida del modo B+B, que ofrece una reparación de líneas y un procesamiento de artefactos mejorados para dispositivos con rendimiento limitado.',
			'anime4k.presetDescriptions.mode_c_a_fast' => 'Versión rápida del modo C+A, que procesa rápidamente fuentes de alta calidad y aporta una reparación ligera de líneas.',
			'anime4k.presetDescriptions.upscale_only_s' => 'Escalado x2 ultrarrápido usando solo el modelo CNN más rápido, sin reparación ni eliminación de ruido y con un consumo mínimo.',
			'anime4k.presetDescriptions.upscale_deblur_fast' => 'Escalado y reducción de desenfoque rápidos mediante algoritmos tradicionales sin CNN; mejores que los del reproductor predeterminado y con un consumo muy bajo.',
			'anime4k.presetDescriptions.restore_s_only' => 'Solo reparación con el modelo CNN más rápido, sin escalado. Adecuado para reproducir en resolución nativa cuando se desea mejorar la calidad.',
			'anime4k.presetDescriptions.denoise_bilateral_fast' => 'Eliminación de ruido rápida mediante filtrado bilateral tradicional; muy veloz y adecuada para tratar ruido leve.',
			'anime4k.presetDescriptions.upscale_non_cnn' => 'Escalado rápido con algoritmos tradicionales, con un consumo muy bajo y mejor que los ajustes predeterminados del reproductor.',
			'anime4k.presetDescriptions.mode_a_fast_darken' => 'Modo A (rápido) + oscurecimiento de líneas, que añade este efecto sobre el modo A rápido para lograr líneas más marcadas y estilizadas.',
			'anime4k.presetDescriptions.mode_a_hq_thin' => 'Modo A (alta calidad) + adelgazamiento de líneas, que añade este efecto sobre el modo A de alta calidad para un aspecto más fino.',
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
			'anime4k.presetNames.upscale_only_s' => 'Escalado con CNN (ultrarrápido)',
			'anime4k.presetNames.upscale_deblur_fast' => 'Escalado y reducción de desenfoque (rápido)',
			'anime4k.presetNames.restore_s_only' => 'Restauración (ultrarrápida)',
			'anime4k.presetNames.denoise_bilateral_fast' => 'Eliminación de ruido bilateral (ultrarrápida)',
			'anime4k.presetNames.upscale_non_cnn' => 'Escalado sin CNN (ultrarrápido)',
			'anime4k.presetNames.mode_a_fast_darken' => 'Modo A (rápido) + oscurecimiento de líneas',
			'anime4k.presetNames.mode_a_hq_thin' => 'Modo A (alta calidad) + adelgazamiento de líneas',
			'anime4k.performanceTip' => '💡 Sugerencia: elija los preajustes adecuados según el rendimiento de su dispositivo. En dispositivos de gama baja se recomienda usar preajustes ligeros.',
			'anime4k.compatibilityTip' => '⚠️ Algunas GPU móviles (p. ej. Kirin 980 / Mali-G76) no pueden renderizar ningún sombreador personalizado. Si la imagen se pone negra mientras el audio sigue reproduciéndose, desactive Anime4K aquí.',
			'anime4k.autoDisabledOnRenderFailure' => 'La GPU de su dispositivo no pudo renderizar el sombreador de Anime4K, por lo que se desactivó automáticamente.',
			'siteMode.title' => 'Modo de sitio',
			'siteMode.mainSite' => 'Principal',
			'siteMode.aiSite' => 'AI',
			'siteMode.drawerSubtitle' => ({required Object currentSite, required Object nextSite}) => 'Actual: ${currentSite} · Toque para cambiar a ${nextSite}',
			'siteMode.dialogTitle' => 'Cambiar el modo de sitio',
			'siteMode.dialogDescription' => 'El cambio actualizará toda la aplicación y restablecerá las listas y el estado de página cargados previamente.',
			'siteMode.chooseLinkTargetTitle' => 'Elegir sitio de destino',
			'siteMode.chooseLinkTargetDescription' => 'Este enlace no incluye un dominio. Elija si desea abrirlo en Principal o en AI.',
			'siteMode.chooseLinkTargetHint' => 'Una vez abierta, esta página y sus solicitudes de detalle posteriores seguirán usando el sitio seleccionado.',
			'siteMode.alreadyUsing' => 'Ya está usando este modo de sitio.',
			'siteMode.openInSite' => ({required Object site}) => 'Abrir en ${site}',
			'siteMode.confirmUsing' => ({required Object site}) => 'Tras confirmar, las solicitudes futuras usarán el modo ${site}.',
			'siteMode.switched' => ({required Object site}) => 'Se cambió a ${site}. La aplicación se ha actualizado.',
			'savedSearchConfig.title' => 'Filtros guardados',
			'savedSearchConfig.empty' => 'Aún no hay filtros guardados',
			'savedSearchConfig.saveTooltip' => 'Guardar filtro actual',
			'savedSearchConfig.namePromptTitle' => 'Guardar filtro',
			'savedSearchConfig.nameLabel' => 'Nombre',
			'savedSearchConfig.nameHint' => 'Introduzca un nombre',
			'savedSearchConfig.saveSuccess' => 'Filtro guardado',
			'savedSearchConfig.deleteSuccess' => 'Filtro eliminado',
			'savedSearchConfig.addCurrent' => 'Guardar filtro actual',
			'savedSearchConfig.reorderHint' => 'Mantenga pulsado y arrastre para reordenar',
			'savedSearchConfig.rename' => 'Renombrar',
			'savedSearchConfig.unnamed' => 'Sin nombre',
			'savedSearchConfig.noConditions' => 'Todo el contenido (sin filtro)',
			'savedSearchConfig.tagsCount' => ({required Object count}) => '${count} etiquetas',
			'savedSearch.title' => 'Búsquedas guardadas',
			'savedSearch.empty' => 'Aún no hay búsquedas guardadas',
			'savedSearch.saveTooltip' => 'Guardar búsqueda actual',
			'savedSearch.namePromptTitle' => 'Guardar búsqueda',
			'savedSearch.nameLabel' => 'Nombre',
			'savedSearch.nameHint' => 'Introduzca un nombre',
			'savedSearch.saveSuccess' => 'Búsqueda guardada',
			'savedSearch.deleteSuccess' => 'Búsqueda eliminada',
			'savedSearch.addCurrent' => 'Guardar búsqueda actual',
			'savedSearch.reorderHint' => 'Mantenga pulsado y arrastre para reordenar',
			'savedSearch.rename' => 'Renombrar',
			'savedSearch.noKeyword' => '(Sin palabra clave)',
			'savedSearch.filtersCount' => ({required Object count}) => '${count} filtros',
			'defaultBlacklistReminder.title' => 'Se detectó la lista negra de etiquetas predeterminada',
			'defaultBlacklistReminder.content' => 'Su cuenta sigue usando la lista negra de etiquetas que el sitio web aplica automáticamente a cada cuenta nueva. ¿Quiere revisarla y gestionarla?',
			'defaultBlacklistReminder.goManage' => 'Gestionar',
			'defaultBlacklistReminder.dismiss' => 'Ahora no',
			'colorVisionAssist.title' => 'Asistencia de visión del color',
			'colorVisionAssist.description' => 'Corrige los colores del vídeo para personas con deficiencia en la visión del color; puede usarse junto con Anime4K',
			'colorVisionAssist.galleryDescription' => 'Corrige los colores de las imágenes de la galería para personas con deficiencia en la visión del color (independiente del interruptor del reproductor)',
			'colorVisionAssist.galleryDescriptionSpatial' => 'Corrige los colores de las imágenes de la galería para personas con deficiencia en la visión del color. Solo se aplica al visor 2D dentro de este panel; las imágenes de la pantalla espacial se renderizan de forma nativa y no pasan por este filtro',
			'colorVisionAssist.disable' => 'Desactivado',
			'colorVisionAssist.disableDescription' => 'Sin corrección de color',
			'colorVisionAssist.protanopia' => 'Asistencia para el rojo (protanopía)',
			'colorVisionAssist.protanopiaDescription' => 'Para la protanopía: dificultad para distinguir el rojo',
			'colorVisionAssist.deuteranopia' => 'Asistencia para el verde (deuteranopía)',
			'colorVisionAssist.deuteranopiaDescription' => 'Para la deuteranopía: dificultad para distinguir el verde',
			'colorVisionAssist.tritanopia' => 'Asistencia para el azul (tritanopía)',
			'colorVisionAssist.tritanopiaDescription' => 'Para la tritanopía: dificultad para distinguir el azul y el amarillo',
			'colorVisionAssist.appliedToast' => ({required Object filterName}) => '${filterName} aplicado, surte efecto de inmediato',
			'colorVisionAssist.disabledToast' => 'Asistencia de visión del color desactivada',
			'externalPlayer.title' => 'Abrir con otra aplicación',
			'externalPlayer.description' => 'Pase el vídeo actual a otro reproductor de este dispositivo, como Skybox o Pigasus en un visor VR, o MX Player y VLC en un teléfono',
			'externalPlayer.openWithOtherApp' => 'Elegir otra aplicación',
			'externalPlayer.openWithOtherAppDescription' => 'Muestre el selector del sistema y elija un reproductor',
			'externalPlayer.openWithSystemPlayer' => 'Abrir en el reproductor predeterminado',
			'externalPlayer.openWithSystemPlayerDescription' => 'Páselo a la aplicación de vídeo predeterminada del sistema',
			'externalPlayer.copyLink' => 'Copiar enlace del vídeo',
			'externalPlayer.copyLinkDescription' => 'Para reproductores que solo permiten pegar una URL, como Skybox o DeoVR',
			'externalPlayer.linkCopied' => 'Enlace del vídeo copiado',
			'externalPlayer.sourceLocal' => 'Archivo local',
			'externalPlayer.sourceOnline' => 'Enlace directo',
			'externalPlayer.sourceOnlineWithQuality' => ({required Object quality}) => 'Enlace directo · ${quality}',
			'externalPlayer.onlineLinkExpiryHint' => 'Los enlaces directos caducan, por lo que un reproductor externo puede detenerse a mitad. Descargarlo primero es la opción fiable.',
			'externalPlayer.vrPlayerHint' => 'Si su reproductor de VR no aparece en el selector, use Copiar enlace del vídeo y péguelo en ese reproductor.',
			'externalPlayer.noHandler' => 'Ninguna aplicación de este dispositivo puede abrir el vídeo',
			'externalPlayer.handoffFailed' => ({required Object message}) => 'No se pudo pasar: ${message}',
			'externalPlayer.handoffFailedUnknown' => 'No se pudo pasar al reproductor externo',
			'externalPlayer.sourceUnavailable' => 'No se pudo obtener la dirección del vídeo actual; inténtelo de nuevo',
			'externalPlayer.localFileMissing' => 'El archivo local ya no existe',
			'externalPlayer.handedOff' => 'Se pasó al reproductor externo',
			'externalPlayer.desktopSectionTitle' => 'Reproductores externos',
			'externalPlayer.managePlayers' => 'Gestionar reproductores externos',
			'externalPlayer.managePlayersDescWindows' => 'Los reproductores de PCVR como HereSphere, DeoVR y Whirligig no son la aplicación predeterminada del sistema. Apunte esto a su .exe y podrá pasar el vídeo actual directamente desde el reproductor.',
			'externalPlayer.managePlayersDescMac' => 'Apunte esto a reproductores como IINA, VLC o mpv y podrá pasar el vídeo actual directamente desde el reproductor.',
			'externalPlayer.managePlayersDescLinux' => 'Apunte esto a reproductores como mpv, VLC o Celluloid y podrá pasar el vídeo actual directamente desde el reproductor.',
			'externalPlayer.pickExecutableHintWindows' => 'Elija el .exe principal dentro de la carpeta de instalación del reproductor, p. ej. HereSphere.exe o vlc.exe. Los accesos directos del escritorio (.lnk) no funcionarán.',
			'externalPlayer.pickExecutableHintMac' => 'Elija el .app del reproductor en Aplicaciones, p. ej. IINA.app; el ejecutable real que contiene se localizará por usted.',
			'externalPlayer.pickExecutableHintLinux' => 'Elija el ejecutable del reproductor, p. ej. /usr/bin/mpv. Ejecutar which mpv le indicará dónde se encuentra.',
			'externalPlayer.emptyStateGuide' => ({required Object examples}) => 'Una vez configurado, aparecerá como una entrada propia en Abrir con otra aplicación, en la página del reproductor. Los más comunes: ${examples}',
			'externalPlayer.detectNothingFoundGuide' => 'No se encontraron reproductores instalados. Las carpetas de instalación personalizadas y las versiones portátiles no se pueden detectar; use Añadir reproductor para indicar uno manualmente.',
			'externalPlayer.detectNothingNew' => 'No se encontraron reproductores nuevos; todo lo instalado ya está en la lista',
			'externalPlayer.detectFailed' => 'La detección falló; use Añadir reproductor para indicar uno manualmente',
			'externalPlayer.advancedOptions' => 'Avanzado',
			'externalPlayer.playerNameHint' => 'Déjelo vacío para usar el nombre del archivo',
			'externalPlayer.executablePathRequired' => 'Elija primero el ejecutable del reproductor',
			'externalPlayer.playerCount' => ({required Object count}) => '${count} configurados',
			'externalPlayer.noPlayerConfigured' => 'Aún no hay ningún reproductor externo configurado',
			'externalPlayer.autoDetect' => 'Detección automática',
			'externalPlayer.detecting' => 'Detectando…',
			'externalPlayer.detectFound' => ({required Object count}) => 'Se encontraron ${count} reproductor(es)',
			'externalPlayer.detectNothingFound' => 'No se encontraron reproductores nuevos; añada uno manualmente',
			'externalPlayer.autoDetectedTag' => 'detectado',
			'externalPlayer.addPlayer' => 'Añadir reproductor',
			'externalPlayer.editPlayer' => 'Editar reproductor',
			'externalPlayer.playerName' => 'Nombre',
			'externalPlayer.executablePath' => 'Ejecutable',
			'externalPlayer.browse' => 'Examinar',
			'externalPlayer.argumentTemplate' => 'Argumentos de inicio',
			'externalPlayer.argumentTemplateHint' => 'Use {input} para la ruta o la URL del vídeo. Déjelo vacío para pasarla como único argumento.',
			'externalPlayer.nameAndPathRequired' => 'Se requieren tanto el nombre como el ejecutable',
			'externalPlayer.testLaunch' => 'Probar inicio',
			'externalPlayer.testLaunched' => 'Reproductor iniciado',
			'externalPlayer.testFailed' => 'No se pudo iniciar; compruebe la ruta del ejecutable',
			'externalPlayer.executableMissing' => 'No se encontró el ejecutable',
			'externalPlayer.openWithNamed' => ({required Object name}) => 'Abrir en ${name}',
			'externalPlayer.managePlayersEntry' => 'Gestionar reproductores externos…',
			'watchLater.title' => 'Ver más tarde',
			'watchLater.addToWatchLater' => 'Ver más tarde',
			'watchLater.removeFromWatchLater' => 'Quitar de Ver más tarde',
			'watchLater.addedToWatchLater' => 'Añadido a Ver más tarde',
			'watchLater.alreadyInWatchLater' => 'Ya está en Ver más tarde',
			'watchLater.removedFromWatchLater' => 'Quitado de Ver más tarde',
			'watchLater.removedCount' => ({required Object count}) => 'Se quitaron ${count} elementos',
			'watchLater.viewWatchLaterList' => 'Ver la lista',
			'watchLater.addFailed' => 'No se pudo añadir a Ver más tarde',
			'watchLater.invalidItem' => 'No disponible',
			'watchLater.clearWatched' => 'Borrar lo visto',
			'watchLater.watchedCleared' => ({required Object count}) => 'Se borraron ${count} elementos vistos',
			'watchLater.noWatchedToClear' => 'No hay nada visto que borrar',
			'watchLater.emptyVideo' => 'Aún no hay videos en Ver más tarde',
			'watchLater.emptyGallery' => 'Aún no hay galerías en Ver más tarde',
			'watchLater.filterAll' => 'Todo',
			'watchLater.filterUnwatched' => 'No visto',
			'watchLater.sortRecentlyAdded' => 'Añadidos recientemente',
			'watchLater.sortEarliestAdded' => 'Añadidos primero',
			'watchLater.watched' => 'Visto',
			'watchLater.playlistLoadFailed' => 'No se pudieron cargar las listas de reproducción',
			'watchLater.noPlaylists' => 'Aún no hay listas de reproducción',
			'watchLater.undo' => 'Deshacer',
			'watchLater.clearWatchedConfirm' => '¿Borrar todo lo que ya ha visto en esta pestaña? Esta acción no se puede deshacer.',
			'watchLater.emptyUnwatchedVideo' => 'No queda nada por ver aquí',
			'watchLater.emptyUnwatchedGallery' => 'No queda nada por ver aquí',
			'watchLater.queueLoadFailed' => 'No se pudo cargar; toque para reintentar',
			'mediaMenu.like' => 'Me gusta',
			'mediaMenu.unlike' => 'Ya no me gusta',
			'mediaMenu.viewAuthor' => 'Ver el autor',
			'mediaMenu.inFolders' => ({required Object count}) => '${count} carpetas',
			'mediaMenu.inPlaylists' => ({required Object count}) => '${count} listas de reproducción',
			'mediaMenu.downloaded' => 'Descargado',
			'mediaPreview.preview' => 'Vista previa',
			'mediaPreview.openDetail' => 'Abrir',
			'mediaPreview.moreActions' => 'Más acciones',
			'mediaPreview.previousImage' => 'Imagen anterior',
			'mediaPreview.nextImage' => 'Imagen siguiente',
			'playbackQueue.galleryImageCount' => ({required Object count}) => '${count} imágenes',
			'playbackQueue.upNext' => 'A continuación',
			'playbackQueue.sourceTab' => 'Origen',
			'playbackQueue.emptyQueue' => 'Nada reproducible en esta cola',
			'playbackQueue.emptyGalleryQueue' => 'No hay galerías en esta cola',
			'playbackQueue.nowPlaying' => 'Reproduciendo ahora',
			'playbackQueue.myPlaylists' => 'Mis listas de reproducción',
			'playbackQueue.authorPlaylists' => 'Listas de reproducción del autor',
			'playbackQueue.openQueue' => 'A continuación',
			'playbackQueue.continueInQueue' => 'Seguir reproduciendo desde la cola actual',
			'playbackQueue.continueInQueueSubtitle' => 'Reproduce el siguiente elemento automáticamente; desactiva "repetir al finalizar"',
			'playbackQueue.repeatDisabledByQueue' => 'Desactivado mientras "seguir reproduciendo desde la cola actual" está activado',
			'playbackQueue.playNext' => 'Reproducir siguiente',
			'playbackQueue.queueEnded' => 'Este es el último elemento de la cola',
			'playbackQueue.playNextHint' => 'Toque para reproducir el siguiente elemento; mantenga pulsado para abrir "A continuación"',
			'playbackQueue.authorVideos' => 'Videos del autor',
			'playbackQueue.authorGalleries' => 'Galerías del autor',
			'playbackQueue.favoriteFolders' => 'Carpetas favoritas',
			'playbackQueue.localFiles' => 'En este dispositivo',
			'playbackQueue.currentFolder' => 'Carpeta de este archivo',
			'playbackQueue.playThisFolder' => 'Ver la cola de videos de esta carpeta',
			'playbackQueue.browseThisFolder' => 'Ver la cola de galerías de esta carpeta',
			'playbackQueue.downloads' => 'Descargados',
			'playbackQueue.otherPlaylists' => 'Listas de reproducción de otros usuarios',
			'playbackQueue.nothingHere' => 'Nada por aquí',
			'vrFormat.playInSpace' => 'Reproducir en el reproductor espacial',
			'vrFormat.handingOff' => 'Pasando al espacio…',
			'vrFormat.title' => 'Modo de reproducción',
			'vrFormat.spatialSectionTitle' => 'Reproducción espacial',
			'vrFormat.spatialSectionDesc' => 'En el visor, un video no se dibuja dentro de este panel: el reproductor espacial lo coloca en una pantalla de la habitación.',
			'vrFormat.spatialPanelEntry' => 'Panel de control espacial',
			'vrFormat.spatialPanelEntryDesc' => 'La distancia, el tamaño y la curvatura de la pantalla, el entorno de fondo, además de la velocidad, la repetición y el ocultado automático se encuentran en el panel de control espacial.',
			'vrFormat.spatialGuideEntry' => 'Guía de controles del visor',
			'vrFormat.spatialGuideEntryDesc' => 'Botones del controlador, agarrar la pantalla, búsqueda con el joystick y pasar páginas',
			'vrFormat.spatialFlatOmitted' => 'Los gestos táctiles, la mejora de imagen y los parámetros de audio/video solo se aplican al reproductor 2D; el reproductor espacial usa un motor diferente, por lo que no se enumeran aquí.',
			'vrFormat.spatialGallerySectionTitle' => 'Galería espacial',
			'vrFormat.spatialGalleryPanelDesc' => 'El intervalo de la presentación, la repetición de un solo clip y la curvatura de la pantalla se ajustan en el panel de control espacial.',
			'vrFormat.autoEnterGallery' => 'Abrir las imágenes de la galería en la galería espacial',
			'vrFormat.autoEnterGalleryDesc' => 'En Quest, tocar una imagen abre toda la galería en la pantalla flotante con tira de película, presentación y paginación con el controlador, en lugar del visor dentro de este panel.',
			'vrFormat.panelSettings' => 'Panel y fondo',
			'vrFormat.panelSettingsDesc' => 'A qué distancia se sitúa este panel de la aplicación y cuánto de su habitación se ve detrás',
			'vrFormat.panelDistance' => 'Distancia del panel',
			'vrFormat.panelDistanceValue' => ({required Object meters}) => '${meters} m',
			'vrFormat.panelResetPlacement' => 'Restablecer la ubicación',
			'vrFormat.panelResetBackground' => 'Restablecer al valor predeterminado',
			'vrFormat.panelBackground' => 'Transparencia del fondo',
			'vrFormat.panelBackgroundHint' => '0 %: entorno negro · 100 %: su habitación real, con luz ambiental',
			'vrFormat.panelUnavailable' => 'El panel no está en su sitio ahora mismo; inténtelo de nuevo en un momento',
			'vrFormat.desc' => 'Elija la geometría con la que debe reproducirse este video. El sitio no proporciona esta información, por lo que la detección automática solo elige un punto de partida: su elección manda.',
			'vrFormat.sectionFlat' => 'Plano',
			'vrFormat.sectionStereo' => '3D plano',
			'vrFormat.sectionPanorama' => 'Panorama VR',
			'vrFormat.flat' => 'Video normal',
			'vrFormat.flatDesc' => 'Reproducir tal cual, sin reasignación',
			'vrFormat.flatSideBySide' => '3D lado a lado',
			'vrFormat.flatSideBySideDesc' => 'Un ojo por mitad, izquierda y derecha; muestra el ojo izquierdo y restaura su relación de aspecto',
			'vrFormat.flatTopBottom' => '3D arriba y abajo',
			'vrFormat.flatTopBottomDesc' => 'Un ojo por mitad, arriba y abajo; muestra la mitad superior y restaura su relación de aspecto',
			'vrFormat.vr180SideBySide' => 'VR180 lado a lado',
			'vrFormat.vr180SideBySideDesc' => 'Panorama hemisférico con ambos ojos; la fuente VR más común',
			'vrFormat.vr180Mono' => 'VR180 mono',
			'vrFormat.vr180MonoDesc' => 'Panorama hemisférico, un solo ojo por fotograma',
			'vrFormat.vr360Mono' => 'VR360 mono',
			'vrFormat.vr360MonoDesc' => 'Panorama envolvente completo, un solo ojo por fotograma',
			'vrFormat.vr360TopBottom' => 'VR360 arriba y abajo',
			'vrFormat.vr360TopBottomDesc' => 'Panorama envolvente completo con ambos ojos apilados',
			'vrFormat.resetView' => 'Restablecer la vista',
			'vrFormat.resetViewDesc' => 'Devolver la dirección de mirada y el campo de visión al frente',
			_ => null,
		} ?? switch (path) {
			'vrFormat.resetToAuto' => 'Volver a la detección automática',
			'vrFormat.resetToAutoDesc' => 'Olvidar la elección manual para este video y dejar que la detección decida de nuevo',
			'vrFormat.manualBadge' => 'Establecido manualmente',
			'vrFormat.panoramaHint' => 'Arrastre la imagen para mirar alrededor; pellizque para cambiar el campo de visión',
			'vrFormat.panoramaGestureNotice' => 'Mientras mira alrededor, arrastrar gira la vista; use la barra de progreso para buscar',
			'vrFormat.shaderUnsupported' => 'Este dispositivo no puede renderizar el panorama en vivo; se muestra un solo ojo en su lugar',
			'vrFormat.handoffTooltip' => 'Reproducir de otra forma',
			'vrFormat.suggestedBadge' => 'Sugerido',
			'vrFormat.suggestedEntryDesc' => ({required Object format}) => 'Parece ${format}: toque para cambiar',
			'vrFormat.suggestionTitle' => ({required Object format}) => 'Puede que este sea un video VR (${format})',
			'vrFormat.suggestionTitleShort' => 'Puede que este sea un video VR',
			'vrFormat.suggestionAction' => 'Reproducir como VR',
			'vrFormat.suggestionDismiss' => 'Descartar',
			'localMedia.browse.pinnedSection' => 'Acceso rápido',
			'localMedia.browse.sourcesSection' => 'Carpetas',
			'localMedia.browse.pin' => 'Añadir a acceso rápido',
			'localMedia.browse.unpin' => 'Quitar del acceso rápido',
			'localMedia.browse.pinned' => 'Añadido a acceso rápido',
			'localMedia.browse.unpinned' => 'Quitado del acceso rápido',
			'localMedia.browse.folderCount' => ({required Object count}) => '${count} carpetas',
			'localMedia.browse.videoCount' => ({required Object count}) => '${count} vídeos',
			'localMedia.browse.imageCount' => ({required Object count}) => '${count} imágenes',
			'localMedia.browse.emptyFolder' => 'Esta carpeta está vacía',
			'localMedia.browse.videosSection' => 'Vídeos',
			'localMedia.browse.imagesSection' => 'Imágenes',
			'localMedia.browse.galleriesSection' => 'Galerías',
			'localMedia.browse.filterAll' => 'Todo',
			'localMedia.browse.searchInFolder' => 'Buscar en esta carpeta',
			'localMedia.browse.searchHint' => 'Buscar por nombre',
			'localMedia.browse.clearSearch' => 'Borrar búsqueda',
			'localMedia.browse.searchNoResult' => ({required Object query}) => 'No hay coincidencias con «${query}»',
			'localMedia.browse.viewAllFolders' => ({required Object count}) => 'Ver las ${count} carpetas',
			'localMedia.browse.viewAllVideos' => ({required Object count}) => 'Ver los ${count} vídeos',
			'localMedia.browse.viewAllImages' => ({required Object count}) => 'Ver las ${count} imágenes',
			'localMedia.browse.viewAllGalleries' => ({required Object count}) => 'Ver las ${count} galerías',
			'localMedia.browse.location' => 'Ubicación',
			'localMedia.browse.sourceMissing' => 'Esta fuente ya no existe',
			'localMedia.browse.notScannedYet' => 'Esta carpeta aún no se ha escaneado',
			'localMedia.browse.scanning' => 'Leyendo esta carpeta…',
			'localMedia.browse.deleteFileTitle' => '¿Eliminar este archivo?',
			'localMedia.browse.deleteFileBody' => ({required Object name}) => '"${name}" se eliminará permanentemente de este dispositivo. Esta acción no se puede deshacer.',
			'localMedia.browse.hideFolder' => 'Ocultar esta carpeta',
			'localMedia.browse.unhideFolder' => 'Mostrar de nuevo',
			'localMedia.browse.showHiddenFolders' => 'Mostrar carpetas ocultas',
			'localMedia.browse.includeDotFolders' => 'Escanear carpetas que empiezan por .',
			'localMedia.browse.dotFoldersIncluded' => 'Ahora se escanean las carpetas que empiezan por .',
			'localMedia.browse.dotFoldersExcluded' => 'Ya no se escanean las carpetas que empiezan por .',
			'localMedia.browse.showDotFolders' => 'Mostrar carpetas que empiezan por .',
			'localMedia.browse.dotFoldersSkipped' => ({required Object count}) => 'Aquí hay ${count} carpetas que empiezan por . sin escanear',
			'localMedia.browse.scanDotFoldersAction' => 'Activar para esta fuente',
			'localMedia.browse.otherAppsPrivateNotice' => 'Desde Android 11 ninguna app puede leer los archivos de otras apps en Android/data o Android/obb, y esta app no puede evitarlo. Descarga o exporta los vídeos a una carpeta pública como Download en la app original y luego añade esa carpeta aquí. Las cachés de reproducción suelen estar fragmentadas y no se pueden reproducir aunque se lean.',
			'localMedia.browse.folderHidden' => 'Oculta; el escaneo también la omitirá',
			'localMedia.browse.folderUnhidden' => 'Ya no está oculta',
			'localMedia.browse.hiddenFolderBadge' => 'Oculta',
			'localMedia.browse.deleteFolder' => 'Eliminar carpeta',
			'localMedia.browse.deleteFolderTitle' => '¿Eliminar esta carpeta?',
			'localMedia.browse.deleteFolderBody' => ({required Object name}) => '«${name}» y todo su contenido se eliminarán definitivamente de este dispositivo. No se puede deshacer.',
			'localMedia.browse.deleteFolderIncludesOthers' => 'Los demás archivos que contenga también se eliminarán',
			'localMedia.browse.folderDeleted' => 'Carpeta eliminada',
			'localMedia.browse.deleteFolderFailed' => 'No se pudo eliminar: sin permisos o hay un archivo en uso',
			'localMedia.browse.deleteGalleryTitle' => '¿Eliminar esta galería?',
			'localMedia.browse.deleteGalleryBody' => ({required Object name}) => 'Se eliminarán el registro de descarga y los archivos de imagen locales de "${name}". Esta acción no se puede deshacer.',
			'localMedia.browse.galleryResourceMissing' => 'Los archivos locales ya no existen. Se limpió el registro.',
			'localMedia.browse.viewDownloadDetail' => 'Ver los detalles de la descarga',
			'localMedia.browse.viewOnlineGallery' => 'Ver en el sitio web',
			'localMedia.browse.pickFolderTitle' => 'Elija una carpeta',
			'localMedia.browse.useThisFolder' => 'Usar esta carpeta',
			'localMedia.browse.noSubfolders' => 'Aquí no hay subcarpetas',
			'localMedia.browse.storageRoot' => 'Almacenamiento del dispositivo',
			'localMedia.browse.homeFolder' => 'Inicio',
			'localMedia.browse.filesystemRoot' => 'Raíz del sistema de archivos',
			'localMedia.browse.folderUnreadable' => 'No se puede leer esta carpeta',
			'localMedia.browse.setCover' => 'Establecer portada',
			'localMedia.browse.setAsFolderCover' => 'Usar como portada de la carpeta',
			'localMedia.browse.folderCoverSet' => 'Portada de la carpeta actualizada',
			'localMedia.browse.setFolderCoverPick' => 'Establecer portada…',
			'localMedia.browse.restoreAutoCover' => 'Restaurar la portada automática',
			'localMedia.browse.autoCoverRestored' => 'Se restauró la portada automática',
			'localMedia.browse.rescanFolder' => 'Volver a escanear esta carpeta',
			'localMedia.browse.coverPickerTitle' => 'Elegir un fotograma',
			'localMedia.browse.folderCoverPickerTitle' => 'Elegir portada',
			'localMedia.browse.coverPickerEmpty' => 'Aún no hay imágenes disponibles en esta carpeta. Es posible que las miniaturas de vídeo se sigan generando en segundo plano.',
			'localMedia.browse.coverSaved' => 'Portada actualizada',
			'localMedia.browse.coverSaveFailed' => 'No se pudo guardar la portada',
			'localMedia.browse.coverUnavailable' => 'No se pudo leer ningún fotograma de vídeo de este archivo',
			'localMedia.browse.deleted' => 'Eliminado',
			'localMedia.browse.deleteFailed' => 'No se pudo eliminar: puede que el archivo esté en uso o que no se pueda escribir en él',
			'localMedia.browse.openFolder' => 'Abrir',
			'localMedia.browse.favorite' => 'Añadir a favoritos',
			'localMedia.browse.unfavorite' => 'Quitar de favoritos',
			'localMedia.browse.favorited' => 'Añadido a favoritos',
			'localMedia.browse.unfavorited' => 'Quitado de favoritos',
			'localMedia.browse.sortBy' => 'Ordenar por',
			'localMedia.browse.sortAscending' => 'Ascendente',
			'localMedia.browse.sortDescending' => 'Descendente',
			'localMedia.browse.sortFieldName' => 'Nombre',
			'localMedia.browse.sortFieldModified' => 'Fecha de modificación',
			'localMedia.browse.sortFieldDuration' => 'Duración',
			'localMedia.browse.sortFieldSize' => 'Tamaño',
			'localMedia.browse.sortFieldResolution' => 'Resolución',
			'localMedia.browse.sortFieldFileType' => 'Tipo de archivo',
			'localMedia.browse.sortFieldFps' => 'Frecuencia de fotogramas',
			'localMedia.browse.sortFieldFavorited' => 'Fecha de añadido a favoritos',
			'localMedia.browse.emptyAllVideos' => 'Aún no se han encontrado vídeos. Para empezar, añada una carpeta en Carpetas.',
			'localMedia.browse.emptyAllImages' => 'Aún no se han encontrado imágenes. Para empezar, añada una carpeta en Carpetas.',
			'localMedia.browse.emptyFavorites' => 'Aún no hay favoritos. Añada uno desde el menú ⋮ de un vídeo.',
			'localMedia.browse.emptyPinned' => 'Aún no hay carpetas fijadas. Mantenga pulsada una carpeta en Carpetas y elija Fijar.',
			'localMedia.browse.emptyDownloadedVideos' => 'Aún no hay descargas de vídeos finalizadas.',
			'localMedia.browse.emptyDownloadedGalleries' => 'Aún no hay descargas de galerías finalizadas.',
			'localMedia.browse.folderInfo' => 'Información de la carpeta',
			'localMedia.browse.folderInfoName' => 'Nombre',
			'localMedia.browse.folderInfoPath' => 'Ruta',
			'localMedia.browse.folderInfoSource' => 'Fuente',
			'localMedia.browse.folderInfoContents' => 'Contenido',
			'localMedia.browse.folderInfoSize' => 'Tamaño en disco',
			'localMedia.browse.folderInfoScannedAt' => 'Último escaneo',
			'localMedia.browse.folderInfoNeverScanned' => 'Sin escanear todavía',
			'localMedia.browse.folderInfoNoPath' => 'Esta fuente no tiene ninguna carpeta que abrir',
			'localMedia.browse.copyPath' => 'Copiar ruta',
			'localMedia.browse.pathCopied' => 'Ruta copiada',
			'localMedia.tabFolders' => 'Carpetas',
			'localMedia.tabFavoriteVideos' => 'Favoritos',
			'localMedia.tabAllVideos' => 'Todos los vídeos',
			'localMedia.tabAllImages' => 'Todas las imágenes',
			'localMedia.tabDownloadedVideos' => 'Vídeos descargados',
			'localMedia.tabDownloadedGalleries' => 'Galerías descargadas',
			'localMedia.title' => 'En este dispositivo',
			'localMedia.sourceOnline' => 'Iwara en línea',
			'localMedia.manageSources' => 'Gestionar fuentes',
			'localMedia.moveToCategory' => 'Mover a categoría',
			'localMedia.manageCategories' => 'Gestionar categorías',
			'localMedia.suggestedFolders' => 'Carpetas con vídeos',
			'localMedia.sortRecentlyAdded' => 'Añadidos recientemente',
			'localMedia.sortRecentlyPlayed' => 'Reproducidos recientemente',
			'localMedia.sortName' => 'Nombre',
			'localMedia.sortDuration' => 'Duración',
			'localMedia.sortSize' => 'Tamaño',
			'localMedia.sortFolder' => 'Carpeta',
			'localMedia.sortRecentlyModified' => 'Modificados recientemente',
			'localMedia.sortCount' => 'Cantidad',
			'localMedia.folderCardItemCount' => ({required Object count}) => '${count} imágenes',
			'localMedia.downloadsSource' => 'Descargados',
			'localMedia.builtInSourceHint' => 'Descargados se gestiona automáticamente',
			'localMedia.filterByCategory' => 'Filtrar por categoría',
			'localMedia.longPressToCategorize' => 'Mantenga pulsado para mover a una categoría',
			'localMedia.uncategorized' => 'Sin categoría',
			'localMedia.setCategoryFailed' => 'No se pudo establecer la categoría',
			'localMedia.categoryUpdated' => 'Categoría actualizada',
			'localMedia.addFolder' => 'Añadir carpeta',
			'localMedia.addDeviceVideos' => 'Escanear los vídeos del dispositivo',
			'localMedia.mediaStoreSourceName' => 'Vídeos del dispositivo',
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
			'localMedia.mediaStoreUnavailable' => 'El índice multimedia del dispositivo solo está disponible en Android',
			'localMedia.mediaStorePermissionDenied' => 'No se concedió el acceso a los vídeos',
			'localMedia.rescan' => 'Volver a escanear',
			'localMedia.scanning' => ({required Object count}) => 'Escaneando… ${count} encontrados',
			'localMedia.scanFailed' => ({required Object reason}) => 'No se pudo escanear: ${reason}',
			'localMedia.scanTruncated' => ({required Object count}) => 'Esa carpeta es muy grande; solo se añadieron los primeros ${count} archivos.',
			'localMedia.sourceOverlaps' => ({required Object name}) => 'Ya está cubierta por la carpeta "${name}"',
			'localMedia.addedAsPinnedFolder' => ({required Object name, required Object source}) => '"${name}" está dentro de "${source}", así que se añadió a las carpetas fijadas',
			'localMedia.alreadyPinnedFolder' => ({required Object name}) => '"${name}" ya está en las carpetas fijadas',
			'localMedia.sourceAlreadyAdded' => ({required Object name}) => '"${name}" ya se ha añadido',
			'localMedia.sourceContainsExisting' => ({required Object name}) => 'Ya contiene la carpeta añadida "${name}"; aún no se admite añadir su carpeta superior',
			'localMedia.addSourceFailed' => 'No se pudo añadir esa carpeta',
			'localMedia.fileMissing' => 'Ese archivo ya no está en el disco',
			'localMedia.permissionDenied' => 'Acceso a archivos no concedido · toque para concederlo',
			'localMedia.noVideosFound' => 'No hay vídeos en esta carpeta',
			'localMedia.emptyTitle' => 'Añada una carpeta para ver los vídeos que ya están en este dispositivo',
			'localMedia.emptyPrivacyNote' => 'Los archivos solo se leen en este dispositivo. No se sube nada.',
			'localMedia.removeSourceTitle' => ({required Object name}) => '¿Quitar "${name}"?',
			'localMedia.removeSourceBody' => 'Los archivos permanecen en el disco. Solo se quita esta entrada de la biblioteca.',
			'localMedia.remove' => 'Quitar',
			'localMedia.removeFolder' => 'Quitar carpeta',
			'localMedia.removeFolderSelectTitle' => 'Seleccione la carpeta que quiere quitar',
			'localMedia.longPressToRemove' => 'Mantenga pulsado para quitar esta carpeta',
			'localMedia.clearProgress' => 'Borrar el historial de reproducción local',
			'localMedia.clearProgressCount' => ({required Object count}) => '${count} entradas',
			'localMedia.clearProgressEmpty' => 'Aún no hay historial de reproducción local',
			'localMedia.clearProgressTitle' => '¿Borrar el historial de reproducción local?',
			'localMedia.clearProgressBody' => 'Solo se eliminan las posiciones de reproducción y las marcas de visto. Sus archivos y carpetas permanecen exactamente igual.',
			'localMedia.clearProgressDone' => ({required Object count}) => 'Se borraron ${count} entradas del historial de reproducción local',
			'localMedia.clearAction' => 'Borrar',
			'localMedia.iosManualRescanNotice' => 'iOS no detecta automáticamente los archivos nuevos. Deberá volver a escanear manualmente después de añadir o eliminar archivos.',
			'historyPage.removeFromHistory' => 'Quitar del historial',
			'historyPage.removed' => 'Quitado del historial',
			'historyPage.watchedTo' => ({required Object time}) => 'Visto hasta ${time}',
			'historyPage.finished' => 'Visto',
			'historyPage.clearTabTitle' => ({required Object tab}) => 'Borrar «${tab}»',
			'historyPage.clearTabConfirm' => ({required Object tab}) => 'Se eliminará todo el historial de «${tab}», junto con el progreso de reproducción de esos vídeos. No se puede deshacer.',
			'historyPage.rangeByLastViewed' => 'Filtrado por última visualización',
			_ => null,
		};
	}
}
