import 'dart:io';

import 'package:cameraviewer/ResultPage.dart';
import 'package:cameraviewer/services/imageProcessing/image_processing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
class ParentBuilder extends StatefulWidget {
  const ParentBuilder({Key key}) : super(key: key);

  @override
  _ParentBuilderState createState() => _ParentBuilderState();
}

class _ParentBuilderState extends State<ParentBuilder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TestImages(),
    );
  }
}


class TestImages extends StatefulWidget {
  const TestImages({Key key}) : super(key: key);

  @override
  _TestImagesState createState() => _TestImagesState();
}

class _TestImagesState extends State<TestImages> {
  @override
  List<Asset> images = <Asset>[];
  DateTime picked_time;
  String status=null;
  TextEditingController _controller = TextEditingController();

  void initState() {
    super.initState();
  }

  Future<void> pickImages() async {
    List<Asset> resultList = <Asset>[];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 12,
        enableCamera: false,
        selectedAssets: images,
        materialOptions: MaterialOptions(
          actionBarTitle: "Pick 12 Image",
        ),
      );
    } on Exception catch (e) {
      print(e);
    }
    setState(() {
      images = resultList;
    });
    images.forEach((element) {
      print("${element.name} ${element.identifier}");
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            RaisedButton(
                child: Text('pick binary images'),
                onPressed: pickImages),
            // RaisedButton(
            //     onPressed: () async {
            //       DatePicker.showDateTimePicker(context,
            //           showTitleActions: true,
            //           minTime: DateTime(2019, 5, 5, 20, 50),
            //           maxTime: DateTime(2022, 6, 7, 05, 09), onChanged: (date) {
            //         print('change $date in time zone ' +
            //             date.timeZoneOffset.inHours.toString());
            //       }, onConfirm: (date) {
            //         setState(() {
            //           picked_time = date;
            //         });
            //         print('confirm $date');
            //       }, locale: LocaleType.en);
            //     },
            //     child: Text(
            //       'Pick Date And Time',
            //     )),
            RaisedButton(
                child: Text('Process Images'),
                onPressed: images.length!=12?null:() async{
               var data=  await   ImageProcessing().calculate(images,
                      (String res) async{
                    setState(() {
                      status=res;
                    });
                  });
               print("done 100 %");
              await Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(data)));
                }),
                SizedBox(height: 20,),
                Text(status!=null?status:"")
          ])),
        ),
      ),
    );
  }
}
