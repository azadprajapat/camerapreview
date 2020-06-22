
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyPainter extends CustomPainter{
  final pitch;
  final screen;
  final roll;
  final ImgList;
  final azimuth;
  final n;
  final list;
  final visible_list;

  MyPainter({this.pitch,this.screen,this.azimuth,this.roll,this.ImgList,this.n,this.list,this.visible_list});
  @override


   void paint(Canvas canvas, Size size) {
    Paint paint=new Paint()
        ..color=Colors.blueGrey
        ..strokeWidth=1;
    Paint circle= new Paint()
    ..color=Colors.green
    ..style=PaintingStyle.fill;
    Paint Center_circle= new Paint()
      ..color=Colors.white
      ..strokeWidth=2
      ..style=PaintingStyle.stroke;
    Paint Captured= new Paint()
    ..color=Colors.red
    ..style=PaintingStyle.fill;
    var x_center=screen.width/2;
    var y_center=screen.height/2;
    var c_width=250;
    var c_heigth=400;

//To draw mini directional triangle
    var path1= Path();
    path1.moveTo(x_center, y_center-65);
    path1.lineTo(x_center-15, y_center-50);
    path1.lineTo(x_center+15, y_center-50);
    path1.close();
    var path2= Path();
    path2.moveTo(x_center, y_center+65);
    path2.lineTo(x_center-15, y_center+50);
    path2.lineTo(x_center+15, y_center+50);
    path2.close();
    var path3= Path();
    path3.moveTo(x_center-65, y_center);
    path3.lineTo(x_center-50, y_center-15);
    path3.lineTo(x_center-50, y_center+15);
    path3.close();
    var path4= Path();
    path4.moveTo(x_center+65, y_center);
    path4.lineTo(x_center+50, y_center-15);
    path4.lineTo(x_center+50, y_center+15);
    path4.close();


    //drawing boundary over image
    canvas.drawRect(Rect.fromPoints(Offset(0,0), Offset(screen.width,(screen.height-c_heigth)/2)), paint);
    canvas.drawRect(Rect.fromPoints(Offset(0,(screen.height+c_heigth)/2), Offset(screen.width,screen.height)), paint);
    canvas.drawRect(Rect.fromPoints(Offset(0,(screen.height-c_heigth)/2), Offset((screen.width-c_width)/2,(screen.height+c_heigth)/2)), paint);
    canvas.drawRect(Rect.fromPoints(Offset((screen.width+c_width)/2,(screen.height-c_heigth)/2), Offset(screen.width,(screen.height+c_heigth)/2)), paint);


    //working with image display on the screen
    if(n!=0){
//         for(int i=0;i<n;i++) {
//          var e1=ImgList[i].azimuth-18.5;
//          var e2=ImgList[i].azimuth+18.5;
//            var cx1 = ((e1- azimuth) * screen.width / 66.19) +
//                screen.width / 2;
//            var cy1 = ((pitch - ImgList[i].elevation+11.5) * screen.height / 52.09) +
//                screen.height / 2;
//            var cx2 = ((e2 - azimuth) * screen.width / 66.19) +
//                screen.width / 2;
//            var cy2 = ((pitch - ImgList[i].elevation-11.5) * screen.height / 52.09) +
//                screen.height / 2;
//            canvas.drawRect(Rect.fromPoints(
//                Offset(cx1, cy1), Offset(cx2, cy2)),
//                Captured);
//       }
     }
    visible_list.forEach((element){
      var start_P1_x;
      var start_P1_y;
      var x;
      var y;
      start_P1_x = ((int.parse(element.A)-azimuth)*screen.width/66.19);
      start_P1_y = ((pitch-int.parse(element.E))*screen.height/52.09);
      x =  ((start_P1_x*cos(roll)-start_P1_y*sin(-roll))+screen.width/2);
      y =  ((start_P1_x*sin(-roll)+start_P1_y*cos(roll))+screen.height/2);
      canvas.drawCircle(Offset(x,y), 20.0, circle);
      if(n==0){
        if(y_center-y >10){
          canvas.drawPath(path1, Center_circle);
        }
        else if(y_center-y<10&&y_center-y>-10){
        }else{
          canvas.drawPath(path2, Center_circle);
        }
        if(x_center-x >10){
          canvas.drawPath(path3, Center_circle);
        }
        else if(x_center-x<10&&x_center-x>-10){
        }else{
          canvas.drawPath(path4, Center_circle);
        }
      }
    });
     canvas.drawRect(Rect.fromPoints(Offset((screen.width-c_width)/2,(screen.height-c_heigth)/2), Offset((screen.width+c_width)/2,(screen.height+c_heigth)/2)), Center_circle);
    canvas.drawCircle(Offset(x_center,y_center), 30, Center_circle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}






