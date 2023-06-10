import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/message.dart';

class SessionPage extends StatefulWidget {
  final String targetUsername;

  const SessionPage({super.key, required this.targetUsername});

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final dio = Dio();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMessage();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchMessage();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchMessage() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'username': username,
      'target': widget.targetUsername,
    });
    Response response = await dio.post('${serverIP}start_session/', data: formData);
    if (response.statusCode == 201) {
      return;
    }
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.checkSession(widget.targetUsername);
    Map<String, dynamic> jsonData = response.data;
    List messageList = jsonData['list'];
    List<Message> messages = messageList.map((e) => Message.fromJson(e)).toList();
    userProvider.updateMessageStatus(widget.targetUsername, messages);
    Future.delayed(const Duration(milliseconds: 300), () {
      scrollToBottom();
    });
  }

  Future<void> _sendMessage() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'sender': username,
      'receiver': widget.targetUsername,
      'content': _messageController.text,
    });
    await dio.post('${serverIP}send_message/', data: formData);
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updateSession(widget.targetUsername, _messageController.text);
    _messageController.clear();
    _fetchMessage();
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    List<Message> messageList = userProvider.messageStatus[widget.targetUsername] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.targetUsername),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messageList.length,
              itemBuilder: (context, index) {
                return MessageItem(message: messageList[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _sendMessage();
                  }
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
