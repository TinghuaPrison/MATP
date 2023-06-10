import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';

import '../pages/person/other_person.dart';

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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 2,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: comment.user.username))),
              child: CircleAvatar(
                backgroundImage: NetworkImage(serverIP + comment.user.avatar),
                radius: 25.0,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent,
                    radius: 0.0,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: comment.user.username))),
                    child: Text(
                      comment.user.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    comment.content,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    comment.c_time,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}