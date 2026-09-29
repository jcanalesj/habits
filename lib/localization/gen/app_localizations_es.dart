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
  String get nicknameLabel => 'Apodo';

  @override
  String get nicknameHint => 'Elige un apodo';

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
  String get nicknameRequired => 'Introduce un apodo';

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
  String get weightEncouragementTitle => '¡Vas por buen camino!';

  @override
  String get weightEncouragementBody => 'Cada pequeño paso cuenta 💜';

  @override
  String get weightSinceLast => 'desde la última vez';

  @override
  String get weightRemaining => 'Faltan';

  @override
  String get weightEvolutionSubtitle => 'Tu progreso en el tiempo';

  @override
  String get weightDailyCaloriesTitle => 'Calorías diarias';

  @override
  String get weightForYourGoal => 'Para tu objetivo';

  @override
  String get weightToday => 'Hoy';

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
  String get weightInvitationTitle => '¿Seguimos tu progreso?';

  @override
  String get weightInvitationBody =>
      'Registra tu peso y define un objetivo para ver tu evolución paso a paso con Constanza.';

  @override
  String get weightInvitationStart => 'Configurar mi peso';

  @override
  String get weightInvitationLater => 'Ahora no';

  @override
  String get weightInvitationNever => 'No volver a mostrar';

  @override
  String get weightInvitationCatLabel => 'Gato de Constanza haciendo ejercicio';

  @override
  String get weightResetData => 'Eliminar mis datos de peso';

  @override
  String get weightResetTitle => '¿Quieres empezar de cero?';

  @override
  String get weightResetBody =>
      'Se eliminarán tus mediciones, tu objetivo y los datos de tu plan. Esta acción no se puede deshacer.';

  @override
  String get weightResetConfirm => 'Eliminar y empezar de cero';

  @override
  String get weightDataDeleted => 'Tus datos de peso se han eliminado';

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
  String get gymCatImageLabel => 'Gato deportista de Constanza';

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
  String get avatarTraveler => 'Constanza';

  @override
  String get avatarFriendly => 'Licorice';

  @override
  String get avatarMagic => 'Pearl';

  @override
  String get avatarGamer => 'Peaches';

  @override
  String get avatarZen => 'Constanza';

  @override
  String get avatarNight => 'Mocha';

  @override
  String get avatarAdventurer => 'Yarn';

  @override
  String get avatarLegendary => 'Tangerine';

  @override
  String get avatarHazel => 'Hazel';

  @override
  String get avatarCookie => 'Crispin';

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
  String get nicknameTooLong => 'El apodo no puede superar los 40 caracteres';

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
  String get quitHabitNameHint => 'Ej. Dejar de fumar';

  @override
  String get habitEmojiLabel => 'Emoji';

  @override
  String get emojiSearchHint => 'Buscar emoji';

  @override
  String get emojiSearchEmpty => 'No hay emojis para esa búsqueda.';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get habitColorLabel => 'Color';

  @override
  String get habitAmbitoLabel => 'Ámbito';

  @override
  String get habitKindQuestion => '¿Qué quieres hacer?';

  @override
  String get habitKindBuild => 'Hábito positivo';

  @override
  String get habitKindQuit => 'Dejar hábito';

  @override
  String get habitKindBuildHint =>
      'Una acción que quieres repetir y marcar como completada.';

  @override
  String get habitKindQuitHint =>
      'Verás cuánto tiempo llevas sin hacerlo y podrás reiniciar el contador si recaes.';

  @override
  String get quitHabitsTab => 'Dejar hábitos';

  @override
  String get buildHabitsTab => 'Crear hábitos';

  @override
  String quitHabitSince(String date) {
    return 'Sin hacerlo desde $date';
  }

  @override
  String quitHabitRecord(String duration) {
    return 'Récord: $duration';
  }

  @override
  String get quitHabitReset => 'He recaído';

  @override
  String get quitHabitResetTitle => 'Un tropiezo no borra tu progreso';

  @override
  String get quitHabitResetBody =>
      'Lo importante es volver a intentarlo. Guardaremos este periodo y empezaremos uno nuevo desde ahora.';

  @override
  String quitHabitProgressKept(String duration) {
    return 'Todo lo conseguido durante $duration sigue contando.';
  }

  @override
  String get quitHabitResetConfirm => 'Registrar y seguir';

  @override
  String get quitHabitKeepGoing => 'Seguir sin reiniciar';

  @override
  String get quitHabitResetSuccess =>
      'Nuevo comienzo registrado. Sigue adelante, puedes hacerlo.';

  @override
  String quitHabitHoursDetail(int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours horas',
      one: '1 hora',
    );
    return 'y $_temp0';
  }

  @override
  String get quitHabitEncouragement =>
      'Estás construyendo algo importante. Sigue adelante.';

  @override
  String get quitHabitEmpty => 'Aún no tienes hábitos que quieras dejar.';

  @override
  String get homeQuitHabitsTitle => 'Cada momento cuenta';

  @override
  String get homeQuitEncouragement => 'Sigue así, cada momento suma.';

  @override
  String homeQuitDurationDays(int days, int hours) {
    return '$days d · $hours h';
  }

  @override
  String homeQuitDurationHours(int hours, int minutes) {
    return '$hours h · $minutes min';
  }

  @override
  String get homeQuitFirstDay => 'Primer día';

  @override
  String homeQuitDurationDaysOnly(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String homeQuitDurationMonthsOnly(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String homeQuitDurationMonthsDays(int months, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    String _temp1 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0 y $_temp1';
  }

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
  String get a11yShowPassword => 'Mostrar contraseña';

  @override
  String get a11yHidePassword => 'Ocultar contraseña';

  @override
  String get a11yPreviousMonth => 'Mes anterior';

  @override
  String get a11yNextMonth => 'Mes siguiente';

  @override
  String get a11yDecrease => 'Quitar uno';

  @override
  String get a11yIncrease => 'Añadir uno';

  @override
  String get iconWater => 'Agua';

  @override
  String get iconExercise => 'Ejercicio';

  @override
  String get iconStrength => 'Fuerza';

  @override
  String get iconMeditation => 'Meditación';

  @override
  String get iconRest => 'Descanso';

  @override
  String get iconReading => 'Lectura';

  @override
  String get iconWellbeing => 'Bienestar';

  @override
  String get iconGoal => 'Meta';

  @override
  String get iconFood => 'Alimentación';

  @override
  String get iconMedication => 'Medicación';

  @override
  String get iconPet => 'Mascota';

  @override
  String get iconDrink => 'Bebida';

  @override
  String get iconGeneral => 'General';

  @override
  String get progressIconWaterDrop => 'Gota de agua';

  @override
  String get progressIconStar => 'Estrella';

  @override
  String get progressIconFruit => 'Fruta';

  @override
  String get progressIconPill => 'Pastilla';

  @override
  String get progressIconPaw => 'Huella';

  @override
  String get progressIconBrush => 'Cepillo';

  @override
  String get cityLondon => 'Londres';

  @override
  String get cityNewYork => 'Nueva York';

  @override
  String get cityMexicoCity => 'Ciudad de México';

  @override
  String get cityTokyo => 'Tokio';

  @override
  String get weightConsentTitle => 'Tus datos de salud';

  @override
  String get weightConsentBody =>
      'Para mostrar tu evolución y estimar tus calorías guardaremos en tu cuenta tu peso, edad, altura, sexo y nivel de actividad. Solo se usan para esto, no se comparten y puedes borrarlos cuando quieras (o eliminar tu cuenta).';

  @override
  String get weightConsentAccept => 'Acepto';

  @override
  String get weightConsentDecline => 'Ahora no';

  @override
  String get weightConsentPrivacy => 'Leer la política de privacidad';

  @override
  String get weightConsentCatLabel =>
      'Gato de Constanza protegiendo tus datos de salud';

  @override
  String get pageNotFound => 'Esta pantalla no existe.';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get signOutConfirmTitle => '¿Ya te vas?';

  @override
  String get signOutConfirmBody =>
      'Tus datos se quedan guardados en tu cuenta. Los recordatorios dejarán de llegar a este dispositivo hasta que vuelvas a entrar.';

  @override
  String get sadCatImageLabel => 'Gato triste de Constanza';

  @override
  String get paywallTitle => 'Constanza Premium';

  @override
  String get paywallSubtitle =>
      'Todo lo que necesitas para no romper la racha.';

  @override
  String get paywallMonthly => 'Mensual';

  @override
  String get paywallAnnual => 'Anual';

  @override
  String get paywallLifetime => 'Para siempre';

  @override
  String get paywallOtherPlan => 'Plan Premium';

  @override
  String paywallPerMonth(String price) {
    return '$price al mes';
  }

  @override
  String paywallPerYear(String price) {
    return '$price al año';
  }

  @override
  String paywallOneTime(String price) {
    return '$price, pago único';
  }

  @override
  String paywallTrialDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días gratis',
      one: '1 día gratis',
    );
    return '$_temp0';
  }

  @override
  String paywallTrialWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas gratis',
      one: '1 semana gratis',
    );
    return '$_temp0';
  }

  @override
  String paywallTrialMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses gratis',
      one: '1 mes gratis',
    );
    return '$_temp0';
  }

  @override
  String paywallTrialYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años gratis',
      one: '1 año gratis',
    );
    return '$_temp0';
  }

  @override
  String get paywallContinue => 'Continuar';

  @override
  String get paywallRestore => 'Restaurar compras';

  @override
  String get paywallRestoreNothing =>
      'No hemos encontrado compras anteriores con esta cuenta de la tienda.';

  @override
  String get paywallLegal =>
      'La suscripción se renueva automáticamente al mismo precio salvo que la canceles al menos 24 horas antes de que termine el periodo. Puedes gestionarla o cancelarla en los ajustes de tu cuenta de la App Store o de Google Play.';

  @override
  String get paywallUnavailable =>
      'Las compras no están disponibles en este momento. Inténtalo más tarde.';

  @override
  String get paywallPurchaseFailed =>
      'No se ha podido completar la compra. No se te ha cobrado nada.';

  @override
  String get paywallWelcome =>
      '¡Ya eres Premium! Gracias por apoyar Constanza.';

  @override
  String get paywallActive => 'Tu suscripción Premium está activa.';

  @override
  String get paywallManage => 'Gestionar suscripción';

  @override
  String get premiumCustomization => 'Hazla tuya';

  @override
  String get premiumCustomizationBody =>
      'Tema oscuro, iconos, avatares y mensajes propios.';

  @override
  String get profilePremium => 'Constanza Premium';

  @override
  String get profilePremiumSubtitleFree => 'Descubre los planes';

  @override
  String get profilePremiumSubtitleActive => 'ACTIVADA';

  @override
  String get profilePremiumBadgeLabel => 'Cuenta Premium';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileChangePasswordSubtitle =>
      'Confirma la actual y elige una nueva';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profileDeleteAccountSubtitle =>
      'Borra tu cuenta y todos tus datos';

  @override
  String get profilePrivacyPolicy => 'Política de privacidad';

  @override
  String get profilePrivacyPolicySubtitle => 'Qué datos guardamos y para qué';

  @override
  String get profileTerms => 'Términos y condiciones';

  @override
  String get profileTermsSubtitle => 'Condiciones de uso de Constanza';

  @override
  String get profileLegal => 'Legal';

  @override
  String get profileSupport => 'Ayúdanos a mejorar';

  @override
  String get profileFeedback => '¿Qué echas de menos?';

  @override
  String get profileFeedbackSubtitle =>
      'Cuéntanos ideas o funciones que te gustaría ver';

  @override
  String get profileReportProblem => 'Algo no funciona';

  @override
  String get profileReportProblemSubtitle => 'Escríbenos y lo revisamos';

  @override
  String get supportFeedbackSubject => 'Idea para Constanza';

  @override
  String supportFeedbackBody(String platform) {
    return '¡Hola, equipo de Constanza!\n\nLo que echo de menos en la app:\n\n\n— Enviado desde $platform';
  }

  @override
  String get supportProblemSubject => 'Problema en Constanza';

  @override
  String supportProblemBody(String platform) {
    return '¡Hola, equipo de Constanza!\n\nQué ha pasado:\n\n\nQué esperaba:\n\n\n— Enviado desde $platform';
  }

  @override
  String supportEmailCopied(String email) {
    return 'No hay ninguna app de correo. Hemos copiado $email para que nos escribas desde donde quieras.';
  }

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get changePasswordTitle => 'Cambia tu contraseña';

  @override
  String get changePasswordHelper =>
      'Elige una contraseña segura que puedas recordar.';

  @override
  String get changePasswordCatImageLabel =>
      'Gato de Constanza protegiendo tu cuenta';

  @override
  String get savePassword => 'Guardar contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get passwordChanged => 'Contraseña actualizada';

  @override
  String get deleteAccountTitle => '¿De verdad quieres eliminar tu cuenta?';

  @override
  String get deleteAccountBody =>
      'Se borrarán para siempre tu cuenta, tus hábitos, tu historial, tus rachas, tus comodines y tus datos de peso. No se puede deshacer.';

  @override
  String get deleteAccountSubscriptionNote =>
      'Si tienes una suscripción Premium, cancélala también en la App Store o en Google Play: borrar la cuenta no la cancela.';

  @override
  String get deleteAccountPasswordHint =>
      'Escribe tu contraseña para confirmar';

  @override
  String get deleteAccountConfirm => 'Eliminar definitivamente';

  @override
  String get accountDeleted => 'Tu cuenta se ha eliminado';

  @override
  String get linkOpenFailed => 'No se ha podido abrir el enlace';

  @override
  String get save => 'Guardar';

  @override
  String get habitCalendarsEmpty =>
      'Aún no tienes hábitos. Crea el primero y aquí verás sus calendarios.';

  @override
  String get weightDeleteEntry => 'Borrar medición';

  @override
  String get weightDeleteConfirmTitle => '¿Borrar esta medición?';

  @override
  String get weightDeleteConfirmBody =>
      'Se eliminará de tu historial y de la gráfica. No se puede deshacer.';

  @override
  String get weightEntryDeleted => 'Medición borrada';

  @override
  String get errorLoadFailed =>
      'No hemos podido cargar tus datos. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get errorActionFailed =>
      'No se ha podido completar. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

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
  String get statsQuitHabits => 'Logros al dejar hábitos';

  @override
  String get statsQuitCurrent => 'Tiempo actual';

  @override
  String get statsQuitBest => 'Mejor récord';

  @override
  String statsQuitRestarts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevos comienzos',
      one: '1 nuevo comienzo',
      zero: 'Sin nuevos comienzos',
    );
    return '$_temp0';
  }

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

  @override
  String get navTools => 'Herramientas';

  @override
  String get toolsTitle => 'Herramientas';

  @override
  String get toolsSubtitle => 'Utilidades para tu día a día';

  @override
  String get toolsNoticeBody =>
      'Las herramientas no afectan a tu racha: son ayudas para organizar tu día.';

  @override
  String get toolsNoticeDismiss => 'Entendido';

  @override
  String get toolsComingSoon => 'Próximamente';

  @override
  String get toolTasksTitle => 'Tareas';

  @override
  String get toolTasksSubtitle => 'Lo que tienes que hacer, día a día';

  @override
  String get toolPomodoroTitle => 'Pomodoro';

  @override
  String get toolPomodoroSubtitle => 'Concéntrate por bloques';

  @override
  String get toolShoppingTitle => 'Compra';

  @override
  String get toolShoppingSubtitle => 'Para no olvidar nada';

  @override
  String get toolFinanceTitle => 'Finanzas';

  @override
  String get toolFinanceSubtitle => 'Tu dinero bajo control';

  @override
  String get toolStepsTitle => 'Pasos';

  @override
  String get toolStepsSubtitle => 'Lo que caminas cada día';

  @override
  String get toolsPremiumTitle => 'Herramientas Premium';

  @override
  String get toolsPremiumBody =>
      'Tareas, Pomodoro, lista de la compra, finanzas y pasos forman parte de Constanza Premium.';

  @override
  String get toolsPremiumBenefit1 => 'Las cinco herramientas, sin límites';

  @override
  String get toolsPremiumBenefit2 => 'Sincronizadas en todos tus dispositivos';

  @override
  String get toolsPremiumBenefit3 => 'Sin anuncios y con todas las novedades';

  @override
  String get tasksTitle => 'Tareas';

  @override
  String get tasksViewDay => 'Día';

  @override
  String get tasksViewUpcoming => 'Próximas';

  @override
  String get tasksViewUndated => 'Sin fecha';

  @override
  String get tasksEmptyDay => 'Nada pendiente para este día';

  @override
  String get tasksEmptyUpcoming =>
      'No tienes tareas programadas para los próximos días';

  @override
  String get tasksEmptyUndated => 'No hay tareas sin fecha';

  @override
  String get tasksCompletedSection => 'Completadas';

  @override
  String get tasksNewTask => 'Nueva tarea';

  @override
  String get tasksEditTask => 'Editar tarea';

  @override
  String get tasksFormHelper =>
      'Ponle un título claro; la fecha y la hora son opcionales.';

  @override
  String get tasksTitleLabel => 'Título';

  @override
  String get tasksNoteLabel => 'Nota (opcional)';

  @override
  String get tasksDateLabel => 'Fecha';

  @override
  String get tasksDateNone => 'Sin fecha';

  @override
  String get tasksDatePick => 'Elegir';

  @override
  String get tasksTimeLabel => 'Hora';

  @override
  String get tasksTimeNone => 'Sin hora';

  @override
  String get tasksTimeNeedsDate => 'Pon una fecha para elegir hora';

  @override
  String get tasksPriorityLabel => 'Prioridad';

  @override
  String get tasksPriorityLow => 'Baja';

  @override
  String get tasksPriorityNormal => 'Media';

  @override
  String get tasksPriorityMedium => 'Media';

  @override
  String get tasksPriorityHigh => 'Alta';

  @override
  String get tasksPriorityUrgent => 'Urgente';

  @override
  String get tasksSave => 'Guardar tarea';

  @override
  String get tasksCreated => 'Tarea creada';

  @override
  String get tasksUpdated => 'Tarea actualizada';

  @override
  String get tasksDeleted => 'Tarea eliminada';

  @override
  String get tasksUndo => 'Deshacer';

  @override
  String get tasksDeleteTitle => '¿Eliminar esta tarea?';

  @override
  String get tasksDeleteBody => 'Se borrará con su nota. No afecta a tu racha.';

  @override
  String tasksMarkDone(String title) {
    return 'Marcar $title como hecha';
  }

  @override
  String tasksMarkUndone(String title) {
    return 'Marcar $title como pendiente';
  }

  @override
  String tasksRolledFrom(String date) {
    return 'desde el $date';
  }

  @override
  String get tasksToday => 'Hoy';

  @override
  String get tasksTomorrow => 'Mañana';

  @override
  String get tasksYesterday => 'Ayer';

  @override
  String get tasksOverdueBadge => 'Atrasada';

  @override
  String tasksRolloverTitle(int count) {
    return 'Tienes $count tareas sin terminar';
  }

  @override
  String get tasksRolloverBody =>
      'Son de días anteriores. Elige cuáles pasan a hoy; las demás se quedan donde están.';

  @override
  String get tasksRolloverAll => 'Pasar todas a hoy';

  @override
  String get tasksRolloverSelected => 'Pasar las seleccionadas';

  @override
  String get tasksRolloverDeleteSelected => 'Descartar seleccionadas';

  @override
  String get tasksRolloverDeleteTitle => '¿Descartar estas tareas?';

  @override
  String tasksRolloverDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Estas $count tareas pendientes se eliminarán definitivamente.',
      one: 'Esta tarea pendiente se eliminará definitivamente.',
    );
    return '$_temp0';
  }

  @override
  String get tasksRolloverDeleteConfirm => 'Descartar';

  @override
  String tasksRolloverDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas descartadas',
      one: 'Tarea descartada',
    );
    return '$_temp0';
  }

  @override
  String get tasksRolloverNotNow => 'Ahora no';

  @override
  String tasksRolloverDone(int count) {
    return '$count tareas pasadas a hoy';
  }

  @override
  String get tasksReminderTitle => 'Tarea pendiente';

  @override
  String tasksPendingTodayWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pendientes hoy',
      one: '1 pendiente hoy',
      zero: 'Nada pendiente hoy',
    );
    return '$_temp0';
  }

  @override
  String tasksPendingWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas pendientes',
      one: '1 tarea pendiente',
      zero: 'Nada pendiente',
    );
    return '$_temp0';
  }

  @override
  String get tasksSaveError =>
      'No se pudo guardar la tarea. Inténtalo de nuevo.';

  @override
  String get pomodoroTitle => 'Pomodoro';

  @override
  String get pomodoroPhaseWork => 'Concentración';

  @override
  String get pomodoroPhaseShortBreak => 'Descanso';

  @override
  String get pomodoroPhaseLongBreak => 'Descanso largo';

  @override
  String pomodoroCycleProgress(int current, int total) {
    return 'Pomodoro $current de $total';
  }

  @override
  String get pomodoroStart => 'Empezar';

  @override
  String get pomodoroPause => 'Pausar';

  @override
  String get pomodoroResume => 'Reanudar';

  @override
  String get pomodoroReset => 'Reiniciar fase';

  @override
  String get pomodoroSkip => 'Saltar fase';

  @override
  String get pomodoroLabelHint => '¿En qué trabajas?';

  @override
  String get pomodoroTodayLabel => 'Hoy';

  @override
  String get pomodoroWeekLabel => 'Esta semana';

  @override
  String pomodoroTodayDetailWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pomodoros',
      one: '1 pomodoro',
    );
    return '$_temp0';
  }

  @override
  String pomodoroMinutesWithCount(int count) {
    return '$count min';
  }

  @override
  String get pomodoroFocusMinutes => 'de concentración';

  @override
  String get pomodoroSessionsToday => 'Sesiones de hoy';

  @override
  String get pomodoroSessionsEmpty =>
      'Aún no has completado ningún pomodoro hoy';

  @override
  String get pomodoroSessionNoLabel => 'Sin etiqueta';

  @override
  String get pomodoroSettingsTitle => 'Ajustes del Pomodoro';

  @override
  String get pomodoroSettingWork => 'Concentración';

  @override
  String get pomodoroSettingShortBreak => 'Descanso corto';

  @override
  String get pomodoroSettingLongBreak => 'Descanso largo';

  @override
  String get pomodoroSettingPerCycle => 'Pomodoros por ciclo';

  @override
  String get pomodoroSettingAutoBreaks => 'Iniciar descansos automáticamente';

  @override
  String get pomodoroSettingAutoWork => 'Iniciar concentración automáticamente';

  @override
  String get pomodoroSettingSound => 'Sonido al terminar';

  @override
  String get pomodoroSettingVibration => 'Vibración';

  @override
  String get pomodoroSettingsSave => 'Guardar ajustes';

  @override
  String get pomodoroSettingsSaved => 'Ajustes guardados';

  @override
  String get pomodoroClearHistory => 'Borrar historial';

  @override
  String get pomodoroClearHistoryTitle => '¿Borrar todas las sesiones?';

  @override
  String get pomodoroClearHistoryBody =>
      'Se eliminarán todos los pomodoros registrados. Los ajustes se conservan.';

  @override
  String get pomodoroHistoryCleared => 'Historial borrado';

  @override
  String get pomodoroWorkDoneTitle => '¡Concentración terminada!';

  @override
  String pomodoroWorkDoneBody(int minutes) {
    return 'Toca un descanso de $minutes min';
  }

  @override
  String get pomodoroBreakDoneTitle => 'Descanso terminado';

  @override
  String pomodoroBreakDoneBody(int minutes) {
    return 'Vuelve a la concentración: $minutes min';
  }

  @override
  String pomodoroTodayWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pomodoros hoy',
      one: '1 pomodoro hoy',
      zero: 'Ningún pomodoro hoy',
    );
    return '$_temp0';
  }

  @override
  String get pomodoroMinutesLabel => 'minutos';

  @override
  String get shoppingTitle => 'Lista de la compra';

  @override
  String get shoppingListsTitle => 'Mis listas';

  @override
  String get shoppingNewList => 'Nueva lista';

  @override
  String get shoppingCreateList => 'Crear una lista';

  @override
  String get shoppingRenameList => 'Cambiar nombre';

  @override
  String get shoppingListName => 'Nombre de la lista';

  @override
  String get shoppingDeleteList => 'Eliminar lista';

  @override
  String get shoppingDeleteListTitle => '¿Eliminar esta lista?';

  @override
  String shoppingDeleteListBody(String name) {
    return 'Se eliminarán $name y todos sus artículos.';
  }

  @override
  String shoppingProgress(int bought, int total) {
    return '$bought de $total comprados';
  }

  @override
  String get shoppingShare => 'Compartir lista';

  @override
  String get shoppingShareImage => 'Imagen';

  @override
  String get shoppingShareText => 'Texto';

  @override
  String get shoppingAddHint => 'Añadir artículo…';

  @override
  String get shoppingAdd => 'Añadir';

  @override
  String get shoppingToBuy => 'Por comprar';

  @override
  String get shoppingInCart => 'En el carrito';

  @override
  String get shoppingEmpty =>
      'Tu lista está vacía. Escribe arriba lo que necesitas.';

  @override
  String get shoppingEmptyTitle => 'Tu lista está vacía';

  @override
  String get shoppingEmptyBody => 'Añade lo que necesitas y aparecerá aquí.';

  @override
  String get shoppingCompletedTitle => '¡Genial, ya lo tienes todo!';

  @override
  String get shoppingCompletedBody =>
      'Has completado todos los artículos de esta lista.';

  @override
  String get shoppingClearBought => 'Vaciar comprados';

  @override
  String get shoppingClearAll => 'Vaciar todo';

  @override
  String get shoppingClearBoughtTitle => '¿Quitar los artículos comprados?';

  @override
  String get shoppingClearBoughtBody =>
      'Se eliminarán los artículos marcados en el carrito.';

  @override
  String get shoppingClearAllTitle => '¿Vaciar toda la lista?';

  @override
  String get shoppingClearAllBody =>
      'Se eliminarán todos los artículos, comprados o no.';

  @override
  String get shoppingCleared => 'Lista actualizada';

  @override
  String get shoppingEditItem => 'Editar artículo';

  @override
  String get shoppingNameLabel => 'Artículo';

  @override
  String get shoppingQuantityLabel => 'Cantidad (opcional)';

  @override
  String get shoppingNoteLabel => 'Nota (opcional)';

  @override
  String get shoppingSave => 'Guardar';

  @override
  String get shoppingDeleteTitle => '¿Eliminar este artículo?';

  @override
  String shoppingMarkBought(String name) {
    return 'Marcar $name como comprado';
  }

  @override
  String shoppingMarkPending(String name) {
    return 'Devolver $name a la lista';
  }

  @override
  String shoppingPendingWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por comprar',
      one: '1 por comprar',
      zero: 'Nada por comprar',
    );
    return '$_temp0';
  }

  @override
  String shoppingQuantityShort(int count) {
    return 'x$count';
  }

  @override
  String get shoppingSaveError =>
      'No se pudo guardar el artículo. Inténtalo de nuevo.';

  @override
  String get financeTitle => 'Finanzas';

  @override
  String get financeMonthBalance => 'Saldo del mes';

  @override
  String get financeIncome => 'Ingresos';

  @override
  String get financeExpenses => 'Gastos';

  @override
  String financeFixedProgress(int done, int total) {
    return 'Fijos registrados $done de $total';
  }

  @override
  String get financePreviousMonth => 'Mes anterior';

  @override
  String get financeNextMonth => 'Mes siguiente';

  @override
  String get financeTabMovements => 'Movimientos';

  @override
  String get financeTabFixed => 'Fijos';

  @override
  String get financeTabInvestments => 'Inversiones';

  @override
  String get financeTabPending => 'Pendientes';

  @override
  String get financeRecentMovements => 'Últimos movimientos';

  @override
  String get financeMovementsEmpty =>
      'Sin movimientos este mes. Apunta el primero.';

  @override
  String get financeFixedEmpty =>
      'Sin gastos fijos. Añade los que se repiten cada mes.';

  @override
  String get financeInvestmentsEmpty =>
      'Sin inversiones. Apunta lo que tienes invertido y actualiza su valor cuando quieras.';

  @override
  String get financePendingEmpty =>
      'Sin compras pendientes. Anota lo que quieres comprar más adelante.';

  @override
  String get financeNewMovement => 'Nuevo movimiento';

  @override
  String get financeEditMovement => 'Editar movimiento';

  @override
  String get financeNewFixed => 'Nuevo gasto fijo';

  @override
  String get financeEditFixed => 'Editar gasto fijo';

  @override
  String get financeNewInvestment => 'Nueva inversión';

  @override
  String get financeEditInvestment => 'Editar inversión';

  @override
  String get financeNewPending => 'Nueva compra pendiente';

  @override
  String get financeEditPending => 'Editar compra pendiente';

  @override
  String get financeTypeExpense => 'Gasto';

  @override
  String get financeTypeIncome => 'Ingreso';

  @override
  String get financeAmountLabel => 'Importe';

  @override
  String get financeConceptLabel => 'Concepto';

  @override
  String get financeCategoryLabel => 'Categoría';

  @override
  String get financeDateLabel => 'Fecha';

  @override
  String get financeNoteLabel => 'Nota (opcional)';

  @override
  String get financeNameLabel => 'Nombre';

  @override
  String get financeDayOfMonthLabel => 'Día del mes';

  @override
  String financeDayOfMonth(int day) {
    return 'día $day de cada mes';
  }

  @override
  String get financeActiveLabel => 'Activo';

  @override
  String get financeInactive => 'Inactivo';

  @override
  String financeLogThisMonth(String month) {
    return 'Registrar en $month';
  }

  @override
  String get financeLoggedThisMonth => 'Registrado ✓';

  @override
  String get financeFixedTotal => 'Comprometido al mes';

  @override
  String get financeInvestmentTypeLabel => 'Tipo';

  @override
  String get financeContributedLabel => 'Aportado';

  @override
  String get financeCurrentValueLabel => 'Valor actual';

  @override
  String get financeUpdateValue => 'Actualizar valor';

  @override
  String get financeContribute => 'Aportar';

  @override
  String get financeContributionAmount => 'Cantidad a aportar';

  @override
  String get financeContributionAsMovement => 'Registrar también como gasto';

  @override
  String get financeReturn => 'Rentabilidad';

  @override
  String get financeTotalContributed => 'Total aportado';

  @override
  String get financeTotalValue => 'Valor total';

  @override
  String get financeEstimatedLabel => 'Importe estimado';

  @override
  String get financeTargetDateLabel => 'Fecha objetivo (opcional)';

  @override
  String get financeNoTargetDate => 'Sin fecha';

  @override
  String get financePriorityLabel => 'Prioridad';

  @override
  String get financePriorityLow => 'Baja';

  @override
  String get financePriorityNormal => 'Normal';

  @override
  String get financePriorityHigh => 'Alta';

  @override
  String get financeMarkBought => 'Comprado';

  @override
  String get financeBoughtTitle => '¿Cuánto ha costado?';

  @override
  String get financeBoughtHelper => 'Se registrará como gasto de este mes.';

  @override
  String get financeBoughtSection => 'Compradas';

  @override
  String get financeEstimatedTotal => 'Total estimado';

  @override
  String get financeSave => 'Guardar';

  @override
  String get financeSaved => 'Guardado';

  @override
  String get financeDeleteTitle => '¿Eliminar este elemento?';

  @override
  String get financeDeleteBody => 'Los movimientos ya registrados no se tocan.';

  @override
  String get financeSettingsTitle => 'Ajustes de Finanzas';

  @override
  String get financeCurrencyLabel => 'Moneda';

  @override
  String get financeCurrencyHelper =>
      'Cambiar la moneda no convierte los importes: solo cambia el símbolo.';

  @override
  String get financeMonthStartLabel => 'Día de inicio del mes';

  @override
  String get financeSettingsSave => 'Guardar ajustes';

  @override
  String get financeCategoryHome => 'Casa';

  @override
  String get financeCategoryFood => 'Comida';

  @override
  String get financeCategoryTransport => 'Transporte';

  @override
  String get financeCategoryLeisure => 'Ocio';

  @override
  String get financeCategoryHealth => 'Salud';

  @override
  String get financeCategoryClothes => 'Ropa';

  @override
  String get financeCategorySubscriptions => 'Suscripciones';

  @override
  String get financeCategoryGifts => 'Regalos';

  @override
  String get financeCategorySalary => 'Nómina';

  @override
  String get financeCategoryInvestment => 'Inversión';

  @override
  String get financeCategoryOther => 'Otros';

  @override
  String get financeInvestmentFunds => 'Fondos';

  @override
  String get financeInvestmentStocks => 'Acciones';

  @override
  String get financeInvestmentCrypto => 'Cripto';

  @override
  String get financeInvestmentDeposit => 'Depósito';

  @override
  String get financeInvestmentProperty => 'Inmueble';

  @override
  String get financeInvestmentOther => 'Otro';

  @override
  String financeMonthSummary(String balance) {
    return 'Saldo $balance';
  }

  @override
  String get financeSaveError => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get financeToday => 'Hoy';

  @override
  String get financeYesterday => 'Ayer';

  @override
  String get stepsTitle => 'Pasos';

  @override
  String get stepsConsentTitle => 'Tus pasos';

  @override
  String get stepsConsentAccept => 'Permitir';

  @override
  String get stepsConsentLater => 'Ahora no';

  @override
  String get stepsNoPermissionTitle => 'Sin permiso de salud';

  @override
  String get stepsGrantPermission => 'Dar permiso';

  @override
  String stepsOfGoal(String goal) {
    return 'de $goal';
  }

  @override
  String get stepsGoalReached => '¡Objetivo conseguido!';

  @override
  String get stepsDistanceLabel => 'Distancia';

  @override
  String stepsDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get stepsDistanceEstimated => 'estimada';

  @override
  String get stepsAverageLabel => 'Media 7 días';

  @override
  String get stepsAverageDetail => 'pasos al día';

  @override
  String get stepsWeekTitle => 'Esta semana';

  @override
  String get stepsChangeGoal => 'Cambiar objetivo';

  @override
  String get stepsGoalTitle => 'Objetivo diario';

  @override
  String get stepsGoalHelper => 'Pasos que quieres dar cada día.';

  @override
  String get stepsGoalSave => 'Guardar objetivo';

  @override
  String get stepsGoalSaved => 'Objetivo guardado';

  @override
  String stepsUpdatedAt(String time) {
    return 'Última actualización $time';
  }

  @override
  String get stepsRefresh => 'Actualizar';

  @override
  String get stepsTimezoneHint =>
      'El día se corta según la zona horaria de tu perfil.';

  @override
  String stepsSummary(String steps, String goal) {
    return '$steps / $goal';
  }

  @override
  String get stepsSummaryNoPermission => 'Sin permiso';

  @override
  String get stepsReadError =>
      'No se pudieron leer los pasos. Inténtalo de nuevo.';

  @override
  String get stepsConsentBody =>
      'Constanza contará tus pasos con el sensor de movimiento del propio móvil, sin depender de otras apps. El total de cada día se guarda en tu cuenta para que puedas ver tu evolución desde que usas Constanza. No se comparte con nadie y puedes borrarlo cuando quieras.';

  @override
  String get stepsNoPermissionBody =>
      'Para contar tus pasos, Constanza necesita acceso al sensor de movimiento. iOS: Ajustes › Privacidad › Movimiento y forma física › Constanza. Android: Ajustes › Aplicaciones › Constanza › Permisos › Actividad física.';

  @override
  String get stepsUnavailableTitle => 'Sin sensor de pasos';

  @override
  String get stepsUnavailableBody =>
      'Este dispositivo no tiene contador de pasos. Podrás ver aquí el histórico guardado en tu cuenta desde otros dispositivos.';

  @override
  String get stepsSummaryUnavailable => 'Sin sensor';

  @override
  String get stepsCaloriesLabel => 'Calorías';

  @override
  String stepsCaloriesKcal(String kcal) {
    return '$kcal kcal';
  }

  @override
  String get stepsEstimatedShort => 'estimación';

  @override
  String get stepsStreakLabel => 'Racha de objetivo';

  @override
  String stepsStreakDaysWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get stepsStreakDetail => 'seguidos cumpliendo';

  @override
  String stepsRemainingWithCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Te faltan $countString pasos',
      one: 'Te falta 1 paso',
    );
    return '$_temp0';
  }

  @override
  String get stepsHistoryTitle => 'Tu evolución';

  @override
  String get stepsRangeWeek => '7 días';

  @override
  String get stepsRangeMonth => '30 días';

  @override
  String get stepsRangeYear => '1 año';

  @override
  String get stepsRangeAll => 'Todo';

  @override
  String get stepsHistoryEmpty =>
      'Todavía no hay días guardados. En cuanto camines con Constanza, aparecerán aquí.';

  @override
  String get stepsTotalLabel => 'Total';

  @override
  String get stepsDailyAverageLabel => 'Media diaria';

  @override
  String get stepsBestDayLabel => 'Mejor día';

  @override
  String get stepsGoalDaysLabel => 'Días con objetivo';

  @override
  String stepsGoalDaysValue(int done, int total) {
    return '$done de $total';
  }

  @override
  String get stepsDistanceTotalLabel => 'Distancia';

  @override
  String get stepsCaloriesTotalLabel => 'Calorías';

  @override
  String get stepsRecentDays => 'Días recientes';

  @override
  String get stepsByMonth => 'Por meses';

  @override
  String stepsStepsWithCount(String count) {
    return '$count pasos';
  }

  @override
  String stepsSinceLabel(String date) {
    return 'Desde el $date';
  }

  @override
  String get stepsGoalCelebrationTitle => '¡Enhorabuena!';

  @override
  String stepsGoalCelebrationBody(String steps) {
    return 'Has alcanzado tu objetivo con $steps pasos hoy. ¡Sigue así!';
  }

  @override
  String get stepsGoalCelebrationAction => '¡Genial!';

  @override
  String get stepsCelebrationCatImageLabel => 'Gato celebrando';

  @override
  String get stepsCountingLive => 'Contando con el sensor del móvil';

  @override
  String get stepsSensorNote =>
      'Los pasos se cuentan aunque la app esté cerrada. Ábrela de vez en cuando para guardar el total del día.';
}
