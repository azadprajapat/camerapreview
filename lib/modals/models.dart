class MobileSensor {
  var pitch;
  var azimuth;
  var roll;
  MobileSensor({this.pitch,this.azimuth,this.roll});
}
class Image_set {
  String name;
  String binary_path;
  final String captured_path;
  final double azimuth;
  final double elevation;
  bool isbinary;
  Image_set({this.elevation, this.azimuth, this.captured_path,this.name,this.binary_path,this.isbinary});
}

class Points {
  final double A;
  final double E;
  Points({this.A, this.E});
}
