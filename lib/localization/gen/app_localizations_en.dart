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
  String get homeEmptyHabitsBody =>
      'Your first small step starts here. Create it with the New habit button.';

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
  String get navHome => 'Habits';

  @override
  String get navHabits => 'My habits';

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
  String get profileSubtitle => 'Your personal space';

  @override
  String get profileVerified => 'Verified account';

  @override
  String get profileYourProgress => 'Your progress';

  @override
  String get profileCurrentStreak => 'Current streak';

  @override
  String get profileActiveHabits => 'Active habits';

  @override
  String get profileProtectors => 'Protectors';

  @override
  String get profileManage => 'Manage your experience';

  @override
  String get profileMyHabitsSubtitle => 'Organize and edit your habits';

  @override
  String get profileCalendarsSubtitle => 'View your full history';

  @override
  String get profileStatsSubtitle => 'See how you\'re progressing';

  @override
  String get profilePreferences => 'Preferences';

  @override
  String get profileTimezone => 'Time zone';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileViewStats => 'View statistics';

  @override
  String get profileTimezoneSubtitle => 'Configure your time zone';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileNotificationsSubtitle => 'Customize your reminders';

  @override
  String get profileAppearance => 'Appearance';

  @override
  String get profileAppearanceSubtitle => 'Theme, color and app icon';

  @override
  String get appearanceHeroTitle => 'Make it a little more yours';

  @override
  String get appearanceHeroBody =>
      'Customize how Constanza feels as it joins you each day.';

  @override
  String get appearancePreview => 'Preview';

  @override
  String get appearanceExperience => 'Experience';

  @override
  String get appearanceReducedMotion => 'Reduce motion';

  @override
  String get appearanceReducedMotionHint =>
      'Follows your device accessibility setting';

  @override
  String get appearanceActive => 'Active';

  @override
  String get appearanceInactive => 'Inactive';

  @override
  String get appearanceTheme => 'Theme';

  @override
  String get appearanceLightTheme => 'Light';

  @override
  String get appearanceLightThemeHint => 'Constanza\'s current style';

  @override
  String get appearanceDarkTheme => 'Dark';

  @override
  String get appearanceComingSoon => 'A more comfortable experience at night';

  @override
  String get appearanceSoon => 'Coming soon';

  @override
  String get appearanceAppIcon => 'App icon';

  @override
  String get appearanceAppIconHint =>
      'Choose how you want to recognize Constanza on your device.';

  @override
  String get appearanceClassic => 'Classic';

  @override
  String get appearanceSystemHint =>
      'Reduced motion automatically follows your device accessibility settings.';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileName => 'Name';

  @override
  String get profileChooseTimezone => 'Choose your time zone';

  @override
  String get profileReminderSettings => 'Habit reminders';

  @override
  String get profileReminderSettingsHint =>
      'Tap a habit to configure its reminder time.';

  @override
  String get notificationHeroTitle => 'A little nudge on time';

  @override
  String get notificationHeroBody =>
      'Choose when you want Constanza to remind you about each habit.';

  @override
  String notificationActiveSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active reminders',
      one: '1 active reminder',
      zero: 'No active reminders',
    );
    return '$_temp0';
  }

  @override
  String get notificationActiveSummaryHint =>
      'You can configure each one separately.';

  @override
  String get notificationHabitListHint =>
      'Enable a habit or tap its time to change it.';

  @override
  String notificationEveryDayAt(String time) {
    return 'Every day at $time';
  }

  @override
  String get notificationChooseTime => 'Choose reminder time';

  @override
  String get notificationReminderSaved => 'Reminder updated';

  @override
  String get notificationTimezoneHint =>
      'Reminders will follow the time zone configured in your profile.';

  @override
  String get profileNoHabits => 'You don\'t have any habits to configure yet.';

  @override
  String get profileWelcomeAnimation => 'Welcome animation';

  @override
  String get profileWelcomeAnimationHint =>
      'Show the mascot and motivation when opening the app';

  @override
  String get profileChangesSaved => 'Changes saved';

  @override
  String get profileStreakEncouragement => 'Keep it up! 💪';

  @override
  String get profileHabitsEncouragement => 'You\'re building a great habit 💚';

  @override
  String profileProtectorEncouragement(int count) {
    return 'You have $count for a difficult day ✨';
  }

  @override
  String get chooseAvatar => 'Choose your avatar';

  @override
  String get chooseAvatarSubtitle =>
      'Make Constanza feel a little more yours 💜';

  @override
  String get avatarTraveler => 'Traveler cat';

  @override
  String get avatarFriendly => 'Curious cat';

  @override
  String get avatarMagic => 'Magic cat';

  @override
  String get avatarGamer => 'Gamer cat';

  @override
  String get avatarZen => 'Zen cat';

  @override
  String get avatarNight => 'Night cat';

  @override
  String get avatarAdventurer => 'Adventurer cat';

  @override
  String get avatarLegendary => 'Legendary cat';

  @override
  String get avatarSelected => 'Selected';

  @override
  String get avatarAvailable => 'Available';

  @override
  String get avatarComingSoon => 'Coming soon';

  @override
  String get avatarLocked => 'locked';

  @override
  String get avatarLockedTitle => 'Locked avatar 🔒';

  @override
  String get avatarLockedBody => 'This avatar will be available soon.';

  @override
  String get understood => 'Got it';

  @override
  String get timezoneHeroTitle => 'Your day, your time';

  @override
  String get timezoneHeroBody =>
      'We use your time zone to know when a new day begins and keep your habits and streak accurate.';

  @override
  String get timezoneAutomatic => 'Automatic time zone';

  @override
  String get timezoneAutomaticSubtitle => 'Use the device time zone';

  @override
  String get timezoneRecommended => 'Recommended for most users.';

  @override
  String get timezoneCurrent => 'Your current time zone';

  @override
  String get timezoneActive => 'Active';

  @override
  String timezoneCurrentTime(String time) {
    return 'Current time: $time';
  }

  @override
  String get timezoneManual => 'Select manually';

  @override
  String get timezoneManualSubtitle =>
      'If you prefer, you can choose another time zone.';

  @override
  String get timezoneSearch => 'Search city or time zone...';

  @override
  String get timezoneRecent => 'Available zones';

  @override
  String get timezoneTravelHint =>
      'When automatic mode is enabled, Constanza will update your time zone as you travel so your days follow local time.';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileSignOutHint =>
      'You can sign in again with your email and password.';

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
  String get collapseStreakCard => 'Collapse streak card';

  @override
  String get expandStreakCard => 'Expand streak card';

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
  String get habitTrackingQuestion => 'How many times do you want to do it?';

  @override
  String get habitTrackingOnce => 'Once';

  @override
  String get habitTrackingSeveral => 'Several times';

  @override
  String get habitTargetCount => 'How many times?';

  @override
  String get habitUnitOptional => 'Unit (optional)';

  @override
  String get habitUnitHint => 'Example: glasses';

  @override
  String get habitDisplayGoalOptional => 'Visible goal (optional)';

  @override
  String get habitDisplayGoalHint => 'Example: 2 L';

  @override
  String get habitProgressIcon => 'Progress icon';

  @override
  String get habitProgressIconSubtitle =>
      'Choose how you want to log each time you do it.';

  @override
  String habitRepetitionProgress(Object completed, Object target, Object unit) {
    return '$completed of $target$unit';
  }

  @override
  String habitRepetitionItemCompleted(
    Object index,
    Object item,
    Object target,
  ) {
    return '$item $index of $target, completed';
  }

  @override
  String habitRepetitionItemPending(Object index, Object item, Object target) {
    return '$item $index of $target, pending';
  }

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
  String get myHabitsManageSubtitle =>
      'Here you can view and manage all your habits.';

  @override
  String get addHabit => 'Add habit';

  @override
  String get emptyHabitsImageLabel => 'Cat waiting for new habits';

  @override
  String get emptyHabitsTitle => 'You don\'t have any habits yet';

  @override
  String get emptyHabitsBody =>
      'Start by adding your first habit and take the first step towards the best version of yourself.';

  @override
  String get addFirstHabit => 'Add my first habit';

  @override
  String get needIdeas => 'Need some ideas?';

  @override
  String get habitIdeaExercise => 'Exercise';

  @override
  String get habitIdeaRead => 'Read';

  @override
  String get habitIdeaWater => 'Drink water';

  @override
  String get habitIdeaSleep => 'Sleep better';

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

  @override
  String get timezoneChangeConfirmTitle => 'Change your time zone?';

  @override
  String get timezoneChangeConfirmAction => 'Change';

  @override
  String get timezoneAutomaticConfirmBody =>
      'Constanza will use the device time zone and update it automatically when you travel, so your days follow local time.';

  @override
  String get timezoneManualConfirmBody =>
      'When you choose a time zone manually, it will no longer update automatically as you travel. Your habits and streak will follow the zone you select.';
}
