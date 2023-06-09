import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Moment> moments = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchMoments(String query) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'username': username,
      'query': query,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}search_moment/', data: formData);
    if (response.statusCode == 201) {
      return;
    }
    Map<String, dynamic> jsonData = response.data;
    List momentsData = jsonData['list'];
    List<Moment> momentsList = momentsData.map((e) => Moment.fromJson(e)).toList();
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    Map<String, bool> newFollowStatus = {};
    for (var moment in momentsList) {
      newFollowStatus[moment.user.username] = (moment.followed == 1);
      userProvider.likedStatus[moment.id] = (moment.liked == 1);
      userProvider.likeCounts[moment.id] = moment.likes_count;
      userProvider.favoriteStatus[moment.id] = (moment.favorited == 1);
      userProvider.favoriteCounts[moment.id] = moment.favorites_count;
      userProvider.commentCounts[moment.id] = moment.comments_count;
      userProvider.blockStatus[moment.user.username] = false;
    }
    userProvider.updateFollowStatus(newFollowStatus);
    setState(() {
      moments = momentsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Search",
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (query) async {
                    fetchMoments(query);
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: moments.length,
                  itemBuilder: (BuildContext context, int index) {
                    Moment moment = moments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: MomentItem(moment),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}