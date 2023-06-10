import 'package:cached_network_image/cached_network_image.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/pages/message/session.dart';
import 'package:provider/provider.dart';

class Session {
  final User user;
  final User target;
  String lastMessage;
  int messageNotChecked;
  String c_time;

  Session({required this.user, required this.target, required this.lastMessage, required this.messageNotChecked, required this.c_time});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      user: User.fromJson(json['user']),
      target: User.fromJson(json['target']),
      lastMessage: json['last_message'],
      messageNotChecked: json['message_not_checked'],
      c_time: json['c_time'],
    );
  }
}

class SessionItem extends StatelessWidget {
  final Session session;

  const SessionItem({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    int messageNotChecked = userProvider.sessionStatus[session.target.username]?.messageNotChecked ?? 0;
    String lastMessage = userProvider.sessionStatus[session.target.username]?.lastMessage ?? '';
    String c_time = userProvider.sessionStatus[session.target.username]?.c_time ?? '';

    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SessionPage(targetUsername: session.target.username))),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(serverIP + session.target.avatar),
              radius: 30.0,
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        session.target.username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                      ),
                      Text(
                        c_time,
                        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    lastMessage,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (messageNotChecked > 0)
              Container(
                margin: const EdgeInsets.only(left: 10.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  messageNotChecked.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ),
          ],
        ),
      ),
    );
  }
}