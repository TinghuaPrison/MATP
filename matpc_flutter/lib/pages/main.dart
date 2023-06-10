import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/notification.dart';
import 'package:matpc_flutter/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;
  final dio = Dio();

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) => fetchNotifications());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> showNotification(List<AppNotification> newNotifications) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        '1', 'android_channel',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,);

    for (var notification in newNotifications) {
      await flutterLocalNotificationsPlugin.show(
          0,
          notification.title,
          notification.content,
          platformChannelSpecifics);
    }
  }

  Future<void> fetchNotifications() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    Response response = await dio.post('${serverIP}get_notifications/', data: FormData.fromMap({'username': username}));
    if (response.statusCode == 201) {
      return;
    }
    Map<String, dynamic> jsonData = response.data;
    List notificationsList = jsonData['list'];
    List<AppNotification> notifications = notificationsList.map((e) => AppNotification.fromJson(e)).toList();
    List<AppNotification> newNotifications = notifications.where((element) => !element.checked).toList();
    if (newNotifications.isNotEmpty) {
      showNotification(newNotifications);
    }
  }


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}