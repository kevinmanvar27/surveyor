import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLogin;
  
  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoUrl,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();
  
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
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: data['last_login'] != null 
          ? (data['last_login'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'photo_url': photoUrl,
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
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
