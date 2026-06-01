import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum BookingStatus { confirmed, checkedIn, boarded, cancelled, noShow }

extension BookingStatusX on BookingStatus {
  String get value {
    switch (this) {
      case BookingStatus.checkedIn:
        return 'checked_in';
      case BookingStatus.noShow:
        return 'no_show';
      default:
        return name;
    }
  }

  static BookingStatus fromString(String s) {
    switch (s) {
      case 'checked_in':
        return BookingStatus.checkedIn;
      case 'no_show':
        return BookingStatus.noShow;
      default:
        return BookingStatus.values.firstWhere(
          (e) => e.name == s,
          orElse: () => BookingStatus.confirmed,
        );
    }
  }
}

class BookingModel extends Equatable {
  final String id;
  final String flightId;
  final String flightNumber;
  final String passengerId;
  final String passengerName;
  final String bookingReference;
  final BookingStatus status;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? seatNumber;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.flightId,
    required this.flightNumber,
    required this.passengerId,
    required this.passengerName,
    required this.bookingReference,
    this.status = BookingStatus.confirmed,
    required this.totalAmount,
    this.paymentMethod = '',
    this.paymentStatus = '',
    this.seatNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'flightId': flightId,
        'flightNumber': flightNumber,
        'passengerId': passengerId,
        'passengerName': passengerName,
        'bookingReference': bookingReference,
        'status': status.value,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentStatus,
        'seatNumber': seatNumber,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      flightId: map['flightId'] as String? ?? '',
      flightNumber: map['flightNumber'] as String? ?? '',
      passengerId: map['passengerId'] as String? ?? '',
      passengerName: map['passengerName'] as String? ?? '',
      bookingReference: map['bookingReference'] as String? ?? '',
      status: BookingStatusX.fromString(map['status'] as String? ?? ''),
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] as String? ?? '',
      paymentStatus: map['paymentStatus'] as String? ?? '',
      seatNumber: map['seatNumber'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  BookingModel copyWith({
    String? id,
    String? flightId,
    String? flightNumber,
    String? passengerId,
    String? passengerName,
    String? bookingReference,
    BookingStatus? status,
    double? totalAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? seatNumber,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      flightId: flightId ?? this.flightId,
      flightNumber: flightNumber ?? this.flightNumber,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      bookingReference: bookingReference ?? this.bookingReference,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      seatNumber: seatNumber ?? this.seatNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, flightId, flightNumber, passengerId, passengerName,
        bookingReference, status, totalAmount, paymentMethod,
        paymentStatus, seatNumber, createdAt,
      ];
}
