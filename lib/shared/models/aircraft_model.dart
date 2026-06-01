import 'package:equatable/equatable.dart';

enum AircraftStatus { active, maintenance, retired }

extension AircraftStatusX on AircraftStatus {
  String get value => name;

  static AircraftStatus fromString(String s) {
    return AircraftStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => AircraftStatus.active,
    );
  }
}

class AircraftModel extends Equatable {
  final String id;
  final String model;
  final String registration;
  final String airlineId;
  final int totalSeats;
  final int firstClassSeats;
  final int businessSeats;
  final int economySeats;
  final AircraftStatus status;

  const AircraftModel({
    required this.id,
    required this.model,
    required this.registration,
    required this.airlineId,
    required this.totalSeats,
    this.firstClassSeats = 0,
    this.businessSeats = 0,
    this.economySeats = 0,
    this.status = AircraftStatus.active,
  });

  Map<String, dynamic> toMap() => {
        'model': model,
        'registration': registration,
        'airlineId': airlineId,
        'totalSeats': totalSeats,
        'firstClassSeats': firstClassSeats,
        'businessSeats': businessSeats,
        'economySeats': economySeats,
        'status': status.value,
      };

  factory AircraftModel.fromMap(String id, Map<String, dynamic> map) {
    return AircraftModel(
      id: id,
      model: map['model'] as String? ?? '',
      registration: map['registration'] as String? ?? '',
      airlineId: map['airlineId'] as String? ?? '',
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 0,
      firstClassSeats: (map['firstClassSeats'] as num?)?.toInt() ?? 0,
      businessSeats: (map['businessSeats'] as num?)?.toInt() ?? 0,
      economySeats: (map['economySeats'] as num?)?.toInt() ?? 0,
      status: AircraftStatusX.fromString(map['status'] as String? ?? ''),
    );
  }

  AircraftModel copyWith({
    String? id,
    String? model,
    String? registration,
    String? airlineId,
    int? totalSeats,
    int? firstClassSeats,
    int? businessSeats,
    int? economySeats,
    AircraftStatus? status,
  }) {
    return AircraftModel(
      id: id ?? this.id,
      model: model ?? this.model,
      registration: registration ?? this.registration,
      airlineId: airlineId ?? this.airlineId,
      totalSeats: totalSeats ?? this.totalSeats,
      firstClassSeats: firstClassSeats ?? this.firstClassSeats,
      businessSeats: businessSeats ?? this.businessSeats,
      economySeats: economySeats ?? this.economySeats,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, model, registration, airlineId, totalSeats,
        firstClassSeats, businessSeats, economySeats, status,
      ];
}
