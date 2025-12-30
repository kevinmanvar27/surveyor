import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneNumber = Validators.formatPhoneWithCountryCode(
      _phoneController.text.trim(),
    );

    await ref.read(authProvider.notifier).sendOtp(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isOtpSent) {
        Navigator.of(context).pushNamed(
          AppRoutes.otpVerification,
          arguments: {'phoneNumber': _phoneController.text.trim()},
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.phoneLogin),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                Icon(
                  Icons.phone_android_outlined,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  loc.enterPhoneNumber,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.weWillSendOtp,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                ),
                
                const SizedBox(height: 48),
                
                // Phone Field with Country Code
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+91',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthTextField(
                        controller: _phoneController,
                        label: loc.phoneNumber,
                        hint: loc.enterPhoneNumber,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        maxLength: 10,
                        validator: (value) => Validators.validatePhone(
                          value,
                          emptyMessage: loc.phoneRequired,
                          invalidMessage: loc.invalidPhone,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Send OTP Button
                AuthButton(
                  text: loc.sendOtp,
                  isLoading: authState.isLoading,
                  onPressed: _handleSendOtp,
                ),
                
                const SizedBox(height: 24),
                
                // Back to Email Login
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: Text(loc.loginWithEmail),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
