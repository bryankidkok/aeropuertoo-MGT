import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../models/result_state.dart';

class NotificationItem extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? flightId;
  final List<String> readBy;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.flightId,
    this.readBy = const [],
    required this.createdAt,
  });

  factory NotificationItem.fromMap(String id, Map<String, dynamic> map) {
    return NotificationItem(
      id: id,
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      flightId: map['flightId'] as String?,
      readBy: (map['readBy'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, type, title, body, flightId, readBy, createdAt];
}

class NotificationsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  ResultState<List<NotificationItem>> _state = const Idle();

  ResultState<List<NotificationItem>> get state => _state;
  List<NotificationItem> get notifications =>
      _state is Success<List<NotificationItem>> ? (_state as Success<List<NotificationItem>>).data : [];

  int get unreadCount => notifications.where((n) => n.readBy.isEmpty).length;

  void startListening(String userId) {
    _sub?.cancel();
    _state = const Loading();
    notifyListeners();

    _sub = _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map((doc) => NotificationItem.fromMap(doc.id, doc.data())).toList();
      _state = Success(list);
      notifyListeners();
    }, onError: (e) {
      _state = const Error('Error al cargar notificaciones');
      notifyListeners();
    });
  }

  Future<void> markAsRead(String notificationId, String userId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
