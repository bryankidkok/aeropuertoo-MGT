import 'package:equatable/equatable.dart';

class AirlineModel extends Equatable {
  final String id;
  final String name;
  final String iataCode;
  final String logoUrl;
  final String country;
  final bool isActive;

  const AirlineModel({
    required this.id,
    required this.name,
    required this.iataCode,
    this.logoUrl = '',
    this.country = '',
    this.isActive = true,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'iataCode': iataCode,
        'logoUrl': logoUrl,
        'country': country,
        'isActive': isActive,
      };

  factory AirlineModel.fromMap(String id, Map<String, dynamic> map) {
    return AirlineModel(
      id: id,
      name: map['name'] as String? ?? '',
      iataCode: map['iataCode'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? '',
      country: map['country'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  AirlineModel copyWith({
    String? id,
    String? name,
    String? iataCode,
    String? logoUrl,
    String? country,
    bool? isActive,
  }) {
    return AirlineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iataCode: iataCode ?? this.iataCode,
      logoUrl: logoUrl ?? this.logoUrl,
      country: country ?? this.country,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, iataCode, logoUrl, country, isActive];
}
