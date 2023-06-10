import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matpc_flutter/const/const.dart';
import 'package:matpc_flutter/pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/utils.dart';

class PostMomentPage extends StatefulWidget {
  const PostMomentPage({super.key});

  @override
  State<PostMomentPage> createState() => _PostMomentPageState();
}

class _PostMomentPageState extends State<PostMomentPage> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  String? _selectedType;
  List<Placemark>? _placeMarkList;
  Placemark? _selectedLocation;
  File? _selectedImage;
  File? _selectedVideo;
  bool _isSending = false;

  @override
  void dispose() {
    _quillController.dispose();
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
    setState(() {
      _isSending = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    final dio = Dio();
    print(_quillController.document.toDelta().toJson().toString());
    final formData = FormData.fromMap({
      'username': username,
      'type': _selectedType,
      'content': jsonEncode(_quillController.document.toDelta().toJson()).toString(),
      'media': _selectedImage != null ? await MultipartFile.fromFile(_selectedImage!.path) : (_selectedVideo != null ? await MultipartFile.fromFile(_selectedVideo!.path) : null),
      'location': _selectedLocation?.street.toString(),
    });
    try {
      await dio.post('${serverIP}post_moment/', data: formData);
      _showDialog('成功', '发布成功');
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const IndexPage()),
        );
      });
    } catch (e) {
      _showDialog('失败', '发布失败');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('确定'),
              ),
            ],
          ),
    );
  }

  Future<void> _imagePicker(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedVideo = null;
        _selectedImage = File(pickedImage.path);
      });
    }
    setState(() {
      Navigator.of(context).pop();
    });
  }

  Future<void> _videoPicker(ImageSource source) async {
    final pickedVideo = await ImagePicker().pickVideo(source: source);
    if (pickedVideo != null) {
      setState(() {
        _selectedVideo = File(pickedVideo.path);
      });
    }
    setState(() {
      Navigator.of(context).pop();
    });
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('拍照'),
                onTap: () {
                  _imagePicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.image),
                title: const Text('选择图片'),
                onTap: () {
                  _imagePicker(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('录像'),
                onTap: () {
                  _videoPicker(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('选择视频'),
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
        title: const Text('Add Moment'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SizedBox(
                height: 250,
                child: quill.QuillEditor(
                  controller: _quillController,
                  scrollController: ScrollController(),
                  scrollable: true,
                  focusNode: FocusNode(),
                  autoFocus: false,
                  readOnly: false,
                  placeholder: 'What\'s happening?',
                  expands: false,
                  padding: const EdgeInsets.all(10.0),
                ),
              ),
              quill.QuillToolbar.basic(
                controller: _quillController,
                multiRowsDisplay: false,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _showImagePicker,
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text('Add Image or Video'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.5,
                  ),
                ),
              if (_selectedVideo != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: VideoPlayerWidget(url: _selectedVideo!.path),
                  ),
                ),
              const SizedBox(height: 16.0),
              _placeMarkList == null
                  ? ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.location_on, color: Colors.white),
                label: const Text('获取当前位置'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              )
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
                decoration: const InputDecoration(
                  labelText: 'Select Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: _selectType,
                items: const [
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
                decoration: const InputDecoration(
                  labelText: 'Select Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _publishMoment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text('Publish Moment'),
              ),
            ],
          ),
          if (_isSending)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}