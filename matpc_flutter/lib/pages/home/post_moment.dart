import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class PostMomentPage extends StatefulWidget {
  @override
  _PostMomentPageState createState() => _PostMomentPageState();
}

class _PostMomentPageState extends State<PostMomentPage> {
  final TextEditingController _textEditingController = TextEditingController();
  String? _selectedType;
  List<Placemark>? _placeMarkList;
  Placemark? _selectedLocation;
  File? _selectedImage;
  File? _selectedVideo;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    setState(() {
      _placeMarkList = placeMarks;
    });
  }

  void _selectLocation(Placemark? location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void _selectType(String? type) {
    setState(() {
      _selectedType = type;
    });
  }

  void _publishMoment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    final dio = Dio();
    final formData = FormData.fromMap({
      'username': username,
      'type': _selectedType,
      'content': _textEditingController.text,
      'media': _selectedImage != null ? await MultipartFile.fromFile(_selectedImage!.path) : (_selectedVideo != null ? await MultipartFile.fromFile(_selectedVideo!.path) : null),
      'location': _selectedLocation,
    });
    try {
      final response = await dio.post('${serverIP}post_moment/', data: formData);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('成功'),
          content: Text('发布成功'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IndexPage()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('失败'),
          content: Text('发布失败'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _imagePicker(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedVideo = null;
        _selectedImage = File(pickedImage.path);
      });
    }
    Navigator.of(context).pop();
  }

  Future<void> _videoPicker(ImageSource source) async {
    final pickedVideo = await ImagePicker().pickVideo(source: source);
    if (pickedVideo != null) {
      setState(() {
        _selectedVideo = File(pickedVideo.path);
      });
    }
    Navigator.of(context).pop();
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined),
                title: Text('拍照'),
                onTap: () {
                  _imagePicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.image),
                title: Text('选择图片'),
                onTap: () {
                  _imagePicker(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('录像'),
                onTap: () {
                  _videoPicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library),
                title: Text('选择视频'),
                onTap: () {
                  _videoPicker(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Moment'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(
              hintText: 'Enter your moment text...',
            ),
            minLines: 10,
            maxLines: 10,
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _showImagePicker,
            child: Text('Add Image or Video'),
          ),
          if (_selectedImage != null)
            Image.file(_selectedImage!)
          else
            SizedBox.shrink(),
          if (_selectedVideo != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayerWidget(file: _selectedVideo!,),
            )
          else
            SizedBox.shrink(),
          SizedBox(height: 16.0),
          _placeMarkList == null
          ?  TextButton(onPressed: _getCurrentLocation, child: Text('获取当前位置'))
          : DropdownButtonFormField<Placemark>(
              value: _selectedLocation,
              onChanged: _selectLocation,
              items: _placeMarkList?.map((e) => DropdownMenuItem(
                value: e,
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    e.street.toString(),
                  ),
                ),
              )).toList(),
              decoration: InputDecoration(
                labelText: 'Select Location',
              ),
            ),
          SizedBox(height: 16.0),
          DropdownButtonFormField<String>(
            value: _selectedType,
            onChanged: _selectType,
            items: [
              DropdownMenuItem(
                value: '校园生活',
                child: Text('校园生活'),
              ),
              DropdownMenuItem(
                value: '二手物品',
                child: Text('二手物品'),
              ),
              // Add more dropdown items as needed
            ],
            decoration: InputDecoration(
              labelText: 'Select Type',
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _publishMoment,
            child: Text('Publish Moment'),
          ),
        ],
      ),
    );
  }
}