import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class EmployeeModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  final String? assignedTerminalId;
  final bool isActive;
  final DateTime createdAt;

  const EmployeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.assignedTerminalId,
    this.isActive = true,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'assignedTerminalId': assignedTerminalId,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory EmployeeModel.fromMap(String id, Map<String, dynamic> map) {
    return EmployeeModel(
      id: id,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? '',
      assignedTerminalId: map['assignedTerminalId'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  EmployeeModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? assignedTerminalId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      assignedTerminalId: assignedTerminalId ?? this.assignedTerminalId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, firstName, lastName, email, role,
        assignedTerminalId, isActive, createdAt,
      ];
}
