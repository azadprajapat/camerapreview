import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:camera/camera.dart' as camera_;
import 'package:camera/new/camera.dart';
import 'package:cameraviewer/painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'package:flutter/widgets.dart' as w;

import 'ResultPage.dart';

class Home extends StatefulWidget {
  final camera_.CameraDescription camera;

  const Home({Key key, this.camera}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  List<ui.Image> imgframelist=[];
  camera_.CameraController _controller;
  Future<void> _initialiseControllerFuture;
  var pitch;
  var roll;
    List _list1 = [
      {"A": "110", "E": "30"},
      {"A": "140", "E": "30"},
      {"A": "170", "E": "30"},
      {"A": "200", "E": "30"},
      {"A": "230", "E": "30"},
      {"A": "260", "E": "30"},
      {"A": "260", "E": "60"},
      {"A": "230", "E": "60"},
      {"A": "200", "E": "60"},
      {"A": "170", "E": "60"},
      {"A": "140", "E": "60"},
      {"A": "110", "E": "60"},
  ];
  List<Points> _list = List<Points>();
  Points capture_point;
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
    capture_point =_list[0];
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
    Timer.periodic(Duration(seconds: 1), (timer) async{
      var current_A=int.parse(capture_point.A);
      var current_E=int.parse(capture_point.E);
      if(current_A-azimuth<=1&&current_A-azimuth>=-1&&current_E-pitch>=-1&&current_E-pitch<=1&&roll==0){
       await TakePhoto(current_A,current_E,context);
        print("# STATUS 200 PHOTO CAPTURED");
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(97, 97, 97, 1),
        body: Stack(
      children: <Widget>[
        Container(
          alignment: Alignment.topCenter,
          padding: EdgeInsets.only(top: 70),
          child: roll!=0?Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey,
              image: DecorationImage(
                image: AssetImage("assets/rotate.jpg"),
                fit: BoxFit.cover

              )
            ),
          ):Container(),

        ),
        CustomPaint(
          foregroundPainter: MyPainter(
              pitch: pitch,
              screen: MediaQuery.of(context).size,
              azimuth: azimuth,
              roll: roll,
              n: number,
              ImgList: _imglist,
              list: _list,
              img: imgframelist,
              capture_point: capture_point),
          child: FutureBuilder<void>(
            future: _initialiseControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return number==0? Container(
                      margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*(1-1/2.2)/2,horizontal:MediaQuery.of(context).size.width*(1-1/1.8)/2),
                   child: camera_.CameraPreview(_controller),
                ):Container();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 30),
             child: number!=0?CustomPaint(
               foregroundPainter: ProgressPainer(number/12),
               child:   GestureDetector(
                 onTap: (){
                   if(number==12){
                     Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=>ResultPage(_imglist)));
                   }
                 },
                 child: Container(
                   height: 60,
                   width: 60,
                   child: Center(child: number==12?Icon(Icons.check,color: Colors.green,size: 30,):
                   Text("${((number*100)/12).toInt()}%",style: TextStyle(fontSize: 18),)
                   ),
                   decoration: BoxDecoration(
                       borderRadius: BorderRadius.circular(35),
                       color: Colors.white,
                       boxShadow: [
                         BoxShadow(color: Colors.black,blurRadius: 5.0)
                       ]
                   ),
                 ),
               )
             ):Container(
               child: Text("Point the camera at the dot",style: TextStyle(color: Colors.white,fontSize: 20,),),
             ),
          ),
        ),
      ],
    )
    );
  }

  void TakePhoto(int current_A,int current_E,context) async {
    await _initialiseControllerFuture;
   final path =
        join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');
    await _controller.takePicture(path);
     print("#1 STATUS 200 IMAGE CAPTURED");
    setState(() {
          Image_set _set =Image_set(azimuth:current_A,elevation:current_E,Imagepath: path);
         _imglist.add(_set);
      });
    var img= await loadUiImage(number);
    setState(() {
      imgframelist.add(img);
      number++;
      if(number!=12) {
        capture_point = _list[number];
      }
    });

  }
  Future<ui.Image> loadUiImage(int k) async {
     final data2= await File(_imglist[k].Imagepath).readAsBytes();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(data2, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class ProgressPainer extends CustomPainter {
  final prgress;

  ProgressPainer(this.prgress);
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    Paint pt= new Paint()
    ..color=Colors.green
    ..style=PaintingStyle.stroke
    ..strokeWidth=10;
    canvas.drawArc(Rect.fromCircle(center:Offset(size.width/2,size.height/2),radius: 35), -pi/2, pi*prgress*2, false, pt);
   // canvas.drawCircle(Offset(size.width/2,size.height/2), 32, pt);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
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
