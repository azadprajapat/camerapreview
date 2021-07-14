import 'package:cameraviewer/modals/camera_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
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

  Future<void> calculate()async{
    List<Image_set> images=[];
    CameraModel cameraModel = await get_camera_hardware();
    for(int i=1;i<13;i++){
      File img = await getImageFileFromAssets("assets/test/img${13-i}_raw.jpg");
      images.add(Image_set(Imagepath: img.path,azimuth: angles[i]["A"],elevation: angles[i]["E"]));
    }

    print("Now we have each and every image with their azimuth and elevation angle");
   await processimage(images, cameraModel.focal_length.toDouble());
  }



  Future<List<List<int>>> processimage(List<Image_set> images, double focal_length)async{
    int row = 910;
    int col = 3610;
    var matrix = List<List<int>>.generate(
        col, (i) => List<int>.generate(row, (j) => 1));

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
    }
    // List<List<int>> pixel_matrix=[];
    // print(image.height);
    print("Image is successfully converted to matrix");
    final directory = await getExternalStorageDirectories(type: StorageDirectory.documents);
    File file= File(directory[0].path+"result.txt");
      await file.writeAsString(matrix.toString());
    print("File writed successfully");
    return matrix;
  }
  Future<File> getImageFileFromAssets(String path) async {
    print("Getting file from assets");
    final byteData = await rootBundle.load('$path');
    print("Read from assets done");
   List<String> end = path.split("/");
    final file = File('${(await getApplicationDocumentsDirectory()).path}/${end[end.length-1]}');
    print("writing to file");
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
}