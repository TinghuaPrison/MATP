import 'package:flutter/material.dart';
import 'package:matpc_flutter/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:matpc_flutter/domain/user.dart';

void main() async {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}