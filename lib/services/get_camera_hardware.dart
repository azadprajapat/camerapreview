
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:flutter/services.dart';

Future<CameraModel> get_camera_hardware () async{
  CameraModel cameraModel= new CameraModel();

  // final cameras = await availableCameras();
  // final firstCamera = cameras.first;
  // cameraModel.camera=firstCamera;
  var platform = const MethodChannel("get");
  try {
    var result1 = await platform.invokeMethod("get");
    cameraModel.focal_length=(result1*100).toInt();
  } on PlatformException catch (e) {}
  try {
    var result2 = await platform.invokeMethod("horizon");
    cameraModel.Horizontal_View_angle=result2;
    print("h set successfully");
  } on PlatformException catch (e) {
    print('unable to get h ${e}');
  }
  try {
    var result3 = await platform.invokeMethod("vert");
    cameraModel.Vertical_View_angle=result3;
    print("v set successfully");
  } on PlatformException catch (e) {}

  return cameraModel;
}