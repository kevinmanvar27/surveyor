import 'package:flutter/material.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/phone_login_screen.dart';
import '../../features/auth/screens/otp_verification_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/survey/screens/survey_list_screen.dart';
import '../../features/survey/screens/survey_form_screen.dart';
import '../../features/survey/screens/survey_detail_screen.dart';
import '../../features/invoice/screens/invoice_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/edit_profile_screen.dart';
import '../../features/expense/screens/expense_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneLogin = '/phone-login';
  static const String otpVerification = '/otp-verification';
  static const String forgotPassword = '/forgot-password';
  static const String surveyList = '/surveys';
  static const String surveyForm = '/survey-form';
  static const String surveyDetail = '/survey-detail';
  static const String invoice = '/invoice';
  static const String settings = '/settings';
  static const String editProfile = '/settings/edit-profile';
  static const String expenses = '/expenses';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
        
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );
        
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );
        
      case AppRoutes.phoneLogin:
        return MaterialPageRoute(
          builder: (_) => const PhoneLoginScreen(),
        );
        
      case AppRoutes.otpVerification:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: args?['phoneNumber'] ?? '',
          ),
        );
        
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
        
      case AppRoutes.surveyList:
        return MaterialPageRoute(
          builder: (_) => const SurveyListScreen(),
        );
        
      case AppRoutes.surveyForm:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => SurveyFormScreen(
            surveyId: args?['surveyId'],
          ),
        );
        
      case AppRoutes.surveyDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SurveyDetailScreen(
            surveyId: args['surveyId'],
          ),
        );
        
      case AppRoutes.invoice:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InvoiceScreen(
            surveyId: args['surveyId'],
          ),
        );
        
      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );
        
      case AppRoutes.editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );
        
      case AppRoutes.expenses:
        return MaterialPageRoute(
          builder: (_) => const ExpenseScreen(),
        );
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
