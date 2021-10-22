import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:camera/camera.dart' as CAM;
import 'package:cameraviewer/modals/models.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/painter.dart';
import 'package:cameraviewer/services/imageProcessing/image_processing.dart';
import 'package:cameraviewer/services/image_optimization.dart';
import 'package:cameraviewer/services/socket-services/ImageSocket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'ResultPage.dart';

class Camera_Preview extends StatefulWidget {
  final CAM.CameraDescription camera;
  final CameraModel model;
  Camera_Preview({Key key, this.camera,this.model }) : super(key: key);
  @override
  _Camera_PreviewState createState() => _Camera_PreviewState();
}

class _Camera_PreviewState extends State<Camera_Preview> with SingleTickerProviderStateMixin {

  //camera and image controller
  int total_count=0;
  List<Points> capture_points =[];
  Points curr_capture_point;
  List<ui.Image> imgframelist=[];

  CAM.CameraController _cameraController;
  Future<void> _initialiseControllerFuture;

  int list_index;
  int number = 0;
  List<Image_set> image_collection = [];

  //senors
  MobileSensor sensor_data=MobileSensor();
  StreamSubscription<dynamic> _angles_stream;
  StreamSubscription<dynamic> _compass_stream;

  //image streams
  ImageSocket socket=ImageSocket();
  Stream image_stream;
  // audio controller
  AudioPlayer _audioPlayer=AudioPlayer();


  @override
  void initState() {
    super.initState();
    set_capture_points();
    set_senors();
    initiate_image_stream();
    initate_audio_feature();
    initiate_camera();
  }

  @override
  void dispose() {
    if (_angles_stream != null) {
      _angles_stream.cancel();
    }
    if (_compass_stream != null) {
      _compass_stream.cancel();
    }
    _cameraController.dispose();
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
              child: sensor_data.roll!=0?Container(
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
                  Text("Azimuth: ${sensor_data.azimuth}"),
                  Text("Elevation: ${sensor_data.pitch}")
                ],
              ),),

            ),
            widget.model!=null?CustomPaint(
              foregroundPainter: MyPainter(
                  sensor:sensor_data,
                  screen: MediaQuery.of(context).size,
                  n: number,
                  ImgList: image_collection,
                  list: capture_points,
                  model:widget.model,
                  img: imgframelist,
                  capture_point: curr_capture_point),
              child: FutureBuilder<void>(
                future: _initialiseControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return number==0? Container(
                      //   margin: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*(1-1/2.2)/2,horizontal:MediaQuery.of(context).size.width*(1-1/1.8)/2),
                      child: CAM.CameraPreview(_cameraController),
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
                      onTap: ()async{
                        if(if_all_image_received()){
                          print("Transfering to analysis model");
                          var data=  await   ImageProcessing().calculate(image_collection,capture_points,
                                  (String res) async{
                                print("status:"+res);
                              });
                          print("done 100 %");
                          socket.disconnect();
                          await Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(data)));

                        }else{
                          print('uh oh not all images are with us');
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
    await _cameraController.takePicture(path);
    // final result = await ImageGallerySaver.saveImage(File(path).readAsBytesSync(),quality: 100,name: path.split("/").last);

    socket.send_image(File(path), "Img"+number.toString());
    setState(() {
      Image_set _set =Image_set(azimuth:current_A,elevation:current_E,captured_path: path,name: "Img"+number.toString(),isbinary: false);
      image_collection.add(_set);
    });

    var img= await loadUiImage(image_collection[number].captured_path);
    setState(() {
      imgframelist.add(img);
      number++;
      if(number!=total_count) {
        curr_capture_point = capture_points[number];
      }else{
        curr_capture_point=capture_points[4];
      }
    });

  }
  bool if_all_image_received(){
      image_collection.forEach((element) {
        if(!element.isbinary)
          return false;
      });
      return true;
  }
  void set_capture_points(){
    setState(() {
      capture_points= OptimiseImage().get_image_cordinates(widget.model);
      total_count=capture_points.length;
    });
    curr_capture_point =capture_points[0];
  }
  void initiate_image_stream(){
    socket.initiate();
    image_stream=socket.streamSocket.stream;
    image_stream.listen((event) {
      image_collection.forEach((element) {
        if(!element.isbinary&&element.name==event['name']){
          element.binary_path=event['image'];
          element.isbinary=true;
        }
      });
    });
  }
  void set_senors()async{
    _angles_stream = AeyriumSensor.sensorEvents.listen((event) {
      setState(() {
        sensor_data.pitch = ((event.pitch) * 180 / math.pi).toInt();
        sensor_data.roll = (event.roll).toInt();
      });
    });
    _compass_stream = FlutterCompass.events.listen((event) {
      setState(() {
        sensor_data.azimuth= event.toInt();
      });
    });
  }
  void initiate_camera(){
    _cameraController = CAM.CameraController(
        widget.camera, CAM.ResolutionPreset.medium);
    _initialiseControllerFuture =  _cameraController.initialize();
  }
  void initate_audio_feature(){
    Timer.periodic(Duration(seconds: 1), (timer) async{
      double distance= pow((curr_capture_point.A-sensor_data.azimuth),2)+pow((curr_capture_point.A-sensor_data.azimuth),2);
      if(distance<40&&distance>5) {
        _audioPlayer.setSpeed(2);
        _audioPlayer.setVolume(1);
      }else{
        _audioPlayer.setSpeed(1);
        _audioPlayer.setVolume(0.5);
      }
      var current_A= curr_capture_point.A ;
      var current_E= curr_capture_point.E;
      if(current_A-sensor_data.azimuth<=1&&current_A-sensor_data.azimuth>=-1&&current_E-sensor_data.pitch>=-1&&current_E-sensor_data.pitch<=1&&sensor_data.roll==0){
        await TakePhoto(current_A,current_E,context);
        print("# STATUS 200 PHOTO CAPTURED");
      }

    });
  }
  void set_player()async{
    await _audioPlayer.setAsset('assets/beep.wav');
    await _audioPlayer.play();
  }

}




