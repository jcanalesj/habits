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
  /// **'Good morning, {name}!'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}!'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}!'**
  String goodEvening(String name);

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Small actions, big changes.'**
  String get tagline;

  /// No description provided for @welcomeMessage1.
  ///
  /// In en, this message translates to:
  /// **'A small step still counts.'**
  String get welcomeMessage1;

  /// No description provided for @welcomeMessage2.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats perfection.'**
  String get welcomeMessage2;

  /// No description provided for @welcomeMessage3.
  ///
  /// In en, this message translates to:
  /// **'Today is a good day to move forward a little.'**
  String get welcomeMessage3;

  /// No description provided for @welcomeMessage4.
  ///
  /// In en, this message translates to:
  /// **'Do it for your future self.'**
  String get welcomeMessage4;

  /// No description provided for @welcomeMessage5.
  ///
  /// In en, this message translates to:
  /// **'You don\'t need to do it perfectly, just do it.'**
  String get welcomeMessage5;

  /// No description provided for @welcomeMessage6.
  ///
  /// In en, this message translates to:
  /// **'Every habit today builds your tomorrow.'**
  String get welcomeMessage6;

  /// No description provided for @skipWelcome.
  ///
  /// In en, this message translates to:
  /// **'Skip welcome'**
  String get skipWelcome;

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

  /// No description provided for @habitFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get habitFilterAll;

  /// No description provided for @habitFilterDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitFilterDaily;

  /// No description provided for @habitFilterWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get habitFilterWeekly;

  /// No description provided for @habitFilterMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get habitFilterMonthly;

  /// No description provided for @habitFilterYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get habitFilterYearly;

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

  /// No description provided for @homeEmptyHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Your first small step starts here. Create it with the New habit button.'**
  String get homeEmptyHabitsBody;

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

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHabits.
  ///
  /// In en, this message translates to:
  /// **'My habits'**
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
  /// **'Open it from your inbox and come back here to continue. If you can\'t see it, check your spam folder.'**
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

  /// No description provided for @pendingVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account isn\'t verified yet'**
  String get pendingVerificationTitle;

  /// No description provided for @pendingVerificationBody.
  ///
  /// In en, this message translates to:
  /// **'This is the only step left. Open the link we sent you or request a new one; check your spam folder too.'**
  String get pendingVerificationBody;

  /// No description provided for @signInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInCta;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your change starts here'**
  String get welcomeTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'The best day to start was months ago.\nThe next best moment is '**
  String get welcomeMessage;

  /// No description provided for @welcomeMessageHighlight.
  ///
  /// In en, this message translates to:
  /// **'TODAY.'**
  String get welcomeMessageHighlight;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeStart;

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

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal space'**
  String get profileSubtitle;

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified account'**
  String get profileVerified;

  /// No description provided for @profileYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get profileYourProgress;

  /// No description provided for @profileHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get profileHealth;

  /// No description provided for @profileWeightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight and goals'**
  String get profileWeightTitle;

  /// No description provided for @profileWeightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get profileWeightSubtitle;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// No description provided for @weightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightTitle;

  /// No description provided for @weightHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your progress, step by step'**
  String get weightHeroTitle;

  /// No description provided for @weightHeroEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log your first measurement to start seeing your progress.'**
  String get weightHeroEmpty;

  /// No description provided for @weightHeroCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your latest measurement is {weight} kg.'**
  String weightHeroCurrent(String weight);

  /// No description provided for @weightHeroProgress.
  ///
  /// In en, this message translates to:
  /// **'You are {weight} kg away from your goal.'**
  String weightHeroProgress(String weight);

  /// No description provided for @weightCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get weightCurrent;

  /// No description provided for @weightInitial.
  ///
  /// In en, this message translates to:
  /// **'Starting weight'**
  String get weightInitial;

  /// No description provided for @weightGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get weightGoal;

  /// No description provided for @weightPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your goal'**
  String get weightPlanTitle;

  /// No description provided for @weightModifyGoals.
  ///
  /// In en, this message translates to:
  /// **'Edit goals'**
  String get weightModifyGoals;

  /// No description provided for @weightSinceStart.
  ///
  /// In en, this message translates to:
  /// **'since the start'**
  String get weightSinceStart;

  /// No description provided for @weightToGoal.
  ///
  /// In en, this message translates to:
  /// **'to go'**
  String get weightToGoal;

  /// No description provided for @weightGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal {weight} kg'**
  String weightGoalLabel(String weight);

  /// No description provided for @weightViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get weightViewAll;

  /// No description provided for @weightDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'{calories} recommended kcal/day'**
  String weightDailyCalories(int calories);

  /// No description provided for @weightSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get weightSetGoal;

  /// No description provided for @weightEvolution.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get weightEvolution;

  /// No description provided for @weightHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get weightHistory;

  /// No description provided for @weightRegister.
  ///
  /// In en, this message translates to:
  /// **'Log weight'**
  String get weightRegister;

  /// No description provided for @weightGoalDialog.
  ///
  /// In en, this message translates to:
  /// **'What is your target weight?'**
  String get weightGoalDialog;

  /// No description provided for @weightLogDialog.
  ///
  /// In en, this message translates to:
  /// **'Log your weight'**
  String get weightLogDialog;

  /// No description provided for @weightGoalDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Set the goal you want to work towards.'**
  String get weightGoalDialogHint;

  /// No description provided for @weightLogDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current weight to track your progress.'**
  String get weightLogDialogHint;

  /// No description provided for @weightValidRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 20 and 400 kg.'**
  String get weightValidRange;

  /// No description provided for @weightSaved.
  ///
  /// In en, this message translates to:
  /// **'Weight updated'**
  String get weightSaved;

  /// No description provided for @weightChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Add at least two measurements to see your progress.'**
  String get weightChartEmpty;

  /// No description provided for @weightHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any measurements yet. Log the first one whenever you like.'**
  String get weightHistoryEmpty;

  /// No description provided for @weightLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your weight data. Check your connection or try again.'**
  String get weightLoadError;

  /// No description provided for @weightRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get weightRetry;

  /// No description provided for @weightOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal plan'**
  String get weightOnboardingTitle;

  /// No description provided for @weightOnboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String weightOnboardingStep(int current, int total);

  /// No description provided for @weightQuestionGoal.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get weightQuestionGoal;

  /// No description provided for @weightQuestionGoalHint.
  ///
  /// In en, this message translates to:
  /// **'We will use it to tailor the estimate to what you want to achieve.'**
  String get weightQuestionGoalHint;

  /// No description provided for @weightGoalLose.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get weightGoalLose;

  /// No description provided for @weightGoalLoseHint.
  ///
  /// In en, this message translates to:
  /// **'Reduce weight progressively'**
  String get weightGoalLoseHint;

  /// No description provided for @weightGoalMaintain.
  ///
  /// In en, this message translates to:
  /// **'Maintain my weight'**
  String get weightGoalMaintain;

  /// No description provided for @weightGoalMaintainHint.
  ///
  /// In en, this message translates to:
  /// **'Stay close to my current weight'**
  String get weightGoalMaintainHint;

  /// No description provided for @weightGoalGain.
  ///
  /// In en, this message translates to:
  /// **'Gain weight'**
  String get weightGoalGain;

  /// No description provided for @weightGoalGainHint.
  ///
  /// In en, this message translates to:
  /// **'Increase weight gradually'**
  String get weightGoalGainHint;

  /// No description provided for @weightQuestionCurrent.
  ///
  /// In en, this message translates to:
  /// **'What is your current weight?'**
  String get weightQuestionCurrent;

  /// No description provided for @weightQuestionCurrentHint.
  ///
  /// In en, this message translates to:
  /// **'This will be the starting point for your progress.'**
  String get weightQuestionCurrentHint;

  /// No description provided for @weightRangeKg.
  ///
  /// In en, this message translates to:
  /// **'Between 20 and 400 kg'**
  String get weightRangeKg;

  /// No description provided for @weightQuestionTarget.
  ///
  /// In en, this message translates to:
  /// **'What weight do you want to reach?'**
  String get weightQuestionTarget;

  /// No description provided for @weightQuestionTargetHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a realistic goal that you can review later.'**
  String get weightQuestionTargetHint;

  /// No description provided for @weightTargetGoalHelper.
  ///
  /// In en, this message translates to:
  /// **'It must match the goal you selected'**
  String get weightTargetGoalHelper;

  /// No description provided for @weightTargetGoalError.
  ///
  /// In en, this message translates to:
  /// **'Check the weight: it does not match your selected goal'**
  String get weightTargetGoalError;

  /// No description provided for @weightQuestionAboutYou.
  ///
  /// In en, this message translates to:
  /// **'Tell us a little about yourself'**
  String get weightQuestionAboutYou;

  /// No description provided for @weightQuestionAboutYouHint.
  ///
  /// In en, this message translates to:
  /// **'Age and height are needed to estimate your energy requirements.'**
  String get weightQuestionAboutYouHint;

  /// No description provided for @weightYears.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get weightYears;

  /// No description provided for @weightAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get weightAge;

  /// No description provided for @weightHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get weightHeight;

  /// No description provided for @weightQuestionSex.
  ///
  /// In en, this message translates to:
  /// **'Biological data for the calculation'**
  String get weightQuestionSex;

  /// No description provided for @weightQuestionSexHint.
  ///
  /// In en, this message translates to:
  /// **'The equation uses this information to estimate resting metabolism. You may choose not to provide it.'**
  String get weightQuestionSexHint;

  /// No description provided for @weightSexFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get weightSexFemale;

  /// No description provided for @weightSexFemaleHint.
  ///
  /// In en, this message translates to:
  /// **'Use the female constant in the equation'**
  String get weightSexFemaleHint;

  /// No description provided for @weightSexMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get weightSexMale;

  /// No description provided for @weightSexMaleHint.
  ///
  /// In en, this message translates to:
  /// **'Use the male constant in the equation'**
  String get weightSexMaleHint;

  /// No description provided for @weightSexUnspecified.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get weightSexUnspecified;

  /// No description provided for @weightSexUnspecifiedHint.
  ///
  /// In en, this message translates to:
  /// **'An intermediate estimate will be used'**
  String get weightSexUnspecifiedHint;

  /// No description provided for @weightQuestionActivity.
  ///
  /// In en, this message translates to:
  /// **'What is your activity level?'**
  String get weightQuestionActivity;

  /// No description provided for @weightQuestionActivityHint.
  ///
  /// In en, this message translates to:
  /// **'Think of a typical week, including work, travel and exercise.'**
  String get weightQuestionActivityHint;

  /// No description provided for @weightActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary · little exercise'**
  String get weightActivitySedentary;

  /// No description provided for @weightActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Light · 1–3 days per week'**
  String get weightActivityLight;

  /// No description provided for @weightActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate · 3–5 days per week'**
  String get weightActivityModerate;

  /// No description provided for @weightActivityActive.
  ///
  /// In en, this message translates to:
  /// **'Active · 6–7 days per week'**
  String get weightActivityActive;

  /// No description provided for @weightActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very active · intense exercise or physical work'**
  String get weightActivityVeryActive;

  /// No description provided for @weightResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Your estimate is ready'**
  String get weightResultTitle;

  /// No description provided for @weightEstimatedCalories.
  ///
  /// In en, this message translates to:
  /// **'Estimated daily intake'**
  String get weightEstimatedCalories;

  /// No description provided for @weightPerDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get weightPerDay;

  /// No description provided for @weightMedicalDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This is an estimate for adults, not medical advice. Do not use it during pregnancy or breastfeeding, or with a medical condition or eating disorder; consult a healthcare professional.'**
  String get weightMedicalDisclaimer;

  /// No description provided for @weightStart.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get weightStart;

  /// No description provided for @profileCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get profileCurrentStreak;

  /// No description provided for @profileActiveHabits.
  ///
  /// In en, this message translates to:
  /// **'Active habits'**
  String get profileActiveHabits;

  /// No description provided for @profileProtectors.
  ///
  /// In en, this message translates to:
  /// **'Protectors'**
  String get profileProtectors;

  /// No description provided for @profileManage.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get profileManage;

  /// No description provided for @profileMyHabitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit and organize your habits'**
  String get profileMyHabitsSubtitle;

  /// No description provided for @profileCalendarsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View all your progress'**
  String get profileCalendarsSubtitle;

  /// No description provided for @profileStatsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze your consistency'**
  String get profileStatsSubtitle;

  /// No description provided for @profilePreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get profilePreferences;

  /// No description provided for @profileTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get profileTimezone;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileEditPersonalTitle.
  ///
  /// In en, this message translates to:
  /// **'Your profile, your way'**
  String get profileEditPersonalTitle;

  /// No description provided for @profileEditPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like us to call you?'**
  String get profileEditPersonalSubtitle;

  /// No description provided for @profileEditNameHint.
  ///
  /// In en, this message translates to:
  /// **'This name will appear in your achievements'**
  String get profileEditNameHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @profileViewStats.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get profileViewStats;

  /// No description provided for @profileTimezoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure your time zone'**
  String get profileTimezoneSubtitle;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your reminders'**
  String get profileNotificationsSubtitle;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get profileAppearance;

  /// No description provided for @profileAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Messages, welcome and appearance'**
  String get profileAppearanceSubtitle;

  /// No description provided for @personalizationHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Make Constanza support you in your own way'**
  String get personalizationHeroTitle;

  /// No description provided for @personalizationMotivation.
  ///
  /// In en, this message translates to:
  /// **'Motivational messages'**
  String get personalizationMotivation;

  /// No description provided for @personalizationDefaultPreview.
  ///
  /// In en, this message translates to:
  /// **'Today matters. Take it at your own pace ✨'**
  String get personalizationDefaultPreview;

  /// No description provided for @personalizationShowMessages.
  ///
  /// In en, this message translates to:
  /// **'Show messages'**
  String get personalizationShowMessages;

  /// No description provided for @personalizationShowMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'Include motivational phrases in your welcome'**
  String get personalizationShowMessagesHint;

  /// No description provided for @personalizationYourMessages.
  ///
  /// In en, this message translates to:
  /// **'Your phrases'**
  String get personalizationYourMessages;

  /// No description provided for @personalizationYourMessagesHint.
  ///
  /// In en, this message translates to:
  /// **'You know what motivates you. Write it your way.'**
  String get personalizationYourMessagesHint;

  /// No description provided for @personalizationNoMessages.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t added any personal phrases yet.'**
  String get personalizationNoMessages;

  /// No description provided for @personalizationAddMessage.
  ///
  /// In en, this message translates to:
  /// **'Add message'**
  String get personalizationAddMessage;

  /// No description provided for @personalizationEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get personalizationEditMessage;

  /// No description provided for @personalizationMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write a phrase that motivates you'**
  String get personalizationMessageHint;

  /// No description provided for @premiumMessageLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock more phrases with Premium'**
  String get premiumMessageLimitTitle;

  /// No description provided for @premiumMessageLimitBody.
  ///
  /// In en, this message translates to:
  /// **'The free version includes one personalized phrase. With Premium, you can save as many as you like.'**
  String get premiumMessageLimitBody;

  /// No description provided for @personalizationAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get personalizationAppearance;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @appearanceHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it a little more yours'**
  String get appearanceHeroTitle;

  /// No description provided for @appearanceHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Customize how Constanza feels as it joins you each day.'**
  String get appearanceHeroBody;

  /// No description provided for @appearancePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get appearancePreview;

  /// No description provided for @appearanceExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get appearanceExperience;

  /// No description provided for @appearanceReducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get appearanceReducedMotion;

  /// No description provided for @appearanceReducedMotionHint.
  ///
  /// In en, this message translates to:
  /// **'Follows your device accessibility setting'**
  String get appearanceReducedMotionHint;

  /// No description provided for @appearanceActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get appearanceActive;

  /// No description provided for @appearanceInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get appearanceInactive;

  /// No description provided for @appearanceTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get appearanceTheme;

  /// No description provided for @appearanceLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLightTheme;

  /// No description provided for @appearanceLightThemeHint.
  ///
  /// In en, this message translates to:
  /// **'Constanza\'s current style'**
  String get appearanceLightThemeHint;

  /// No description provided for @appearanceDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDarkTheme;

  /// No description provided for @appearanceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'A more comfortable experience at night'**
  String get appearanceComingSoon;

  /// No description provided for @appearanceSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get appearanceSoon;

  /// No description provided for @appearanceAppIcon.
  ///
  /// In en, this message translates to:
  /// **'App icon'**
  String get appearanceAppIcon;

  /// No description provided for @appearanceAppIconHint.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to recognize Constanza on your device.'**
  String get appearanceAppIconHint;

  /// No description provided for @appearanceClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get appearanceClassic;

  /// No description provided for @appearanceSystemHint.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion automatically follows your device accessibility settings.'**
  String get appearanceSystemHint;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSave;

  /// No description provided for @profileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// No description provided for @profileChooseTimezone.
  ///
  /// In en, this message translates to:
  /// **'Choose your time zone'**
  String get profileChooseTimezone;

  /// No description provided for @profileReminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Habit reminders'**
  String get profileReminderSettings;

  /// No description provided for @profileReminderSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a habit to configure its reminder time.'**
  String get profileReminderSettingsHint;

  /// No description provided for @notificationHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'A little nudge on time'**
  String get notificationHeroTitle;

  /// No description provided for @notificationHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Choose when you want Constanza to remind you about each habit.'**
  String get notificationHeroBody;

  /// No description provided for @notificationActiveSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active reminders} =1{1 active reminder} other{{count} active reminders}}'**
  String notificationActiveSummary(int count);

  /// No description provided for @notificationActiveSummaryHint.
  ///
  /// In en, this message translates to:
  /// **'You can configure each one separately.'**
  String get notificationActiveSummaryHint;

  /// No description provided for @notificationHabitListHint.
  ///
  /// In en, this message translates to:
  /// **'Enable a habit or tap its time to change it.'**
  String get notificationHabitListHint;

  /// No description provided for @notificationEveryDayAt.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String notificationEveryDayAt(String time);

  /// No description provided for @notificationChooseTime.
  ///
  /// In en, this message translates to:
  /// **'Choose reminder time'**
  String get notificationChooseTime;

  /// No description provided for @reminderPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'What time should we remind you?'**
  String get reminderPickerTitle;

  /// No description provided for @reminderPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the best time for your habit'**
  String get reminderPickerSubtitle;

  /// No description provided for @reminderPickerMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get reminderPickerMorning;

  /// No description provided for @reminderPickerAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get reminderPickerAfternoon;

  /// No description provided for @reminderPickerNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get reminderPickerNight;

  /// No description provided for @reminderPickerSave.
  ///
  /// In en, this message translates to:
  /// **'Save time'**
  String get reminderPickerSave;

  /// No description provided for @notificationReminderSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminder updated'**
  String get notificationReminderSaved;

  /// No description provided for @notificationTimezoneHint.
  ///
  /// In en, this message translates to:
  /// **'Reminders will follow the time zone configured in your profile.'**
  String get notificationTimezoneHint;

  /// No description provided for @profileNoHabits.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any habits to configure yet.'**
  String get profileNoHabits;

  /// No description provided for @profileWelcomeAnimation.
  ///
  /// In en, this message translates to:
  /// **'Welcome animation'**
  String get profileWelcomeAnimation;

  /// No description provided for @profileWelcomeAnimationHint.
  ///
  /// In en, this message translates to:
  /// **'Show the mascot and motivation when opening the app'**
  String get profileWelcomeAnimationHint;

  /// No description provided for @profileChangesSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get profileChangesSaved;

  /// No description provided for @profileStreakEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! 💪'**
  String get profileStreakEncouragement;

  /// No description provided for @profileHabitsEncouragement.
  ///
  /// In en, this message translates to:
  /// **'You\'re building a great habit 💚'**
  String get profileHabitsEncouragement;

  /// No description provided for @profileProtectorEncouragement.
  ///
  /// In en, this message translates to:
  /// **'You have {count} for a difficult day ✨'**
  String profileProtectorEncouragement(int count);

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatar;

  /// No description provided for @chooseAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Make Constanza feel a little more yours 💜'**
  String get chooseAvatarSubtitle;

  /// No description provided for @avatarTraveler.
  ///
  /// In en, this message translates to:
  /// **'Cloud'**
  String get avatarTraveler;

  /// No description provided for @avatarFriendly.
  ///
  /// In en, this message translates to:
  /// **'Licorice'**
  String get avatarFriendly;

  /// No description provided for @avatarMagic.
  ///
  /// In en, this message translates to:
  /// **'Pearl'**
  String get avatarMagic;

  /// No description provided for @avatarGamer.
  ///
  /// In en, this message translates to:
  /// **'Peaches'**
  String get avatarGamer;

  /// No description provided for @avatarZen.
  ///
  /// In en, this message translates to:
  /// **'Snowball'**
  String get avatarZen;

  /// No description provided for @avatarNight.
  ///
  /// In en, this message translates to:
  /// **'Mocha'**
  String get avatarNight;

  /// No description provided for @avatarAdventurer.
  ///
  /// In en, this message translates to:
  /// **'Yarn'**
  String get avatarAdventurer;

  /// No description provided for @avatarLegendary.
  ///
  /// In en, this message translates to:
  /// **'Tangerine'**
  String get avatarLegendary;

  /// No description provided for @avatarHazel.
  ///
  /// In en, this message translates to:
  /// **'Hazel'**
  String get avatarHazel;

  /// No description provided for @avatarCookie.
  ///
  /// In en, this message translates to:
  /// **'Cookie'**
  String get avatarCookie;

  /// No description provided for @avatarPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get avatarPremium;

  /// No description provided for @avatarPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile with Premium'**
  String get avatarPremiumTitle;

  /// No description provided for @avatarPremiumBody.
  ///
  /// In en, this message translates to:
  /// **'This avatar is part of the Premium collection. Unlock it and give your profile an even more personal style.'**
  String get avatarPremiumBody;

  /// No description provided for @avatarPremiumBenefitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exclusive customization'**
  String get avatarPremiumBenefitTitle;

  /// No description provided for @avatarPremiumBenefitBody.
  ///
  /// In en, this message translates to:
  /// **'Access special avatars and new visual options.'**
  String get avatarPremiumBenefitBody;

  /// No description provided for @avatarSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get avatarSelected;

  /// No description provided for @avatarAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get avatarAvailable;

  /// No description provided for @avatarComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get avatarComingSoon;

  /// No description provided for @avatarLocked.
  ///
  /// In en, this message translates to:
  /// **'locked'**
  String get avatarLocked;

  /// No description provided for @avatarLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Locked avatar 🔒'**
  String get avatarLockedTitle;

  /// No description provided for @avatarLockedBody.
  ///
  /// In en, this message translates to:
  /// **'This avatar will be available soon.'**
  String get avatarLockedBody;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @timezoneHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your day, your time'**
  String get timezoneHeroTitle;

  /// No description provided for @timezoneHeroBody.
  ///
  /// In en, this message translates to:
  /// **'We use your time zone to know when a new day begins and keep your habits and streak accurate.'**
  String get timezoneHeroBody;

  /// No description provided for @timezoneAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic time zone'**
  String get timezoneAutomatic;

  /// No description provided for @timezoneAutomaticSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the device time zone'**
  String get timezoneAutomaticSubtitle;

  /// No description provided for @timezoneRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for most users.'**
  String get timezoneRecommended;

  /// No description provided for @timezoneCurrent.
  ///
  /// In en, this message translates to:
  /// **'Your current time zone'**
  String get timezoneCurrent;

  /// No description provided for @timezoneActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get timezoneActive;

  /// No description provided for @timezoneCurrentTime.
  ///
  /// In en, this message translates to:
  /// **'Current time: {time}'**
  String timezoneCurrentTime(String time);

  /// No description provided for @timezoneManual.
  ///
  /// In en, this message translates to:
  /// **'Select manually'**
  String get timezoneManual;

  /// No description provided for @timezoneManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If you prefer, you can choose another time zone.'**
  String get timezoneManualSubtitle;

  /// No description provided for @timezoneSearch.
  ///
  /// In en, this message translates to:
  /// **'Search city or time zone...'**
  String get timezoneSearch;

  /// No description provided for @timezoneRecent.
  ///
  /// In en, this message translates to:
  /// **'Available zones'**
  String get timezoneRecent;

  /// No description provided for @timezoneTravelHint.
  ///
  /// In en, this message translates to:
  /// **'When automatic mode is enabled, Constanza will update your time zone as you travel so your days follow local time.'**
  String get timezoneTravelHint;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileSignOutHint.
  ///
  /// In en, this message translates to:
  /// **'You can sign in again with your email and password.'**
  String get profileSignOutHint;

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
  /// **'An account already exists with this email.'**
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

  /// No description provided for @streakAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Your streak is at risk'**
  String get streakAtRisk;

  /// No description provided for @streakAtRiskBody.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t complete any habit yesterday. You can protect it with a wildcard until the end of the day.'**
  String get streakAtRiskBody;

  /// No description provided for @streakSafeToday.
  ///
  /// In en, this message translates to:
  /// **'Today already counts. Keep it up!'**
  String get streakSafeToday;

  /// No description provided for @streakPendingToday.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t completed anything today yet.'**
  String get streakPendingToday;

  /// No description provided for @streakStartToday.
  ///
  /// In en, this message translates to:
  /// **'Complete a habit to start your streak.'**
  String get streakStartToday;

  /// No description provided for @collapseStreakCard.
  ///
  /// In en, this message translates to:
  /// **'Collapse streak card'**
  String get collapseStreakCard;

  /// No description provided for @expandStreakCard.
  ///
  /// In en, this message translates to:
  /// **'Expand streak card'**
  String get expandStreakCard;

  /// No description provided for @useWildcard.
  ///
  /// In en, this message translates to:
  /// **'Use wildcard'**
  String get useWildcard;

  /// No description provided for @wildcardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak protectors} =1{1 streak protector} other{{count} streak protectors}}'**
  String wildcardsAvailable(int count);

  /// No description provided for @noWildcardsLeft.
  ///
  /// In en, this message translates to:
  /// **'You have no wildcards left. You\'ll get a new one next month.'**
  String get noWildcardsLeft;

  /// No description provided for @wildcardProtectsNotAdds.
  ///
  /// In en, this message translates to:
  /// **'A wildcard protects your streak, but it doesn\'t add a day or mark any habit.'**
  String get wildcardProtectsNotAdds;

  /// No description provided for @wildcardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Use a wildcard?'**
  String get wildcardConfirmTitle;

  /// No description provided for @wildcardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll protect {day} and your {streak}-day streak will stay alive.'**
  String wildcardConfirmBody(String day, int streak);

  /// No description provided for @wildcardUsed.
  ///
  /// In en, this message translates to:
  /// **'Streak protected. Keep going!'**
  String get wildcardUsed;

  /// No description provided for @wildcardErrorWindowClosed.
  ///
  /// In en, this message translates to:
  /// **'That day can no longer be protected.'**
  String get wildcardErrorWindowClosed;

  /// No description provided for @wildcardErrorNone.
  ///
  /// In en, this message translates to:
  /// **'You have no wildcards left.'**
  String get wildcardErrorNone;

  /// No description provided for @wildcardErrorConnection.
  ///
  /// In en, this message translates to:
  /// **'You need a connection to use a wildcard.'**
  String get wildcardErrorConnection;

  /// No description provided for @wildcardErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'The wildcard couldn\'t be used. Please try again.'**
  String get wildcardErrorGeneric;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goalProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {goal}'**
  String goalProgressLabel(int completed, int goal);

  /// No description provided for @goalPeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'this week'**
  String get goalPeriodWeek;

  /// No description provided for @goalPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'this month'**
  String get goalPeriodMonth;

  /// No description provided for @goalPeriodYear.
  ///
  /// In en, this message translates to:
  /// **'this year'**
  String get goalPeriodYear;

  /// No description provided for @goalPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get goalPeriodDay;

  /// No description provided for @periodicityDailyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get periodicityDailyLabel;

  /// No description provided for @periodicityWeeklyLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time per week} other{{count} times per week}}'**
  String periodicityWeeklyLabel(int count);

  /// No description provided for @periodicityMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time per month} other{{count} times per month}}'**
  String periodicityMonthlyLabel(int count);

  /// No description provided for @periodicityYearlyLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 time per year} other{{count} times per year}}'**
  String periodicityYearlyLabel(int count);

  /// No description provided for @frequencyChangeDeferred.
  ///
  /// In en, this message translates to:
  /// **'This change will apply on {date}. Until then your current goal stays the same.'**
  String frequencyChangeDeferred(String date);

  /// No description provided for @logNotTodayError.
  ///
  /// In en, this message translates to:
  /// **'You can only mark habits for today.'**
  String get logNotTodayError;

  /// No description provided for @bestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Best streak: {count}'**
  String bestStreakLabel(int count);

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabitTitle;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitTitle;

  /// No description provided for @editHabitWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitWarningTitle;

  /// No description provided for @editHabitWarningBody.
  ///
  /// In en, this message translates to:
  /// **'If you change the frequency, progress will be recalculated for the new goal.\nYour history and streak won\'t be deleted.'**
  String get editHabitWarningBody;

  /// No description provided for @editHabitProgressInfo.
  ///
  /// In en, this message translates to:
  /// **'Progress will adjust to the new goal.'**
  String get editHabitProgressInfo;

  /// No description provided for @editHabitHistoryInfo.
  ///
  /// In en, this message translates to:
  /// **'Your history will be kept.'**
  String get editHabitHistoryInfo;

  /// No description provided for @editHabitStreakInfo.
  ///
  /// In en, this message translates to:
  /// **'Your streak won\'t be deleted.'**
  String get editHabitStreakInfo;

  /// No description provided for @habitIdentityLockedHint.
  ///
  /// In en, this message translates to:
  /// **'The name and area can\'t be changed. Create a new habit instead.'**
  String get habitIdentityLockedHint;

  /// No description provided for @habitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get habitNameLabel;

  /// No description provided for @habitNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Drink water'**
  String get habitNameHint;

  /// No description provided for @habitEmojiLabel.
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get habitEmojiLabel;

  /// No description provided for @habitColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habitColorLabel;

  /// No description provided for @habitAmbitoLabel.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get habitAmbitoLabel;

  /// No description provided for @habitPeriodicityLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get habitPeriodicityLabel;

  /// No description provided for @habitTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times per period'**
  String get habitTimesLabel;

  /// No description provided for @habitTrackingQuestion.
  ///
  /// In en, this message translates to:
  /// **'How many times do you want to do it?'**
  String get habitTrackingQuestion;

  /// No description provided for @habitTrackingOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get habitTrackingOnce;

  /// No description provided for @habitTrackingSeveral.
  ///
  /// In en, this message translates to:
  /// **'Several times'**
  String get habitTrackingSeveral;

  /// No description provided for @habitTargetCount.
  ///
  /// In en, this message translates to:
  /// **'How many times?'**
  String get habitTargetCount;

  /// No description provided for @habitUnitOptional.
  ///
  /// In en, this message translates to:
  /// **'Unit (optional)'**
  String get habitUnitOptional;

  /// No description provided for @habitUnitHint.
  ///
  /// In en, this message translates to:
  /// **'Example: glasses'**
  String get habitUnitHint;

  /// No description provided for @habitDisplayGoalOptional.
  ///
  /// In en, this message translates to:
  /// **'Visible goal (optional)'**
  String get habitDisplayGoalOptional;

  /// No description provided for @habitDisplayGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 2 L'**
  String get habitDisplayGoalHint;

  /// No description provided for @habitProgressIcon.
  ///
  /// In en, this message translates to:
  /// **'Progress icon'**
  String get habitProgressIcon;

  /// No description provided for @habitProgressIconSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to log each time you do it.'**
  String get habitProgressIconSubtitle;

  /// No description provided for @habitRepetitionProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {target}{unit}'**
  String habitRepetitionProgress(Object completed, Object target, Object unit);

  /// No description provided for @habitRepetitionItemCompleted.
  ///
  /// In en, this message translates to:
  /// **'{item} {index} of {target}, completed'**
  String habitRepetitionItemCompleted(Object index, Object item, Object target);

  /// No description provided for @habitRepetitionItemPending.
  ///
  /// In en, this message translates to:
  /// **'{item} {index} of {target}, pending'**
  String habitRepetitionItemPending(Object index, Object item, Object target);

  /// No description provided for @habitReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get habitReminderLabel;

  /// No description provided for @habitReminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get habitReminderNone;

  /// No description provided for @habitReminderSet.
  ///
  /// In en, this message translates to:
  /// **'Every day at {time}'**
  String habitReminderSet(String time);

  /// No description provided for @saveHabit.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveHabit;

  /// No description provided for @createHabit.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get createHabit;

  /// No description provided for @deleteHabit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabit;

  /// No description provided for @deleteHabitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this habit?'**
  String get deleteHabitConfirmTitle;

  /// No description provided for @deleteHabitConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'It will disappear from your lists, but its history is kept and the days you already completed still count towards your streak.'**
  String get deleteHabitConfirmBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @habitCreated.
  ///
  /// In en, this message translates to:
  /// **'Habit created'**
  String get habitCreated;

  /// No description provided for @habitSaved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get habitSaved;

  /// No description provided for @habitDeleted.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get habitDeleted;

  /// No description provided for @habitNotFound.
  ///
  /// In en, this message translates to:
  /// **'This habit no longer exists'**
  String get habitNotFound;

  /// No description provided for @errorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get errorNameRequired;

  /// No description provided for @errorNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'The name is too long'**
  String get errorNameTooLong;

  /// No description provided for @errorEmojiRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick an emoji'**
  String get errorEmojiRequired;

  /// No description provided for @errorTimesInvalid.
  ///
  /// In en, this message translates to:
  /// **'That number doesn\'t fit in the period'**
  String get errorTimesInvalid;

  /// No description provided for @errorReminderInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid time'**
  String get errorReminderInvalid;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Please try again.'**
  String get errorSaveFailed;

  /// No description provided for @noHabitsYetLong.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any habits yet.\nCreate your first one and start your streak.'**
  String get noHabitsYetLong;

  /// No description provided for @myHabitsManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit and organize your habits'**
  String get myHabitsManageSubtitle;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// No description provided for @emptyHabitsImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Cat waiting for new habits'**
  String get emptyHabitsImageLabel;

  /// No description provided for @emptyHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any habits yet'**
  String get emptyHabitsTitle;

  /// No description provided for @emptyHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first habit and take the first step towards the best version of yourself.'**
  String get emptyHabitsBody;

  /// No description provided for @addFirstHabit.
  ///
  /// In en, this message translates to:
  /// **'Add my first habit'**
  String get addFirstHabit;

  /// No description provided for @needIdeas.
  ///
  /// In en, this message translates to:
  /// **'Need some ideas?'**
  String get needIdeas;

  /// No description provided for @habitIdeaExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get habitIdeaExercise;

  /// No description provided for @habitIdeaRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get habitIdeaRead;

  /// No description provided for @habitIdeaWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get habitIdeaWater;

  /// No description provided for @habitIdeaSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep better'**
  String get habitIdeaSleep;

  /// No description provided for @allHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'My habits'**
  String get allHabitsTitle;

  /// No description provided for @habitCalendarsAction.
  ///
  /// In en, this message translates to:
  /// **'Calendars'**
  String get habitCalendarsAction;

  /// No description provided for @editHabitsAction.
  ///
  /// In en, this message translates to:
  /// **'Edit habits'**
  String get editHabitsAction;

  /// No description provided for @habitCalendarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habit calendars'**
  String get habitCalendarsTitle;

  /// No description provided for @habitCalendarsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get habitCalendarsCompleted;

  /// No description provided for @habitCalendarsNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get habitCalendarsNotCompleted;

  /// No description provided for @statsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your consistency shows 💜'**
  String get statsSubtitle;

  /// No description provided for @statsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// No description provided for @statsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get statsThisMonth;

  /// No description provided for @statsThisYear.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get statsThisYear;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statsBestStreak;

  /// No description provided for @statsDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String statsDayCount(int count);

  /// No description provided for @statsKeepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get statsKeepGoing;

  /// No description provided for @statsPersonalRecord.
  ///
  /// In en, this message translates to:
  /// **'Your personal best!'**
  String get statsPersonalRecord;

  /// No description provided for @statsCompliance.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get statsCompliance;

  /// No description provided for @statsCompletedRecords.
  ///
  /// In en, this message translates to:
  /// **'Habits completed'**
  String get statsCompletedRecords;

  /// No description provided for @statsActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get statsActiveDays;

  /// No description provided for @statsProtectors.
  ///
  /// In en, this message translates to:
  /// **'Protectors available'**
  String get statsProtectors;

  /// No description provided for @statsWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly activity'**
  String get statsWeeklyProgress;

  /// No description provided for @statsMonthlyProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress this month'**
  String get statsMonthlyProgress;

  /// No description provided for @statsYearlyProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress this year'**
  String get statsYearlyProgress;

  /// No description provided for @statsSeeCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get statsSeeCalendar;

  /// No description provided for @statsHabits.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get statsHabits;

  /// No description provided for @pendingHabitsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingHabitsWithCount(int count);

  /// No description provided for @completedHabitsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Completed today ({count})'**
  String completedHabitsWithCount(int count);

  /// No description provided for @allHabitsDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All done for today! 🎉'**
  String get allHabitsDoneTitle;

  /// No description provided for @allHabitsDoneBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve logged every habit.'**
  String get allHabitsDoneBody;

  /// No description provided for @markHabitDone.
  ///
  /// In en, this message translates to:
  /// **'Mark {habit} as done today'**
  String markHabitDone(String habit);

  /// No description provided for @markHabitUndone.
  ///
  /// In en, this message translates to:
  /// **'Unmark {habit} for today'**
  String markHabitUndone(String habit);

  /// No description provided for @habitPendingEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Small steps, big results ✨'**
  String get habitPendingEncouragement;

  /// No description provided for @habitCompletedEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Goal completed! 🎉'**
  String get habitCompletedEncouragement;

  /// No description provided for @habitCompletedCelebration.
  ///
  /// In en, this message translates to:
  /// **'Great job! One step closer 💪'**
  String get habitCompletedCelebration;

  /// No description provided for @habitCompletedCelebration2.
  ///
  /// In en, this message translates to:
  /// **'Amazing! Your consistency is growing ✨'**
  String get habitCompletedCelebration2;

  /// No description provided for @habitCompletedCelebration3.
  ///
  /// In en, this message translates to:
  /// **'Done! You chose yourself again today 💜'**
  String get habitCompletedCelebration3;

  /// No description provided for @habitCompletedCelebration4.
  ///
  /// In en, this message translates to:
  /// **'Nice work! Every step counts 🌱'**
  String get habitCompletedCelebration4;

  /// No description provided for @habitCompletedCelebration5.
  ///
  /// In en, this message translates to:
  /// **'Keep going! You\'re building something great 🚀'**
  String get habitCompletedCelebration5;

  /// No description provided for @habitCompletedCelebration6.
  ///
  /// In en, this message translates to:
  /// **'Goal complete! You\'ve got this ⭐'**
  String get habitCompletedCelebration6;

  /// No description provided for @allHabitsCompletedCelebration.
  ///
  /// In en, this message translates to:
  /// **'Day complete! You\'re unstoppable'**
  String get allHabitsCompletedCelebration;

  /// No description provided for @allHabitsCompletedCelebration2.
  ///
  /// In en, this message translates to:
  /// **'All done for today! Great work 🎉'**
  String get allHabitsCompletedCelebration2;

  /// No description provided for @allHabitsCompletedCelebration3.
  ///
  /// In en, this message translates to:
  /// **'A perfect day! Your consistency shines ✨'**
  String get allHabitsCompletedCelebration3;

  /// No description provided for @allHabitsCompletedCelebration4.
  ///
  /// In en, this message translates to:
  /// **'Every habit done! See you tomorrow 💜'**
  String get allHabitsCompletedCelebration4;

  /// No description provided for @editHabitsHint.
  ///
  /// In en, this message translates to:
  /// **'To edit your habits, go to the Habits tab.'**
  String get editHabitsHint;

  /// No description provided for @timezoneChangeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Change your time zone?'**
  String get timezoneChangeConfirmTitle;

  /// No description provided for @timezoneChangeConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get timezoneChangeConfirmAction;

  /// No description provided for @timezoneAutomaticConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Constanza will use the device time zone and update it automatically when you travel, so your days follow local time.'**
  String get timezoneAutomaticConfirmBody;

  /// No description provided for @timezoneManualConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'When you choose a time zone manually, it will no longer update automatically as you travel. Your habits and streak will follow the zone you select.'**
  String get timezoneManualConfirmBody;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{habit}'**
  String reminderNotificationTitle(String habit);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'It\'s your moment. Shall we call it done today?'**
  String get reminderNotificationBody;

  /// No description provided for @notificationsDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off'**
  String get notificationsDisabledTitle;

  /// No description provided for @notificationsDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'Constanza can\'t remind you until you allow notifications.'**
  String get notificationsDisabledBody;

  /// No description provided for @notificationsEnableAction.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders'**
  String get notificationsEnableAction;

  /// No description provided for @notificationsDeniedHint.
  ///
  /// In en, this message translates to:
  /// **'You denied notifications. You can turn them on from your system settings.'**
  String get notificationsDeniedHint;

  /// No description provided for @notificationsScheduled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No reminders scheduled} =1{1 reminder scheduled} other{{count} reminders scheduled}}'**
  String notificationsScheduled(int count);

  /// No description provided for @premiumHabitLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock more habits with Premium'**
  String get premiumHabitLimitTitle;

  /// No description provided for @premiumHabitLimitBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the limit of 5 habits on the free version. With Premium you can create as many habits as you want and keep moving forward.'**
  String get premiumHabitLimitBody;

  /// No description provided for @premiumUnlimitedHabits.
  ///
  /// In en, this message translates to:
  /// **'Unlimited habits'**
  String get premiumUnlimitedHabits;

  /// No description provided for @premiumUnlimitedHabitsBody.
  ///
  /// In en, this message translates to:
  /// **'Create all the habits you need.'**
  String get premiumUnlimitedHabitsBody;

  /// No description provided for @premiumAdvancedStats.
  ///
  /// In en, this message translates to:
  /// **'Advanced statistics'**
  String get premiumAdvancedStats;

  /// No description provided for @premiumAdvancedStatsBody.
  ///
  /// In en, this message translates to:
  /// **'See your progress in detail.'**
  String get premiumAdvancedStatsBody;

  /// No description provided for @premiumNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'New features'**
  String get premiumNewFeatures;

  /// No description provided for @premiumNewFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'More exclusive tools coming soon.'**
  String get premiumNewFeaturesBody;

  /// No description provided for @premiumNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get premiumNotNow;

  /// No description provided for @premiumViewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Premium plans'**
  String get premiumViewPlans;

  /// No description provided for @premiumCatImageLabel.
  ///
  /// In en, this message translates to:
  /// **'Premium cat wearing a crown'**
  String get premiumCatImageLabel;
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
