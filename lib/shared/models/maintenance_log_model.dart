import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MaintenanceType { routine, repair, inspection, emergency }

extension MaintenanceTypeX on MaintenanceType {
  String get value => name;

  static MaintenanceType fromString(String s) {
    return MaintenanceType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => MaintenanceType.routine,
    );
  }
}

enum MaintenanceStatus { scheduled, inProgress, completed, deferred }

extension MaintenanceStatusX on MaintenanceStatus {
  String get value {
    switch (this) {
      case MaintenanceStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  static MaintenanceStatus fromString(String s) {
    switch (s) {
      case 'in_progress':
        return MaintenanceStatus.inProgress;
      default:
        return MaintenanceStatus.values.firstWhere(
          (e) => e.name == s,
          orElse: () => MaintenanceStatus.scheduled,
        );
    }
  }
}

class MaintenanceLogModel extends Equatable {
  final String id;
  final String aircraftId;
  final String aircraftRegistration;
  final MaintenanceType type;
  final String description;
  final String performedById;
  final DateTime startDate;
  final DateTime? endDate;
  final MaintenanceStatus status;

  const MaintenanceLogModel({
    required this.id,
    required this.aircraftId,
    required this.aircraftRegistration,
    required this.type,
    this.description = '',
    required this.performedById,
    required this.startDate,
    this.endDate,
    this.status = MaintenanceStatus.scheduled,
  });

  Map<String, dynamic> toMap() => {
        'aircraftId': aircraftId,
        'aircraftRegistration': aircraftRegistration,
        'type': type.value,
        'description': description,
        'performedById': performedById,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
        'status': status.value,
      };

  factory MaintenanceLogModel.fromMap(String id, Map<String, dynamic> map) {
    return MaintenanceLogModel(
      id: id,
      aircraftId: map['aircraftId'] as String? ?? '',
      aircraftRegistration: map['aircraftRegistration'] as String? ?? '',
      type: MaintenanceTypeX.fromString(map['type'] as String? ?? ''),
      description: map['description'] as String? ?? '',
      performedById: map['performedById'] as String? ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate(),
      status: MaintenanceStatusX.fromString(map['status'] as String? ?? ''),
    );
  }

  MaintenanceLogModel copyWith({
    String? id,
    String? aircraftId,
    String? aircraftRegistration,
    MaintenanceType? type,
    String? description,
    String? performedById,
    DateTime? startDate,
    DateTime? endDate,
    MaintenanceStatus? status,
  }) {
    return MaintenanceLogModel(
      id: id ?? this.id,
      aircraftId: aircraftId ?? this.aircraftId,
      aircraftRegistration: aircraftRegistration ?? this.aircraftRegistration,
      type: type ?? this.type,
      description: description ?? this.description,
      performedById: performedById ?? this.performedById,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id, aircraftId, aircraftRegistration, type, description,
        performedById, startDate, endDate, status,
      ];
}
