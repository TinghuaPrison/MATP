import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/user.dart';

class FavoriteMomentsPage extends StatefulWidget {
  const FavoriteMomentsPage({super.key});

  @override
  State<FavoriteMomentsPage> createState() => _FavoriteMomentsPageState();
}

class _FavoriteMomentsPageState extends State<FavoriteMomentsPage> {
  List<Moment> favoriteMoments = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteMoments();
  }

  Future<void> fetchFavoriteMoments() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'username': username,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_favorite_moments/', data: formData);
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
      favoriteMoments = momentsList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Moments"),
      ),
      body: RefreshIndicator(
        onRefresh: fetchFavoriteMoments,
        child: ListView.builder(
          itemCount: favoriteMoments.length,
          itemBuilder: (BuildContext context, int index) {
            Moment moment = favoriteMoments[index];
            return MomentItem(moment); // Assuming you have a widget named MomentItem for displaying moments
          },
        ),
      ),
    );
  }
}