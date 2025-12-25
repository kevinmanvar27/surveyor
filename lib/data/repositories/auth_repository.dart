import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  AuthRepository(this._auth, this._firestore);
  
  /// Get current user
  User? get currentUser => _auth.currentUser;
  
  /// Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Sign in with email and password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update last login in background - don't block login if Firestore fails
      _updateLastLoginSafe(credential.user!.uid);
      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  /// Sign up with email and password
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _createUserDocument(credential.user!);
      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  /// Phone authentication - send OTP
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
    );
  }
  
  /// Sign in with phone credential
  Future<UserCredential> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Check if user exists, if not create document
      // Handle Firestore errors gracefully - don't block login
      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();
        
        if (!userDoc.exists) {
          await _createUserDocument(userCredential.user!);
        } else {
          _updateLastLoginSafe(userCredential.user!.uid);
        }
      } catch (e, stackTrace) {
        // Firestore might not be available - log but don't fail login
        developer.log(
          'Firestore operation failed during phone login',
          name: 'AuthRepository',
          error: e,
          stackTrace: stackTrace,
        );
      }
      
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  /// Create phone auth credential
  PhoneAuthCredential createPhoneCredential(String verificationId, String smsCode) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
  
  /// Sign in with OTP (convenience method)
  Future<User?> signInWithOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final credential = createPhoneCredential(verificationId, otp);
      final userCredential = await signInWithPhoneCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  
  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e, stackTrace) {
      // Firestore might not be available
      developer.log(
        'Failed to get user data from Firestore',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
  
  /// Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    try {
      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        displayName: user.displayName,
        photoUrl: user.photoURL,
      );
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());
    } catch (e, stackTrace) {
      // Firestore might not be available - log but don't fail
      developer.log(
        'Failed to create user document in Firestore',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Update last login timestamp - safe version that doesn't throw
  /// Uses set with merge to create document if it doesn't exist
  void _updateLastLoginSafe(String uid) {
    _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(
          {'last_login': Timestamp.now()},
          SetOptions(merge: true),  // Creates doc if doesn't exist, otherwise merges
        )
        .catchError((e, stackTrace) {
          // Firestore might not be available - log but don't fail
          developer.log(
            'Failed to update last login in Firestore',
            name: 'AuthRepository',
            error: e,
            stackTrace: stackTrace,
          );
          return null;
        });
  }
}
