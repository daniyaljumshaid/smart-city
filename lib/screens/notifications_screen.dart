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
          TextButton(
            onPressed: hasNotifications
                ? () {
                    setState(() {
                      ComplaintStore.markAllNotificationsRead();
                    });
                  }
                : null,
            child: const Text('Mark all'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.lightGradient),
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: notification.isRead
                          ? const Color(0xFFF4F8FD)
                          : const Color(0xFFE8F3FF),
                    ),
                    child: ListTile(
                      leading: Icon(
                        notification.isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded,
                        color: AppTheme.primary,
                      ),
                      title: Text(notification.message),
                      subtitle: Text(_timeAgo(notification.createdAt)),
                      onTap: () {
                        setState(() {
                          ComplaintStore.markNotificationRead(notification.id);
                        });
                      },
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
