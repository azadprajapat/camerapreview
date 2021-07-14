class SunPos{
  double azimuth;
  double elevation;
  SunPos({this.azimuth,this.elevation});
}
class SunPosEstimateData{
  DateTime time;
  String lat;
  String long;
  SunPosEstimateData({this.time,this.lat,this.long});
}