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
  
  /// Sign up with email, password, and additional user data
  Future<UserCredential> signUpWithEmailAndData({
    required String email,
    required String password,
    required String name,
    String? companyName,
    String? profileImageBase64,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user!.updateDisplayName(name);
      
      // Create user document with additional data
      await _createUserDocumentWithData(
        user: credential.user!,
        displayName: name,
        companyName: companyName,
        profileImageBase64: profileImageBase64,
      );
      
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
        userStatus: UserStatus.activated, // Default activated
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
  
  /// Create user document with additional data
  Future<void> _createUserDocumentWithData({
    required User user,
    String? displayName,
    String? companyName,
    String? profileImageBase64,
  }) async {
    try {
      final userModel = UserModel(
        uid: user.uid,
        email: user.email,
        phoneNumber: user.phoneNumber,
        displayName: displayName ?? user.displayName,
        photoUrl: user.photoURL,
        companyName: companyName,
        profileImageBase64: profileImageBase64,
        userStatus: UserStatus.activated, // Default activated
      );
      
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create user document with data in Firestore',
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
  
  /// Delete user account - deletes all user data from Firestore and Firebase Auth
  Future<void> deleteUserAccount(String uid) async {
    try {
      // Delete all surveys belonging to this user
      final surveysSnapshot = await _firestore
          .collection(AppConstants.surveysCollection)
          .where('user_id', isEqualTo: uid)
          .get();
      
      // Delete surveys in batches
      final batch = _firestore.batch();
      for (final doc in surveysSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      
      // Delete all expenses belonging to this user
      final expensesSnapshot = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('user_id', isEqualTo: uid)
          .get();
      
      // Delete expenses in batches
      final expenseBatch = _firestore.batch();
      for (final doc in expensesSnapshot.docs) {
        expenseBatch.delete(doc.reference);
      }
      await expenseBatch.commit();
      
      // Delete user document from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();
      
      // Delete the Firebase Auth user
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
      
      developer.log(
        'User account deleted successfully',
        name: 'AuthRepository',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete user account',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update user profile in Firestore and Firebase Auth
  Future<UserModel?> updateUserProfile({
    required String uid,
    String? displayName,
    String? email,
    String? companyName,
    String? profileImageBase64,
  }) async {
    try {
      // Build update map with only provided fields
      final Map<String, dynamic> updateData = {
        'updated_at': FieldValue.serverTimestamp(),
      };
      
      if (displayName != null) {
        updateData['display_name'] = displayName;
      }
      if (email != null) {
        updateData['email'] = email;
      }
      if (companyName != null) {
        updateData['company_name'] = companyName;
      }
      if (profileImageBase64 != null) {
        updateData['profile_image_base64'] = profileImageBase64;
      }
      
      // Update Firestore user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updateData);
      
      // Update Firebase Auth display name if provided
      final user = _auth.currentUser;
      if (user != null && displayName != null) {
        await user.updateDisplayName(displayName);
      }
      
      // Update Firebase Auth email if provided (requires recent authentication)
      if (user != null && email != null && email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
      }
      
      developer.log(
        'User profile updated successfully',
        name: 'AuthRepository',
      );
      
      // Return updated user data
      return await getUserData(uid);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update user profile',
        name: 'AuthRepository',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
