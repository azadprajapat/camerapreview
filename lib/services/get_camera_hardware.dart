
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