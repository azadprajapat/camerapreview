import 'package:camera/camera.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/services/platform_channels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'camerapreview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  Permission camera = Permission.camera;
  Permission record = Permission.location;
  Permission media = Permission.microphone;
  Permission storage = Permission.storage;
  await camera.request();
  await record.request();
  await media.request();
  await storage.request();

  final cameras = await availableCameras();
  final firstCamera=cameras.first;
  CameraModel cameraModel = await get_camera_hardware();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomePage(),
    routes: {
      '/capture-img': (C) => Camera_Preview(camera: firstCamera,model: cameraModel )
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
        title: Text("Sunscape Beta Application"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            RaisedButton(
                child: Text('Start Analysis'),
                onPressed: ()async{
                  await Navigator.pushNamed(context, "/capture-img");
                }),
            SizedBox(height: 15,),
            //
          ],
        ),
      ),
    );
  }
}


