import 'package:equatable/equatable.dart';

enum GateStatus { available, occupied, maintenance }

extension GateStatusX on GateStatus {
  String get value => name;

  static GateStatus fromString(String s) {
    return GateStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => GateStatus.available,
    );
  }
}

class GateModel extends Equatable {
  final String id;
  final String terminalId;
  final String terminalName;
  final String name;
  final GateStatus status;
  final String? currentFlightId;
  final String? currentFlightNumber;

  const GateModel({
    required this.id,
    required this.terminalId,
    required this.terminalName,
    required this.name,
    this.status = GateStatus.available,
    this.currentFlightId,
    this.currentFlightNumber,
  });

  Map<String, dynamic> toMap() => {
        'terminalId': terminalId,
        'terminalName': terminalName,
        'name': name,
        'status': status.value,
        'currentFlightId': currentFlightId,
        'currentFlightNumber': currentFlightNumber,
      };

  factory GateModel.fromMap(String id, Map<String, dynamic> map) {
    return GateModel(
      id: id,
      terminalId: map['terminalId'] as String? ?? '',
      terminalName: map['terminalName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      status: GateStatusX.fromString(map['status'] as String? ?? ''),
      currentFlightId: map['currentFlightId'] as String?,
      currentFlightNumber: map['currentFlightNumber'] as String?,
    );
  }

  GateModel copyWith({
    String? id,
    String? terminalId,
    String? terminalName,
    String? name,
    GateStatus? status,
    String? currentFlightId,
    String? currentFlightNumber,
  }) {
    return GateModel(
      id: id ?? this.id,
      terminalId: terminalId ?? this.terminalId,
      terminalName: terminalName ?? this.terminalName,
      name: name ?? this.name,
      status: status ?? this.status,
      currentFlightId: currentFlightId ?? this.currentFlightId,
      currentFlightNumber: currentFlightNumber ?? this.currentFlightNumber,
    );
  }

  @override
  List<Object?> get props => [
        id, terminalId, terminalName, name, status,
        currentFlightId, currentFlightNumber,
      ];
}
