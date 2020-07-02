import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'camerapreview.dart';

class ResultPage extends StatefulWidget {
  final List<Image_set> imglist;

  ResultPage(this.imglist); 
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('result'),),
      body: Container(child: Image.file(File(widget.imglist[0].Imagepath)),),
    );
  }
}
