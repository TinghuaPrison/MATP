import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/domain/user.dart';
import 'package:matpc_flutter/pages/home/moment_details.dart';
import 'package:matpc_flutter/pages/person/other_person.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/utils.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class Moment {
  final int id;
  final User user;
  final String type;
  final String content;
  final String media;
  final String location;
  final String c_time;
  final int likes_count;
  final int favorites_count;
  final int comments_count;
  final int followed;
  final int liked;
  final int favorited;

  Moment({
    required this.id,
    required this.user,
    required this.type,
    required this.content,
    required this.media,
    required this.location,
    required this.likes_count,
    required this.favorites_count,
    required this.comments_count,
    required this.c_time,
    required this.followed,
    required this.liked,
    required this.favorited,
  });

  factory Moment.fromJson(Map<String, dynamic> json) {
    return Moment(
        id: json['id'],
        user: User.fromJson(json['user']),
        type: json['type'],
        content: json['content'],
        media: json['media'],
        location: json['location'],
        likes_count: json['likes_count'],
        favorites_count: json['favorites_count'],
        comments_count: json['comments_count'],
        c_time: json['c_time'],
        followed: json['followed'],
        liked: json['liked'],
        favorited: json['favorited'],
    );
  }
}

class MomentItem extends StatefulWidget {
  final Moment moment;

  const MomentItem(this.moment, {Key? key}): super(key: key);

  @override
  State<MomentItem> createState() => _MomentItemState();
}

class _MomentItemState extends State<MomentItem> {
  final dio = Dio();

