import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum FlightStatus { scheduled, boarding, departed, arrived, delayed, cancelled }

extension FlightStatusX on FlightStatus {
  String get value => name;

  static FlightStatus fromString(String s) {
    return FlightStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => FlightStatus.scheduled,
    );
  }
}

class FlightModel extends Equatable {
  final String id;
  final String flightNumber;
  final String airlineId;
  final String airlineName;
  final String aircraftId;
  final String originCode;
  final String originName;
  final String destinationCode;
  final String destinationName;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final FlightStatus status;
  final String gateId;
  final String gateName;
  final double basePrice;
  final int availableSeats;
  final int totalSeats;
  final DateTime createdAt;

  const FlightModel({
    required this.id,
    required this.flightNumber,
    required this.airlineId,
    required this.airlineName,
    required this.aircraftId,
    required this.originCode,
    required this.originName,
    required this.destinationCode,
    required this.destinationName,
    required this.departureTime,
    required this.arrivalTime,
    this.status = FlightStatus.scheduled,
    required this.gateId,
    required this.gateName,
    required this.basePrice,
    required this.availableSeats,
    required this.totalSeats,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'flightNumber': flightNumber,
        'airlineId': airlineId,
        'airlineName': airlineName,
        'aircraftId': aircraftId,
        'originCode': originCode,
        'originName': originName,
        'destinationCode': destinationCode,
        'destinationName': destinationName,
        'departureTime': Timestamp.fromDate(departureTime),
        'arrivalTime': Timestamp.fromDate(arrivalTime),
        'status': status.value,
        'gateId': gateId,
        'gateName': gateName,
        'basePrice': basePrice,
        'availableSeats': availableSeats,
        'totalSeats': totalSeats,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory FlightModel.fromMap(String id, Map<String, dynamic> map) {
    return FlightModel(
      id: id,
      flightNumber: map['flightNumber'] as String? ?? '',
      airlineId: map['airlineId'] as String? ?? '',
      airlineName: map['airlineName'] as String? ?? '',
      aircraftId: map['aircraftId'] as String? ?? '',
      originCode: map['originCode'] as String? ?? '',
      originName: map['originName'] as String? ?? '',
      destinationCode: map['destinationCode'] as String? ?? '',
      destinationName: map['destinationName'] as String? ?? '',
      departureTime: (map['departureTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      arrivalTime: (map['arrivalTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: FlightStatusX.fromString(map['status'] as String? ?? ''),
      gateId: map['gateId'] as String? ?? '',
      gateName: map['gateName'] as String? ?? '',
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0.0,
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 0,
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  FlightModel copyWith({
    String? id,
    String? flightNumber,
    String? airlineId,
    String? airlineName,
    String? aircraftId,
    String? originCode,
    String? originName,
    String? destinationCode,
    String? destinationName,
    DateTime? departureTime,
    DateTime? arrivalTime,
    FlightStatus? status,
    String? gateId,
    String? gateName,
    double? basePrice,
    int? availableSeats,
    int? totalSeats,
    DateTime? createdAt,
  }) {
    return FlightModel(
      id: id ?? this.id,
      flightNumber: flightNumber ?? this.flightNumber,
      airlineId: airlineId ?? this.airlineId,
      airlineName: airlineName ?? this.airlineName,
      aircraftId: aircraftId ?? this.aircraftId,
      originCode: originCode ?? this.originCode,
      originName: originName ?? this.originName,
      destinationCode: destinationCode ?? this.destinationCode,
      destinationName: destinationName ?? this.destinationName,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      gateId: gateId ?? this.gateId,
      gateName: gateName ?? this.gateName,
      basePrice: basePrice ?? this.basePrice,
      availableSeats: availableSeats ?? this.availableSeats,
      totalSeats: totalSeats ?? this.totalSeats,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, flightNumber, airlineId, airlineName, aircraftId,
        originCode, originName, destinationCode, destinationName,
        departureTime, arrivalTime, status, gateId, gateName,
        basePrice, availableSeats, totalSeats, createdAt,
      ];
}
