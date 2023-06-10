import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/pages/index.dart';
import 'package:matpc_flutter/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File? avatarImage;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isLoading = false;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
    });

    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      _showDialog('错误', '请填写用户名和密码');
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
      _showDialog('成功', '注册成功', onSuccess: true);
    } catch (error) {
      _showDialog('错误', '注册失败，请检查网络设置');
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
              setState(() {
                isLoading = false;
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectAvatarImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    final imageCompress = ImageCompressUtil();
    if (pickedImage != null) {
      final compressedImage = await imageCompress.imageCompressAndGetFile(File(pickedImage.path));
      setState(() {
        avatarImage = compressedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('注册'),
      ),
      body: Stack(
        children: [
            Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _selectAvatarImage,
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: avatarImage != null ? FileImage(avatarImage!) : null,
                    child: avatarImage == null ? const Icon(Icons.person, size: 50.0) : null,
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: '简介',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('注册并登录'),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: Container(
                color: Colors.black45,
                child: const CircularProgressIndicator(),
              ),
            )
        ]
      ),
    );
  }
}