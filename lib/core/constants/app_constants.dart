class AppConstants {
  AppConstants._();
  
  // App Info
  static const String appName = 'Surveyor';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Survey Solutions';
  static const String companyAddress = 'Gujarat, India';
  static const String companyPhone = '+91 9876543210';
  static const String companyEmail = 'contact@surveysolutions.com';
  
  // Support & Legal
  static const String supportEmail = 'rektech.uk@gmail.com';
  
  // Firestore Collections
  static const String surveysCollection = 'surveys';
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  
  // Storage Paths
  static const String invoicesPath = 'invoices';
  static const String logoPath = 'assets/images/logo.png';
  
  // Currency
  static const String currencySymbol = '₹';
  
  // Splash Duration
  static const int splashDuration = 3;
  
  // Pagination
  static const int pageSize = 20;
  
  // Status Values
  static const String statusWorking = 'Working';
  static const String statusWaiting = 'Waiting';
  static const String statusDone = 'Done';
  
  // Map Types
  static const String mapTypeGovernment = 'Government';
  static const String mapTypePrivate = 'Private';
  
  // Shared Preferences Keys
  static const String prefLocale = 'locale';
  static const String prefUserId = 'user_id';
}

class ValidationConstants {
  ValidationConstants._();
  
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 10;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxSurveyNumberLength = 50;
  static const int maxVillageNameLength = 100;
}
