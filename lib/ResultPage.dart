import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
    final path =
    join((await getExternalStorageDirectory()).path,DateTime.now().toString()+'result.pdf');
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    Share.shareFiles([file.path]);
    // final file = File('${(await getApplicationDocumentsDirectory()).path}/sunscape_result.pdf');
    // await file.writeAsBytes();
  }
  //DateTime now = DateTime.now();
  //we will use this in future to convert datetime to string
  //String t1 =DateFormat('kk:mm').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(

        body: SafeArea(
            child: Stack(
              children: [
                Column(children: [
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
                    child: Text("Day result from 9 am to 6pm  : ${widget.data["result"]}%"),
                  )

                ]),
                Align(
                  alignment: Alignment(0.95,0.95),
                  child: FloatingActionButton(
                    child: Icon(Icons.share),
                    onPressed: (){
                      print("hello world");
                      write_data();
                    },
                  ),
                )
              ],
            )
        )), onWillPop: (){
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
