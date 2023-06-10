import 'package:flutter/material.dart';
import 'package:matpc_flutter/pages/home/home.dart';
import 'package:matpc_flutter/pages/search/search.dart';
import 'package:matpc_flutter/pages/message/sessions.dart';
import 'package:matpc_flutter/pages/person/person.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pageOptions = <Widget>[
    const HomePage(),
    const SearchPage(),
    const SessionsPage(),
    PersonPage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pageOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Message',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Person',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black45,
        ),
      ),
    );
  }
}