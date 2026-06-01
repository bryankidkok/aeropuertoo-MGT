import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';
import '../models/result_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final uid = auth.user?.uid;
      if (uid != null && uid.isNotEmpty) {
        _userId = uid;
        context.read<NotificationsProvider>().startListening(uid);
      }
    });
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'info':
        return Icons.info_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'alert':
        return Icons.dangerous_outlined;
      case 'flight':
        return Icons.flight_takeoff;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'info':
        return AppColors.cyan;
      case 'warning':
        return AppColors.chipYellow;
      case 'alert':
        return AppColors.chipRed;
      case 'flight':
        return AppColors.blue;
      default:
        return AppColors.gray;
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NOTIFICACIONES')),
      body: Consumer<NotificationsProvider>(
        builder: (context, np, _) {
          if (np.state is Loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }

          if (np.state is Error) {
            final msg = (np.state as Error).message;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.chipRed, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: AppColors.chipRed, fontSize: 14),
                    ),
                  ],
                ),
              ),
            );
          }

          final notifications = np.notifications;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none, color: AppColors.gray, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No hay notificaciones',
                    style: GoogleFonts.inter(
                      color: AppColors.gray,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isUnread = _userId != null && !n.readBy.contains(_userId);

              return _buildNotificationCard(n, isUnread);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification, bool isUnread) {
    final icon = _iconForType(notification.type);
    final color = _colorForType(notification.type);
    final time = _relativeTime(notification.createdAt);

    return GestureDetector(
      onTap: () {
        if (_userId != null) {
          context.read<NotificationsProvider>().markAsRead(notification.id, _userId!);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.card.withValues(alpha: 0.9)
              : AppColors.card,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUnread ? AppColors.cyan.withValues(alpha: 0.3) : AppColors.cardBorder,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.gray,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.gray.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
