
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
  final A;
  final n;
  final E;

  MyPainter({this.pitch,this.screen,this.A,this.E,this.azimuth,this.roll,this.ImgList,this.n});
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

    var c_width=200;
    var c_heigth=300;

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

    var start_P1_x = ((A-azimuth)*screen.width/66.19);
    var start_P1_y = ((pitch-E)*screen.height/52.09);

    var   x =  ((start_P1_x*cos(roll)-start_P1_y*sin(-roll))+screen.width/2);
    var  y =  ((start_P1_x*sin(-roll)+start_P1_y*cos(roll))+screen.height/2);

    //drawing boundary over image
    canvas.drawRect(Rect.fromPoints(Offset(0,0), Offset(screen.width,(screen.height-c_heigth)/2)), paint);
    canvas.drawRect(Rect.fromPoints(Offset(0,(screen.height+c_heigth)/2), Offset(screen.width,screen.height)), paint);
    canvas.drawRect(Rect.fromPoints(Offset(0,(screen.height-c_heigth)/2), Offset((screen.width-c_width)/2,(screen.height+c_heigth)/2)), paint);
    canvas.drawRect(Rect.fromPoints(Offset((screen.width+c_width)/2,(screen.height-c_heigth)/2), Offset(screen.width,(screen.height+c_heigth)/2)), paint);


    //working with image display on the screen
    if(n!=0){
      if(ImgList!=null){
        for(int i=0;i<n;i++) {
          var A1=ImgList[i].azimuth-18.5;
         var A2=ImgList[i].azimuth+18.5;
          var cx1 = ((A1- azimuth) * screen.width / 66.19) +
              screen.width / 2;
          var cy1 = ((pitch - ImgList[i].elevation+11.5) * screen.height / 52.09) +
              screen.height / 2;
          var cx2 = ((A2 - azimuth) * screen.width / 66.19) +
              screen.width / 2;
          var cy2 = ((pitch - ImgList[i].elevation-11.5) * screen.height / 52.09) +
              screen.height / 2;
            canvas.drawRect(Rect.fromPoints(
              Offset(cx1, cy1), Offset(cx2, cy2)),
              Captured);
        }
      }
     }




    if(y_center-y >10){
      canvas.drawPath(path1, Center_circle);

    }
    else if(y_center-y<10&&y_center-y>-10){
    }else{
      canvas.drawPath(path2, Center_circle);
    }

    if(x_center-x>10){
      canvas.drawPath(path3, Center_circle);
    }else if(x_center-x<10&&x_center-x>-10){
    }
    else{
      canvas.drawPath(path4, Center_circle);
    }

    canvas.drawRect(Rect.fromPoints(Offset((screen.width-c_width)/2,(screen.height-c_heigth)/2), Offset((screen.width+c_width)/2,(screen.height+c_heigth)/2)), Center_circle);
    canvas.drawCircle(Offset(x_center,y_center), 30, Center_circle);
    canvas.drawCircle(Offset(x,y), 20.0, circle);




  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}






