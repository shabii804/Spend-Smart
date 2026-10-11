/// All user-visible strings live here so they can be tuned in one place
/// and easily localized later.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'SpendSmart';
  static const String appTagline = 'Track · Plan · Achieve';

  // Splash
  static const String splashLoading = 'Loading your wallet...';

  // Onboarding
  static const String onboardingSkip = 'Skip';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingPage1Title = 'Track Every Rupee';
  static const String onboardingPage1Subtitle =
      'Log expenses in seconds and watch your spending patterns come to life with beautiful charts.';
  static const String onboardingPage2Title = 'Master Your Budget';
  static const String onboardingPage2Subtitle =
      'Set a monthly budget, see your remaining balance instantly, and get alerts before you overspend.';
  static const String onboardingPage3Title = 'Save For Goals';
  static const String onboardingPage3Subtitle =
      'Set savings goals, contribute monthly, and watch your dreams come true — one deposit at a time.';

  // Auth
  static const String login = 'Log In';
  static const String register = 'Register';
  static const String forgotPassword = 'Forgot Password';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String fullName = 'Full Name';
  static const String confirmPassword = 'Confirm Password';
  static const String createAccount = 'Create Account';
  static const String logIn = 'Log In';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String orContinueWith = 'or continue with';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Continue with Apple';
  static const String demoOnly = 'This is a demo app — no real authentication is performed.';
  static const String acceptTerms = 'I accept the Terms & Conditions and Privacy Policy';
  static const String welcomeBack = 'Welcome Back';
  static const String welcomeBackSubtitle = 'Log in to keep tracking your spending.';
  static const String createAccountTitle = 'Create Your Account';
  static const String createAccountSubtitle = 'Start your smart spending journey today.';
  static const String forgotPasswordTitle = 'Reset Your Password';
  static const String forgotPasswordSubtitle =
      'Enter your email and we will send you a reset link.';
  static const String sendResetLink = 'Send Reset Link';
  static const String resetLinkSent =
      'Demo mode: no real email was sent. In production, a reset link would be emailed to you.';
  static const String backToLogin = 'Back to Login';

  // Validation
  static const String errRequired = 'This field is required';
  static const String errEmail = 'Enter a valid email address';
  static const String errPasswordShort = 'Password must be at least 6 characters';
  static const String errPasswordMatch = 'Passwords do not match';
  static const String errAcceptTerms = 'Please accept the Terms to continue';
  static const String errAmount = 'Enter a valid amount';

  // Dashboard / home
  static const String goodMorning = 'Good Morning';
  static const String goodAfternoon = 'Good Afternoon';
  static const String goodEvening = 'Good Evening';
  static const String home = 'Home';
  static const String monthlyBudget = 'Monthly Budget';
  static const String spentThisMonth = 'Spent this month';
  static const String remaining = 'Remaining';
  static const String quickActions = 'Quick Actions';
  static const String addExpense = 'Add Expense';
  static const String voiceEntry = 'Voice Entry';
  static const String analytics = 'Analytics';
  static const String goals = 'Goals';
  static const String spendingOverview = 'Spending Overview';
  static const String last7Days = 'Last 7 Days';
  static const String topCategories = 'Top Categories';
  static const String recentTransactions = 'Recent Transactions';
  static const String viewAll = 'View All';

  // Expenses
  static const String expenses = 'Expenses';
  static const String transactions = 'Transactions';
  static const String expenseDetails = 'Expense Details';
  static const String editExpense = 'Edit Expense';
  static const String manual = 'Manual';
  static const String voice = 'Voice';
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String date = 'Date';
  static const String note = 'Note';
  static const String noteHint = 'Optional note (max 80 chars)';
  static const String selectCategory = 'Select Category';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String cancel = 'Cancel';
  static const String search = 'Search';
  static const String searchTransactions = 'Search transactions';
  static const String all = 'All';
  static const String food = 'Food';
  static const String transport = 'Transport';
  static const String bills = 'Bills';
  static const String groceries = 'Groceries';
  static const String others = 'Others';
  static const String noTransactions = 'No transactions found';
  static const String noTransactionsSubtitle =
      'Try a different search or filter.';
  static const String expenseAdded = 'Expense added successfully';
  static const String expenseUpdated = 'Expense updated successfully';
  static const String expenseDeleted = 'Expense deleted';
  static const String listening = 'Listening...';
  static const String voiceStartPrompt = 'Tap the mic and describe your expense';
  static const String voiceDemoLabel = 'Simulated — voice recognition is a demo feature';
  static const String voiceResultTitle = 'Did we hear this correctly?';
  static const String voiceUse = 'Use This';
  static const String voiceTryAgain = 'Try Again';
  static const String selectCategoryTitle = 'Select a Category';

  // Budgets
  static const String budget = 'Budget';
  static const String budgetOverview = 'Budget Overview';
  static const String editBudget = 'Edit Budget';
  static const String monthlyLimit = 'Monthly Limit';
  static const String budgetPeriod = 'Period';
  static const String budgetMonthly = 'Monthly';
  static const String perCategory = 'Per Category';
  static const String budgetUpdated = 'Budget updated successfully';
  static const String used = 'Used';
  static const String ofText = 'of';

  // Analytics
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String totalSpent = 'Total Spent';
  static const String byCategory = 'By Category';
  static const String monthlyTrend = 'Monthly Trend';
  static const String averageDailySpend = 'Average Daily Spend';
  static const String highestSpendingDay = 'Highest Spending Day';
  static const String noDataYet = 'No data yet';

  // Goals
  static const String savingsGoals = 'Savings Goals';
  static const String createGoal = 'Create Goal';
  static const String addMoney = 'Add Money';
  static const String targetAmount = 'Target Amount';
  static const String savedAmount = 'Saved Amount';
  static const String monthlySaving = 'Monthly Saving';
  static const String targetDate = 'Target Date';
  static const String goalCreated = 'Goal created successfully';
  static const String moneyAdded = 'Money added to goal';
  static const String goalComplete = 'Goal Achieved!';
  static const String goalCompleteSubtitle = 'You reached your target. Congratulations!';
  static const String remainingToSave = 'remaining to save';
  static const String noGoals = 'No goals yet';
  static const String noGoalsSubtitle = 'Tap the + button to create your first savings goal.';

  // Advice
  static const String smartAdvice = 'Smart Advice';
  static const String adviceGreeting = "You're doing great!";
  static const String adviceGreetingSubtitle =
      'Here are some insights based on your spending this month.';
  static const String adviceDemoLabel = 'Sample insights for demonstration';
  static const String adviceFood = 'Food & Dining is your biggest category';
  static const String adviceFoodBody =
      'Consider cooking at home a couple more nights a week to save up to Rs. 1,500.';
  static const String adviceTransport = 'You spent on transport';
  static const String adviceTransportBody =
      'Carpooling or riding public transit twice a week could save around Rs. 500.';
  static const String adviceBudget = 'Budget pacing';
  static const String adviceBudgetBody =
      'You are on track with your monthly budget. Keep your daily spend under Rs. 500 to stay safe.';
  static const String adviceSaving = 'Boost your savings';
  static const String adviceSavingBody =
      'You have Rs. 0 left over this month. Consider increasing your Emergency Fund contribution.';

  // Notifications
  static const String notifications = 'Notifications';
  static const String markAllRead = 'Mark All Read';
  static const String noNotifications = 'No notifications yet';
  static const String noNotificationsSubtitle =
      'Budget alerts and savings reminders will appear here.';

  // Profile & settings
  static const String profile = 'Profile';
  static const String personalInfo = 'Personal Info';
  static const String budgetSettings = 'Budget Settings';
  static const String notifPreferences = 'Notifications';
  static const String securityPrivacy = 'Security & Privacy';
  static const String languageCurrency = 'Language & Currency';
  static const String theme = 'Theme';
  static const String generalSettings = 'General Settings';
  static const String logOut = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String logoutConfirmBody =
      'You will be returned to the login screen. Your sample data will remain.';
  static const String editProfile = 'Edit Profile';
  static const String profileUpdated = 'Profile updated successfully';
  static const String budgetAlerts = 'Budget Alerts';
  static const String budgetAlertsSubtitle = 'Get notified when you near 80% of your budget';
  static const String lowBalanceReminder = 'Low Balance Reminder';
  static const String lowBalanceSubtitle = 'Remind me when only 20% of my budget is left';
  static const String savingsGoalUpdates = 'Savings Goal Updates';
  static const String savingsGoalSubtitle = 'Progress and milestone alerts for goals';
  static const String currencySelection = 'Currency';
  static const String themeSettings = 'Theme';
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String system = 'System';
  static const String lightSubtitle = 'Bright and clean';
  static const String darkSubtitle = 'Easy on the eyes';
  static const String systemSubtitle = 'Match device setting';
  static const String securitySubtitle = 'Biometrics, app lock (demo)';
  static const String languageHint = 'App language is English only in this demo';

  // Misc
  static const String confirm = 'Confirm';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String deleteExpenseConfirm = 'Delete this expense?';
  static const String deleteExpenseConfirmBody = 'This action cannot be undone.';
}
