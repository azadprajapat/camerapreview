import 'dart:async';
import 'dart:math';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:camera/camera.dart' as camera_;
import 'package:camera/new/camera.dart';
import 'package:cameraviewer/painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

import 'ResultPage.dart';

class Home extends StatefulWidget {
  final camera_.CameraDescription camera;

  const Home({Key key, this.camera}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  camera_.CameraController _controller;
  Future<void> _initialiseControllerFuture;
  var pitch;
  var roll;
  int number=0;
  List<Image_set> _imglist=[];
  var A;
  var E=0;
  var azimuth;
   StreamSubscription<dynamic> _streamSubscriptions;
   StreamSubscription<dynamic> _streamSubscriptions2;
   @override
  void initState() {
    super.initState();
    _streamSubscriptions = AeyriumSensor.sensorEvents.listen((event) {
      setState(() {
        pitch = ((event.pitch)*180/math.pi).toInt();
        roll = (event.roll).toInt() ;
      });
    });
    _streamSubscriptions2=FlutterCompass.events.listen((event) {
      setState(() {
        azimuth=event.toInt();
      if(number==0) {
        A = event.toInt();
      }
      });
    });
    _controller = camera_.CameraController(widget.camera, camera_.ResolutionPreset.ultraHigh);
    _initialiseControllerFuture = _controller.initialize();
     Timer.periodic(Duration(seconds: 1), (timer) {
      if(A-azimuth<=1&&A-azimuth>=-1&&E-pitch>=-1&&E-pitch<=1){
        TakePhoto();
      }

    });
  }
  @override
  void dispose() {
    if (_streamSubscriptions != null) {
      _streamSubscriptions.cancel();
    }
    if (_streamSubscriptions2 != null) {
      _streamSubscriptions2.cancel();
    }
    _controller.dispose();
    super.dispose();
  }
  Widget build(BuildContext context ) {
    return Scaffold(
         body: Stack(

          children: <Widget>[
            CustomPaint(
              foregroundPainter: MyPainter(
                  pitch: pitch, screen: MediaQuery.of(context).size,A:A,E: E,azimuth: azimuth,roll: roll,n: number,ImgList: _imglist),
                      child: FutureBuilder<void>(
                        future: _initialiseControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return  Container(
                              child: camera_.CameraPreview(_controller),
                            );
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),

            ),
           ],
        ));
  }
    void TakePhoto() async{
    await _initialiseControllerFuture;
    final path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png');

    await _controller.takePicture(path);
   Image_set _set =Image_set(azimuth: A,elevation: pitch,Imagepath: path);
   _imglist.add(_set);

    print("# STATUS 200 IMAGE CAPTURED");
    setState(() {
      number++;
    });
    setState(() {
      E=E;
      A=A+30;

    });
   }
}
class Image_set {
  final Imagepath;
  final azimuth;
  final elevation;
  Image_set({this.elevation,this.azimuth,this.Imagepath});
}