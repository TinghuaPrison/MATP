import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedListPage extends StatefulWidget {
  @override
  _BlockedListPageState createState() => _BlockedListPageState();
}

class _BlockedListPageState extends State<BlockedListPage> {
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
    Response response = await dio.post('${serverIP}get_blockeds/', data: formData);
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
        title: Text('黑名单'),
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