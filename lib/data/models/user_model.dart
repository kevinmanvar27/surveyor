import 'package:cloud_firestore/cloud_firestore.dart';

// User status enum
enum UserStatus {
  activated,
  blocked,
}

class UserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final String? companyName;
  final String? profileImageBase64; // Base64 encoded image
  final UserStatus userStatus;
  final DateTime createdAt;
  final DateTime lastLogin;
  
  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    this.companyName,
    this.profileImageBase64,
    this.userStatus = UserStatus.activated, // Default is activated
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();
  
  // Check if user is blocked
  bool get isBlocked => userStatus == UserStatus.blocked;
  
  // Check if user is activated
  bool get isActivated => userStatus == UserStatus.activated;
  
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    // Handle null data case
    if (data == null) {
      throw Exception('Document data is null for user: ${doc.id}');
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      phoneNumber: data['phone_number'] as String?,
      displayName: data['display_name'] as String?,
      photoUrl: data['photo_url'] as String?,
      companyName: data['company_name'] as String?,
      profileImageBase64: data['profile_image_base64'] as String?,
      userStatus: _parseUserStatus(data['user_status'] as String?),
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data['last_login'] != null 
          ? (data['last_login'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
  
  static UserStatus _parseUserStatus(String? status) {
    if (status == 'blocked') {
      return UserStatus.blocked;
    }
    return UserStatus.activated; // Default
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'photo_url': photoUrl,
      'company_name': companyName,
      'profile_image_base64': profileImageBase64,
      'user_status': userStatus == UserStatus.blocked ? 'blocked' : 'activated',
      'created_at': Timestamp.fromDate(createdAt),
      'last_login': Timestamp.fromDate(lastLogin),
    };
  }
  
  UserModel copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    String? companyName,
    String? profileImageBase64,
    UserStatus? userStatus,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      companyName: companyName ?? this.companyName,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      userStatus: userStatus ?? this.userStatus,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
