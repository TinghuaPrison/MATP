import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/pages/person/favorited_moment.dart';
import 'package:matpc_flutter/pages/person/followee_list.dart';
import 'package:matpc_flutter/pages/person/notification_list.dart';
import 'package:matpc_flutter/pages/person/profile_edit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'follower_list.dart';

class PersonPage extends StatelessWidget {
  PersonPage({Key? key}) : super(key: key);

  GlobalKey<_UserSectionState> userSectionController = GlobalKey();
  GlobalKey<_MomentSectionState> momentSectionController = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (value) => handleClick(value, context),
              itemBuilder: (BuildContext context) {
                return {'编辑个人信息', '登出账号', '通知消息列表'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          title: const Text('个人主页'),
          centerTitle: true,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: UserSection(key: userSectionController,)),
            const SliverToBoxAdapter(child: ButtonSection()),
            MomentSection(key: momentSectionController,),
          ],
        ),
      ),
    );
  }

  void handleClick(String value, BuildContext context) {
    switch (value) {
      case '编辑个人信息':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EditProfilePage()),
        ).then((value) => {
          userSectionController.currentState?.fetchUser(),
          momentSectionController.currentState?.fetchMoments(),
        });
        break;
      case '登出账号':
        // 执行登出账号的操作
        break;
      case '通知消息列表':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationListPage()),
        );
        break;
    }
  }
}

class UserSection extends StatefulWidget {
  const UserSection({Key? key}) : super(key: key);

  @override
  State<UserSection> createState() => _UserSectionState();
}

class _UserSectionState extends State<UserSection> {
  User? user;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  Future<void> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    final formData = FormData.fromMap({
      'username': savedUsername,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_user/', data: formData);
    Map<String, dynamic> jsonData = response.data;
    List userData = jsonData['list'];
    User usr = User.fromJson(userData[0]);
    setState(() {
      user = usr;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[400]!))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user != null ? UserItem(user!) : const SizedBox(height: 177,),
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  Widget buildButton(BuildContext context, IconData icon, String label, Widget destination) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(16.0),
      ),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 36.0,),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[400]!))
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildButton(context, Icons.group, '关注', const FolloweeListPage()),
            buildButton(context, Icons.person, '粉丝', const FollowerListPage()),
            buildButton(context, Icons.bookmark_added, '收藏', const FavoriteMomentsPage()),
          ],
        ),
      ),
    );
  }
}

class MomentSection extends StatefulWidget {
  const MomentSection({Key? key}) : super(key: key);

  @override
  State<MomentSection> createState() => _MomentSectionState();
}

class _MomentSectionState extends State<MomentSection> {
  List<Moment> moments = [];

  @override
  void initState() {
    super.initState();
    // 在页面初始化时，从后端获取瞬间数据
    fetchMoments();
  }

  Future<void> fetchMoments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'sorted_by': 'user',
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_moments/', data: formData);
    if (response.statusCode == 201) {
      return;
    }
    Map<String, dynamic> jsonData = response.data;
    List momentsData = jsonData['list'];
    List<Moment> momentsList = momentsData.map((e) => Moment.fromJson(e)).toList();
    Map<String, bool> newFollowStatus = {};
    for (var moment in momentsList) {
      newFollowStatus[moment.user.username] = (moment.followed == 1);
    }
    setState(() {
      Provider.of<UserProvider>(context, listen: false).updateFollowStatus(newFollowStatus);
      moments = momentsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (moments.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink(),);
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: (index == 0) ? 16.0 : 0.0, bottom: 16.0),
              child: MomentItem(moments[index]),
            );
          },
          childCount: moments.length,
        ),
      );
    }
  }
}
