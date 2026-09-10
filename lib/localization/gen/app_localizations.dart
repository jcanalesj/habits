import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Constanza'**
  String get appTitle;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}! 👋'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}! 👋'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}! 👋'**
  String goodEvening(String name);

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Small actions, big changes.'**
  String get tagline;

  /// No description provided for @generalStreak.
  ///
  /// In en, this message translates to:
  /// **'Overall streak'**
  String get generalStreak;

  /// No description provided for @consecutiveDays.
  ///
  /// In en, this message translates to:
  /// **'consecutive days'**
  String get consecutiveDays;

  /// No description provided for @freeWildcardAvailable.
  ///
  /// In en, this message translates to:
  /// **'1 free wildcard available this week'**
  String get freeWildcardAvailable;

  /// No description provided for @amazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing!'**
  String get amazing;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get keepItUp;

  /// No description provided for @streaksByAmbito.
  ///
  /// In en, this message translates to:
  /// **'Streaks by area'**
  String get streaksByAmbito;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @myHabits.
  ///
  /// In en, this message translates to:
  /// **'My habits'**
  String get myHabits;

  /// No description provided for @newHabit.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabit;

  /// No description provided for @seeAllMyHabits.
  ///
  /// In en, this message translates to:
  /// **'See all my habits'**
  String get seeAllMyHabits;

  /// No description provided for @noHabitsYet.
  ///
  /// In en, this message translates to:
  /// **'No habits yet. Create your first one with the + button.'**
  String get noHabitsYet;

  /// No description provided for @nextReminder.
  ///
  /// In en, this message translates to:
  /// **'Next reminder'**
  String get nextReminder;

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// No description provided for @markNow.
  ///
  /// In en, this message translates to:
  /// **'Mark now'**
  String get markNow;

  /// No description provided for @periodicityDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get periodicityDaily;

  /// No description provided for @periodicityWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodicityWeekly;

  /// No description provided for @periodicityMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodicityMonthly;

  /// No description provided for @periodicityYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodicityYearly;

  /// No description provided for @restDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rest day} other{{count} rest days}}'**
  String restDaysCount(int count);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get navHabits;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @createHabitComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create habit: coming soon'**
  String get createHabitComingSoon;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {error}'**
  String somethingWentWrong(String error);

  /// No description provided for @taglineLine1.
  ///
  /// In en, this message translates to:
  /// **'Small actions,'**
  String get taglineLine1;

  /// No description provided for @taglineLine2.
  ///
  /// In en, this message translates to:
  /// **'big changes.'**
  String get taglineLine2;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your account'**
  String get signInSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerAction;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start building your best self today.'**
  String get registerSubtitle;

  /// No description provided for @nicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nicknameLabel;

  /// No description provided for @nicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a nickname'**
  String get nicknameHint;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailExampleHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get emailExampleHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerPasswordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password again'**
  String get confirmPasswordHint;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyJoiner.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get privacyJoiner;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @nicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get nicknameRequired;

  /// No description provided for @registerInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get registerInvalidEmail;

  /// No description provided for @registerPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get registerPasswordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @acceptTermsError.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and privacy policy'**
  String get acceptTermsError;

  /// No description provided for @verifyLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification link to'**
  String get verifyLinkSent;

  /// No description provided for @verifyLinkInstructions.
  ///
  /// In en, this message translates to:
  /// **'Open it from your inbox and come back here to continue.'**
  String get verifyLinkInstructions;

  /// No description provided for @iHaveVerified.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iHaveVerified;

  /// No description provided for @notVerifiedYet.
  ///
  /// In en, this message translates to:
  /// **'It doesn\'t show as verified yet. Check your inbox and spam folder.'**
  String get notVerifiedYet;

  /// No description provided for @emailNotReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get emailNotReceived;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @resendEmailIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendEmailIn(int seconds);

  /// No description provided for @emailResent.
  ///
  /// In en, this message translates to:
  /// **'Email resent. It may take a few minutes to arrive.'**
  String get emailResent;

  /// No description provided for @useAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Use another account'**
  String get useAnotherAccount;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a link to create a new one.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, you\'ll receive a link to reset your password.'**
  String get resetLinkSent;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get backToSignIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @nicknameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Nickname can\'t be longer than 40 characters'**
  String get nicknameTooLong;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email.'**
  String get authErrorEmailAlreadyInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'The email address is not valid.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorUserDisabled.
  ///
  /// In en, this message translates to:
  /// **'This account has been disabled.'**
  String get authErrorUserDisabled;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a few minutes and try again.'**
  String get authErrorTooManyRequests;

  /// No description provided for @authErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get authErrorNetwork;

  /// No description provided for @authErrorRequiresRecentLogin.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again to continue.'**
  String get authErrorRequiresRecentLogin;

  /// No description provided for @authErrorNoSession.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get authErrorNoSession;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get authErrorUnknown;

  /// No description provided for @verifyAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your account'**
  String get verifyAccountTitle;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @brandFooter.
  ///
  /// In en, this message translates to:
  /// **'Your best version, every day.'**
  String get brandFooter;

  /// No description provided for @loadingYourBestVersion.
  ///
  /// In en, this message translates to:
  /// **'Loading your best version...'**
  String get loadingYourBestVersion;

  /// No description provided for @splashPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Small actions, big changes.'**
  String get splashPhrase1;

  /// No description provided for @splashPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Build who you want to be'**
  String get splashPhrase2;

  /// No description provided for @splashPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Every day counts, even if you can\'t feel it'**
  String get splashPhrase3;

  /// No description provided for @splashPhrase4.
  ///
  /// In en, this message translates to:
  /// **'Consistency isn\'t perfection, it\'s continuing.'**
  String get splashPhrase4;

  /// No description provided for @splashPhrase5.
  ///
  /// In en, this message translates to:
  /// **'Today is a good day to keep going'**
  String get splashPhrase5;

  /// Single-letter initials for Monday through Sunday, comma-separated
  ///
  /// In en, this message translates to:
  /// **'M,T,W,T,F,S,S'**
  String get weekdayInitials;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
