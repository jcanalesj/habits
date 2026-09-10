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
  String get generalStreak => 'Racha general';

  @override
  String get consecutiveDays => 'días consecutivos';

  @override
  String get freeWildcardAvailable => '1 comodín gratis disponible esta semana';

  @override
  String get amazing => '¡Increíble!';

  @override
  String get keepItUp => 'Sigue así';

  @override
  String get streaksByAmbito => 'Rachas por ámbito';

  @override
  String get seeAll => 'Ver todos';

  @override
  String get days => 'días';

  @override
  String get myHabits => 'Mis hábitos';

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
  String restDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descansos',
      one: '1 descanso',
    );
    return '$_temp0';
  }

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
      'Ábrelo desde tu correo y vuelve aquí para continuar.';

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
      'Ya existe una cuenta con ese correo.';

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
}
