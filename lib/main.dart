import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'camerapreview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera=cameras.first;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(camera:firstCamera),
  ));
}

