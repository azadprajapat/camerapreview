import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class TestImages extends StatefulWidget {
  const TestImages({Key key}) : super(key: key);

  @override
  _TestImagesState createState() => _TestImagesState();
}

class _TestImagesState extends State<TestImages> {
  @override
  List<Asset> images = <Asset>[];
  void initState(){
    super.initState();
  }
  Future <void> pickImages() async{
    List<Asset> resultList=<Asset>[];
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

  }
  Widget build(BuildContext context) {
    return Container(
      child:Center(
          child:Column(
              children: <Widget>[
                RaisedButton(
                    child: Text('Pick Your 12 binary Image'),
                    onPressed: pickImages) ,
                RaisedButton(
                    onPressed: () async{
                      await DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          minTime: DateTime(2021,1,1),
                          maxTime: DateTime(2030,12,30), onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                          }, currentTime: DateTime.now(), locale: LocaleType.en);
                      await showTimePicker(context: context,
                        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      );
                    },
                    child: Text(
                      'Date and Time Picker',
                      style: TextStyle(color: Colors.blue),
                    )),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25.0),
                    color: Theme.of(context).accentColor

                  ),
                  child: InkWell(
                    child:Center(
                        child:Text(
                      'Procced'
                    )
                  ),
                    onTap: (){},
                )
                )
                ,
              ]
          )
      ),
    );
  }
}
