// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Constanza';

  @override
  String goodMorning(String name) {
    return '¡Buenos días, $name!';
  }

  @override
  String goodAfternoon(String name) {
    return '¡Buenas tardes, $name!';
  }

  @override
  String goodEvening(String name) {
    return '¡Buenas noches, $name!';
  }

  @override
  String get tagline => 'Pequeñas acciones, grandes cambios.';

  @override
  String get welcomeMessage1 => 'Un pequeño paso también cuenta.';

  @override
  String get welcomeMessage2 => 'La constancia gana a la perfección.';

  @override
  String get welcomeMessage3 => 'Hoy es un buen día para avanzar un poquito.';

  @override
  String get welcomeMessage4 => 'Hazlo por tu yo de mañana.';

  @override
  String get welcomeMessage5 => 'No necesitas hacerlo perfecto, solo hacerlo.';

  @override
  String get welcomeMessage6 => 'Cada hábito de hoy construye tu mañana.';

  @override
  String get skipWelcome => 'Saltar bienvenida';

  @override
  String get generalStreak => 'Racha general';

  @override
  String get consecutiveDays => 'días consecutivos';

  @override
  String get amazing => '¡Increíble!';

  @override
  String get keepItUp => 'Sigue así';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get days => 'días';

  @override
  String get myHabits => 'Mis hábitos';

  @override
  String get habitFilterAll => 'Todos';

  @override
  String get habitFilterDaily => 'Diarios';

  @override
  String get habitFilterWeekly => 'Semanales';

  @override
  String get habitFilterMonthly => 'Mensuales';

  @override
  String get habitFilterYearly => 'Anuales';

  @override
  String get newHabit => 'Nuevo hábito';

  @override
  String get seeAllMyHabits => 'Ver todos mis hábitos';

  @override
  String get noHabitsYet =>
      'Aún no tienes hábitos. Crea el primero con el botón +.';

  @override
  String get homeEmptyHabitsBody =>
      'Tu primer pequeño paso empieza aquí. Créalo con el botón Nuevo hábito.';

  @override
  String get nextReminder => 'Próximo recordatorio';

  @override
  String todayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String get markNow => 'Marcar ahora';

  @override
  String get periodicityDaily => 'Diario';

  @override
  String get periodicityWeekly => 'Semanal';

  @override
  String get periodicityMonthly => 'Mensual';

  @override
  String get periodicityYearly => 'Anual';

  @override
  String get navHome => 'Inicio';

  @override
  String get navHabits => 'Mis hábitos';

  @override
  String get navStats => 'Estadísticas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get comingSoon => 'Muy pronto';

  @override
  String get createHabitComingSoon => 'Crear hábito: muy pronto';

  @override
  String somethingWentWrong(String error) {
    return 'Algo ha ido mal: $error';
  }

  @override
  String get taglineLine1 => 'Pequeñas acciones,';

  @override
  String get taglineLine2 => 'grandes cambios.';

  @override
  String get signInTitle => 'Inicia sesión';

  @override
  String get signInSubtitle => 'Accede a tu cuenta';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get orContinueWith => 'o continúa con';

  @override
  String get noAccountQuestion => '¿No tienes cuenta?';

  @override
  String get registerAction => 'Regístrate';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerSubtitle => 'Empieza hoy tu mejor versión.';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameHint => 'Elige un nickname';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailExampleHint => 'ejemplo@correo.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get registerPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get confirmPasswordLabel => 'Confirma tu contraseña';

  @override
  String get confirmPasswordHint => 'Vuelve a escribir tu contraseña';

  @override
  String get acceptTermsPrefix => 'Acepto los ';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get privacyJoiner => ' y la ';

  @override
  String get privacyPolicy => 'Política de Privacidad';

  @override
  String get registerButton => 'Registrarme';

  @override
  String get alreadyHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get signInAction => 'Inicia sesión';

  @override
  String get nicknameRequired => 'Introduce un nickname';

  @override
  String get registerInvalidEmail => 'Introduce un correo válido';

  @override
  String get registerPasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get acceptTermsError =>
      'Debes aceptar los términos y la política de privacidad';

  @override
  String get verifyLinkSent => 'Te hemos enviado un enlace de verificación a';

  @override
  String get verifyLinkInstructions =>
      'Ábrelo desde tu correo y vuelve aquí para continuar. Si no lo ves, mira en la carpeta de spam.';

  @override
  String get iHaveVerified => 'Ya he verificado mi correo';

  @override
  String get notVerifiedYet =>
      'Todavía no consta como verificado. Revisa tu bandeja de entrada y la carpeta de spam.';

  @override
  String get emailNotReceived => '¿No te ha llegado?';

  @override
  String get resendEmail => 'Reenviar correo';

  @override
  String resendEmailIn(int seconds) {
    return 'Reenviar en $seconds s';
  }

  @override
  String get emailResent =>
      'Correo reenviado. Puede tardar unos minutos en llegar.';

  @override
  String get useAnotherAccount => 'Usar otra cuenta';

  @override
  String get pendingVerificationTitle => 'Tu cuenta todavía no está verificada';

  @override
  String get pendingVerificationBody =>
      'Solo falta este paso para entrar. Abre el enlace que te enviamos o pide uno nuevo; revisa también la carpeta de spam.';

  @override
  String get signInCta => 'Iniciar sesión';

  @override
  String get welcomeTitle => 'Tu cambio empieza aquí';

  @override
  String get welcomeMessage =>
      'El mejor día para empezar fue hace unos meses.\nEl siguiente mejor momento es ';

  @override
  String get welcomeMessageHighlight => 'HOY.';

  @override
  String get welcomeStart => 'Empezar';

  @override
  String get forgotPasswordTitle => 'Recupera tu contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Te enviaremos un enlace para crear una nueva.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get resetLinkSent =>
      'Si existe una cuenta con ese correo, recibirás un enlace para restablecer tu contraseña.';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get profileSubtitle => 'Tu espacio personal';

  @override
  String get profileVerified => 'Cuenta verificada';

  @override
  String get profileYourProgress => 'Tu progreso';

  @override
  String get profileHealth => 'Salud';

  @override
  String get profileWeightTitle => 'Peso y objetivos';

  @override
  String get profileWeightSubtitle => 'Sigue tu evolución';

  @override
  String get profileChangePhoto => 'Cambiar foto';

  @override
  String get weightTitle => 'Peso';

  @override
  String get weightHeroTitle => 'Tu evolución, paso a paso';

  @override
  String get weightHeroEmpty =>
      'Registra tu primera medición para empezar a ver tu progreso.';

  @override
  String weightHeroCurrent(String weight) {
    return 'Tu última medición es de $weight kg.';
  }

  @override
  String weightHeroProgress(String weight) {
    return 'Estás a $weight kg de tu objetivo.';
  }

  @override
  String get weightCurrent => 'Peso actual';

  @override
  String get weightInitial => 'Peso inicial';

  @override
  String get weightGoal => 'Objetivo';

  @override
  String get weightPlanTitle => 'Tu objetivo';

  @override
  String get weightModifyGoals => 'Modificar objetivos';

  @override
  String get weightSinceStart => 'desde el inicio';

  @override
  String get weightToGoal => 'por alcanzar';

  @override
  String weightGoalLabel(String weight) {
    return 'Objetivo $weight kg';
  }

  @override
  String get weightViewAll => 'Ver todo';

  @override
  String weightDailyCalories(int calories) {
    return '$calories kcal/día recomendadas';
  }

  @override
  String get weightSetGoal => 'Definir objetivo';

  @override
  String get weightEvolution => 'Evolución';

  @override
  String get weightHistory => 'Historial';

  @override
  String get weightRegister => 'Registrar peso';

  @override
  String get weightGoalDialog => '¿Cuál es tu peso objetivo?';

  @override
  String get weightLogDialog => 'Registra tu peso';

  @override
  String get weightGoalDialogHint =>
      'Define la meta hacia la que quieres avanzar.';

  @override
  String get weightLogDialogHint =>
      'Introduce tu peso actual para llevar un mejor seguimiento.';

  @override
  String get weightValidRange => 'Introduce un valor entre 20 y 400 kg.';

  @override
  String get weightSaved => 'Peso actualizado';

  @override
  String get weightChartEmpty =>
      'Añade al menos dos mediciones para ver tu evolución.';

  @override
  String get weightHistoryEmpty =>
      'Aún no tienes mediciones. Registra la primera cuando quieras.';

  @override
  String get weightLoadError =>
      'No hemos podido cargar tus datos de peso. Comprueba la conexión o vuelve a intentarlo.';

  @override
  String get weightRetry => 'Reintentar';

  @override
  String get weightOnboardingTitle => 'Tu plan personal';

  @override
  String weightOnboardingStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get weightQuestionGoal => '¿Cuál es tu objetivo?';

  @override
  String get weightQuestionGoalHint =>
      'Lo usaremos para adaptar la estimación a lo que quieres conseguir.';

  @override
  String get weightGoalLose => 'Perder peso';

  @override
  String get weightGoalLoseHint => 'Reducir el peso de forma progresiva';

  @override
  String get weightGoalMaintain => 'Mantener mi peso';

  @override
  String get weightGoalMaintainHint => 'Conservarme cerca de mi peso actual';

  @override
  String get weightGoalGain => 'Ganar peso';

  @override
  String get weightGoalGainHint => 'Aumentar el peso de forma gradual';

  @override
  String get weightQuestionCurrent => '¿Cuál es tu peso actual?';

  @override
  String get weightQuestionCurrentHint =>
      'Será el punto de partida de tu evolución.';

  @override
  String get weightRangeKg => 'Entre 20 y 400 kg';

  @override
  String get weightQuestionTarget => '¿A qué peso quieres llegar?';

  @override
  String get weightQuestionTargetHint =>
      'Elige un objetivo realista que puedas revisar más adelante.';

  @override
  String get weightTargetGoalHelper =>
      'Debe ser coherente con el objetivo seleccionado';

  @override
  String get weightTargetGoalError =>
      'Revisa el peso: no coincide con el objetivo seleccionado';

  @override
  String get weightQuestionAboutYou => 'Cuéntanos un poco sobre ti';

  @override
  String get weightQuestionAboutYouHint =>
      'La edad y la altura son necesarias para estimar tus necesidades energéticas.';

  @override
  String get weightYears => 'años';

  @override
  String get weightAge => 'Edad';

  @override
  String get weightHeight => 'Altura';

  @override
  String get weightQuestionSex => 'Dato biológico para el cálculo';

  @override
  String get weightQuestionSexHint =>
      'La fórmula utiliza este dato para estimar el metabolismo en reposo. Puedes elegir no indicarlo.';

  @override
  String get weightSexFemale => 'Femenino';

  @override
  String get weightSexFemaleHint => 'Usar la constante femenina de la fórmula';

  @override
  String get weightSexMale => 'Masculino';

  @override
  String get weightSexMaleHint => 'Usar la constante masculina de la fórmula';

  @override
  String get weightSexUnspecified => 'Prefiero no indicarlo';

  @override
  String get weightSexUnspecifiedHint =>
      'Se utilizará una estimación intermedia';

  @override
  String get weightQuestionActivity => '¿Cómo es tu nivel de actividad?';

  @override
  String get weightQuestionActivityHint =>
      'Piensa en una semana habitual, incluyendo trabajo, desplazamientos y ejercicio.';

  @override
  String get weightActivitySedentary => 'Sedentario · poco ejercicio';

  @override
  String get weightActivityLight => 'Ligero · 1–3 días por semana';

  @override
  String get weightActivityModerate => 'Moderado · 3–5 días por semana';

  @override
  String get weightActivityActive => 'Activo · 6–7 días por semana';

  @override
  String get weightActivityVeryActive =>
      'Muy activo · ejercicio intenso o trabajo físico';

  @override
  String get weightResultTitle => 'Tu estimación está lista';

  @override
  String get weightEstimatedCalories => 'Ingesta diaria orientativa';

  @override
  String get weightPerDay => 'al día';

  @override
  String get weightMedicalDisclaimer =>
      'Es una estimación para adultos, no una prescripción médica. No debe usarse durante embarazo o lactancia ni ante una condición clínica o un trastorno alimentario; consulta con un profesional sanitario.';

  @override
  String get weightStart => 'Empezar mi seguimiento';

  @override
  String get profileCurrentStreak => 'Racha actual';

  @override
  String get profileActiveHabits => 'Hábitos activos';

  @override
  String get profileProtectors => 'Protectores';

  @override
  String get profileManage => 'Gestión';

  @override
  String get profileMyHabitsSubtitle => 'Edita y organiza tus hábitos';

  @override
  String get profileCalendarsSubtitle => 'Consulta todo tu progreso';

  @override
  String get profileStatsSubtitle => 'Analiza tu constancia';

  @override
  String get profilePreferences => 'Preferencias';

  @override
  String get profileTimezone => 'Zona horaria';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileEditPersonalTitle => 'Tu perfil, a tu manera';

  @override
  String get profileEditPersonalSubtitle => '¿Cómo quieres que te llamemos?';

  @override
  String get profileEditNameHint => 'Este nombre aparecerá en tus logros';

  @override
  String get clear => 'Borrar';

  @override
  String get profileViewStats => 'Ver estadísticas';

  @override
  String get profileTimezoneSubtitle => 'Configura tu zona horaria';

  @override
  String get profileNotifications => 'Notificaciones';

  @override
  String get profileNotificationsSubtitle => 'Personaliza tus recordatorios';

  @override
  String get profileAppearance => 'Personalización';

  @override
  String get profileAppearanceSubtitle => 'Mensajes, bienvenida y aspecto';

  @override
  String get personalizationHeroTitle =>
      'Haz que Constanza te acompañe a tu manera';

  @override
  String get personalizationMotivation => 'Mensajes de motivación';

  @override
  String get personalizationDefaultPreview => 'Hoy cuenta. Hazlo a tu ritmo ✨';

  @override
  String get personalizationShowMessages => 'Mostrar mensajes';

  @override
  String get personalizationShowMessagesHint =>
      'Incluye frases motivadoras en tu bienvenida';

  @override
  String get personalizationYourMessages => 'Tus frases';

  @override
  String get personalizationYourMessagesHint =>
      'Tú sabes qué te motiva. Escríbelo a tu manera.';

  @override
  String get personalizationNoMessages =>
      'Todavía no has añadido ninguna frase propia.';

  @override
  String get personalizationAddMessage => 'Añadir mensaje';

  @override
  String get personalizationEditMessage => 'Editar mensaje';

  @override
  String get personalizationMessageHint => 'Escribe una frase que te motive';

  @override
  String get premiumMessageLimitTitle => 'Desbloquea más frases con Premium';

  @override
  String get premiumMessageLimitBody =>
      'La versión gratuita incluye una frase personalizada. Con Premium puedes guardar todas las que quieras.';

  @override
  String get personalizationAppearance => 'Aspecto';

  @override
  String get edit => 'Editar';

  @override
  String get appearanceHeroTitle => 'Hazla un poco más tuya';

  @override
  String get appearanceHeroBody =>
      'Personaliza cómo se siente Constanza al acompañarte cada día.';

  @override
  String get appearancePreview => 'Vista previa';

  @override
  String get appearanceExperience => 'Experiencia';

  @override
  String get appearanceReducedMotion => 'Reducir movimiento';

  @override
  String get appearanceReducedMotionHint =>
      'Sigue la configuración de accesibilidad del dispositivo';

  @override
  String get appearanceActive => 'Activo';

  @override
  String get appearanceInactive => 'Inactivo';

  @override
  String get appearanceTheme => 'Tema';

  @override
  String get appearanceLightTheme => 'Claro';

  @override
  String get appearanceLightThemeHint => 'El estilo actual de Constanza';

  @override
  String get appearanceDarkTheme => 'Oscuro';

  @override
  String get appearanceThemeHint => 'Elige entre el tema claro y el oscuro.';

  @override
  String get appearanceDarkThemeHint => 'Más cómodo para los ojos de noche';

  @override
  String get premiumDarkThemeTitle => 'Descubre Constanza de noche';

  @override
  String get premiumDarkThemeBody =>
      'Un aspecto más envolvente, con colores vivos y menos brillo para acompañarte también al final del día.';

  @override
  String get premiumDarkThemePreviewLabel =>
      'Vista previa de Constanza en modo oscuro';

  @override
  String get appearanceAppIcon => 'Icono de la app';

  @override
  String get appearanceAppIconHint =>
      'Elige cómo quieres reconocer Constanza en tu dispositivo.';

  @override
  String get appearanceClassic => 'Clásico';

  @override
  String get appIconCrown => 'Realeza';

  @override
  String get appIconYarn => 'Ovillo';

  @override
  String get appIconChanged => 'Icono actualizado';

  @override
  String get appIconChangeFailed =>
      'No se pudo cambiar el icono. Inténtalo de nuevo.';

  @override
  String get premiumAppIconTitle => 'Iconos exclusivos';

  @override
  String get premiumAppIconBody =>
      'Cambia el icono de Constanza en tu pantalla de inicio por uno de nuestros gatitos Premium.';

  @override
  String get premiumAppIconPreviewLabel => 'Iconos Premium de Constanza';

  @override
  String get appearanceSystemHint =>
      'La reducción de movimiento se adapta automáticamente a los ajustes de accesibilidad del dispositivo.';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileChooseTimezone => 'Elige tu zona horaria';

  @override
  String get profileReminderSettings => 'Recordatorios de hábitos';

  @override
  String get profileReminderSettingsHint =>
      'Toca un hábito para configurar su hora de aviso.';

  @override
  String get notificationHeroTitle => 'Un empujoncito a tiempo';

  @override
  String get notificationHeroBody =>
      'Elige cuándo quieres que Constanza te recuerde cada hábito.';

  @override
  String notificationActiveSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recordatorios activos',
      one: '1 recordatorio activo',
      zero: 'Ningún recordatorio activo',
    );
    return '$_temp0';
  }

  @override
  String get notificationActiveSummaryHint =>
      'Puedes configurarlos por separado.';

  @override
  String get notificationHabitListHint =>
      'Activa un hábito o toca su hora para cambiarla.';

  @override
  String notificationEveryDayAt(String time) {
    return 'Cada día a las $time';
  }

  @override
  String get notificationChooseTime => 'Elige la hora del recordatorio';

  @override
  String get reminderPickerTitle => '¿A qué hora te avisamos?';

  @override
  String get reminderPickerSubtitle => 'Elige el mejor momento para tu hábito';

  @override
  String get reminderPickerMorning => 'Mañana';

  @override
  String get reminderPickerAfternoon => 'Tarde';

  @override
  String get reminderPickerNight => 'Noche';

  @override
  String get reminderPickerSave => 'Guardar hora';

  @override
  String get notificationReminderSaved => 'Recordatorio actualizado';

  @override
  String get notificationTimezoneHint =>
      'Los recordatorios seguirán la zona horaria configurada en tu perfil.';

  @override
  String get notificationCustomMessage => 'Mensaje';

  @override
  String get notificationDefaultMessageHint => 'Usar mensaje predeterminado';

  @override
  String get notificationCustomMessageTitle => 'Personaliza tu recordatorio';

  @override
  String notificationCustomMessageBody(String habitName) {
    return 'Escribe el mensaje que quieres recibir para $habitName.';
  }

  @override
  String get premiumReminderMessageTitle => 'Tus recordatorios, a tu manera';

  @override
  String get premiumReminderMessageBody =>
      'Con Premium puedes escribir un mensaje distinto para cada hábito y recibir justo el impulso que necesitas.';

  @override
  String get profileNoHabits => 'Aún no tienes hábitos que configurar.';

  @override
  String get profileWelcomeAnimation => 'Animación de bienvenida';

  @override
  String get profileWelcomeAnimationHint =>
      'Mostrar mascota y motivación al abrir la app';

  @override
  String get profileChangesSaved => 'Cambios guardados';

  @override
  String get profileStreakEncouragement => '¡Sigue así! 💪';

  @override
  String get profileHabitsEncouragement =>
      'Estás construyendo un gran hábito 💚';

  @override
  String profileProtectorEncouragement(int count) {
    return 'Tienes $count para un mal día ✨';
  }

  @override
  String get chooseAvatar => 'Elige tu avatar';

  @override
  String get chooseAvatarSubtitle =>
      'Haz que Constanza sea un poquito más tuyo 💜';

  @override
  String get avatarTraveler => 'Cloud';

  @override
  String get avatarFriendly => 'Licorice';

  @override
  String get avatarMagic => 'Pearl';

  @override
  String get avatarGamer => 'Peaches';

  @override
  String get avatarZen => 'Snowball';

  @override
  String get avatarNight => 'Mocha';

  @override
  String get avatarAdventurer => 'Yarn';

  @override
  String get avatarLegendary => 'Tangerine';

  @override
  String get avatarHazel => 'Hazel';

  @override
  String get avatarCookie => 'Cookie';

  @override
  String get avatarPremium => 'Premium';

  @override
  String get avatarPremiumTitle => 'Personaliza tu perfil con Premium';

  @override
  String get avatarPremiumBody =>
      'Este avatar forma parte de la colección Premium. Desbloquéalo y dale a tu perfil un estilo todavía más personal.';

  @override
  String get avatarPremiumBenefitTitle => 'Personalizaciones exclusivas';

  @override
  String get avatarPremiumBenefitBody =>
      'Accede a avatares especiales y a nuevas opciones visuales.';

  @override
  String get avatarSelected => 'Seleccionado';

  @override
  String get avatarAvailable => 'Disponible';

  @override
  String get avatarComingSoon => 'Próximamente';

  @override
  String get avatarLocked => 'bloqueado';

  @override
  String get avatarLockedTitle => 'Avatar bloqueado 🔒';

  @override
  String get avatarLockedBody => 'Este avatar estará disponible próximamente.';

  @override
  String get understood => 'Entendido';

  @override
  String get timezoneHeroTitle => 'Tu día, a tu hora';

  @override
  String get timezoneHeroBody =>
      'Usamos tu zona horaria para saber cuándo empieza un nuevo día y mantener correctamente tus hábitos y tu racha.';

  @override
  String get timezoneAutomatic => 'Zona horaria automática';

  @override
  String get timezoneAutomaticSubtitle =>
      'Usar la zona horaria del dispositivo';

  @override
  String get timezoneRecommended => 'Recomendado para la mayoría de usuarios.';

  @override
  String get timezoneCurrent => 'Tu zona horaria actual';

  @override
  String get timezoneActive => 'Activa';

  @override
  String timezoneCurrentTime(String time) {
    return 'Hora actual: $time';
  }

  @override
  String get timezoneManual => 'Seleccionar manualmente';

  @override
  String get timezoneManualSubtitle =>
      'Si lo prefieres, puedes elegir otra zona horaria.';

  @override
  String get timezoneSearch => 'Buscar ciudad o zona horaria...';

  @override
  String get timezoneRecent => 'Zonas disponibles';

  @override
  String get timezoneTravelHint =>
      'Si viajas, Constanza actualizará automáticamente tu zona horaria cuando esté activada esta opción, para que tus días sigan tu hora local.';

  @override
  String get profileAccount => 'Cuenta';

  @override
  String get profileSignOutHint =>
      'Podrás volver a entrar con tu correo y contraseña.';

  @override
  String get nicknameTooLong =>
      'El nickname no puede superar los 40 caracteres';

  @override
  String get authErrorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'Ya existe una cuenta con este correo.';

  @override
  String get authErrorWeakPassword => 'La contraseña es demasiado débil.';

  @override
  String get authErrorInvalidEmail => 'El correo no es válido.';

  @override
  String get authErrorUserDisabled => 'Esta cuenta está desactivada.';

  @override
  String get authErrorTooManyRequests =>
      'Demasiados intentos. Espera unos minutos e inténtalo de nuevo.';

  @override
  String get authErrorNetwork =>
      'Sin conexión. Comprueba tu red e inténtalo de nuevo.';

  @override
  String get authErrorRequiresRecentLogin =>
      'Por seguridad, vuelve a iniciar sesión para continuar.';

  @override
  String get authErrorNoSession =>
      'Tu sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get authErrorUnknown => 'Algo ha ido mal. Inténtalo de nuevo.';

  @override
  String get verifyAccountTitle => 'Verifica tu cuenta';

  @override
  String get invalidEmail => 'Introduce un correo válido';

  @override
  String get passwordTooShort =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get brandFooter => 'Tu mejor versión, cada día.';

  @override
  String get loadingYourBestVersion => 'Cargando tu mejor versión...';

  @override
  String get splashPhrase1 => 'Pequeñas acciones, grandes cambios.';

  @override
  String get splashPhrase2 => 'Construye quien quieres ser';

  @override
  String get splashPhrase3 => 'Cada día suma aunque no lo sientas';

  @override
  String get splashPhrase4 => 'La constancia no es perfección, es continuar.';

  @override
  String get splashPhrase5 => 'Hoy es un buen día para continuar';

  @override
  String get weekdayInitials => 'L,M,X,J,V,S,D';

  @override
  String get streakAtRisk => 'Tu racha está en peligro';

  @override
  String get streakAtRiskBody =>
      'Ayer no completaste ningún hábito. Puedes protegerlo con un comodín hasta el final del día.';

  @override
  String get streakSafeToday => '¡Hoy ya cuenta! Sigue así.';

  @override
  String get streakPendingToday => 'Aún no has completado nada hoy.';

  @override
  String get streakStartToday => 'Completa un hábito para empezar tu racha.';

  @override
  String get collapseStreakCard => 'Reducir tarjeta de racha';

  @override
  String get expandStreakCard => 'Ampliar tarjeta de racha';

  @override
  String get useWildcard => 'Usar comodín';

  @override
  String wildcardsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count protectores de racha',
      one: '1 protector de racha',
      zero: 'Sin protectores de racha',
    );
    return '$_temp0';
  }

  @override
  String get noWildcardsLeft =>
      'No te quedan comodines. Recibirás uno nuevo el mes que viene.';

  @override
  String get wildcardProtectsNotAdds =>
      'Un comodín protege tu racha, pero no suma un día ni marca ningún hábito.';

  @override
  String get wildcardConfirmTitle => '¿Usar un comodín?';

  @override
  String wildcardConfirmBody(String day, int streak) {
    return 'Protegerás el $day y tu racha de $streak días seguirá viva.';
  }

  @override
  String get wildcardUsed => 'Racha protegida. ¡Sigue adelante!';

  @override
  String get wildcardErrorWindowClosed => 'Ese día ya no se puede proteger.';

  @override
  String get wildcardErrorNone => 'No te quedan comodines.';

  @override
  String get wildcardErrorConnection =>
      'Necesitas conexión para usar un comodín.';

  @override
  String get wildcardErrorGeneric =>
      'No se ha podido usar el comodín. Inténtalo de nuevo.';

  @override
  String get cancel => 'Cancelar';

  @override
  String goalProgressLabel(int completed, int goal) {
    return '$completed / $goal';
  }

  @override
  String get goalPeriodWeek => 'esta semana';

  @override
  String get goalPeriodMonth => 'este mes';

  @override
  String get goalPeriodYear => 'este año';

  @override
  String get goalPeriodDay => 'hoy';

  @override
  String get periodicityDailyLabel => 'Todos los días';

  @override
  String periodicityWeeklyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por semana',
      one: '1 vez por semana',
    );
    return '$_temp0';
  }

  @override
  String periodicityMonthlyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces al mes',
      one: '1 vez al mes',
    );
    return '$_temp0';
  }

  @override
  String periodicityYearlyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces al año',
      one: '1 vez al año',
    );
    return '$_temp0';
  }

  @override
  String frequencyChangeDeferred(String date) {
    return 'Este cambio se aplicará el $date. Hasta entonces se mantiene tu objetivo actual.';
  }

  @override
  String get logNotTodayError => 'Solo puedes marcar hábitos del día de hoy.';

  @override
  String bestStreakLabel(int count) {
    return 'Mejor racha: $count';
  }

  @override
  String get newHabitTitle => 'Nuevo hábito';

  @override
  String get editHabitTitle => 'Editar hábito';

  @override
  String get editHabitWarningTitle => 'Editar hábito';

  @override
  String get editHabitWarningBody =>
      'Si cambias la frecuencia, el progreso se recalculará con el nuevo objetivo.\nEl historial y la racha no se borrarán.';

  @override
  String get editHabitProgressInfo =>
      'El progreso se ajustará al nuevo objetivo.';

  @override
  String get editHabitHistoryInfo => 'Tu historial se mantendrá.';

  @override
  String get editHabitStreakInfo => 'Tu racha no se borrará.';

  @override
  String get habitIdentityLockedHint =>
      'El nombre y el ámbito no se pueden cambiar. Para eso, crea un hábito nuevo.';

  @override
  String get habitNameLabel => 'Nombre';

  @override
  String get habitNameHint => 'Ej. Beber agua';

  @override
  String get habitEmojiLabel => 'Emoji';

  @override
  String get habitColorLabel => 'Color';

  @override
  String get habitAmbitoLabel => 'Ámbito';

  @override
  String get habitPeriodicityLabel => 'Objetivo';

  @override
  String get habitTimesLabel => 'Veces por periodo';

  @override
  String get habitTrackingQuestion => '¿Cuántas veces quieres hacerlo?';

  @override
  String get habitTrackingOnce => 'Una vez';

  @override
  String get habitTrackingSeveral => 'Varias veces';

  @override
  String get habitTargetCount => '¿Cuántas veces?';

  @override
  String get habitUnitOptional => 'Unidad (opcional)';

  @override
  String get habitUnitHint => 'Ejemplo: vasos';

  @override
  String get habitDisplayGoalOptional => 'Objetivo visible (opcional)';

  @override
  String get habitDisplayGoalHint => 'Ejemplo: 2 L';

  @override
  String get habitProgressIcon => 'Icono de progreso';

  @override
  String get habitProgressIconSubtitle =>
      'Elige cómo quieres registrar cada vez que lo hagas.';

  @override
  String habitRepetitionProgress(Object completed, Object target, Object unit) {
    return '$completed de $target$unit';
  }

  @override
  String habitRepetitionItemCompleted(
    Object index,
    Object item,
    Object target,
  ) {
    return '$item $index de $target, completado';
  }

  @override
  String habitRepetitionItemPending(Object index, Object item, Object target) {
    return '$item $index de $target, pendiente';
  }

  @override
  String get habitReminderLabel => 'Recordatorio';

  @override
  String get habitReminderNone => 'Sin recordatorio';

  @override
  String habitReminderSet(String time) {
    return 'Todos los días a las $time';
  }

  @override
  String get saveHabit => 'Guardar';

  @override
  String get createHabit => 'Crear hábito';

  @override
  String get deleteHabit => 'Eliminar hábito';

  @override
  String get deleteHabitConfirmTitle => '¿Eliminar este hábito?';

  @override
  String get deleteHabitConfirmBody =>
      'Dejará de aparecer en tus listas, pero su historial se conserva y los días que ya completaste siguen contando para tu racha.';

  @override
  String get delete => 'Eliminar';

  @override
  String get habitCreated => 'Hábito creado';

  @override
  String get habitSaved => 'Cambios guardados';

  @override
  String get habitDeleted => 'Hábito eliminado';

  @override
  String get habitNotFound => 'Este hábito ya no existe';

  @override
  String get errorNameRequired => 'Escribe un nombre';

  @override
  String get errorNameTooLong => 'El nombre es demasiado largo';

  @override
  String get errorEmojiRequired => 'Elige un emoji';

  @override
  String get errorTimesInvalid => 'Ese número no cabe en el periodo';

  @override
  String get errorReminderInvalid => 'Hora no válida';

  @override
  String get errorSaveFailed => 'No se ha podido guardar. Inténtalo de nuevo.';

  @override
  String get noHabitsYetLong =>
      'Aún no tienes hábitos.\nCrea el primero y empieza tu racha.';

  @override
  String get myHabitsManageSubtitle => 'Edita y organiza tus hábitos';

  @override
  String get addHabit => 'Añadir hábito';

  @override
  String get emptyHabitsImageLabel => 'Gato esperando nuevos hábitos';

  @override
  String get emptyHabitsTitle => 'Aún no tienes hábitos';

  @override
  String get emptyHabitsBody =>
      'Empieza añadiendo tu primer hábito y da el primer paso hacia la mejor versión de ti.';

  @override
  String get addFirstHabit => 'Añadir mi primer hábito';

  @override
  String get needIdeas => '¿Necesitas ideas?';

  @override
  String get habitIdeaExercise => 'Ejercicio';

  @override
  String get habitIdeaRead => 'Leer';

  @override
  String get habitIdeaWater => 'Beber agua';

  @override
  String get habitIdeaSleep => 'Dormir mejor';

  @override
  String get allHabitsTitle => 'Mis hábitos';

  @override
  String get habitCalendarsAction => 'Calendarios';

  @override
  String get editHabitsAction => 'Editar hábitos';

  @override
  String get habitCalendarsTitle => 'Calendarios de hábitos';

  @override
  String get habitCalendarsCompleted => 'Cumplido';

  @override
  String get habitCalendarsNotCompleted => 'Sin completar';

  @override
  String get statsSubtitle => 'Tu constancia se nota 💜';

  @override
  String get statsThisWeek => 'Esta semana';

  @override
  String get statsThisMonth => 'Este mes';

  @override
  String get statsThisYear => 'Este año';

  @override
  String get statsCurrentStreak => 'Racha actual';

  @override
  String get statsBestStreak => 'Mejor racha';

  @override
  String statsDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get statsKeepGoing => '¡Sigue así!';

  @override
  String get statsPersonalRecord => '¡Tu récord personal!';

  @override
  String get statsCompliance => 'Cumplimiento';

  @override
  String get statsCompletedRecords => 'Hábitos completados';

  @override
  String get statsActiveDays => 'Días activos';

  @override
  String get statsProtectors => 'Protectores disponibles';

  @override
  String get statsWeeklyProgress => 'Actividad semanal';

  @override
  String get statsMonthlyProgress => 'Tu progreso este mes';

  @override
  String get statsYearlyProgress => 'Tu progreso este año';

  @override
  String get statsSeeCalendar => 'Calendario';

  @override
  String get statsHabits => 'Hábitos';

  @override
  String pendingHabitsWithCount(int count) {
    return 'Pendientes ($count)';
  }

  @override
  String completedHabitsWithCount(int count) {
    return 'Completados hoy ($count)';
  }

  @override
  String get allHabitsDoneTitle => '¡Todo hecho por hoy! 🎉';

  @override
  String get allHabitsDoneBody => 'Has registrado todos tus hábitos.';

  @override
  String markHabitDone(String habit) {
    return 'Marcar $habit como hecho hoy';
  }

  @override
  String markHabitUndone(String habit) {
    return 'Desmarcar $habit de hoy';
  }

  @override
  String get habitPendingEncouragement =>
      'Pequeños pasos, grandes resultados ✨';

  @override
  String get habitCompletedEncouragement => '¡Objetivo cumplido! 🎉';

  @override
  String get habitCompletedCelebration => '¡Muy bien! Un paso más 💪';

  @override
  String get habitCompletedCelebration2 =>
      '¡Genial! Tu constancia está creciendo ✨';

  @override
  String get habitCompletedCelebration3 => '¡Hecho! Hoy vuelves a elegirte 💜';

  @override
  String get habitCompletedCelebration4 => '¡Buen trabajo! Cada paso cuenta 🌱';

  @override
  String get habitCompletedCelebration5 =>
      '¡Sigue así! Estás creando algo grande 🚀';

  @override
  String get habitCompletedCelebration6 =>
      '¡Objetivo cumplido! Tú puedes con esto ⭐';

  @override
  String get allHabitsCompletedCelebration => '¡Día completado! Eres imparable';

  @override
  String get allHabitsCompletedCelebration2 =>
      '¡Todo listo por hoy! Qué gran trabajo 🎉';

  @override
  String get allHabitsCompletedCelebration3 =>
      '¡Día redondo! Tu constancia brilla ✨';

  @override
  String get allHabitsCompletedCelebration4 =>
      '¡Todos cumplidos! Mañana seguimos 💜';

  @override
  String get editHabitsHint =>
      'Para editar tus hábitos, ve a la pestaña Hábitos.';

  @override
  String get timezoneChangeConfirmTitle => '¿Cambiar tu zona horaria?';

  @override
  String get timezoneChangeConfirmAction => 'Cambiar';

  @override
  String get timezoneAutomaticConfirmBody =>
      'Constanza usará la zona horaria del dispositivo y la actualizará automáticamente cuando viajes, para que tus días sigan tu hora local.';

  @override
  String get timezoneManualConfirmBody =>
      'Al elegir una zona manualmente, dejará de actualizarse automáticamente cuando viajes. Tus hábitos y tu racha seguirán la zona que selecciones.';

  @override
  String reminderNotificationTitle(String habit) {
    return '$habit';
  }

  @override
  String get reminderNotificationBody =>
      'Es tu momento. ¿Lo damos por hecho hoy?';

  @override
  String get notificationsDisabledTitle => 'Los avisos están desactivados';

  @override
  String get notificationsDisabledBody =>
      'Constanza no puede avisarte hasta que des permiso a las notificaciones.';

  @override
  String get notificationsEnableAction => 'Activar avisos';

  @override
  String get notificationsDeniedHint =>
      'Has denegado los avisos. Puedes activarlos desde los ajustes del sistema.';

  @override
  String notificationsScheduled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count avisos programados',
      one: '1 aviso programado',
      zero: 'Sin avisos programados',
    );
    return '$_temp0';
  }

  @override
  String get premiumHabitLimitTitle => 'Desbloquea más hábitos con Premium';

  @override
  String get premiumHabitLimitBody =>
      'Has alcanzado el límite de 5 hábitos en la versión gratuita. Con Premium podrás crear todos los hábitos que quieras y seguir avanzando.';

  @override
  String get premiumUnlimitedHabits => 'Hábitos ilimitados';

  @override
  String get premiumUnlimitedHabitsBody =>
      'Crea todos los hábitos que necesites.';

  @override
  String get premiumAdvancedStats => 'Estadísticas avanzadas';

  @override
  String get premiumAdvancedStatsBody => 'Visualiza tu progreso en detalle.';

  @override
  String get premiumNewFeatures => 'Nuevas funcionalidades';

  @override
  String get premiumNewFeaturesBody =>
      'Próximamente, más herramientas exclusivas.';

  @override
  String get premiumNotNow => 'Ahora no';

  @override
  String get premiumViewPlans => 'Ver planes Premium';

  @override
  String get premiumCatImageLabel => 'Gato con corona Premium';
}
