
import 'package:geolocator/geolocator.dart';

Future<Position> fetch_user_location()async {
  var loc = await  Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  return loc;
}