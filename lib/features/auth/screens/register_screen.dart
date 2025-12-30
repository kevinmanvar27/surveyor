import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/image_utils.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/auth_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Image state
  Uint8List? _imageBytes;
  String? _profileImageBase64;
  bool _isCompressingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      // Pick image with crop confirmation dialog
      final result = await ImageUtils.pickImageWithCropConfirmation(
        context: context,
        source: source,
        cropStyle: CropStyle.circle,
        toolbarTitle: 'Crop Profile Image',
      );

      if (result == null) return;
      if (!mounted) return;

      setState(() {
        _isCompressingImage = true;
      });

      // Read image bytes for preview
      final bytes = await File(result.path!).readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });

      // Compress and convert to base64
      String? base64;
      if (result.wasCropped) {
        base64 = await ImageUtils.compressCroppedAndConvertToBase64(
          CroppedFile(result.path!),
        );
      } else {
        base64 = await ImageUtils.compressAndConvertToBase64(
          XFile(result.path!),
        );
      }

      setState(() {
        _profileImageBase64 = base64;
        _isCompressingImage = false;
      });

      if (base64 != null && mounted) {
        final compressedSize = base64.length * 3 ~/ 4; // Approximate decoded size
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image compressed to ${ImageUtils.formatFileSize(compressedSize)}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCompressingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.selectProfileImage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: Text(loc.camera),
                subtitle: Text(loc.takeNewPhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: AppColors.primary),
                ),
                title: Text(loc.gallery),
                subtitle: Text(loc.selectExistingPhoto),
                onTap: () {
                  Navigator.pop(context);
                  _pickAndCropImage(ImageSource.gallery);
                },
              ),
              if (_imageBytes != null) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: AppColors.error),
                  ),
                  title: Text(loc.removeProfileImage),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageBytes = null;
                      _profileImageBase64 = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isCompressingImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for image compression to complete'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
          companyName: _companyNameController.text.trim(),
          profileImageBase64: _profileImageBase64,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated) {
        // Clear entire navigation stack to prevent back navigation to login
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.register),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                Text(
                  loc.createAccount,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.fillDetailsToRegister,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                ),
                
                const SizedBox(height: 32),
                
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark 
                                ? AppColors.darkSurface 
                                : AppColors.backgroundSecondary,
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                              width: 3,
                            ),
                            image: _imageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_imageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _imageBytes == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: isDark 
                                      ? AppColors.darkTextSecondary 
                                      : AppColors.textSecondary,
                                )
                              : null,
                        ),
                        if (_isCompressingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark 
                                    ? AppColors.darkBackground 
                                    : Colors.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              _imageBytes != null ? Icons.edit : Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    loc.tapToAddProfilePhoto,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark 
                              ? AppColors.darkTextSecondary 
                              : AppColors.textSecondary,
                        ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Name Field
                AuthTextField(
                  controller: _nameController,
                  label: loc.name,
                  hint: loc.enterName,
                  keyboardType: TextInputType.name,
                  prefixIcon: Icons.person_outline,
                  validator: (value) => Validators.validateRequired(
                    value,
                    message: loc.nameRequired,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Company Name Field
                AuthTextField(
                  controller: _companyNameController,
                  label: loc.companyName,
                  hint: loc.enterCompanyName,
                  keyboardType: TextInputType.text,
                  prefixIcon: Icons.business_outlined,
                  validator: (value) => Validators.validateRequired(
                    value,
                    message: loc.companyNameRequired,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                AuthTextField(
                  controller: _emailController,
                  label: loc.email,
                  hint: loc.enterEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) => Validators.validateEmail(
                    value,
                    emptyMessage: loc.emailRequired,
                    invalidMessage: loc.invalidEmail,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                AuthTextField(
                  controller: _passwordController,
                  label: loc.password,
                  hint: loc.enterPassword,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) => Validators.validatePassword(
                    value,
                    emptyMessage: loc.passwordRequired,
                    shortMessage: loc.passwordTooShort,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                AuthTextField(
                  controller: _confirmPasswordController,
                  label: loc.confirmPassword,
                  hint: loc.enterConfirmPassword,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) => Validators.validateConfirmPassword(
                    value,
                    _passwordController.text,
                    emptyMessage: loc.confirmPasswordRequired,
                    mismatchMessage: loc.passwordsDoNotMatch,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Register Button
                AuthButton(
                  text: loc.register,
                  isLoading: authState.isLoading || _isCompressingImage,
                  onPressed: _handleRegister,
                ),
                
                const SizedBox(height: 24),
                
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      loc.alreadyHaveAccount,
                      style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(loc.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
