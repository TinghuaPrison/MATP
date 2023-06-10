import 'package:flutter/material.dart';

class AppNotification {
  final String title;
  final String content;
  final bool checked;

  AppNotification({required this.title, required this.content, required this.checked});

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(title: json['title'], content: json['content'], checked: json['checked']);
  }
}

class AppNotificationItem extends StatelessWidget {
  final AppNotification notification;

  const AppNotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              notification.content,
              style: const TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






