import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_button.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    final error = Validators.validateOtp(otp);
    
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).verifyOtp(otp);
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    final phoneNumber = Validators.formatPhoneWithCountryCode(widget.phoneNumber);
    await ref.read(authProvider.notifier).sendOtp(phoneNumber);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.surveyList,
          (route) => false,
        );
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    // Pinput theme
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        border: Border.all(color: Theme.of(context).primaryColor),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.verifyOtp),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                loc.enterOtp,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${loc.otpSentTo} ${Validators.formatPhoneNumber(widget.phoneNumber)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input using Pinput
              Center(
                child: Pinput(
                  length: 6,
                  controller: _otpController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  keyboardType: TextInputType.number,
                  onCompleted: (value) {
                    _handleVerifyOtp();
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend Timer
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _handleResendOtp,
                        child: Text(loc.resendOtp),
                      )
                    : Text(
                        '${loc.resendOtpIn} $_remainingSeconds ${loc.seconds}',
                        style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                      ),
              ),
              
              const SizedBox(height: 32),
              
              // Verify Button
              AuthButton(
                text: loc.verify,
                isLoading: authState.isLoading,
                onPressed: _handleVerifyOtp,
              ),
              
              const SizedBox(height: 24),
              
              // Change Number
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(authProvider.notifier).resetOtpState();
                    Navigator.of(context).pop();
                  },
                  child: Text(loc.changePhoneNumber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
