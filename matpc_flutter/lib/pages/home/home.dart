import 'package:flutter/material.dart';
import 'package:matpc_flutter/pages/home/home_new.dart';
import 'package:matpc_flutter/pages/home/home_hot.dart';
import 'package:matpc_flutter/pages/home/home_type.dart';
import 'package:matpc_flutter/pages/home/home_follow.dart';
import 'package:matpc_flutter/pages/home/post_moment.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: const TabBar(
            tabs: [
              Tab(text: 'New'),
              Tab(text: 'Hot'),
              Tab(text: 'Type'),
              Tab(text: 'Follow'),
            ],
            labelColor: Colors.blue,
          ),
        body: TabBarView(
          children: [
            NewHomePage(),
            HotHomePage(),
            TypeHomePage(),
            FollowHomePage(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostMomentPage()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}