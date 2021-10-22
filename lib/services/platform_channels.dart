
import 'dart:math';

import 'package:cameraviewer/modals/camera_model.dart';
import 'package:flutter/services.dart';

Future<CameraModel> get_camera_hardware () async{
  CameraModel cameraModel= new CameraModel();
  var platform = const MethodChannel("get");
  try {
    var result4 = await platform.invokeMethod("cameradata");
    cameraModel.sensor_p_x=result4["sensorpx"] as int;
    cameraModel.sensor_p_y=result4["sensorpy"] as int;
    cameraModel.focal_length=result4["focal_length"] as double;
    cameraModel.sensorw=result4["sensorw"] as double;
    cameraModel.sensorh=result4["sensorh"] as double;
    cameraModel.vfv=(result4["hfv"] as double)*180/pi;
    cameraModel.hfv=(result4["vfv"] as double)*180/pi;
  } on PlatformException catch (e) {}
  return cameraModel;
}

class AudioService {
  int volume=25;
  Future<void> play_audio()async{
    var platform = const MethodChannel("get");
    try{
      var result = await platform.invokeMethod("audio");

    } on PlatformException catch(e){
      print("errror while playing audio");
    }
  }
  Future<void> Adjust_volume(int volume)async{
    if(this.volume==volume)
      return;
    this.volume=volume;
    var platform = const MethodChannel("get");
    try{
      var result = await platform.invokeMethod("volume",{"vol":volume});
    } on PlatformException catch(e){
      print("errror while adjusting volume"+e.message);
    }
  }
  Future<void> StopAudio()async{
    var platform = const MethodChannel("get");
    try{
      var result = await platform.invokeMethod("stop");
    } on PlatformException catch(e){
      print("errror while stoping audio");
    }
  }
}