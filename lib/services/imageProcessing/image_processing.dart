import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/modals/sun_models.dart';
import 'package:cameraviewer/services/get_location.dart';
import 'package:cameraviewer/services/imageProcessing/sun_position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as IMG;

import '../../camerapreview.dart';
import '../get_camera_hardware.dart';
class ImageProcessing{
  Map<int,dynamic> angles={
    1:{
      "A":110,
      "E":30,
    },
    2:{
      "A":140,
      "E":30,
    },
    3:{
      "A":170,
      "E":30,
    },
    4:{
      "A":200,
      "E":30,
    },
    5:{
      "A":230,
      "E":30,
    },
    6:{
      "A":260,
      "E":30,
    },
    7:{
      "A":260,
      "E":60,
    },
    8:{
      "A":230,
      "E":60,
    },
    9:{
      "A":200,
      "E":60,
    },
    10:{
      "A":170,
      "E":60,
    },
    11:{
      "A":140,
      "E":60,
    },
    12:{
      "A":110,
      "E":60,
    },
  };

  Future<int> calculate(File image_files,DateTime time,Function callback)async{
    List<Image_set> images=[];
    callback("reading camera hardware data");
    CameraModel cameraModel = await get_camera_hardware();
    callback("reading the images");
    for(int i=0;i<12;i++){
      images.add(Image_set(Imagepath: image_files.path,azimuth: angles[i]["A"],elevation: angles[i]["E"]));
    }
    callback("processing images it may take some time");
    print("Now we have each and every image with their azimuth and elevation angle");
    List<List<int>> result_matrix=await processimage(images, cameraModel.focal_length.toDouble(),callback);
   //get lat and long of user;
    callback("getting your location");
    Position user_location =await fetch_user_location();
    callback("geting the suposition");
    SunPos position = await SunPosition().calculate(SunPosEstimateData(time: time,lat:user_location.latitude.toString() ,long:user_location.longitude.toString() ));
    callback("completed");
    return result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()];
  }


  Future<List<List<int>>> processimage(List<Image_set> images, double focal_length,Function callback)async{
    int row = 910;
    int col = 3610;
    var matrix = List<List<int>>.generate(
        col, (i) => List<int>.generate(row, (j) => 1));

    callback("decoding and getting angles of images");//
    for(int k=0;k<12;k++){
      final image = await IMG.decodeImage(File(images[k].Imagepath).readAsBytesSync());
      for(int i=0;i<image.height;i++){
        for(int j=0;j<image.width;j++){
          int pixel= image.getPixel(j, i);
          var x = i - (image.width) / 2;
          var y = j - ((image.height) / 2);
          //verify it once again
          var A = await (images[k].azimuth +
              atan(x / (focal_length)) * 180 / pi);
          var E = await (images[k].elevation -
              atan(y / (focal_length)) * 180 / pi);
          if (E > 90) {
            E = 90.0;
          }
          if (E < 0) {
            E = 0.0;
          }
          if (A < 90) {
            A = 90.0;
          }
          if (A > 270) {
            A = 270.0;
          }
          int Azi = (A * 10).toInt();
          int Elev = (E * 10).toInt();
          int result=0;
          ///change to perfect binary
          if (Color(pixel).blue > 150) {
              result = 0;
          } else if (Color(pixel).blue >= Color(pixel).red &&
              Color(pixel).blue >= Color(pixel).green &&
              Color(pixel).blue >= 115) {
            result = 0;
          }
          else if (Color(pixel).blue >= Color(pixel).red &&
              Color(pixel).blue >= Color(pixel).green &&
              Color(pixel).blue >= 75 && i * j < (image.width * image.height) / 2
          ) {
            result = 0;
          }
          else {
            result = 1;
          }
          matrix[Azi][Elev] = result;
        }
      }
      if(k==6){
         callback("50% images converted");
      }
    }
    // List<List<int>> pixel_matrix=[];
    // print(image.height);
    // print("Image is successfully converted to matrix");
    // final directory = await getExternalStorageDirectories(type: StorageDirectory.documents);
    // File file= File(directory[0].path+"result.txt");
    //   await file.writeAsString(matrix.toString());
    // print("File writed successfully");
    return matrix;
  }
  // Future<File> getImageFileFromAssets(String path) async {
  //   print("Getting file from assets");
  //   final byteData = await rootBundle.load('$path');
  //   print("Read from assets done");
  //  List<String> end = path.split("/");
  //   final file = File('${(await getApplicationDocumentsDirectory()).path}/${end[end.length-1]}');
  //   print("writing to file");
  //   await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  //   return file;
  // }
}