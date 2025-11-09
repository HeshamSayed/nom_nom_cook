import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        type: 'like',
        title: 'Sara Ahmed liked your recipe',
        message: 'Egyptian Koshari',
        time: '2 hours ago',
        isRead: false,
      ),
      NotificationItem(
        type: 'comment',
        title: 'Mohamed Ali commented',
        message: 'This looks delicious! Can you share the recipe?',
        time: '5 hours ago',
        isRead: false,
      ),
      NotificationItem(
        type: 'follow',
        title: 'Fatma Hassan started following you',
        message: '',
        time: '1 day ago',
        isRead: true,
      ),
      NotificationItem(
        type: 'recipe',
        title: 'New recipe from Ahmed Mahmoud',
        message: 'Traditional Molokhia Recipe',
        time: '2 days ago',
        isRead: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'ll notify you when something happens',
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.primary,
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: notification.isRead ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (notification.message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(notification.message),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        notification.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  trailing: notification.isRead
                      ? null
                      : Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                  onTap: () {
                    // Handle notification tap
                  },
                );
              },
            ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'like':
        return Icons.favorite;
      case 'comment':
        return Icons.comment;
      case 'follow':
        return Icons.person_add;
      case 'recipe':
        return Icons.restaurant_menu;
      default:
        return Icons.notifications;
    }
  }
}

class NotificationItem {
  final String type;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  NotificationItem({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });
}