  Future<void> _follow() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'follower': username,
      'followee': widget.moment.user.username,
    });
    Response response = await dio.post('${serverIP}follow/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).followUser(widget.moment.user.username);
      });
    }
  }

  Future<void> _likeMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}like_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).likeMoment(widget.moment.id);
      });
    }
  }

  Future<void> _unlikeMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}unlike_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).unlikeMoment(widget.moment.id);
      });
    }
  }

  Future<void> _favoriteMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}favorite_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).favoriteMoment(widget.moment.id);
      });
    }
  }

  Future<void> _unfavoriteMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}unfavorite_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).unfavoriteMoment(widget.moment.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    bool followed = userProvider.followStatus[widget.moment.user.username] ?? false;
    bool isLiked = userProvider.likedStatus[widget.moment.id] ?? false;
    int likeCount = userProvider.likeCounts[widget.moment.id] ?? 0;
    bool isFavorited = userProvider.favoriteStatus[widget.moment.id] ?? false;
    int favoriteCount = userProvider.favoriteCounts[widget.moment.id] ?? 0;
    int commentCount = userProvider.commentCounts[widget.moment.id] ?? 0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            leading: InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: widget.moment.user.username,))),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(serverIP + widget.moment.user.avatar),
              ),
            ),
            title: InkWell(
                highlightColor: Colors.transparent,
                radius: 0.0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: widget.moment.user.username,))),
                child: Text(widget.moment.user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
            ),
            subtitle: Text(widget.moment.c_time, style: TextStyle(color: Colors.grey[600])),
            trailing: followed
                ? ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('已关注'),
            )
                : ElevatedButton(
              onPressed: _follow,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('关注'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    highlightColor: Colors.transparent,
                    radius: 0.0,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MomentDetail(widget.moment))),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: double.infinity),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (widget.moment.location.toString() != '未分类')
                            Chip(
                              label: Text(widget.moment.type, style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.blue,
                            ),
                          const SizedBox(height: 8.0),
                          quill.QuillEditor(
                              controller: quill.QuillController(document: quill.Document.fromDelta(quill.Delta.fromJson(jsonDecode(widget.moment.content))), selection: const TextSelection.collapsed(offset: 0),),
                              scrollController: ScrollController(),
                              scrollable: true,
                              focusNode: FocusNode(),
                              autoFocus: false,
                              readOnly: true,
                              enableInteractiveSelection: false,
                              placeholder: 'What\'s happening?',
                              expands: false,
                              padding: const EdgeInsets.all(10.0),
                            ),
                          if (widget.moment.media.toString() != 'null')
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: MediaQuery.of(context).size.width * 0.7,
                                child: _displayMedia(serverIP + widget.moment.media),
                              ),
                            ),
                          const SizedBox(height: 8.0,),
                          if (widget.moment.location.toString() != 'null')
                            Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Colors.blue),
                                  Text(widget.moment.location, style: TextStyle(color: Colors.grey[600])),
                                ]
                            ),
                        ],
                      ),
                    )
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      onPressed: isLiked ? _unlikeMoment : _likeMoment,
                      child: Row(
                        children: <Widget>[
                          Icon(!isLiked ? Icons.thumb_up_off_alt : Icons.thumb_up, color: Colors.blue),
                          Text(likeCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: isFavorited ? _unfavoriteMoment : _favoriteMoment,
                      child: Row(
                        children: <Widget>[
                          Icon(!isFavorited ? Icons.bookmark_add : Icons.bookmark, color: Colors.blue),
                          Text(favoriteCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MomentDetail(widget.moment, focusComment: true))),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.comment, color: Colors.blue),
                          Text(commentCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MomentItemWithoutFollow extends StatefulWidget {
  final Moment moment;

  const MomentItemWithoutFollow(this.moment, {Key? key}): super(key: key);

  @override
  State<MomentItemWithoutFollow> createState() => _MomentItemWithoutFollowState();
}

class _MomentItemWithoutFollowState extends State<MomentItemWithoutFollow> {

  final dio = Dio();

  Future<void> _likeMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}like_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).likeMoment(widget.moment.id);
      });
    }
  }

  Future<void> _unlikeMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}unlike_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).unlikeMoment(widget.moment.id);
      });
    }
  }

  Future<void> _favoriteMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}favorite_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).favoriteMoment(widget.moment.id);
      });
    }
  }

  Future<void> _unfavoriteMoment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}unfavorite_moment/', data: formData);
    if (response.statusCode == 200) {
      setState(() {
        Provider.of<UserProvider>(context, listen: false).unfavoriteMoment(widget.moment.id);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: true);
    bool isLiked = userProvider.likedStatus[widget.moment.id] ?? false;
    int likeCount = userProvider.likeCounts[widget.moment.id] ?? 0;
    bool isFavorited = userProvider.favoriteStatus[widget.moment.id] ?? false;
    int favoriteCount = userProvider.favoriteCounts[widget.moment.id] ?? 0;
    int commentCount = userProvider.commentCounts[widget.moment.id] ?? 0;

    return Card(
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
            leading: InkWell(
              highlightColor: Colors.transparent,
              radius: 0.0,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: widget.moment.user.username,))),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: CachedNetworkImageProvider(serverIP + widget.moment.user.avatar),
              ),
            ),
            title: InkWell(
                highlightColor: Colors.transparent,
                radius: 0.0,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherPersonPage(otherUser: widget.moment.user.username,))),
                child: Text(widget.moment.user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
            ),
            subtitle: Text(widget.moment.c_time, style: TextStyle(color: Colors.grey[600])),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.moment.type.toString() != '未分类')
                  Chip(
                    label: Text(widget.moment.type, style: const TextStyle(color: Colors.white)),
                    backgroundColor: Colors.blue,
                  ),
                const SizedBox(height: 8.0),
                quill.QuillEditor(
                  controller: quill.QuillController(document: quill.Document.fromDelta(quill.Delta.fromJson(jsonDecode(widget.moment.content))), selection: const TextSelection.collapsed(offset: 0),),
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: FocusNode(),
                  autoFocus: false,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  placeholder: 'What\'s happening?',
                  expands: false,
                  padding: const EdgeInsets.all(10.0),
                ),
                if (widget.moment.media.toString() != 'null')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: _displayMedia(serverIP + widget.moment.media),
                    ),
                  ),
                const SizedBox(height: 8.0,),
                if (widget.moment.location.toString() != 'null')
                  Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.blue),
                        Text(widget.moment.location, style: TextStyle(color: Colors.grey[600])),
                      ]
                  ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      onPressed: isLiked ? _unlikeMoment : _likeMoment,
                      child: Row(
                        children: <Widget>[
                          Icon(!isLiked ? Icons.thumb_up_off_alt : Icons.thumb_up, color: Colors.blue),
                          Text(likeCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: isFavorited ? _unfavoriteMoment : _favoriteMoment,
                      child: Row(
                        children: <Widget>[
                          Icon(!isFavorited ? Icons.bookmark_add : Icons.bookmark, color: Colors.blue),
                          Text(favoriteCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () { },
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.comment, color: Colors.blue),
                          Text(commentCount.toString(), style: const TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _displayMedia(String mediaUrl) {
  String fileExtension = mediaUrl.split('.').last;

  List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  List<String> videoExtensions = ['mp4', 'avi', 'mov'];

  if (imageExtensions.contains(fileExtension)) {
    return CachedNetworkImage(imageUrl: mediaUrl,);
  } else if (videoExtensions.contains(fileExtension)) {
    return VideoPlayerWidget(url: mediaUrl,);
  } else {
    return const Text('Unknown media type');
  }
}