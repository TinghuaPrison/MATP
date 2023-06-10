import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/session.dart';

import 'message.dart';

class User {
  final String username;
  final String password;
  final String avatar;
  final String bio;

  User({required this.username, required this.password, required this.avatar, required this.bio});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['username'],
        password: json['password'],
        avatar: json['avatar'],
        bio: json['bio'],
    );
  }
}

class UserItem extends StatelessWidget {
  final User user;
  
  const UserItem(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ClipOval(
          child: Image(
            image: NetworkImage(serverIP + user.avatar),
            width: 100.0,
            height: 100.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10,),
        Text(user.username, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10,),
        Text(user.bio, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;

  const UserRow(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: Image(
              image: NetworkImage(serverIP + user.avatar),
              width: 60.0,
              height: 60.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(user.username, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4.0),
                Text(user.bio, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserProvider with ChangeNotifier {
  Map<String, bool> followStatus = {};
  Map<String, bool> blockStatus = {};
  Map<int, bool> likedStatus = {};
  Map<int, bool> favoriteStatus = {};
  Map<int, int> likeCounts = {};
  Map<int, int> favoriteCounts = {};
  Map<int, int> commentCounts = {};
  Map<String, Session> sessionStatus = {};
  Map<String, List<Message>> messageStatus = {};

  void startSession(String target, Session session) {
    sessionStatus[target] = session;
    notifyListeners();
  }

  void checkSession(String target) {
    sessionStatus[target]?.messageNotChecked = 0;
    notifyListeners();
  }

  void updateSession(String target, String text) {
    sessionStatus[target]?.lastMessage = text;
    DateTime now = DateTime.now();
    String cTime = DateFormat('HH:mm:ss').format(now);
    sessionStatus[target]?.c_time = cTime;
    notifyListeners();
  }

  void updateMessageStatus(String target, List<Message> messages) {
    messageStatus[target] = messages;
    notifyListeners();
  }

  void followUser(String username) {
    followStatus[username] = true;
    notifyListeners();
  }

  void unfollowUser(String username) {
    followStatus[username] = false;
    notifyListeners();
  }

  void updateFollowStatus(Map<String, bool> newFollowStatus) {
    followStatus.addAll(newFollowStatus);
    notifyListeners();
  }

  void blockUser(String username) {
    blockStatus[username] = true;
    notifyListeners();
  }

  void unblockUser(String username) {
    blockStatus[username] = false;
  }

  void likeMoment(int momentId) {
    likedStatus[momentId] = true;
    likeCounts[momentId] = (likeCounts[momentId] ?? 0) + 1;
    notifyListeners();
  }

  void unlikeMoment(int momentId) {
    likedStatus[momentId] = false;
    likeCounts[momentId] = (likeCounts[momentId] ?? 0) - 1;
    notifyListeners();
  }

  void favoriteMoment(int momentId) {
    favoriteStatus[momentId] = true;
    favoriteCounts[momentId] = (favoriteCounts[momentId] ?? 0) + 1;
    notifyListeners();
  }

  void unfavoriteMoment(int momentId) {
    favoriteStatus[momentId] = false;
    favoriteCounts[momentId] = (favoriteCounts[momentId] ?? 0) - 1;
    notifyListeners();
  }

  void updateCommentCount(int momentId) {
    commentCounts[momentId] = (commentCounts[momentId] ?? 0) + 1;
    notifyListeners();
  }
}