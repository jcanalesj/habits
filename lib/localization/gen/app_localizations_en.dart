// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Constanza';

  @override
  String goodMorning(String name) {
    return 'Good morning, $name! 👋';
  }

  @override
  String goodAfternoon(String name) {
    return 'Good afternoon, $name! 👋';
  }

  @override
  String goodEvening(String name) {
    return 'Good evening, $name! 👋';
  }

  @override
  String get tagline => 'Small actions, big changes.';

  @override
  String get generalStreak => 'Overall streak';

  @override
  String get consecutiveDays => 'consecutive days';

  @override
  String get freeWildcardAvailable => '1 free wildcard available this week';

  @override
  String get amazing => 'Amazing!';

  @override
  String get keepItUp => 'Keep it up';

  @override
  String get streaksByAmbito => 'Streaks by area';

  @override
  String get seeAll => 'See all';

  @override
  String get days => 'days';

  @override
  String get myHabits => 'My habits';

  @override
  String get newHabit => 'New habit';

  @override
  String get seeAllMyHabits => 'See all my habits';

  @override
  String get noHabitsYet =>
      'No habits yet. Create your first one with the + button.';

  @override
  String get nextReminder => 'Next reminder';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String get markNow => 'Mark now';

  @override
  String get periodicityDaily => 'Daily';

  @override
  String get periodicityWeekly => 'Weekly';

  @override
  String get periodicityMonthly => 'Monthly';

  @override
  String get periodicityYearly => 'Yearly';

  @override
  String restDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rest days',
      one: '1 rest day',
    );
    return '$_temp0';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navHabits => 'Habits';

  @override
  String get navStats => 'Stats';

  @override
  String get navProfile => 'Profile';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get createHabitComingSoon => 'Create habit: coming soon';

  @override
  String somethingWentWrong(String error) {
    return 'Something went wrong: $error';
  }

  @override
  String get taglineLine1 => 'Small actions,';

  @override
  String get taglineLine2 => 'big changes.';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInSubtitle => 'Access your account';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get continueLabel => 'Continue';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get registerAction => 'Sign up';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Start building your best self today.';

  @override
  String get nicknameLabel => 'Nickname';

  @override
  String get nicknameHint => 'Choose a nickname';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailExampleHint => 'example@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get registerPasswordHint => 'At least 8 characters';

  @override
  String get confirmPasswordLabel => 'Confirm your password';

  @override
  String get confirmPasswordHint => 'Enter your password again';

  @override
  String get acceptTermsPrefix => 'I accept the ';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get privacyJoiner => ' and the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get registerButton => 'Sign up';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signInAction => 'Sign in';

  @override
  String get nicknameRequired => 'Enter a nickname';

  @override
  String get registerInvalidEmail => 'Enter a valid email address';

  @override
  String get registerPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get acceptTermsError => 'You must accept the terms and privacy policy';

  @override
  String get verifyLinkSent => 'We sent a verification link to';

  @override
  String get verifyLinkInstructions =>
      'Open it from your inbox and come back here to continue.';

  @override
  String get iHaveVerified => 'I\'ve verified my email';

  @override
  String get notVerifiedYet =>
      'It doesn\'t show as verified yet. Check your inbox and spam folder.';

  @override
  String get emailNotReceived => 'Didn\'t get it?';

  @override
  String get resendEmail => 'Resend email';

  @override
  String resendEmailIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get emailResent =>
      'Email resent. It may take a few minutes to arrive.';

  @override
  String get useAnotherAccount => 'Use another account';

  @override
  String get forgotPasswordTitle => 'Recover your password';

  @override
  String get forgotPasswordSubtitle =>
      'We\'ll send you a link to create a new one.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get resetLinkSent =>
      'If an account exists for that email, you\'ll receive a link to reset your password.';

  @override
  String get backToSignIn => 'Back to sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get nicknameTooLong => 'Nickname can\'t be longer than 40 characters';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorEmailAlreadyInUse =>
      'An account already exists for that email.';

  @override
  String get authErrorWeakPassword => 'The password is too weak.';

  @override
  String get authErrorInvalidEmail => 'The email address is not valid.';

  @override
  String get authErrorUserDisabled => 'This account has been disabled.';

  @override
  String get authErrorTooManyRequests =>
      'Too many attempts. Wait a few minutes and try again.';

  @override
  String get authErrorNetwork =>
      'No connection. Check your network and try again.';

  @override
  String get authErrorRequiresRecentLogin =>
      'For security, sign in again to continue.';

  @override
  String get authErrorNoSession => 'Your session has expired. Sign in again.';

  @override
  String get authErrorUnknown => 'Something went wrong. Try again.';

  @override
  String get verifyAccountTitle => 'Verify your account';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get brandFooter => 'Your best version, every day.';

  @override
  String get loadingYourBestVersion => 'Loading your best version...';

  @override
  String get splashPhrase1 => 'Small actions, big changes.';

  @override
  String get splashPhrase2 => 'Build who you want to be';

  @override
  String get splashPhrase3 => 'Every day counts, even if you can\'t feel it';

  @override
  String get splashPhrase4 =>
      'Consistency isn\'t perfection, it\'s continuing.';

  @override
  String get splashPhrase5 => 'Today is a good day to keep going';

  @override
  String get weekdayInitials => 'M,T,W,T,F,S,S';
}
