import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PassengerModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String passportNumber;
  final String? frequentFlyerNumber;
  final bool isActive;
  final DateTime createdAt;

  const PassengerModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.passportNumber,
    this.frequentFlyerNumber,
    this.isActive = true,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'passportNumber': passportNumber,
        'frequentFlyerNumber': frequentFlyerNumber,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory PassengerModel.fromMap(String id, Map<String, dynamic> map) {
    return PassengerModel(
      id: id,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      passportNumber: map['passportNumber'] as String? ?? '',
      frequentFlyerNumber: map['frequentFlyerNumber'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PassengerModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? passportNumber,
    String? frequentFlyerNumber,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PassengerModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passportNumber: passportNumber ?? this.passportNumber,
      frequentFlyerNumber: frequentFlyerNumber ?? this.frequentFlyerNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, firstName, lastName, email, phone, passportNumber,
        frequentFlyerNumber, isActive, createdAt,
      ];
}
