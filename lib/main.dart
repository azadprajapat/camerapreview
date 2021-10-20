import 'dart:math';

import 'package:camera/camera.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/services/get_camera_hardware.dart';
import 'package:cameraviewer/test_images.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'camerapreview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    routes: {
      '/capture-img': (C) => Home(
            camera: firstCamera,
          )
    },
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sunscape Test Application"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
                child: Text('Capture Images'),
                onPressed: () async {
                  await Navigator.pushNamed(context, "/capture-img");
                }),
            /*RaisedButton(
                child: Text('Test Images'),
                onPressed: ()async{
                  print("Camera Datas");
                  CameraModel cameraModel = await get_camera_hardware();
                  print(cameraModel.focal_length);
                  print("sensor PIXELS ${cameraModel.sensor_p_x}X${cameraModel.sensor_p_y}");
                  print("sensor MM ${cameraModel.sensorw}X${cameraModel.sensorh}");
                  print("sensor FOV ${cameraModel.vfv}X${cameraModel.hfv}");
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>ParentBuilder()));
                }),*/

            SizedBox(
              height: 15,
            ),
            //
          ],
        ),
      ),
    );
  }
}
