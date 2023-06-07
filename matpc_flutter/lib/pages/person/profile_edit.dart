import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final dio = Dio();
  File? avatarImage;
  String? username;

  @override
  void initState() {
    super.initState();
    getUsername();
  }

  Future<void> getUsername() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences.getString('username');
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

  Future<void> editAvatar() async {
    final formData = FormData.fromMap({
      'username': username,
      'new_avatar': avatarImage != null ? await MultipartFile.fromFile(avatarImage!.path) : null,
    });
    final response = await dio.post('${serverIP}edit_avatar/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Avatar edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(content: Text('Avatar edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editUsername() async {
    final formData = FormData.fromMap({
      'username': username,
      'new_username': usernameController.text,
    });
    final response = await dio.post('${serverIP}edit_username/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Avatar edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
      username = usernameController.text;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('username', usernameController.text);
      usernameController.clear();
    } else {
      final snackBar = SnackBar(content: Text('Avatar edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editPassword() async {
    final formData = FormData.fromMap({
      'username': username,
      'new_password': passwordController.text,
    });
    final response = await dio.post('${serverIP}edit_password/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Avatar edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('password', passwordController.text);
      passwordController.clear();
    } else {
      final snackBar = SnackBar(content: Text('Avatar edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editBio() async {
    final formData = FormData.fromMap({
      'username': username,
      'new_bio': bioController.text,
    });
    final response = await dio.post('${serverIP}edit_bio/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response.statusCode == 200) {
      final snackBar = SnackBar(content: Text('Avatar edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      final snackBar = SnackBar(content: Text('Avatar edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _selectAvatarImage,
              child: CircleAvatar(
                radius: 50.0,
                backgroundImage: avatarImage != null ? FileImage(avatarImage!) : null,
                child: avatarImage == null ? Icon(Icons.person, size: 50.0) : null,
              ),
            ),
            ElevatedButton(
              onPressed: editAvatar,
              child: Text('Edit Avatar'),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'New Username'),
            ),
            ElevatedButton(
              onPressed: editUsername,
              child: Text('Edit Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            ElevatedButton(
              onPressed: editPassword,
              child: Text('Edit Password'),
            ),
            TextField(
              controller: bioController,
              decoration: InputDecoration(labelText: 'New Bio'),
            ),
            ElevatedButton(
              onPressed: editBio,
              child: Text('Edit Bio'),
            ),
          ],
        ),
      ),
    );
  }
}
