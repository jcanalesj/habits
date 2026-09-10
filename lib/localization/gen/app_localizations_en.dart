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
  String get verifyAccountTitle => 'Verify your account';

  @override
  String get verificationCodeSent => 'We sent a 6-digit code to';

  @override
  String codeExpiresIn(String time) {
    return 'The code will expire in $time minutes';
  }

  @override
  String get verifyButton => 'Verify';

  @override
  String get codeNotReceived => 'Didn\'t receive the code?';

  @override
  String get resendCode => 'Resend code';

  @override
  String get invalidVerificationCode => 'Enter the complete 6-digit code';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get signInError => 'Could not sign in. Try again.';

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
