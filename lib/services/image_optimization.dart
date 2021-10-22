import 'package:cameraviewer/modals/camera_model.dart';
import 'package:cameraviewer/modals/models.dart';

class OptimiseImage{
  List<Points> get_image_cordinates(CameraModel model){
    List<Points> list=[];
    double left_A= 60.0;
    double right_A= 300.0;
    double top_E= 90.0;
    double bottom_E=0.0;
    double hfv= model.hfv;
    double vfv= model.vfv;
    Points curr_point= Points(A: left_A+model.hfv/2,E:bottom_E+model.vfv/2);
    while(curr_point.A<right_A){
      list.add(curr_point);
      curr_point=Points(A: curr_point.A+hfv,E: curr_point.E);
    }
    curr_point=Points(A: list.last.A,E:list.last.E+vfv/2);
    while(curr_point.A>left_A){
      list.add(curr_point);
      curr_point=Points(A: curr_point.A-hfv,E: curr_point.E);
    }
    return list;
  }
}