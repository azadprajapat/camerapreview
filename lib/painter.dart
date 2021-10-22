import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cameraviewer/modals/models.dart';
import 'package:cameraviewer/modals/camera_model.dart';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressPainer extends CustomPainter {
  final prgress;
  ProgressPainer(this.prgress);
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    Paint pt= new Paint()
      ..color=Colors.green
      ..style=PaintingStyle.stroke
      ..strokeWidth=10;
    canvas.drawArc(Rect.fromCircle(center:Offset(size.width/2,size.height/2),radius: 35), -pi/2, pi*prgress*2, false, pt);
    // canvas.drawCircle(Offset(size.width/2,size.height/2), 32, pt);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MyPainter extends CustomPainter{
  final screen;
  final ImgList;
  final CameraModel model;
  final n;
  final MobileSensor sensor;
  final list;
  final capture_point;
  final List<ui.Image> img;

  MyPainter({this.model,this.sensor,this.screen,this.ImgList,this.n,this.list,this.capture_point,this.img});
  @override


   void paint(Canvas canvas, Size size) {
    if(capture_point==null)
        return;
    Paint paint=new Paint()
        ..color=Color.fromRGBO(97, 97, 97, 1)
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
    var c_width=size.width/1.8;
    var c_heigth=size.height/2.2;

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


    //working with image display on the screen
    if(n!=0){
         for(int i=0;i<n;i++) {
          var A=ImgList[i].azimuth;
          var E= ImgList[i].elevation;
          double h_f = model.sensorw/img[i].height;
          double w_f = model.sensorh/img[i].width;
         // var cx1 = atan((A-azimuth)*pi/180)*model.focal_length/w_f;
         // var cy1=  atan((E-pitch)*pi/180)*model.focal_length/h_f;

          var cx1 = 2*tan((A-sensor.azimuth)*pi/360)*model.focal_length/w_f+screen.width/2;
          var cy1 =  2*tan((sensor.pitch-E)*pi/360)*model.focal_length/h_f+screen.height/2;
          if(sensor.azimuth-A>120||sensor.azimuth-A<-120)
            continue;
          var l_t_a = A-model.hfv/2;
          var l_t_e = E+ model.vfv/2;
          var r_b_a = A+model.hfv/2;
          var r_b_e = E- model.vfv/2;
          var l_t_x = 2*tan((l_t_a-sensor.azimuth)*pi/360)*model.focal_length/w_f+screen.width/2;
          var l_t_y =  2*tan((sensor.pitch-l_t_e)*pi/360)*model.focal_length/h_f+screen.height/2;
          var r_b_x = 2*tan((r_b_a-sensor.azimuth)*pi/360)*model.focal_length/w_f+screen.width/2;
          var r_b_y =  2*tan((sensor.pitch-r_b_e)*pi/360)*model.focal_length/h_f+screen.height/2;
         canvas.drawImageNine(img[i], Rect.fromPoints(Offset(cx1,cy1), Offset(cx1,cy1)), Rect.fromPoints(Offset(l_t_x,l_t_y), Offset(r_b_x,r_b_y)), Captured);

         //  canvas.drawImageNine(img[i], Rect.fromPoints(Offset(cx1,cy1), Offset(cx1,cy1)), Rect.fromPoints(Offset(cx1-img[i].width/2,cy1-img[i].height/2), Offset(cx1+img[i].width/2,cy1+img[i].height/2)), Captured);
           //   canvas.drawImageNine(img[i], Rect.fromPoints(Offset(cx1,cy1), Offset(cx1,cy1)), Rect.fromPoints(Offset(l_t_x,l_t_y), Offset(r_b_x,r_b_y)), Captured);

         }
     }
    Points  element = capture_point;
      var start_P1_x;
      var start_P1_y;
      var x;
      var y;
     double h_f = model.sensorw/screen.height;
     double w_f = model.sensorh/screen.width;
    start_P1_x = 2*tan(( element.A -sensor.azimuth)*pi/360)*model.focal_length/w_f;
    start_P1_y=  2*tan((sensor.pitch- element.E )*pi/360)*model.focal_length/h_f;
      x =  ((start_P1_x*cos(sensor.roll)-start_P1_y*sin(-sensor.roll))+screen.width/2);
      y =  ((start_P1_x*sin(-sensor.roll)+start_P1_y*cos(sensor.roll))+screen.height/2);
          if(sensor.roll==0&&n<12){
            canvas.drawCircle(Offset(x, y), 25, circle);
          }
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

     canvas.drawRect(Rect.fromPoints(Offset(0,0), Offset(screen.width,screen.height)), Center_circle);
    canvas.drawCircle(Offset(x_center,y_center), 30, Center_circle);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}
Future<ui.Image> loadUiImage(String path) async {
  final data2= await File(path).readAsBytes();

  final Completer<ui.Image> completer = Completer();
  ui.decodeImageFromList(data2, (ui.Image img) {
    return completer.complete(img);
  });
  return completer.future;
}






