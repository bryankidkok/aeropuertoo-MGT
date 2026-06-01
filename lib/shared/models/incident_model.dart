import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum IncidentType { delay, cancellation, emergency, technical, other }

extension IncidentTypeX on IncidentType {
  String get value => name;

  static IncidentType fromString(String s) {
    return IncidentType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => IncidentType.other,
    );
  }
}

enum IncidentSeverity { low, medium, high, critical }

extension IncidentSeverityX on IncidentSeverity {
  String get value => name;

  static IncidentSeverity fromString(String s) {
    return IncidentSeverity.values.firstWhere(
      (e) => e.name == s,
      orElse: () => IncidentSeverity.low,
    );
  }
}

enum IncidentStatus { open, inProgress, resolved }

extension IncidentStatusX on IncidentStatus {
  String get value {
    if (this == IncidentStatus.inProgress) return 'in_progress';
    return name;
  }

  static IncidentStatus fromString(String s) {
    if (s == 'in_progress') return IncidentStatus.inProgress;
    return IncidentStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => IncidentStatus.open,
    );
  }
}

class IncidentModel extends Equatable {
  final String id;
  final String flightId;
  final String flightNumber;
  final IncidentType type;
  final IncidentSeverity severity;
  final String description;
  final String actionsTaken;
  final String reportedById;
  final String reportedByName;
  final IncidentStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const IncidentModel({
    required this.id,
    required this.flightId,
    required this.flightNumber,
    required this.type,
    this.severity = IncidentSeverity.medium,
    this.description = '',
    this.actionsTaken = '',
    required this.reportedById,
    required this.reportedByName,
    this.status = IncidentStatus.open,
    required this.createdAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
        'flightId': flightId,
        'flightNumber': flightNumber,
        'type': type.value,
        'severity': severity.value,
        'description': description,
        'actionsTaken': actionsTaken,
        'reportedById': reportedById,
        'reportedByName': reportedByName,
        'status': status.value,
        'createdAt': Timestamp.fromDate(createdAt),
        'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      };

  factory IncidentModel.fromMap(String id, Map<String, dynamic> map) {
    return IncidentModel(
      id: id,
      flightId: map['flightId'] as String? ?? '',
      flightNumber: map['flightNumber'] as String? ?? '',
      type: IncidentTypeX.fromString(map['type'] as String? ?? ''),
      severity: IncidentSeverityX.fromString(map['severity'] as String? ?? ''),
      description: map['description'] as String? ?? '',
      actionsTaken: map['actionsTaken'] as String? ?? '',
      reportedById: map['reportedById'] as String? ?? '',
      reportedByName: map['reportedByName'] as String? ?? '',
      status: IncidentStatusX.fromString(map['status'] as String? ?? ''),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (map['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  IncidentModel copyWith({
    String? id,
    String? flightId,
    String? flightNumber,
    IncidentType? type,
    IncidentSeverity? severity,
    String? description,
    String? actionsTaken,
    String? reportedById,
    String? reportedByName,
    IncidentStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return IncidentModel(
      id: id ?? this.id,
      flightId: flightId ?? this.flightId,
      flightNumber: flightNumber ?? this.flightNumber,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      actionsTaken: actionsTaken ?? this.actionsTaken,
      reportedById: reportedById ?? this.reportedById,
      reportedByName: reportedByName ?? this.reportedByName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id, flightId, flightNumber, type, severity, description,
        actionsTaken, reportedById, reportedByName, status, createdAt, resolvedAt,
      ];
}
