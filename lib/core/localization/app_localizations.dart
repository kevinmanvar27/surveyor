import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../constants/app_strings.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  // Helper method to reduce boilerplate
  String _getString(String en, String hi, String gu) {
    switch (locale.languageCode) {
      case 'hi': return hi;
      case 'gu': return gu;
      default: return en;
    }
  }
  
  // ==================== General ====================
  String get appName => _getString(AppStringsEn.appName, AppStringsHi.appName, AppStringsGu.appName);
  String get surveyManagement => _getString(AppStringsEn.surveyManagement, AppStringsHi.surveyManagement, AppStringsGu.surveyManagement);
  String get loading => _getString(AppStringsEn.loading, AppStringsHi.loading, AppStringsGu.loading);
  String get error => _getString(AppStringsEn.error, AppStringsHi.error, AppStringsGu.error);
  String get success => _getString(AppStringsEn.success, AppStringsHi.success, AppStringsGu.success);
  String get cancel => _getString(AppStringsEn.cancel, AppStringsHi.cancel, AppStringsGu.cancel);
  String get save => _getString(AppStringsEn.save, AppStringsHi.save, AppStringsGu.save);
  String get delete => _getString(AppStringsEn.delete, AppStringsHi.delete, AppStringsGu.delete);
  String get edit => _getString(AppStringsEn.edit, AppStringsHi.edit, AppStringsGu.edit);
  String get add => _getString(AppStringsEn.add, AppStringsHi.add, AppStringsGu.add);
  String get search => _getString(AppStringsEn.search, AppStringsHi.search, AppStringsGu.search);
  String get filter => _getString(AppStringsEn.filter, AppStringsHi.filter, AppStringsGu.filter);
  String get sort => _getString(AppStringsEn.sort, AppStringsHi.sort, AppStringsGu.sort);
  String get refresh => _getString(AppStringsEn.refresh, AppStringsHi.refresh, AppStringsGu.refresh);
  String get retry => _getString(AppStringsEn.retry, AppStringsHi.retry, AppStringsGu.retry);
  String get ok => _getString(AppStringsEn.ok, AppStringsHi.ok, AppStringsGu.ok);
  String get yes => _getString(AppStringsEn.yes, AppStringsHi.yes, AppStringsGu.yes);
  String get no => _getString(AppStringsEn.no, AppStringsHi.no, AppStringsGu.no);
  String get close => _getString(AppStringsEn.close, AppStringsHi.close, AppStringsGu.close);
  String get submit => _getString(AppStringsEn.submit, AppStringsHi.submit, AppStringsGu.submit);
  String get update => _getString(AppStringsEn.update, AppStringsHi.update, AppStringsGu.update);
  String get noData => _getString(AppStringsEn.noData, AppStringsHi.noData, AppStringsGu.noData);
  String get offline => _getString(AppStringsEn.offline, AppStringsHi.offline, AppStringsGu.offline);
  String get online => _getString(AppStringsEn.online, AppStringsHi.online, AppStringsGu.online);
  String get reset => _getString(AppStringsEn.reset, AppStringsHi.reset, AppStringsGu.reset);
  String get all => _getString(AppStringsEn.all, AppStringsHi.all, AppStringsGu.all);
  String get apply => _getString(AppStringsEn.apply, AppStringsHi.apply, AppStringsGu.apply);
  String get generating => _getString(AppStringsEn.generating, AppStringsHi.generating, AppStringsGu.generating);
  String get downloading => _getString(AppStringsEn.downloading, AppStringsHi.downloading, AppStringsGu.downloading);
  String get sharing => _getString(AppStringsEn.sharing, AppStringsHi.sharing, AppStringsGu.sharing);
  String get uploading => _getString(AppStringsEn.uploading, AppStringsHi.uploading, AppStringsGu.uploading);
  String get call => _getString(AppStringsEn.call, AppStringsHi.call, AppStringsGu.call);
  String get copy => _getString(AppStringsEn.copy, AppStringsHi.copy, AppStringsGu.copy);
  String get share => _getString(AppStringsEn.share, AppStringsHi.share, AppStringsGu.share);
  String get print => _getString(AppStringsEn.print, AppStringsHi.print, AppStringsGu.print);
  String get camera => _getString(AppStringsEn.camera, AppStringsHi.camera, AppStringsGu.camera);
  String get gallery => _getString(AppStringsEn.gallery, AppStringsHi.gallery, AppStringsGu.gallery);
  
  // ==================== Auth ====================
  String get login => _getString(AppStringsEn.login, AppStringsHi.login, AppStringsGu.login);
  String get logout => _getString(AppStringsEn.logout, AppStringsHi.logout, AppStringsGu.logout);
  String get register => _getString(AppStringsEn.register, AppStringsHi.register, AppStringsGu.register);
  String get email => _getString(AppStringsEn.email, AppStringsHi.email, AppStringsGu.email);
  String get password => _getString(AppStringsEn.password, AppStringsHi.password, AppStringsGu.password);
  String get confirmPassword => _getString(AppStringsEn.confirmPassword, AppStringsHi.confirmPassword, AppStringsGu.confirmPassword);
  String get phoneNumber => _getString(AppStringsEn.phoneNumber, AppStringsHi.phoneNumber, AppStringsGu.phoneNumber);
  String get enterOtp => _getString(AppStringsEn.enterOtp, AppStringsHi.enterOtp, AppStringsGu.enterOtp);
  String get verifyOtp => _getString(AppStringsEn.verifyOtp, AppStringsHi.verifyOtp, AppStringsGu.verifyOtp);
  String get sendOtp => _getString(AppStringsEn.sendOtp, AppStringsHi.sendOtp, AppStringsGu.sendOtp);
  String get resendOtp => _getString(AppStringsEn.resendOtp, AppStringsHi.resendOtp, AppStringsGu.resendOtp);
  String get loginWithPhone => _getString(AppStringsEn.loginWithPhone, AppStringsHi.loginWithPhone, AppStringsGu.loginWithPhone);
  String get loginWithEmail => _getString(AppStringsEn.loginWithEmail, AppStringsHi.loginWithEmail, AppStringsGu.loginWithEmail);
  String get forgotPassword => _getString(AppStringsEn.forgotPassword, AppStringsHi.forgotPassword, AppStringsGu.forgotPassword);
  String get resetPassword => _getString(AppStringsEn.resetPassword, AppStringsHi.resetPassword, AppStringsGu.resetPassword);
  String get invalidEmail => _getString(AppStringsEn.invalidEmail, AppStringsHi.invalidEmail, AppStringsGu.invalidEmail);
  String get invalidPassword => _getString(AppStringsEn.invalidPassword, AppStringsHi.invalidPassword, AppStringsGu.invalidPassword);
  String get invalidPhone => _getString(AppStringsEn.invalidPhone, AppStringsHi.invalidPhone, AppStringsGu.invalidPhone);
  String get authFailed => _getString(AppStringsEn.authFailed, AppStringsHi.authFailed, AppStringsGu.authFailed);
  String get otpSent => _getString(AppStringsEn.otpSent, AppStringsHi.otpSent, AppStringsGu.otpSent);
  String get otpVerified => _getString(AppStringsEn.otpVerified, AppStringsHi.otpVerified, AppStringsGu.otpVerified);
  String get logoutConfirm => _getString(AppStringsEn.logoutConfirm, AppStringsHi.logoutConfirm, AppStringsGu.logoutConfirm);
  String get logoutConfirmation => _getString(AppStringsEn.logoutConfirmation, AppStringsHi.logoutConfirmation, AppStringsGu.logoutConfirmation);
  String get createAccount => _getString(AppStringsEn.createAccount, AppStringsHi.createAccount, AppStringsGu.createAccount);
  String get alreadyHaveAccount => _getString(AppStringsEn.alreadyHaveAccount, AppStringsHi.alreadyHaveAccount, AppStringsGu.alreadyHaveAccount);
  String get dontHaveAccount => _getString(AppStringsEn.dontHaveAccount, AppStringsHi.dontHaveAccount, AppStringsGu.dontHaveAccount);
  String get signUp => _getString(AppStringsEn.signUp, AppStringsHi.signUp, AppStringsGu.signUp);
  String get signIn => _getString(AppStringsEn.signIn, AppStringsHi.signIn, AppStringsGu.signIn);
  String get otpSentTo => _getString(AppStringsEn.otpSentTo, AppStringsHi.otpSentTo, AppStringsGu.otpSentTo);
  String get resendIn => _getString(AppStringsEn.resendIn, AppStringsHi.resendIn, AppStringsGu.resendIn);
  String get seconds => _getString(AppStringsEn.seconds, AppStringsHi.seconds, AppStringsGu.seconds);
  String get enterEmailForReset => _getString(AppStringsEn.enterEmailForReset, AppStringsHi.enterEmailForReset, AppStringsGu.enterEmailForReset);
  String get enterEmailToReset => _getString(AppStringsEn.enterEmailToReset, AppStringsHi.enterEmailToReset, AppStringsGu.enterEmailToReset);
  String get resetLinkSent => _getString(AppStringsEn.resetLinkSent, AppStringsHi.resetLinkSent, AppStringsGu.resetLinkSent);
  String get passwordsDoNotMatch => _getString(AppStringsEn.passwordsDoNotMatch, AppStringsHi.passwordsDoNotMatch, AppStringsGu.passwordsDoNotMatch);
  String get enterEmail => _getString(AppStringsEn.enterEmail, AppStringsHi.enterEmail, AppStringsGu.enterEmail);
  String get enterPassword => _getString(AppStringsEn.enterPassword, AppStringsHi.enterPassword, AppStringsGu.enterPassword);
  String get enterPhoneNumber => _getString(AppStringsEn.enterPhoneNumber, AppStringsHi.enterPhoneNumber, AppStringsGu.enterPhoneNumber);
  String get notLoggedIn => _getString(AppStringsEn.notLoggedIn, AppStringsHi.notLoggedIn, AppStringsGu.notLoggedIn);
  String get emailRequired => _getString(AppStringsEn.emailRequired, AppStringsHi.emailRequired, AppStringsGu.emailRequired);
  String get passwordRequired => _getString(AppStringsEn.passwordRequired, AppStringsHi.passwordRequired, AppStringsGu.passwordRequired);
  String get sendResetLink => _getString(AppStringsEn.sendResetLink, AppStringsHi.sendResetLink, AppStringsGu.sendResetLink);
  String get backToLogin => _getString(AppStringsEn.backToLogin, AppStringsHi.backToLogin, AppStringsGu.backToLogin);
  String get emailSent => _getString(AppStringsEn.emailSent, AppStringsHi.emailSent, AppStringsGu.emailSent);
  String get checkEmailForReset => _getString(AppStringsEn.checkEmailForReset, AppStringsHi.checkEmailForReset, AppStringsGu.checkEmailForReset);
  String get openEmailApp => _getString(AppStringsEn.openEmailApp, AppStringsHi.openEmailApp, AppStringsGu.openEmailApp);
  String get tryDifferentEmail => _getString(AppStringsEn.tryDifferentEmail, AppStringsHi.tryDifferentEmail, AppStringsGu.tryDifferentEmail);
  String get loginToYourAccount => _getString(AppStringsEn.loginToYourAccount, AppStringsHi.loginToYourAccount, AppStringsGu.loginToYourAccount);
  String get or => _getString(AppStringsEn.or, AppStringsHi.or, AppStringsGu.or);
  String get phoneLogin => _getString(AppStringsEn.phoneLogin, AppStringsHi.phoneLogin, AppStringsGu.phoneLogin);
  String get weWillSendOtp => _getString(AppStringsEn.weWillSendOtp, AppStringsHi.weWillSendOtp, AppStringsGu.weWillSendOtp);
  String get phoneRequired => _getString(AppStringsEn.phoneRequired, AppStringsHi.phoneRequired, AppStringsGu.phoneRequired);
  String get fillDetailsToRegister => _getString(AppStringsEn.fillDetailsToRegister, AppStringsHi.fillDetailsToRegister, AppStringsGu.fillDetailsToRegister);
  String get name => _getString(AppStringsEn.name, AppStringsHi.name, AppStringsGu.name);
  String get enterName => _getString(AppStringsEn.enterName, AppStringsHi.enterName, AppStringsGu.enterName);
  String get nameRequired => _getString(AppStringsEn.nameRequired, AppStringsHi.nameRequired, AppStringsGu.nameRequired);
  String get passwordTooShort => _getString(AppStringsEn.passwordTooShort, AppStringsHi.passwordTooShort, AppStringsGu.passwordTooShort);
  String get enterConfirmPassword => _getString(AppStringsEn.enterConfirmPassword, AppStringsHi.enterConfirmPassword, AppStringsGu.enterConfirmPassword);
  String get confirmPasswordRequired => _getString(AppStringsEn.confirmPasswordRequired, AppStringsHi.confirmPasswordRequired, AppStringsGu.confirmPasswordRequired);
  String get resendOtpIn => _getString(AppStringsEn.resendOtpIn, AppStringsHi.resendOtpIn, AppStringsGu.resendOtpIn);
  String get verify => _getString(AppStringsEn.verify, AppStringsHi.verify, AppStringsGu.verify);
  String get changePhoneNumber => _getString(AppStringsEn.changePhoneNumber, AppStringsHi.changePhoneNumber, AppStringsGu.changePhoneNumber);
  String get noSearchResults => _getString(AppStringsEn.noSearchResults, AppStringsHi.noSearchResults, AppStringsGu.noSearchResults);
  String get addFirstSurvey => _getString(AppStringsEn.addFirstSurvey, AppStringsHi.addFirstSurvey, AppStringsGu.addFirstSurvey);
  String get total => _getString(AppStringsEn.total, AppStringsHi.total, AppStringsGu.total);
  String get pending => _getString(AppStringsEn.pending, AppStringsHi.pending, AppStringsGu.pending);
  String get noSelection => _getString(AppStringsEn.noSelection, AppStringsHi.noSelection, AppStringsGu.noSelection);
  String get offlineMode => _getString('Offline Mode', 'ऑफ़लाइन मोड', 'ઓફલાઇન મોડ');
  
  // ==================== Survey ====================
  String get surveys => _getString(AppStringsEn.surveys, AppStringsHi.surveys, AppStringsGu.surveys);
  String get addSurvey => _getString(AppStringsEn.addSurvey, AppStringsHi.addSurvey, AppStringsGu.addSurvey);
  String get editSurvey => _getString(AppStringsEn.editSurvey, AppStringsHi.editSurvey, AppStringsGu.editSurvey);
  String get surveyDetails => _getString(AppStringsEn.surveyDetails, AppStringsHi.surveyDetails, AppStringsGu.surveyDetails);
  String get villageName => _getString(AppStringsEn.villageName, AppStringsHi.villageName, AppStringsGu.villageName);
  String get surveyNumber => _getString(AppStringsEn.surveyNumber, AppStringsHi.surveyNumber, AppStringsGu.surveyNumber);
  String get mobileNumber => _getString(AppStringsEn.mobileNumber, AppStringsHi.mobileNumber, AppStringsGu.mobileNumber);
  String get applicantName => _getString(AppStringsEn.applicantName, AppStringsHi.applicantName, AppStringsGu.applicantName);
  String get mapType => _getString(AppStringsEn.mapType, AppStringsHi.mapType, AppStringsGu.mapType);
  String get government => _getString(AppStringsEn.government, AppStringsHi.government, AppStringsGu.government);
  String get privateType => _getString(AppStringsEn.private, AppStringsHi.private, AppStringsGu.private);
  String get totalPayment => _getString(AppStringsEn.totalPayment, AppStringsHi.totalPayment, AppStringsGu.totalPayment);
  String get receivedPayment => _getString(AppStringsEn.receivedPayment, AppStringsHi.receivedPayment, AppStringsGu.receivedPayment);
  String get pendingPayment => _getString(AppStringsEn.pendingPayment, AppStringsHi.pendingPayment, AppStringsGu.pendingPayment);
  String get status => _getString(AppStringsEn.status, AppStringsHi.status, AppStringsGu.status);
  String get working => _getString(AppStringsEn.working, AppStringsHi.working, AppStringsGu.working);
  String get waiting => _getString(AppStringsEn.waiting, AppStringsHi.waiting, AppStringsGu.waiting);
  String get done => _getString(AppStringsEn.done, AppStringsHi.done, AppStringsGu.done);
  String get createdAt => _getString(AppStringsEn.createdAt, AppStringsHi.createdAt, AppStringsGu.createdAt);
  String get updatedAt => _getString(AppStringsEn.updatedAt, AppStringsHi.updatedAt, AppStringsGu.updatedAt);
  String get surveySaved => _getString(AppStringsEn.surveySaved, AppStringsHi.surveySaved, AppStringsGu.surveySaved);
  String get surveyUpdated => _getString(AppStringsEn.surveyUpdated, AppStringsHi.surveyUpdated, AppStringsGu.surveyUpdated);
  String get surveyDeleted => _getString(AppStringsEn.surveyDeleted, AppStringsHi.surveyDeleted, AppStringsGu.surveyDeleted);
  String get deleteSurveyConfirm => _getString(AppStringsEn.deleteSurveyConfirm, AppStringsHi.deleteSurveyConfirm, AppStringsGu.deleteSurveyConfirm);
  String get searchSurveys => _getString(AppStringsEn.searchSurveys, AppStringsHi.searchSurveys, AppStringsGu.searchSurveys);
  String get filterByStatus => _getString(AppStringsEn.filterByStatus, AppStringsHi.filterByStatus, AppStringsGu.filterByStatus);
  String get sortBy => _getString(AppStringsEn.sortBy, AppStringsHi.sortBy, AppStringsGu.sortBy);
  String get sortByDate => _getString(AppStringsEn.sortByDate, AppStringsHi.sortByDate, AppStringsGu.sortByDate);
  String get sortByPending => _getString(AppStringsEn.sortByPending, AppStringsHi.sortByPending, AppStringsGu.sortByPending);
  String get allStatus => _getString(AppStringsEn.allStatus, AppStringsHi.allStatus, AppStringsGu.allStatus);
  String get surveyCreated => _getString(AppStringsEn.surveyCreated, AppStringsHi.surveyCreated, AppStringsGu.surveyCreated);
  String get enterVillageName => _getString(AppStringsEn.enterVillageName, AppStringsHi.enterVillageName, AppStringsGu.enterVillageName);
  String get surveyNumberRequired => _getString(AppStringsEn.surveyNumberRequired, AppStringsHi.surveyNumberRequired, AppStringsGu.surveyNumberRequired);
  String get enterSurveyNumber => _getString(AppStringsEn.enterSurveyNumber, AppStringsHi.enterSurveyNumber, AppStringsGu.enterSurveyNumber);
  String get enterApplicantName => _getString(AppStringsEn.enterApplicantName, AppStringsHi.enterApplicantName, AppStringsGu.enterApplicantName);
  String get applicantNameRequired => _getString(AppStringsEn.applicantNameRequired, AppStringsHi.applicantNameRequired, AppStringsGu.applicantNameRequired);
  String get enterMobileNumber => _getString(AppStringsEn.enterMobileNumber, AppStringsHi.enterMobileNumber, AppStringsGu.enterMobileNumber);
  String get mobileNumberRequired => _getString(AppStringsEn.mobileNumberRequired, AppStringsHi.mobileNumberRequired, AppStringsGu.mobileNumberRequired);
  String get villageNameRequired => _getString(AppStringsEn.villageNameRequired, AppStringsHi.villageNameRequired, AppStringsGu.villageNameRequired);
  String get totalPaymentRequired => _getString(AppStringsEn.totalPaymentRequired, AppStringsHi.totalPaymentRequired, AppStringsGu.totalPaymentRequired);
  String get enterTotalPayment => _getString(AppStringsEn.enterTotalPayment, AppStringsHi.enterTotalPayment, AppStringsGu.enterTotalPayment);
  String get enterReceivedPayment => _getString(AppStringsEn.enterReceivedPayment, AppStringsHi.enterReceivedPayment, AppStringsGu.enterReceivedPayment);
  String get deleteSurvey => _getString(AppStringsEn.deleteSurvey, AppStringsHi.deleteSurvey, AppStringsGu.deleteSurvey);
  String get deleteSurveyConfirmation => _getString(AppStringsEn.deleteSurveyConfirmation, AppStringsHi.deleteSurveyConfirmation, AppStringsGu.deleteSurveyConfirmation);
  String get errorLoadingSurvey => _getString(AppStringsEn.errorLoadingSurvey, AppStringsHi.errorLoadingSurvey, AppStringsGu.errorLoadingSurvey);
  String get surveyNotFound => _getString(AppStringsEn.surveyNotFound, AppStringsHi.surveyNotFound, AppStringsGu.surveyNotFound);
  String get surveyInformation => _getString(AppStringsEn.surveyInformation, AppStringsHi.surveyInformation, AppStringsGu.surveyInformation);
  String get applicantInformation => _getString(AppStringsEn.applicantInformation, AppStringsHi.applicantInformation, AppStringsGu.applicantInformation);
  String get phoneCopied => _getString(AppStringsEn.phoneCopied, AppStringsHi.phoneCopied, AppStringsGu.phoneCopied);
  String get paymentPending => _getString(AppStringsEn.paymentPending, AppStringsHi.paymentPending, AppStringsGu.paymentPending);
  String get current => _getString(AppStringsEn.current, AppStringsHi.current, AppStringsGu.current);
  String get tapToViewInvoice => _getString(AppStringsEn.tapToViewInvoice, AppStringsHi.tapToViewInvoice, AppStringsGu.tapToViewInvoice);
  String get noSurveys => _getString(AppStringsEn.noSurveys, AppStringsHi.noSurveys, AppStringsGu.noSurveys);
  String get noSurveysDescription => _getString(AppStringsEn.noSurveysDescription, AppStringsHi.noSurveysDescription, AppStringsGu.noSurveysDescription);
  String get noMatchingSurveys => _getString(AppStringsEn.noMatchingSurveys, AppStringsHi.noMatchingSurveys, AppStringsGu.noMatchingSurveys);
  String get tryDifferentSearch => _getString(AppStringsEn.tryDifferentSearch, AppStringsHi.tryDifferentSearch, AppStringsGu.tryDifferentSearch);
  String get filterAndSort => _getString(AppStringsEn.filterAndSort, AppStringsHi.filterAndSort, AppStringsGu.filterAndSort);
  String get applyFilters => _getString(AppStringsEn.applyFilters, AppStringsHi.applyFilters, AppStringsGu.applyFilters);
  String get newestFirst => _getString(AppStringsEn.newestFirst, AppStringsHi.newestFirst, AppStringsGu.newestFirst);
  String get oldestFirst => _getString(AppStringsEn.oldestFirst, AppStringsHi.oldestFirst, AppStringsGu.oldestFirst);
  String get highestPendingFirst => _getString(AppStringsEn.highestPendingFirst, AppStringsHi.highestPendingFirst, AppStringsGu.highestPendingFirst);
  String get lowestPendingFirst => _getString(AppStringsEn.lowestPendingFirst, AppStringsHi.lowestPendingFirst, AppStringsGu.lowestPendingFirst);
  String get notes => _getString(AppStringsEn.notes, AppStringsHi.notes, AppStringsGu.notes);
  String get enterNotes => _getString(AppStringsEn.enterNotes, AppStringsHi.enterNotes, AppStringsGu.enterNotes);
  
  // ==================== Invoice ====================
  String get invoice => _getString(AppStringsEn.invoice, AppStringsHi.invoice, AppStringsGu.invoice);
  String get generateInvoice => _getString(AppStringsEn.generateInvoice, AppStringsHi.generateInvoice, AppStringsGu.generateInvoice);
  String get downloadInvoice => _getString(AppStringsEn.downloadInvoice, AppStringsHi.downloadInvoice, AppStringsGu.downloadInvoice);
  String get invoiceGenerated => _getString(AppStringsEn.invoiceGenerated, AppStringsHi.invoiceGenerated, AppStringsGu.invoiceGenerated);
  String get invoiceDownloaded => _getString(AppStringsEn.invoiceDownloaded, AppStringsHi.invoiceDownloaded, AppStringsGu.invoiceDownloaded);
  String get invoiceNumber => _getString(AppStringsEn.invoiceNumber, AppStringsHi.invoiceNumber, AppStringsGu.invoiceNumber);
  String get invoiceDate => _getString(AppStringsEn.invoiceDate, AppStringsHi.invoiceDate, AppStringsGu.invoiceDate);
  String get paymentDetails => _getString(AppStringsEn.paymentDetails, AppStringsHi.paymentDetails, AppStringsGu.paymentDetails);
  String get surveyInfo => _getString(AppStringsEn.surveyInfo, AppStringsHi.surveyInfo, AppStringsGu.surveyInfo);
  String get thankYou => _getString(AppStringsEn.thankYou, AppStringsHi.thankYou, AppStringsGu.thankYou);
  String get invoiceNotAvailable => _getString(AppStringsEn.invoiceNotAvailable, AppStringsHi.invoiceNotAvailable, AppStringsGu.invoiceNotAvailable);
  String get surveyMustBeDone => _getString(AppStringsEn.surveyMustBeDone, AppStringsHi.surveyMustBeDone, AppStringsGu.surveyMustBeDone);
  String get currentStatus => _getString(AppStringsEn.currentStatus, AppStringsHi.currentStatus, AppStringsGu.currentStatus);
  String get invoiceDetails => _getString(AppStringsEn.invoiceDetails, AppStringsHi.invoiceDetails, AppStringsGu.invoiceDetails);
  String get isGenerating => _getString(AppStringsEn.isGenerating, AppStringsHi.isGenerating, AppStringsGu.isGenerating);
  String get generateInvoiceTitle => _getString(AppStringsEn.generateInvoiceTitle, AppStringsHi.generateInvoiceTitle, AppStringsGu.generateInvoiceTitle);
  String get generateInvoiceDescription => _getString(AppStringsEn.generateInvoiceDescription, AppStringsHi.generateInvoiceDescription, AppStringsGu.generateInvoiceDescription);
  String get invoiceReady => _getString(AppStringsEn.invoiceReady, AppStringsHi.invoiceReady, AppStringsGu.invoiceReady);
  String get invoiceReadyDescription => _getString(AppStringsEn.invoiceReadyDescription, AppStringsHi.invoiceReadyDescription, AppStringsGu.invoiceReadyDescription);
  String get shareInvoice => _getString(AppStringsEn.shareInvoice, AppStringsHi.shareInvoice, AppStringsGu.shareInvoice);
  String get uploadInvoice => _getString(AppStringsEn.uploadToCloud, AppStringsHi.uploadToCloud, AppStringsGu.uploadToCloud);
  String get uploadToCloud => _getString(AppStringsEn.uploadToCloud, AppStringsHi.uploadToCloud, AppStringsGu.uploadToCloud);
  String get regenerateInvoice => _getString(AppStringsEn.regenerateInvoice, AppStringsHi.regenerateInvoice, AppStringsGu.regenerateInvoice);
  String get uploadedToCloud => _getString(AppStringsEn.uploadedToCloud, AppStringsHi.uploadedToCloud, AppStringsGu.uploadedToCloud);
  String get invoiceUploaded => _getString(AppStringsEn.invoiceUploaded, AppStringsHi.invoiceUploaded, AppStringsGu.invoiceUploaded);
  String get preview => _getString(AppStringsEn.preview, AppStringsHi.preview, AppStringsGu.preview);
  String get download => _getString(AppStringsEn.download, AppStringsHi.download, AppStringsGu.download);
  
  // ==================== Validation ====================
  String get fieldRequired => _getString(AppStringsEn.fieldRequired, AppStringsHi.fieldRequired, AppStringsGu.fieldRequired);
  String get invalidNumber => _getString(AppStringsEn.invalidNumber, AppStringsHi.invalidNumber, AppStringsGu.invalidNumber);
  String get invalidAmount => _getString(AppStringsEn.invalidAmount, AppStringsHi.invalidAmount, AppStringsGu.invalidAmount);
  String get receivedExceedsTotal => _getString(AppStringsEn.receivedExceedsTotal, AppStringsHi.receivedExceedsTotal, AppStringsGu.receivedExceedsTotal);
  
  // ==================== Settings ====================
  String get settings => _getString(AppStringsEn.settings, AppStringsHi.settings, AppStringsGu.settings);
  String get language => _getString(AppStringsEn.language, AppStringsHi.language, AppStringsGu.language);
  String get english => _getString(AppStringsEn.english, AppStringsHi.english, AppStringsGu.english);
  String get hindi => _getString(AppStringsEn.hindi, AppStringsHi.hindi, AppStringsGu.hindi);
  String get gujarati => _getString(AppStringsEn.gujarati, AppStringsHi.gujarati, AppStringsGu.gujarati);
  String get selectLanguage => _getString(AppStringsEn.selectLanguage, AppStringsHi.selectLanguage, AppStringsGu.selectLanguage);
  String get profile => _getString(AppStringsEn.profile, AppStringsHi.profile, AppStringsGu.profile);
  String get about => _getString(AppStringsEn.about, AppStringsHi.about, AppStringsGu.about);
  String get version => _getString(AppStringsEn.version, AppStringsHi.version, AppStringsGu.version);
  String get account => _getString(AppStringsEn.account, AppStringsHi.account, AppStringsGu.account);
  String get helpAndSupport => _getString(AppStringsEn.helpAndSupport, AppStringsHi.helpAndSupport, AppStringsGu.helpAndSupport);
  String get termsOfService => _getString(AppStringsEn.termsOfService, AppStringsHi.termsOfService, AppStringsGu.termsOfService);
  String get privacyPolicy => _getString(AppStringsEn.privacyPolicy, AppStringsHi.privacyPolicy, AppStringsGu.privacyPolicy);
  String get darkMode => _getString(AppStringsEn.darkMode, AppStringsHi.darkMode, AppStringsGu.darkMode);
  String get lightMode => _getString(AppStringsEn.lightMode, AppStringsHi.lightMode, AppStringsGu.lightMode);
  String get systemDefault => _getString(AppStringsEn.systemDefault, AppStringsHi.systemDefault, AppStringsGu.systemDefault);
  String get theme => _getString(AppStringsEn.theme, AppStringsHi.theme, AppStringsGu.theme);
  String get notifications => _getString(AppStringsEn.notifications, AppStringsHi.notifications, AppStringsGu.notifications);
  String get general => _getString(AppStringsEn.general, AppStringsHi.general, AppStringsGu.general);
  String get appearance => _getString(AppStringsEn.appearance, AppStringsHi.appearance, AppStringsGu.appearance);
  
  // ==================== Support & Help ====================
  String get privacyPolicyContent => _getString(AppStringsEn.privacyPolicyContent, AppStringsHi.privacyPolicyContent, AppStringsGu.privacyPolicyContent);
  String get contactUsMessage => _getString(AppStringsEn.contactUsMessage, AppStringsHi.contactUsMessage, AppStringsGu.contactUsMessage);
  String get emailCopied => _getString(AppStringsEn.emailCopied, AppStringsHi.emailCopied, AppStringsGu.emailCopied);
  String get copyEmail => _getString(AppStringsEn.copyEmail, AppStringsHi.copyEmail, AppStringsGu.copyEmail);
  
  // ==================== Delete Account ====================
  String get deleteAccount => _getString(AppStringsEn.deleteAccount, AppStringsHi.deleteAccount, AppStringsGu.deleteAccount);
  String get deleteAccountWarning => _getString(AppStringsEn.deleteAccountWarning, AppStringsHi.deleteAccountWarning, AppStringsGu.deleteAccountWarning);
  String get deleteAccountConfirmation => _getString(AppStringsEn.deleteAccountConfirmation, AppStringsHi.deleteAccountConfirmation, AppStringsGu.deleteAccountConfirmation);
  String get deleteAccountError => _getString(AppStringsEn.deleteAccountError, AppStringsHi.deleteAccountError, AppStringsGu.deleteAccountError);
  String get accountDeletedSuccess => _getString(AppStringsEn.accountDeletedSuccess, AppStringsHi.accountDeletedSuccess, AppStringsGu.accountDeletedSuccess);
  
  // ==================== Edit Profile ====================
  String get editProfile => _getString(AppStringsEn.editProfile, AppStringsHi.editProfile, AppStringsGu.editProfile);
  String get editProfileSubtitle => _getString(AppStringsEn.editProfileSubtitle, AppStringsHi.editProfileSubtitle, AppStringsGu.editProfileSubtitle);
  String get enterYourName => _getString(AppStringsEn.enterYourName, AppStringsHi.enterYourName, AppStringsGu.enterYourName);
  String get enterYourEmail => _getString(AppStringsEn.enterYourEmail, AppStringsHi.enterYourEmail, AppStringsGu.enterYourEmail);
  String get companyName => _getString(AppStringsEn.companyName, AppStringsHi.companyName, AppStringsGu.companyName);
  String get enterCompanyName => _getString(AppStringsEn.enterCompanyName, AppStringsHi.enterCompanyName, AppStringsGu.enterCompanyName);
  String get companyNameRequired => _getString(AppStringsEn.companyNameRequired, AppStringsHi.companyNameRequired, AppStringsGu.companyNameRequired);
  String get profileImage => _getString(AppStringsEn.profileImage, AppStringsHi.profileImage, AppStringsGu.profileImage);
  String get selectProfileImage => _getString(AppStringsEn.selectProfileImage, AppStringsHi.selectProfileImage, AppStringsGu.selectProfileImage);
  String get changeProfileImage => _getString(AppStringsEn.changeProfileImage, AppStringsHi.changeProfileImage, AppStringsGu.changeProfileImage);
  String get removeProfileImage => _getString(AppStringsEn.removeProfileImage, AppStringsHi.removeProfileImage, AppStringsGu.removeProfileImage);
  String get takeNewPhoto => _getString(AppStringsEn.takeNewPhoto, AppStringsHi.takeNewPhoto, AppStringsGu.takeNewPhoto);
  String get selectExistingPhoto => _getString(AppStringsEn.selectExistingPhoto, AppStringsHi.selectExistingPhoto, AppStringsGu.selectExistingPhoto);
  String get tapToAddProfilePhoto => _getString(AppStringsEn.tapToAddProfilePhoto, AppStringsHi.tapToAddProfilePhoto, AppStringsGu.tapToAddProfilePhoto);
  String get tapToEditPhoto => _getString(AppStringsEn.tapToEditPhoto, AppStringsHi.tapToEditPhoto, AppStringsGu.tapToEditPhoto);
  String get cropProfileImage => _getString(AppStringsEn.cropProfileImage, AppStringsHi.cropProfileImage, AppStringsGu.cropProfileImage);
  String get imageCompressedTo => _getString(AppStringsEn.imageCompressedTo, AppStringsHi.imageCompressedTo, AppStringsGu.imageCompressedTo);
  String get failedToProcessImage => _getString(AppStringsEn.failedToProcessImage, AppStringsHi.failedToProcessImage, AppStringsGu.failedToProcessImage);
  String get profileUpdatedSuccess => _getString(AppStringsEn.profileUpdatedSuccess, AppStringsHi.profileUpdatedSuccess, AppStringsGu.profileUpdatedSuccess);
  String get profileUpdateFailed => _getString(AppStringsEn.profileUpdateFailed, AppStringsHi.profileUpdateFailed, AppStringsGu.profileUpdateFailed);
  String get saveChanges => _getString(AppStringsEn.saveChanges, AppStringsHi.saveChanges, AppStringsGu.saveChanges);
  String get discardChanges => _getString(AppStringsEn.discardChanges, AppStringsHi.discardChanges, AppStringsGu.discardChanges);
  String get unsavedChanges => _getString(AppStringsEn.unsavedChanges, AppStringsHi.unsavedChanges, AppStringsGu.unsavedChanges);
  String get unsavedChangesMessage => _getString(AppStringsEn.unsavedChangesMessage, AppStringsHi.unsavedChangesMessage, AppStringsGu.unsavedChangesMessage);
  
  // ==================== Expenses ====================
  String get expenses => _getString(AppStringsEn.expenses, AppStringsHi.expenses, AppStringsGu.expenses);
  String get expenseTracking => _getString(AppStringsEn.expenseTracking, AppStringsHi.expenseTracking, AppStringsGu.expenseTracking);
  String get expenseTrackingSubtitle => _getString(AppStringsEn.expenseTrackingSubtitle, AppStringsHi.expenseTrackingSubtitle, AppStringsGu.expenseTrackingSubtitle);
  String get addExpense => _getString(AppStringsEn.addExpense, AppStringsHi.addExpense, AppStringsGu.addExpense);
  String get editExpense => _getString(AppStringsEn.editExpense, AppStringsHi.editExpense, AppStringsGu.editExpense);
  String get deleteExpense => _getString(AppStringsEn.deleteExpense, AppStringsHi.deleteExpense, AppStringsGu.deleteExpense);
  String get expenseDescription => _getString(AppStringsEn.expenseDescription, AppStringsHi.expenseDescription, AppStringsGu.expenseDescription);
  String get enterExpenseDescription => _getString(AppStringsEn.enterExpenseDescription, AppStringsHi.enterExpenseDescription, AppStringsGu.enterExpenseDescription);
  String get expenseAmount => _getString(AppStringsEn.expenseAmount, AppStringsHi.expenseAmount, AppStringsGu.expenseAmount);
  String get enterExpenseAmount => _getString(AppStringsEn.enterExpenseAmount, AppStringsHi.enterExpenseAmount, AppStringsGu.enterExpenseAmount);
  String get expenseCategory => _getString(AppStringsEn.expenseCategory, AppStringsHi.expenseCategory, AppStringsGu.expenseCategory);
  String get selectCategory => _getString(AppStringsEn.selectCategory, AppStringsHi.selectCategory, AppStringsGu.selectCategory);
  String get expenseDate => _getString(AppStringsEn.expenseDate, AppStringsHi.expenseDate, AppStringsGu.expenseDate);
  String get selectDate => _getString(AppStringsEn.selectDate, AppStringsHi.selectDate, AppStringsGu.selectDate);
  String get dailyExpenses => _getString(AppStringsEn.dailyExpenses, AppStringsHi.dailyExpenses, AppStringsGu.dailyExpenses);
  String get weeklyExpenses => _getString(AppStringsEn.weeklyExpenses, AppStringsHi.weeklyExpenses, AppStringsGu.weeklyExpenses);
  String get monthlyExpenses => _getString(AppStringsEn.monthlyExpenses, AppStringsHi.monthlyExpenses, AppStringsGu.monthlyExpenses);
  String get yearlyExpenses => _getString(AppStringsEn.yearlyExpenses, AppStringsHi.yearlyExpenses, AppStringsGu.yearlyExpenses);
  String get allExpenses => _getString(AppStringsEn.allExpenses, AppStringsHi.allExpenses, AppStringsGu.allExpenses);
  String get totalExpenses => _getString(AppStringsEn.totalExpenses, AppStringsHi.totalExpenses, AppStringsGu.totalExpenses);
  String get noExpenses => _getString(AppStringsEn.noExpenses, AppStringsHi.noExpenses, AppStringsGu.noExpenses);
  String get noExpensesDescription => _getString(AppStringsEn.noExpensesDescription, AppStringsHi.noExpensesDescription, AppStringsGu.noExpensesDescription);
  String get expenseAdded => _getString(AppStringsEn.expenseAdded, AppStringsHi.expenseAdded, AppStringsGu.expenseAdded);
  String get expenseUpdated => _getString(AppStringsEn.expenseUpdated, AppStringsHi.expenseUpdated, AppStringsGu.expenseUpdated);
  String get expenseDeleted => _getString(AppStringsEn.expenseDeleted, AppStringsHi.expenseDeleted, AppStringsGu.expenseDeleted);
  String get deleteExpenseConfirmation => _getString(AppStringsEn.deleteExpenseConfirmation, AppStringsHi.deleteExpenseConfirmation, AppStringsGu.deleteExpenseConfirmation);
  String get expenseDescriptionRequired => _getString(AppStringsEn.expenseDescriptionRequired, AppStringsHi.expenseDescriptionRequired, AppStringsGu.expenseDescriptionRequired);
  String get expenseAmountRequired => _getString(AppStringsEn.expenseAmountRequired, AppStringsHi.expenseAmountRequired, AppStringsGu.expenseAmountRequired);
  String get invalidExpenseAmount => _getString(AppStringsEn.invalidExpenseAmount, AppStringsHi.invalidExpenseAmount, AppStringsGu.invalidExpenseAmount);
  
  // ==================== Expense Categories ====================
  String get categoryTravel => _getString(AppStringsEn.categoryTravel, AppStringsHi.categoryTravel, AppStringsGu.categoryTravel);
  String get categoryEquipment => _getString(AppStringsEn.categoryEquipment, AppStringsHi.categoryEquipment, AppStringsGu.categoryEquipment);
  String get categoryFood => _getString(AppStringsEn.categoryFood, AppStringsHi.categoryFood, AppStringsGu.categoryFood);
  String get categoryFuel => _getString(AppStringsEn.categoryFuel, AppStringsHi.categoryFuel, AppStringsGu.categoryFuel);
  String get categoryAccommodation => _getString(AppStringsEn.categoryAccommodation, AppStringsHi.categoryAccommodation, AppStringsGu.categoryAccommodation);
  String get categoryCommunication => _getString(AppStringsEn.categoryCommunication, AppStringsHi.categoryCommunication, AppStringsGu.categoryCommunication);
  String get categoryOther => _getString(AppStringsEn.categoryOther, AppStringsHi.categoryOther, AppStringsGu.categoryOther);
  
  // ==================== Expense Summary ====================
  String get expenseSummary => _getString(AppStringsEn.expenseSummary, AppStringsHi.expenseSummary, AppStringsGu.expenseSummary);
  String get byCategory => _getString(AppStringsEn.byCategory, AppStringsHi.byCategory, AppStringsGu.byCategory);
  String get recentExpenses => _getString(AppStringsEn.recentExpenses, AppStringsHi.recentExpenses, AppStringsGu.recentExpenses);
  String get viewAll => _getString(AppStringsEn.viewAll, AppStringsHi.viewAll, AppStringsGu.viewAll);
  String get items => _getString(AppStringsEn.items, AppStringsHi.items, AppStringsGu.items);

  // ==================== Survey-Expense Linking ====================
  String get selectSurvey => _getString(AppStringsEn.selectSurvey, AppStringsHi.selectSurvey, AppStringsGu.selectSurvey);
  String get linkToSurvey => _getString(AppStringsEn.linkToSurvey, AppStringsHi.linkToSurvey, AppStringsGu.linkToSurvey);
  String get noWaitingSurveys => _getString(AppStringsEn.noWaitingSurveys, AppStringsHi.noWaitingSurveys, AppStringsGu.noWaitingSurveys);
  String get surveyExpenses => _getString(AppStringsEn.surveyExpenses, AppStringsHi.surveyExpenses, AppStringsGu.surveyExpenses);
  String get addExpenseForSurvey => _getString(AppStringsEn.addExpenseForSurvey, AppStringsHi.addExpenseForSurvey, AppStringsGu.addExpenseForSurvey);
  String get linkedToSurvey => _getString(AppStringsEn.linkedToSurvey, AppStringsHi.linkedToSurvey, AppStringsGu.linkedToSurvey);
  String get noLinkedExpenses => _getString(AppStringsEn.noLinkedExpenses, AppStringsHi.noLinkedExpenses, AppStringsGu.noLinkedExpenses);
  String get optional => _getString(AppStringsEn.optional, AppStringsHi.optional, AppStringsGu.optional);

  // ==================== Image Crop Confirmation ====================
  String get cropImage => _getString(AppStringsEn.cropImage, AppStringsHi.cropImage, AppStringsGu.cropImage);
  String get cropImageConfirmation => _getString(AppStringsEn.cropImageConfirmation, AppStringsHi.cropImageConfirmation, AppStringsGu.cropImageConfirmation);
  String get cropImageYes => _getString(AppStringsEn.cropImageYes, AppStringsHi.cropImageYes, AppStringsGu.cropImageYes);
  String get cropImageNo => _getString(AppStringsEn.cropImageNo, AppStringsHi.cropImageNo, AppStringsGu.cropImageNo);

  // ==================== Survey Form - Expenses Section ====================
  String get surveyExpensesSection => _getString(AppStringsEn.surveyExpensesSection, AppStringsHi.surveyExpensesSection, AppStringsGu.surveyExpensesSection);
  String get addExpenseToSurvey => _getString(AppStringsEn.addExpenseToSurvey, AppStringsHi.addExpenseToSurvey, AppStringsGu.addExpenseToSurvey);
  String get noExpensesForSurvey => _getString(AppStringsEn.noExpensesForSurvey, AppStringsHi.noExpensesForSurvey, AppStringsGu.noExpensesForSurvey);
  String get tapToAddExpense => _getString(AppStringsEn.tapToAddExpense, AppStringsHi.tapToAddExpense, AppStringsGu.tapToAddExpense);

  // ==================== Expense Screen - Calendar Picker ====================
  String get selectDateToView => _getString(AppStringsEn.selectDateToView, AppStringsHi.selectDateToView, AppStringsGu.selectDateToView);
  String get jumpToDate => _getString(AppStringsEn.jumpToDate, AppStringsHi.jumpToDate, AppStringsGu.jumpToDate);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'gu'].contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
