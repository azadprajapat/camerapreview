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
  List _list1 = [
    {"A": "100", "E": "20"},
    {"A": "140", "E": "20"},
    {"A": "180", "E": "20"},
    {"A": "220", "E": "20"},
    {"A": "260", "E": "20"},
    {"A": "100", "E": "48"},
    {"A": "140", "E": "48"},
    {"A": "180", "E": "48"},
    {"A": "220", "E": "48"},
    {"A": "260", "E": "48"},
    {"A": "100", "E": "76"},
    {"A": "140", "E": "76"},
    {"A": "180", "E": "76"},
    {"A": "220", "E": "76"},
    {"A": "260", "E": "76"},
  ];
  List<Points> _list = List<Points>();
  List<Points> _visible_point_list = List<Points>();
  int list_index;
  int number = 0;
  List<Image_set> _imglist = [];
  var azimuth;
  StreamSubscription<dynamic> _streamSubscriptions;
  StreamSubscription<dynamic> _streamSubscriptions2;

  @override
  void initState() {
    _list1.forEach((element) {
      _list.add(Points(A: element['A'], E: element['E']));
    });
    _visible_point_list.add(_list[0]);
      print("# STATUS 200 VISIBLE LIST");
    super.initState();
    _streamSubscriptions = AeyriumSensor.sensorEvents.listen((event) {
      setState(() {
        pitch = ((event.pitch) * 180 / math.pi).toInt();
        roll = (event.roll).toInt();
      });
    });
    _streamSubscriptions2 = FlutterCompass.events.listen((event) {
      setState(() {
        azimuth = event.toInt();
      });
    });
    _controller = camera_.CameraController(
        widget.camera, camera_.ResolutionPreset.medium);
    _initialiseControllerFuture = _controller.initialize();
    Timer.periodic(Duration(seconds: 1), (timer) {
    _visible_point_list.forEach((element) {
      var current_A=int.parse(element.A);
      var current_E=int.parse(element.E);
      if(current_A-azimuth<=1&&current_A-azimuth>=-1&&current_E-pitch>=-1&&current_E-pitch<=1){
        TakePhoto(_visible_point_list.indexOf(element),current_A,current_E);
        print("# STATUS 200 PHOTO CAPTURED");
      }
    });

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

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: <Widget>[
        CustomPaint(
          foregroundPainter: MyPainter(
              pitch: pitch,
              screen: MediaQuery.of(context).size,
              azimuth: azimuth,
              roll: roll,
              n: number,
              ImgList: _imglist,
              list: _list,
              visible_list: _visible_point_list),
          child: FutureBuilder<void>(
            future: _initialiseControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container(
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

  void TakePhoto(int index,int current_A,int current_E) async {
 //   await _initialiseControllerFuture;
  //  final path =
    //    join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
  //  await _controller.takePicture(path);
    var path="# STATUS 200 PATH";
    print("#1 STATUS 200 IMAGE CAPTURED");
   setState(() {
          Image_set _set =Image_set(azimuth:current_A,elevation:current_E,Imagepath: path);
         _imglist.add(_set);
           number++;
          _visible_point_list.removeAt(index);
    });
    print("#2 STATUS 200 ${_visible_point_list.length} ");

    _list.forEach((element) {
     var _listA=int.parse(element.A);
     var _listE=int.parse(element.E);
     if(_listA-current_A==0&&_listE-current_E==0){
       print("#3 STATUS 200");
       setState(() {
         list_index=_list.indexOf(element);
       });
       print("#4 STATUS 200");
       return null;
     }
   });
    setState(() {
      _list.removeAt(list_index);
    });
    print("#5 STATUS 200 ${_list.length}");
    _list.forEach((element) {
      var _listA=int.parse(element.A);
      var _listE=int.parse(element.E);
      if((_listA-current_A<50&&(_listA-current_A>0)&&(_listE-current_E)==0)
          ||(_listA-current_A>-50&&(_listA-current_A<0)&&(_listE-current_E)==0)
          ||(_listA-current_A==0&&(_listE-current_E)<40&&(_listE-current_E)>0)
          ||(_listA-current_A==0&&(_listE-current_E)>-40&&(_listE-current_E)<0)){
        print("#6 STATUS 200");
        setState(() {
        _visible_point_list.add(element);
      });
      }

    });
    print("#7 STATUS 200 ${_visible_point_list.length} & ${_list.length}");
    _visible_point_list.forEach((element) {
      print("${element.A} & ${element.E}");
    });
  }
}

class Image_set {
  final Imagepath;
  final azimuth;
  final elevation;
  Image_set({this.elevation, this.azimuth, this.Imagepath});
}

class Points {
  final A;
  final E;

  Points({this.A, this.E});
}
