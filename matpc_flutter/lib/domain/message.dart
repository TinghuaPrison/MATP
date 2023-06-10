import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/session.dart';
import 'package:matpc_flutter/domain/user.dart';

class Message {
  final User sender;
  final User receiver;
  final String content;
  final String c_time;
  final int side;

  Message({required this.sender, required this.receiver, required this.content, required this.c_time, required this.side});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: User.fromJson(json['sender']),
      receiver: User.fromJson(json['receiver']),
      content: json['content'],
      c_time: json['c_time'],
      side: json['side'],
    );
  }
}

class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isSentByCurrentUser = message.side == 1;
    Color backgroundColor = isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300]!;
    Color textColor = isSentByCurrentUser ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSentByCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSentByCurrentUser) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(serverIP + message.sender.avatar),
              radius: 25.0,
            ),
            const SizedBox(width: 10.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isSentByCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(fontSize: 16.0, color: textColor),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  message.c_time,
                  style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isSentByCurrentUser) ...[
            const SizedBox(width: 10.0),
            CircleAvatar(
              backgroundImage: NetworkImage(serverIP + message.sender.avatar),
              radius: 25.0,
            ),
          ],
        ],
      ),
    );
  }
}
