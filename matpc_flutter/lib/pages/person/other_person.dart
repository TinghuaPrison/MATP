import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/pages/message/sessions.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../message/session.dart';

class OtherPersonPage extends StatelessWidget {
  OtherPersonPage({Key? key, required this.otherUser}) : super(key: key);

  final String otherUser;

  GlobalKey<_UserSectionState> userSectionController = GlobalKey();
  GlobalKey<_MomentSectionState> momentSectionController = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('$otherUser 的主页'),
          automaticallyImplyLeading: true,
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: UserSection(key: userSectionController, username: otherUser)),
            SliverToBoxAdapter(child: ButtonSection(otherUser)),
            MomentSection(key: momentSectionController, username: otherUser),
          ],
        ),
      );
  }
}

class UserSection extends StatefulWidget {
  const UserSection({Key? key, required this.username}) : super(key: key);

  final String username;

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
    final formData = FormData.fromMap({
      'username': widget.username,
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
      return const SizedBox(height: 177,);
    }
  }
}

class ButtonSection extends StatefulWidget {
  final String otherUser;

  ButtonSection(this.otherUser);

  @override
  _ButtonSectionState createState() => _ButtonSectionState();
}

class _ButtonSectionState extends State<ButtonSection> {

  Future<void> _follow() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'follower': username,
      'followee': widget.otherUser,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}follow/', data: formData);
    if (response.statusCode == 200) {
      Provider.of<UserProvider>(context, listen: false).followUser(widget.otherUser);
    }
  }

  Future<void> _unfollow() async {

  }

  Future<void> _block() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'blocker': username,
      'blocked': widget.otherUser,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}block/', data: formData);
    if (response.statusCode == 200) {
      Provider.of<UserProvider>(context, listen: false).blockUser(widget.otherUser);
    }
  }

  Future<void> _unblock() async {

  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    bool followed = userProvider.followStatus[widget.otherUser] ?? false;
    bool blocked = userProvider.blockStatus[widget.otherUser] ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        TextButton(
          onPressed: followed ? _unfollow : _follow,
          child: Column(
            children: <Widget>[
              Icon(!followed ? Icons.star_border : Icons.star),
              !followed ? const Text('关注') : const Text('已关注'),
            ],
          ),
        ),
        TextButton(
          onPressed: blocked ? _unblock : _block,
          child: Column(
            children: <Widget>[
              Icon(!blocked ? Icons.block_flipped : Icons.block_rounded),
              !blocked ? const Text('拉黑') : const Text('已拉黑'),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // 实现私信功能
          },
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SessionPage(targetUsername: widget.otherUser,))),
            child: Column(
              children: const <Widget>[
                Icon(Icons.email),
                Text('私信'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class MomentSection extends StatefulWidget {
  const MomentSection({Key? key, required this.username}) : super(key: key);

  final String username;

  @override
  _MomentSectionState createState() => _MomentSectionState();
}

class _MomentSectionState extends State<MomentSection> {
  List<Moment> moments = [];

  @override
  void initState() {
    super.initState();
    fetchMoments();
  }

  Future<void> fetchMoments() async {
    FormData formData = FormData.fromMap({
      'username': widget.username,
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
      return const SliverToBoxAdapter(child: SizedBox.shrink(),);
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
