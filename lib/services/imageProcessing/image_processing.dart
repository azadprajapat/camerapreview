import 'package:cameraviewer/ResultPage.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/modals/sun_models.dart';
import 'package:cameraviewer/services/get_location.dart';
import 'package:cameraviewer/services/imageProcessing/sun_position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as IMG;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<Map> calculate(List<Asset> image_assets,Function callback)async{
    List<Image_set> images=[];
    callback("reading camera hardware data");
    image_assets.sort((Asset a ,Asset b){
      return a.name.compareTo(b.name);
    });
   // List<Asset> new_test_list =[];
   //  image_assets.forEach((element) {
   //    new_test_list.add(image_assets[0]);
   //  });
    image_assets.add(image_assets[0]);
    image_assets.add(image_assets[1]);
    image_assets.add(image_assets[2]);
    image_assets.removeRange(0,3);

     CameraModel cameraModel = await get_camera_hardware();
    await callback("processing images it may take some time");
    print("Image used");
    for(int i=0;i<image_assets.length;i++){
      print(image_assets[i].name);
    }
    for(int i=1;i<13;i++){
      File image_file =await getImageFileFromAssets(await image_assets[i-1].getByteData(), i);
     await images.add(Image_set(azimuth: angles[i]["A"],elevation: angles[i]["E"],Imagepath: image_file.path),);
    }
    print("Now we have each and every image with their azimuth and elevation angle");
   List<List<int>> result_matrix=await processimage(images, cameraModel,callback);
   await callback("Image processed calculating full day data...");
    //now get the whole data of the day
    return full_day_result(result_matrix);
  //return [];
  }
   //get chart data from the resultant matrix
   Future<Map> full_day_result(List<List<int>> result_matrix)async{

    List<ChartData> data_list=[];
    //get lat and long of user;
     DateTime today_morning = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,9);
    DateTime today_evening = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,17);
       Position user_location =await fetch_user_location();
    while(today_morning.isBefore(today_evening)){
      String tme ="${today_morning.hour}:${today_morning.minute}";
      if(today_morning.minute==0){
        print(tme);
      }
       ChartData current_time_data;
       SunPos position = await SunPosition().calculate(SunPosEstimateData(time: today_morning,lat:user_location.latitude.toString() ,long:user_location.longitude.toString() ));
       if(position.azimuth<0||position.azimuth>270||position.elevation<0||position.elevation>90){
         current_time_data=ChartData(result: 0,time: tme);
         // print("result added 0 for ${tme}");
         data_list.add(current_time_data);
       }
       else{
         current_time_data=ChartData(result: result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()],time: tme);
         // print("result added original ${result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()]} for ${tme}");
         data_list.add(current_time_data);
       }
      today_morning = today_morning.add(Duration(minutes: 5));
    }
    int count=0;
    for(int i=0;i<data_list.length;i++){
      if(data_list[i].result==1)
        count++;
    }
    double res = count*100.0/data_list.length;
     //  return 0;
   //  return result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()];
     return {"result":res,"data":data_list};
  }


  Future<List<List<int>>> processimage(List<Image_set> images, CameraModel cameraModel,Function callback)async{
    int row = 910;
    int col = 3610;
    double focal_length = cameraModel.focal_length;
    var matrix = List<List<int>>.generate(
        col, (i) => List<int>.generate(row, (j) => 0));
    await callback("decoding and getting angles of images");//
    for(int k=0;k<12;k++){
       final image = await IMG.decodeImage(File(images[k].Imagepath).readAsBytesSync());
       double h_f = cameraModel.sensorw/image.height;
       double w_f = cameraModel.sensorh/image.width;
       print((images[k].azimuth +
           atan(image.width*w_f/ (focal_length*2)) * 180 / pi));
      for(int i=0;i<image.height;i++){
        for(int j=0;j<image.width;j++){
          int pixel= image.getPixel(j, i);
          var x = j - (image.width) / 2;
          var y = i - ((image.height) / 2);
          //verify it once again

          var A = await (images[k].azimuth +
              atan(x *w_f/ (focal_length)) * 180 / pi);
          var E = await (images[k].elevation -
              atan(y *h_f/ (focal_length)) * 180 / pi);

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
          if(Color(pixel).red>240&&Color(pixel).green>=240&&Color(pixel).blue>240){
            result= 1;
          }else{
            result=0;
          }

          matrix[Azi][Elev] = result;
        }
      }
      if(k==6){
        await  callback("50% images converted");
      }
     }

    return matrix;
  }
  Future<File> getImageFileFromAssets(ByteData byteData,int index) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/image_${index}.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
}
class TestImageCollection{
  Asset asset;
  final azimuth;
  final elevation;
  TestImageCollection({this.elevation, this.azimuth, this.asset});

}