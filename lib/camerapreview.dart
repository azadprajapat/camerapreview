import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:camera/camera.dart' as camera_;
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/painter.dart';
import 'package:cameraviewer/services/image_optimization.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class Camera_Preview extends StatefulWidget {

  final camera_.CameraDescription camera;
  final CameraModel model;
    Camera_Preview({Key key, this.camera,this.model }) : super(key: key);

  @override
  _Camera_PreviewState createState() => _Camera_PreviewState();
}

class _Camera_PreviewState extends State<Camera_Preview> with SingleTickerProviderStateMixin {

  AudioPlayer _audioPlayer=AudioPlayer();

  List<ui.Image> imgframelist=[];
  camera_.CameraController _controller;
  Future<void> _initialiseControllerFuture;
  var pitch;
  var roll;
  int total_count=0;
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

    set_player();
    setState(() {
      _list= OptimiseImage().get_image_cordinates(widget.model);
      total_count=_list.length;
    });
    print("total count ${total_count}");
    capture_point =_list[0];
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
    _initialiseControllerFuture =  _controller.initialize();

    Timer.periodic(Duration(seconds: 1), (timer) async{
      double distance= pow((capture_point.A-azimuth),2)+pow((capture_point.A-azimuth),2);
       if(distance<40&&distance>5) {
        _audioPlayer.setSpeed(2);
        _audioPlayer.setVolume(1);
      }else{
         _audioPlayer.setSpeed(1);
         _audioPlayer.setVolume(0.5);
       }
      var current_A= capture_point.A ;
      var current_E= capture_point.E;
      if(current_A-azimuth<=1&&current_A-azimuth>=-1&&current_E-pitch>=-1&&current_E-pitch<=1&&roll==0){
       await TakePhoto(current_A,current_E,context);
        print("# STATUS 200 PHOTO CAPTURED");
      }

    });
    }
   void set_player()async{
    await _audioPlayer.setAsset('assets/beep.wav');
    await _audioPlayer.play();
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
          ):Container(child: Column(
            children: [
              Text("Azimuth: ${azimuth}"),
              Text("Elevation: ${pitch}")
            ],
          ),),

        ),
        widget.model!=null?CustomPaint(
          foregroundPainter: MyPainter(
              pitch: pitch,
              screen: MediaQuery.of(context).size,
              azimuth: azimuth,
              roll: roll,
              n: number,
              ImgList: _imglist,
              list: _list,
              model:widget.model,
              img: imgframelist,
              capture_point: capture_point),
          child: FutureBuilder<void>(
            future: _initialiseControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return number==0? Container(
                  //   margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*(1-1/2.2)/2,horizontal:MediaQuery.of(context).size.width*(1-1/1.8)/2),
                   child: camera_.CameraPreview(_controller),
                ):Container();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ):Container(),
        Center(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 30),
             child: number!=0?CustomPaint(
               foregroundPainter: ProgressPainer(number/total_count),
               child:   GestureDetector(
                 onTap: (){
                   if(number==total_count){
                     Navigator.pop(context,_imglist);
                    _shareMixed(_imglist);
                   }
                 },
                 child: Container(
                   height: 60,
                   width: 60,
                   child: Center(child: number==total_count?Icon(Icons.check,color: Colors.green,size: 30,):
                   Text("${((number*100)/total_count).toInt()}%",style: TextStyle(fontSize: 18),)
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

  void TakePhoto(double current_A,double current_E,context) async {
    await _initialiseControllerFuture;
   final path =
        join((await getExternalStorageDirectory()).path,DateTime.now().toString()+'_img.jpg');
   if(await File(path).exists()){
    await File(path).delete();
   }
    await _controller.takePicture(path);

   // final result = await ImageGallerySaver.saveImage(File(path).readAsBytesSync(),quality: 100,name: path.split("/").last);
     print("#1 STATUS 200 IMAGE CAPTURED");
    setState(() {
          Image_set _set =Image_set(azimuth:current_A,elevation:current_E,Imagepath: path);
         _imglist.add(_set);
      });
    var img= await loadUiImage(number);
    print("height and width of images");
    print(img.height);
    print(img.width);
    setState(() {
      imgframelist.add(img);
      number++;
      if(number!=total_count) {
        capture_point = _list[number];
      }else{
        capture_point=_list[4];
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
  Future<void> _shareMixed(List<Image_set> images) async {
    try {
      await Share.files(
          'Sunscape images',
          {
            'img_1.png': File(images[0].Imagepath).readAsBytesSync(),
            'img_2.png': File(images[1].Imagepath).readAsBytesSync(),
            'img_3.png': File(images[2].Imagepath).readAsBytesSync(),
            'img_4.png': File(images[3].Imagepath).readAsBytesSync(),
            'img_5.png': File(images[4].Imagepath).readAsBytesSync(),
            'img_6.png': File(images[5].Imagepath).readAsBytesSync(),
            'img_7.png': File(images[6].Imagepath).readAsBytesSync(),
            'img_8.png': File(images[7].Imagepath).readAsBytesSync(),
            'img_9.png': File(images[8].Imagepath).readAsBytesSync(),
            'img_10.png': File(images[9].Imagepath).readAsBytesSync(),
            'img_11.png': File(images[10].Imagepath).readAsBytesSync(),
            'img_12.png': File(images[11].Imagepath).readAsBytesSync(),
          },
          '*/*',
          text: 'Add these file to google drive folder');
    } catch (e) {
      print('error: $e');
    }
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
  final String Imagepath;
  final double azimuth;
  final double elevation;
  Image_set({this.elevation, this.azimuth, this.Imagepath});
}

class Points {
  final double A;
  final double E;
  Points({this.A, this.E});
}
