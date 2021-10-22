import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
const List EVENTS = [
  'connect',
  'connect_error',
  'connect_timeout',
  'connecting',
  'disconnect',
  'error',
  'reconnect',
  'reconnect_attempt',
  'reconnect_failed',
  'reconnect_error',
  'reconnecting',
  'ping',
  'pong'
];
class ImageSocket{
  int try_count=0;
  StreamController streamSocket =StreamController();

  final SOCKET_SERVER = 'http://172.26.126.103:5000';
  IO.Socket socket;
  void initiate()async{
    socket = IO.io(SOCKET_SERVER,IO.OptionBuilder().setTransports(['websocket']).build());
    print("initiating connection");
    socket.onConnectError((data) => print(data));
    socket.onConnectError((data) => print(data));
    socket.onConnecting((data) => print("Trying to connect"));
    socket.onConnect((_) {
      print("socket connected");
    });
    socket.on("send-image", (data)async{
      print("Received image from server");
      Uint8List binary = data['binary'];
      String name = data['name'];
      final path =
          join((await getExternalStorageDirectory()).path,DateTime.now().toString()+'_img.jpg');
      File(path).writeAsBytes(
          binary.buffer.asUint8List(binary.offsetInBytes, binary.lengthInBytes));
      streamSocket.sink.add({"name":name,"image":path});
    });
  }
  bool isrunning() => socket.connected;
  void send_image(File file,name){
    while(!isrunning()&&try_count<10){
      initiate();
      try_count++;
    }
    socket.emit('image-upload',{
      "name": name,
      "binary": file.readAsBytesSync()
    });
    print("image sended");
   }
   void disconnect(){
    socket.disconnect();
   }

}