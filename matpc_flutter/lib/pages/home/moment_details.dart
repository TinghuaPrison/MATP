import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:matpc_flutter/domain/moment.dart';
import 'package:matpc_flutter/domain/comment.dart';
import 'package:dio/dio.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/user.dart';

class MomentDetail extends StatefulWidget {
  final Moment moment;
  final bool focusComment;

  const MomentDetail(this.moment, {Key? key, this.focusComment=false}): super(key: key);

  @override
  _MomentDetailState createState() => _MomentDetailState();
}

class _MomentDetailState extends State<MomentDetail> {
  final dio = Dio();
  List<Comment> comments = [];
  final _commentController = TextEditingController();
  late FocusNode _commentFocusNode;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _commentFocusNode = FocusNode();
    if (widget.focusComment) {
      Future.delayed(Duration(milliseconds: 200), () {
        _commentFocusNode.requestFocus();
      });
    }
  }

  Future<void> shareMoment() async {
    await FlutterShare.share(
        title: '分享动态',
        text: widget.moment.content,
        chooserTitle: '选择应用分享'
    );
  }

  Future<void> _fetchComments() async {
    FormData formData = FormData.fromMap({
      'moment_id': widget.moment.id,
    });
    Response response = await dio.post('${serverIP}get_moment_comments/', data: formData);
    Map<String, dynamic> jsonData = response.data;
    List commentsData = jsonData['list'];
    comments = commentsData.map((e) => Comment.fromJson(e)).toList();
    setState(() {});
  }

  Future<void> _postComment() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final username = sharedPreferences.getString('username');
    FormData formData = FormData.fromMap({
      'username': username,
      'moment_id': widget.moment.id,
      'content': _commentController.text,
    });
    Response response = await dio.post('${serverIP}comment_moment/', data: formData);
    if (response.statusCode == 200) {
      Provider.of<UserProvider>(context, listen: false).updateCommentCount(widget.moment.id);
      setState(() {
        _commentController.text = '';
        _fetchComments();
      });
    }
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Moment Detail'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: shareMoment,
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: <Widget>[
              MomentItemWithoutFollow(widget.moment),
              ...comments.map((comment) => CommentItem(comment)).toList(),
              const SizedBox(height: 100,),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      focusNode: _commentFocusNode,
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Write a comment...',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _postComment,
                    child: Text('发表'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}