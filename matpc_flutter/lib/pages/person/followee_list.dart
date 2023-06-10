import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolloweeListPage extends StatefulWidget {
  const FolloweeListPage({super.key});

  @override
  State<FolloweeListPage> createState() => _FolloweeListPageState();
}

class _FolloweeListPageState extends State<FolloweeListPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

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
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关注'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchUsers,
        child: ListView.builder(
          itemCount: users.isEmpty ? 1 : users.length,
          itemBuilder: (BuildContext context, int index) {
            if (users.isEmpty) {
              return const Center(child: Text("没有关注任何人"));
            } else {
              User user = users[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserRow(user),
              );
            }
          },
        ),
      ),
    );
  }
}
