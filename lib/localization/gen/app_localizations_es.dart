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
    return '¡Buenos días, $name! 👋';
  }

  @override
  String goodAfternoon(String name) {
    return '¡Buenas tardes, $name! 👋';
  }

  @override
  String goodEvening(String name) {
    return '¡Buenas noches, $name! 👋';
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
  String get navHabits => 'Hábitos';

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
  String get editHabitWarningTitle => '¿Cambiar frecuencia?';

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
  String get allHabitsTitle => 'Mis hábitos';

  @override
  String get habitCalendarsAction => 'Calendarios';

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
  String get statsWeeklyProgress => 'Tu progreso esta semana';

  @override
  String get statsMonthlyProgress => 'Tu progreso este mes';

  @override
  String get statsYearlyProgress => 'Tu progreso este año';

  @override
  String get statsSeeCalendar => 'Ver calendario';

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
  String get allHabitsCompletedCelebration => '¡Día completado! Eres imparable';

  @override
  String get editHabitsHint =>
      'Para editar tus hábitos, ve a la pestaña Hábitos.';
}
