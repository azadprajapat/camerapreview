import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

class ResultPage extends StatefulWidget {
  final Map data;
  ResultPage(this.data);
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    write_data();
  }
  void write_data()async{
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.GridView(
            crossAxisCount: 2,
            children: List.generate(widget.data["data"].length, (index) => pw.Text("${widget.data["data"][index].time}->${widget.data["data"][index].result}"))
          )
        ),
      ),
    );

    // final file = File('${(await getApplicationDocumentsDirectory()).path}/sunscape_result.pdf');
    // await file.writeAsBytes();
    await  Share.file("Sunscape Result", "result.pdf", await pdf.save(), "application/pdf");
  }
  //DateTime now = DateTime.now();
  //we will use this in future to convert datetime to string
  //String t1 =DateFormat('kk:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(

        body: Column(children: [
          //Initialize the chart widget
          Container(
            width: MediaQuery.of(context).size.width,
            child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                // Chart title
                // Enable legend
                legend: Legend(isVisible: false),
                // Enable tooltip
                tooltipBehavior: TooltipBehavior(enable: false),
                series: <ChartSeries<ChartData, String>>[
                  LineSeries<ChartData, String>(
                      dataSource: widget.data["data"],
                      xValueMapper: (ChartData data, _) => data.time,
                      yValueMapper: (ChartData data, _) => data.result,
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: false)),
                ]),
          ),
          Center(
            child: Text("Net Result interval(5 min) : ${widget.data["result"]}"),
          )

        ])), onWillPop: (){
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      return Future.value(true);
    });
  }
}
class ChartData{
  final String time;
  final int result;
  ChartData({this.result, this.time});
}
