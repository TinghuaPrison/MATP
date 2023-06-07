import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';

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
        CircleAvatar(
          backgroundImage: NetworkImage(serverIP + user.avatar),
          radius: 50.0,
        ),
        SizedBox(height: 20,),
        Text(user.username),
        SizedBox(height: 20,),
        Text(user.bio),
      ],
    );
  }
}

class UserRow extends StatelessWidget {
  final User user;

  const UserRow(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(serverIP + user.avatar),
            radius: 30.0,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(user.username),
            Text(user.bio),
          ],
        ),
      ],
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