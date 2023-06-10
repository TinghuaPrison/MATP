import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/pages/index.dart';
import 'package:matpc_flutter/pages/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsernameAndPassword();
  }

  Future<void> loadUsernameAndPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');
    if (username != null) {
      usernameController.text = username;
    }
    if (password != null) {
      passwordController.text = password;
    }
  }

  Future<void> _login() async {
    FormData formData = FormData.fromMap({
      'username': usernameController.text,
      'password': passwordController.text,
    });
    Dio dio = Dio();
    try {
      final response = await dio.post('${serverIP}user_login/', data: formData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', usernameController.text);
      prefs.setString('password', passwordController.text);
      _showDialog('成功', '登录成功', onSuccess: true);
    } catch (e) {
      _showDialog('失败', '登录失败');
    }
  }

  _showDialog(String title, String content, {bool onSuccess = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const IndexPage()),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('登录'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('登录'),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
                );
              },
              child: const Text('注册'),
            ),
          ],
        ),
      ),
    );
  }
}