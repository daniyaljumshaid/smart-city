import 'package:flutter/material.dart';

import '../complaint_store.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  final String role;

  const NotificationsScreen({super.key, this.role = UserRole.citizen});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifications = ComplaintStore.notifications.where((notification) {
      if (widget.role == UserRole.admin) return true;
      return notification.targetRole == widget.role ||
          notification.targetRole == UserRole.citizen;
    }).toList();
    final hasNotifications = notifications.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: hasNotifications
                ? () {
                    setState(() {
                      ComplaintStore.markAllNotificationsRead();
                    });
                  }
                : null,
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: const Text('Mark all'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.lightGradient),
        child: notifications.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 36,
                        color: AppTheme.primary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No notifications yet.',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You will see status updates, alerts, and replies here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF5B7086)),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Semantics(
                    button: true,
                    label: notification.isRead
                        ? 'Read notification'
                        : 'Unread notification',
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: notification.isRead
                              ? const Color(0xFFD6DEE8)
                              : const Color(0xFFBFDDF8),
                        ),
                        color: notification.isRead
                            ? const Color(0xFFF4F8FD)
                            : const Color(0xFFE8F3FF),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: notification.isRead
                                ? const Color(0xFFE2EAF3)
                                : const Color(0xFFCCE4F9),
                          ),
                          child: Icon(
                            notification.isRead
                                ? Icons.notifications_none_rounded
                                : Icons.notifications_active_rounded,
                            color: AppTheme.primary,
                          ),
                        ),
                        title: Text(notification.message),
                        subtitle: Text(_timeAgo(notification.createdAt)),
                        trailing: notification.isRead
                            ? const Text(
                                'Read',
                                style: TextStyle(
                                  color: Color(0xFF5B7086),
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const Text(
                                'New',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        onTap: () {
                          setState(() {
                            ComplaintStore.markNotificationRead(
                              notification.id,
                            );
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} day ago';
  }
}
