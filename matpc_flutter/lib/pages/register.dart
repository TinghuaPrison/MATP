import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/pages/index.dart';
import 'package:matpc_flutter/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? avatarImage;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  Future<void> _register() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('错误'),
          content: Text('请填写用户名和密码'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
      return;
    }

    final dio = Dio();
    final formData = FormData.fromMap({
      'username': usernameController.text,
      'password': passwordController.text,
      'bio': bioController.text,
      'avatar': avatarImage != null ? await MultipartFile.fromFile(avatarImage!.path) : null,
    });

    try {
      final response = await dio.post('${serverIP}user_register/', data: formData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', usernameController.text);
      prefs.setString('password', passwordController.text);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('成功'),
          content: Text('注册成功'),
          actions: [
            TextButton(
              onPressed: () => {
                Navigator.pop(context),
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IndexPage()),
                  ),
              },
              child: Text('确定'),
            ),
          ],
        ),
      );
    } catch (error) {
      print(error);
      // 处理注册失败逻辑
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('错误'),
          content: Text('注册失败'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }


  Future<void> _selectAvatarImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        avatarImage = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('注册'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _selectAvatarImage,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: avatarImage != null ? FileImage(avatarImage!) : null,
                child: avatarImage == null ? Icon(Icons.person, size: 50.0) : null,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: '用户名',
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '密码',
              ),
              obscureText: true,
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: '简介',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _register,
              child: Text('注册并登录'),
            ),
          ],
        ),
      ),
    );
  }
}