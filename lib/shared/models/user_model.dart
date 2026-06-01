import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum UserRole { admin, staff, passenger }

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String role) {
    switch (role) {
      case 'admin':
        return UserRole.admin;
      case 'staff':
        return UserRole.staff;
      case 'passenger':
        return UserRole.passenger;
      default:
        return UserRole.passenger;
    }
  }
}

class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.role = UserRole.passenger,
    this.isActive = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role.value,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      role: UserRoleX.fromString(map['role'] as String? ?? 'passenger'),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    UserRole? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, role, isActive, createdAt];
}
