import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';

class Comment {
  final User user;
  final String content;
  final String c_time;

  Comment({
    required this.user,
    required this.content,
    required this.c_time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: User.fromJson(json['user']),
      content: json['content'],
      c_time: json['c_time'],
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem(this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(serverIP + comment.user.avatar),
            radius: 30.0,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(comment.user.username, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4.0),
              Text(comment.content, softWrap: true,),
              SizedBox(height: 4.0),
              Text(comment.c_time, style: TextStyle(color: Colors.grey, fontSize: 12.0)),
            ],
          ),
        ),
      ],
    );
  }
}