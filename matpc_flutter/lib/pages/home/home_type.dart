import 'package:flutter/material.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/const/const.dart';

import '../../domain/user.dart';

class TypeHomePage extends StatefulWidget {
  @override
  _TypeHomePageState createState() => _TypeHomePageState();
}

class _TypeHomePageState extends State<TypeHomePage> {
  List<Moment> moments = [];
  String selectedType = '校园生活';

  @override
  void initState() {
    super.initState();
    fetchMoments(selectedType);
  }

  Future<void> fetchMoments(String type) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    final formData = FormData.fromMap({
      'sorted_by': 'type',
      'type': type,
      'username': username,
    });
    Dio dio = Dio();
    Response response = await dio.post('${serverIP}get_moments/', data: formData);
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
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: DropdownButton<String>(
          value: selectedType,
          items: <String>['校园生活', '二手物品',]
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                selectedType = newValue;
              });
              fetchMoments(selectedType);
            }
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => fetchMoments(selectedType),
        child: ListView.builder(
          itemCount: moments.length,
          itemBuilder: (BuildContext context, int index) {
            Moment moment = moments[index];
            return MomentItem(moment);
          },
        ),
      ),
    );
  }
}
