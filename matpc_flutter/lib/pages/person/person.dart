import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/pages/person/followee_list.dart';
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
                return {'编辑个人信息', '登出账号'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
          title: Text('个人主页'),
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: UserSection(key: userSectionController,)),
            SliverToBoxAdapter(child: ButtonSection()),
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
          MaterialPageRoute(builder: (context) => EditProfilePage()),
        ).then((value) => {
          userSectionController.currentState?.fetchUser(),
          momentSectionController.currentState?.fetchMoments(),
        });
        break;
      case '登出账号':
        // 执行登出账号的操作
        break;
    }
  }
}

class UserSection extends StatefulWidget {
  const UserSection({Key? key}) : super(key: key);

  @override
  _UserSectionState createState() => _UserSectionState();
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
    if (user != null) {
      return UserItem(user!);
    } else {
      return SizedBox(height: 177,);
    }
  }
}

class ButtonSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.push(context,
            MaterialPageRoute(builder: (context) => FolloweeListPage()));
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.group),
              Text('关注'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FollowerListPage()));
          },
          child: Column(
            children: <Widget>[
              Icon(Icons.person),
              Text('粉丝'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Column(
            children: <Widget>[
              Icon(Icons.block),
              Text('黑名单'),
            ],
          ),
        ),
      ],
    );
  }
}

class MomentSection extends StatefulWidget {
  const MomentSection({Key? key}) : super(key: key);

  @override
  _MomentSectionState createState() => _MomentSectionState();
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
    FormData formData = new FormData.fromMap({
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
    Provider.of<UserProvider>(context, listen: false).updateFollowStatus(newFollowStatus);
    setState(() {
      moments = momentsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (moments.isEmpty) {
      return SliverToBoxAdapter(child: SizedBox.shrink(),);
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return MomentItem(moments[index]);
          },
          childCount: moments.length,
        ),
      );
    }
  }
}
