import 'package:cameraviewer/ResultPage.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/modals/models.dart';
import 'package:cameraviewer/modals/sun_models.dart';
import 'package:cameraviewer/services/get_location.dart';
import 'package:cameraviewer/services/imageProcessing/sun_position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:image/image.dart' as IMG;
import '../platform_channels.dart';
class ImageProcessing{
  int interval = 6; //minute;

  DateTime sunrise = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,5); //5am
  DateTime sunset = new DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day,20); // 8pm

  int max_sunshine_hours = 15; // 5am to 8pm

  Future<Map> calculate(List<Image_set> image_collection,List<Points> angles,Function callback)async{
    callback("reading camera hardware data");
    image_collection.sort((a,b){
      int image_a= int.parse(a.name.substring(3));
      int image_b=int.parse(b.name.substring(3));
      return image_a.compareTo(image_b);
    });

    CameraModel cameraModel = await get_camera_hardware();
    await callback("processing images it may take some time");
    print("Now we have each and every image with their azimuth and elevation angle");
    List<List<int>> result_matrix=await processimage(image_collection, cameraModel,callback);
    await callback("Image processed calculating full day data...");
    return full_day_result(result_matrix);
  }
   Future<Map> full_day_result(List<List<int>> result_matrix)async{
    List<ChartData> data_list=[];
    double irradiance=0;
    //get lat and long of user;
    int sun_visible_counts=0;
     DateTime today_morning = sunrise;
     DateTime today_evening = sunset;
     Position user_location =await fetch_user_location();
     while(today_morning.isBefore(today_evening)){
       String tme ="${today_morning.hour}:${today_morning.minute}";
       ChartData current_time_data;
       SunPos position = await SunPosition().calculate(SunPosEstimateData(time: today_morning,lat:user_location.latitude.toString() ,long:user_location.longitude.toString() ));

       if(position.azimuth<0||position.azimuth>270||position.elevation<0||position.elevation>90){
         current_time_data=ChartData(result: 0,time: tme);

         data_list.add(current_time_data);
       }
       else{
         int visibility =result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()];
         if(visibility==1){
           sun_visible_counts++;
           int day_of_year = sunrise.day + (sunrise.month -1)*30;
           irradiance+= SolarInsolation().calculate(day_of_year, 90 - position.elevation, interval);
         }
         current_time_data=ChartData(result: visibility,time: tme);
         data_list.add(current_time_data);
       }
      today_morning = today_morning.add(Duration(minutes: interval));
    }
    double visibility_fraction = sun_visible_counts/data_list.length;
     double transmittance = 0.4560 +0.3566*(visibility_fraction) + 0.1874*pow(visibility_fraction,2);
     irradiance =(irradiance*transmittance)/(60*1000);  //w*s/sq.m -> kw*h/sq.m
      //  return 0;
   //  return result_matrix[(position.azimuth*10).toInt()][(position.elevation*10).toInt()];
     return {"percent":(visibility_fraction*100).toInt(),"data":data_list,"irradiance":irradiance};
  }


  Future<List<List<int>>> processimage(List<Image_set> images, CameraModel cameraModel,Function callback)async{
    int row = 910;
    int col = 3610;
    double focal_length = cameraModel.focal_length;
    var matrix = List<List<int>>.generate(
        col, (i) => List<int>.generate(row, (j) => 0));
    await callback("decoding and getting angles of images");//
    for(int k=0;k<images.length;k++){
       final image = await IMG.decodeImage(File(images[k].binary_path).readAsBytesSync());
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
      if(k==images.length/2){
        await  callback("50% images converted");
      }
     }

    return matrix;
  }

}
