import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const/const.dart';
import '../../domain/notification.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  List<AppNotification> appNotifications = [];
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');

    Response response = await dio.post('${serverIP}get_notifications/', data: FormData.fromMap({'username': username}));
    Map<String, dynamic> jsonData = response.data;
    List notificationsList = jsonData['list'];
    List<AppNotification> notifications = notificationsList.map((e) => AppNotification.fromJson(e)).toList();
    setState(() {
      appNotifications = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchNotifications,
          child: ListView.builder(
            itemCount: appNotifications.length,
            itemBuilder: (context, index) {
              AppNotification notification = appNotifications[index];
              return AppNotificationItem(notification: notification);
            },
          ),
        ),
      ),
    );
  }
}