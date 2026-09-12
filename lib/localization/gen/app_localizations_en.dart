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
  String get welcomeMessage1 => 'A small step still counts.';

  @override
  String get welcomeMessage2 => 'Consistency beats perfection.';

  @override
  String get welcomeMessage3 => 'Today is a good day to move forward a little.';

  @override
  String get welcomeMessage4 => 'Do it for your future self.';

  @override
  String get welcomeMessage5 =>
      'You don\'t need to do it perfectly, just do it.';

  @override
  String get welcomeMessage6 => 'Every habit today builds your tomorrow.';

  @override
  String get skipWelcome => 'Skip welcome';

  @override
  String get generalStreak => 'Overall streak';

  @override
  String get consecutiveDays => 'consecutive days';

  @override
  String get amazing => 'Amazing!';

  @override
  String get keepItUp => 'Keep it up';

  @override
  String get seeAll => 'See all';

  @override
  String get days => 'days';

  @override
  String get myHabits => 'My habits';

  @override
  String get habitFilterAll => 'All';

  @override
  String get habitFilterDaily => 'Daily';

  @override
  String get habitFilterWeekly => 'Weekly';

  @override
  String get habitFilterMonthly => 'Monthly';

  @override
  String get habitFilterYearly => 'Yearly';

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
      'Open it from your inbox and come back here to continue. If you can\'t see it, check your spam folder.';

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
  String get pendingVerificationTitle => 'Your account isn\'t verified yet';

  @override
  String get pendingVerificationBody =>
      'This is the only step left. Open the link we sent you or request a new one; check your spam folder too.';

  @override
  String get signInCta => 'Sign in';

  @override
  String get welcomeTitle => 'Your change starts here';

  @override
  String get welcomeMessage =>
      'The best day to start was months ago.\nThe next best moment is ';

  @override
  String get welcomeMessageHighlight => 'TODAY.';

  @override
  String get welcomeStart => 'Get started';

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
      'An account already exists with this email.';

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

  @override
  String get streakAtRisk => 'Your streak is at risk';

  @override
  String get streakAtRiskBody =>
      'You didn\'t complete any habit yesterday. You can protect it with a wildcard until the end of the day.';

  @override
  String get streakSafeToday => 'Today already counts. Keep it up!';

  @override
  String get streakPendingToday => 'You haven\'t completed anything today yet.';

  @override
  String get streakStartToday => 'Complete a habit to start your streak.';

  @override
  String get useWildcard => 'Use wildcard';

  @override
  String wildcardsAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak protectors',
      one: '1 streak protector',
      zero: 'No streak protectors',
    );
    return '$_temp0';
  }

  @override
  String get noWildcardsLeft =>
      'You have no wildcards left. You\'ll get a new one next month.';

  @override
  String get wildcardProtectsNotAdds =>
      'A wildcard protects your streak, but it doesn\'t add a day or mark any habit.';

  @override
  String get wildcardConfirmTitle => 'Use a wildcard?';

  @override
  String wildcardConfirmBody(String day, int streak) {
    return 'You\'ll protect $day and your $streak-day streak will stay alive.';
  }

  @override
  String get wildcardUsed => 'Streak protected. Keep going!';

  @override
  String get wildcardErrorWindowClosed =>
      'That day can no longer be protected.';

  @override
  String get wildcardErrorNone => 'You have no wildcards left.';

  @override
  String get wildcardErrorConnection =>
      'You need a connection to use a wildcard.';

  @override
  String get wildcardErrorGeneric =>
      'The wildcard couldn\'t be used. Please try again.';

  @override
  String get cancel => 'Cancel';

  @override
  String goalProgressLabel(int completed, int goal) {
    return '$completed / $goal';
  }

  @override
  String get goalPeriodWeek => 'this week';

  @override
  String get goalPeriodMonth => 'this month';

  @override
  String get goalPeriodYear => 'this year';

  @override
  String get goalPeriodDay => 'today';

  @override
  String get periodicityDailyLabel => 'Every day';

  @override
  String periodicityWeeklyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per week',
      one: '1 time per week',
    );
    return '$_temp0';
  }

  @override
  String periodicityMonthlyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per month',
      one: '1 time per month',
    );
    return '$_temp0';
  }

  @override
  String periodicityYearlyLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per year',
      one: '1 time per year',
    );
    return '$_temp0';
  }

  @override
  String frequencyChangeDeferred(String date) {
    return 'This change will apply on $date. Until then your current goal stays the same.';
  }

  @override
  String get logNotTodayError => 'You can only mark habits for today.';

  @override
  String bestStreakLabel(int count) {
    return 'Best streak: $count';
  }

  @override
  String get newHabitTitle => 'New habit';

  @override
  String get editHabitTitle => 'Edit habit';

  @override
  String get editHabitWarningTitle => 'Change frequency?';

  @override
  String get editHabitWarningBody =>
      'If you change the frequency, progress will be recalculated for the new goal.\nYour history and streak won\'t be deleted.';

  @override
  String get editHabitProgressInfo => 'Progress will adjust to the new goal.';

  @override
  String get editHabitHistoryInfo => 'Your history will be kept.';

  @override
  String get editHabitStreakInfo => 'Your streak won\'t be deleted.';

  @override
  String get habitIdentityLockedHint =>
      'The name and area can\'t be changed. Create a new habit instead.';

  @override
  String get habitNameLabel => 'Name';

  @override
  String get habitNameHint => 'E.g. Drink water';

  @override
  String get habitEmojiLabel => 'Emoji';

  @override
  String get habitColorLabel => 'Color';

  @override
  String get habitAmbitoLabel => 'Area';

  @override
  String get habitPeriodicityLabel => 'Goal';

  @override
  String get habitTimesLabel => 'Times per period';

  @override
  String get habitReminderLabel => 'Reminder';

  @override
  String get habitReminderNone => 'No reminder';

  @override
  String habitReminderSet(String time) {
    return 'Every day at $time';
  }

  @override
  String get saveHabit => 'Save';

  @override
  String get createHabit => 'Create habit';

  @override
  String get deleteHabit => 'Delete habit';

  @override
  String get deleteHabitConfirmTitle => 'Delete this habit?';

  @override
  String get deleteHabitConfirmBody =>
      'It will disappear from your lists, but its history is kept and the days you already completed still count towards your streak.';

  @override
  String get delete => 'Delete';

  @override
  String get habitCreated => 'Habit created';

  @override
  String get habitSaved => 'Changes saved';

  @override
  String get habitDeleted => 'Habit deleted';

  @override
  String get habitNotFound => 'This habit no longer exists';

  @override
  String get errorNameRequired => 'Enter a name';

  @override
  String get errorNameTooLong => 'The name is too long';

  @override
  String get errorEmojiRequired => 'Pick an emoji';

  @override
  String get errorTimesInvalid => 'That number doesn\'t fit in the period';

  @override
  String get errorReminderInvalid => 'Invalid time';

  @override
  String get errorSaveFailed => 'Couldn\'t save. Please try again.';

  @override
  String get noHabitsYetLong =>
      'You don\'t have any habits yet.\nCreate your first one and start your streak.';

  @override
  String get allHabitsTitle => 'My habits';

  @override
  String get habitCalendarsAction => 'Calendars';

  @override
  String get habitCalendarsTitle => 'Habit calendars';

  @override
  String get habitCalendarsCompleted => 'Completed';

  @override
  String get habitCalendarsNotCompleted => 'Not completed';

  @override
  String get statsSubtitle => 'Your consistency shows 💜';

  @override
  String get statsThisWeek => 'This week';

  @override
  String get statsThisMonth => 'This month';

  @override
  String get statsThisYear => 'This year';

  @override
  String get statsCurrentStreak => 'Current streak';

  @override
  String get statsBestStreak => 'Best streak';

  @override
  String statsDayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get statsKeepGoing => 'Keep it up!';

  @override
  String get statsPersonalRecord => 'Your personal best!';

  @override
  String get statsCompliance => 'Completion';

  @override
  String get statsCompletedRecords => 'Habits completed';

  @override
  String get statsActiveDays => 'Active days';

  @override
  String get statsProtectors => 'Protectors available';

  @override
  String get statsWeeklyProgress => 'Your progress this week';

  @override
  String get statsMonthlyProgress => 'Your progress this month';

  @override
  String get statsYearlyProgress => 'Your progress this year';

  @override
  String get statsSeeCalendar => 'View calendar';

  @override
  String get statsHabits => 'Habits';

  @override
  String pendingHabitsWithCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String completedHabitsWithCount(int count) {
    return 'Completed today ($count)';
  }

  @override
  String get allHabitsDoneTitle => 'All done for today! 🎉';

  @override
  String get allHabitsDoneBody => 'You\'ve logged every habit.';

  @override
  String markHabitDone(String habit) {
    return 'Mark $habit as done today';
  }

  @override
  String markHabitUndone(String habit) {
    return 'Unmark $habit for today';
  }

  @override
  String get habitPendingEncouragement => 'Small steps, big results ✨';

  @override
  String get habitCompletedEncouragement => 'Goal completed! 🎉';

  @override
  String get habitCompletedCelebration => 'Great job! One step closer 💪';

  @override
  String get allHabitsCompletedCelebration =>
      'Day complete! You\'re unstoppable';

  @override
  String get editHabitsHint => 'To edit your habits, go to the Habits tab.';
}
