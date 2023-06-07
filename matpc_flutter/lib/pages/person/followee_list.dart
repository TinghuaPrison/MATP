import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolloweeListPage extends StatefulWidget {
  @override
  _FolloweeListPageState createState() => _FolloweeListPageState();
}

class _FolloweeListPageState extends State<FolloweeListPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    final formData = FormData.fromMap({
      'username': savedUsername,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_followees/', data: formData);
    Map<String, dynamic> jsonData = response.data;
    List usersData = jsonData['list'];
    List<User> usersList = usersData.map((e) => User.fromJson(e)).toList();

    setState(() {
      users = usersList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('关注'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUsers,
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (BuildContext context, int index) {
            User user= users[index];
            return UserRow(user);
          },
        ),
      ),
    );
  }
}