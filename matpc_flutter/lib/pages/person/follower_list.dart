import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowerListPage extends StatefulWidget {
  @override
  _FollowerListPageState createState() => _FollowerListPageState();
}

class _FollowerListPageState extends State<FollowerListPage> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    // 在页面初始化时，从后端获取瞬间数据
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    final formData = FormData.fromMap({
      'username': savedUsername,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_followers/', data: formData);
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
        title: Text('粉丝'),
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