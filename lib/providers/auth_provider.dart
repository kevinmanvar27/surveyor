import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// Auth state enum
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Auth state class
class AuthState {
  final AuthStatus status;
  final User? user;
  final UserModel? userModel;
  final String? errorMessage;
  final String? verificationId;
  final bool isOtpSent;
  final bool isDemoMode;
  
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.userModel,
    this.errorMessage,
    this.verificationId,
    this.isOtpSent = false,
    this.isDemoMode = false,
  });
  
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    UserModel? userModel,
    String? errorMessage,
    String? verificationId,
    bool? isOtpSent,
    bool? isDemoMode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      userModel: userModel ?? this.userModel,
      errorMessage: errorMessage,
      verificationId: verificationId ?? this.verificationId,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }
  
  // In demo mode, we consider authenticated if isDemoMode is true
  bool get isAuthenticated => 
      (status == AuthStatus.authenticated && user != null) || isDemoMode;
  bool get isLoading => status == AuthStatus.loading;
}

// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository? _authRepository;
  StreamSubscription<User?>? _authStateSubscription;
  
  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _init();
  }
  
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
  
  void _init() {
    // Skip Firebase auth listener in demo mode or if repository is null
    final repo = _authRepository;
    if (AppConfig.useDemoMode || repo == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    
    _authStateSubscription = repo.authStateChanges.listen((user) async {
      if (user != null) {
        try {
          final userModel = await repo.getUserData(user.uid);
          if (mounted) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              userModel: userModel,
            );
          }
        } catch (e) {
          if (mounted) {
            state = state.copyWith(
              status: AuthStatus.error,
              errorMessage: 'Failed to load user data: $e',
            );
          }
        }
      } else {
        if (mounted) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            userModel: null,
          );
        }
      }
    });
  }
  
  // Demo mode sign in - bypasses Firebase
  Future<void> signInDemo({String? email, String? displayName}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create demo user model with provided or default credentials
    final demoUser = UserModel(
      uid: 'demo_user_001',
      email: email ?? 'demo@surveyor.app',
      displayName: displayName ?? 'Demo User',
      phoneNumber: '+91 9876543210',
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userModel: demoUser,
      isDemoMode: true,
    );
  }
  
  // Email/Password Sign In
  Future<void> signInWithEmail(String email, String password) async {
    // Use demo mode if Firebase is not configured
    if (AppConfig.useDemoMode) {
      // Extract name from email for demo mode
      final name = email.split('@').first;
      final displayName = name[0].toUpperCase() + name.substring(1);
      await signInDemo(email: email, displayName: displayName);
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      await signInDemo(email: email);
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    try {
      final credential = await repo.signInWithEmail(email, password);
      final user = credential.user;
      if (user != null) {
        final userModel = await repo.getUserData(user.uid);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          userModel: userModel,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign in failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Email/Password Sign Up
  Future<void> signUpWithEmail(String email, String password, String name) async {
    // Use demo mode if Firebase is not configured
    if (AppConfig.useDemoMode) {
      await signInDemo(email: email, displayName: name);
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      await signInDemo(email: email, displayName: name);
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    try {
      final credential = await repo.signUpWithEmail(email, password);
      final user = credential.user;
      if (user != null) {
        // Update user display name
        await user.updateDisplayName(name);
        final userModel = await repo.getUserData(user.uid);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          userModel: userModel,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Sign up failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Phone Authentication - Send OTP
  Future<void> sendOtp(String phoneNumber) async {
    // Use demo mode if Firebase is not configured
    if (AppConfig.useDemoMode) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isOtpSent: true,
        verificationId: 'demo_verification_id',
      );
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        isOtpSent: true,
        verificationId: 'demo_verification_id',
      );
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null, isOtpSent: false);
    
    try {
      await repo.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: (String verificationId, int? resendToken) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            verificationId: verificationId,
            isOtpSent: true,
          );
        },
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto sign-in on Android
          final userCredential = await repo.signInWithPhoneCredential(credential);
          final user = userCredential.user;
          if (user != null) {
            final userModel = await repo.getUserData(user.uid);
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: user,
              userModel: userModel,
              isOtpSent: false,
            );
          }
        },
        onVerificationFailed: (FirebaseAuthException e) {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: e.message,
            isOtpSent: false,
          );
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        isOtpSent: false,
      );
    }
  }
  
  // Phone Authentication - Verify OTP
  Future<void> verifyOtp(String otp) async {
    // Use demo mode if Firebase is not configured
    if (AppConfig.useDemoMode) {
      if (otp == '123456') {
        await signInDemo();
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid OTP. Use 123456 for demo.',
        );
      }
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      if (otp == '123456') {
        await signInDemo();
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Invalid OTP. Use 123456 for demo.',
        );
      }
      return;
    }
    
    if (state.verificationId == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification ID not found. Please request OTP again.',
      );
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    try {
      final user = await repo.signInWithOtp(
        verificationId: state.verificationId!,
        otp: otp,
      );
      
      if (user != null) {
        final userModel = await repo.getUserData(user.uid);
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          userModel: userModel,
          isOtpSent: false,
          verificationId: null,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'OTP verification failed',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Reset Password
  Future<void> resetPassword(String email) async {
    // In demo mode, just show success
    if (AppConfig.useDemoMode) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    
    try {
      await repo.resetPassword(email);
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Sign Out
  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    // In demo mode, just reset state
    if (AppConfig.useDemoMode || state.isDemoMode) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    
    final repo = _authRepository;
    if (repo == null) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    
    try {
      await repo.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Clear error
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  // Reset OTP state
  void resetOtpState() {
    state = state.copyWith(
      isOtpSent: false,
      verificationId: null,
    );
  }
}

// Providers
final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  // In demo mode, don't create the repository (Firebase not initialized)
  if (AppConfig.useDemoMode) {
    return null;
  }
  return AuthRepository(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final authStateStreamProvider = StreamProvider<User?>((ref) {
  if (AppConfig.useDemoMode) {
    return Stream.value(null);
  }
  final repository = ref.watch(authRepositoryProvider);
  if (repository == null) {
    return Stream.value(null);
  }
  return repository.authStateChanges;
});
