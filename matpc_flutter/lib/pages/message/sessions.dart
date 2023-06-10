import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/session.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionsPage> {
  List<Session> sessions = [];
  final dio = Dio();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getSessions();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getSessions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getSessions() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'username': username,
    });
    Response response = await dio.post('${serverIP}get_sessions/', data: formData);
    if (response.statusCode == 201) {
      return;
    }
    Map<String, dynamic> jsonData = response.data;
    List sessionsData = jsonData['list'];
    List<Session> sessionsList = sessionsData.map((e) => Session.fromJson(e)).toList();
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      sessions = sessionsList;
      for (var session in sessionsList) {
        userProvider.startSession(session.target.username, session);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sessions"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _getSessions,
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              Session session = sessions[index];
              return SessionItem(session: session);
            },
          ),
        ),
      ),
    );
  }
}