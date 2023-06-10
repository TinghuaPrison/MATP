import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:matpc_flutter/const/const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final dio = Dio();
  File? avatarImage;
  String? username;

  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

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
    setState(() {
      isLoading = true;
    });
    final formData = FormData.fromMap({
      'username': username,
      'new_avatar': avatarImage != null ? await MultipartFile.fromFile(avatarImage!.path) : null,
    });
    final response = await dio.post('${serverIP}edit_avatar/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      const snackBar = SnackBar(content: Text('Avatar edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      const snackBar = SnackBar(content: Text('Avatar edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editUsername() async {
    setState(() {
      isLoading = true;
    });
    final formData = FormData.fromMap({
      'username': username,
      'new_username': usernameController.text,
    });
    final response = await dio.post('${serverIP}edit_username/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      const snackBar = SnackBar(content: Text('Username edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
      username = usernameController.text;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('username', usernameController.text);
      usernameController.clear();
    } else {
      const snackBar = SnackBar(content: Text('Username edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editPassword() async {
    setState(() {
      isLoading = true;
    });
    final formData = FormData.fromMap({
      'username': username,
      'new_password': passwordController.text,
    });
    final response = await dio.post('${serverIP}edit_password/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      const snackBar = SnackBar(content: Text('Password edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString('password', passwordController.text);
      passwordController.clear();
    } else {
      const snackBar = SnackBar(content: Text('Password edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  Future<void> editBio() async {
    setState(() {
      isLoading = true;
    });
    final formData = FormData.fromMap({
      'username': username,
      'new_bio': bioController.text,
    });
    final response = await dio.post('${serverIP}edit_bio/', data: formData);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      const snackBar = SnackBar(content: Text('Bio edit successfully.'));
      scaffoldMessenger.showSnackBar(snackBar);
    } else {
      const snackBar = SnackBar(content: Text('Bio edit failed.'));
      scaffoldMessenger.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      onTap: _selectAvatarImage,
                      child: CircleAvatar(
                        radius: 50.0,
                        backgroundImage: avatarImage != null ? FileImage(avatarImage!) : null,
                        child: avatarImage == null ? const Icon(Icons.person, size: 50.0) : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: editAvatar,
                      child: const Text('Edit Avatar'),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'New Username', // Updated labelText
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        editUsername();
                      }
                    },
                    child: const Text('Edit Username'),
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'New Password', // Updated labelText
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        editPassword();
                      }
                    },
                    child: const Text('Edit Password'),
                  ),
                  const SizedBox(height: 12.0),
                  TextFormField(
                    controller: bioController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter bio';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        labelText: 'New Bio', // Updated labelText
                        border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        editBio();
                      }
                    },
                    child: const Text('Edit Bio'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: Container(
                color: Colors.black45,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}