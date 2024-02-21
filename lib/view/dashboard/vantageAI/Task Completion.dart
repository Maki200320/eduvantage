import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../login/login_screen.dart';

class TaskCompletion extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Vantage Statistics',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            // fontFamily: AppFonts.alatsiRegular, // Use the desired font
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, // Change the color of the back button
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                'Task Completion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            SizedBox(height: 130),
            TaskCompletionWidget(),

          ],
        ),
      ),
    );
  }
}

class TaskCompletionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 350,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0,
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom, // Set the legend position to bottom
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        trackballBehavior: TrackballBehavior(
          enable: true,
          shouldAlwaysShow: true,
          lineType: TrackballLineType.vertical,
        ),
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0),
          minimum: 0,
          maximum: 20,
          interval: 5,
        ),
        series: <CartesianSeries>[ // Use CartesianSeries instead of ChartSeries
          StackedColumnSeries<ChartData, String>( // Use StackedColumnSeries for stacked bar chart
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(color: Colors.white70),
            ),
            dataSource: getData(),
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.value1,
            name: 'Pending',
            color: Colors.blue,
          ),
          StackedColumnSeries<ChartData, String>(
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(color: Colors.white70),
            ),
            dataSource: getData(),
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.value2,
            name: 'Completed',
            color: Colors.green,
          ),
          StackedColumnSeries<ChartData, String>(
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.outer,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(color: Colors.white70),
            ),
            dataSource: getData(),
            xValueMapper: (ChartData data, _) => data.category,
            yValueMapper: (ChartData data, _) => data.value3,
            name: 'Overdue',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  List<ChartData> getData() {
    return [
      ChartData('Subject 1', 5, 3, 2),
      ChartData('Subject 2', 3, 2, 2),
      ChartData('Subject 3', 2, 4, 2),
      ChartData('Subject 4', 7, 5, 3),
      ChartData('Subject 5', 6, 9, 4),
    ];
  }
}

class ChartData {
  final String category;
  final num value1;
  final num value2;
  final num value3;

  ChartData(this.category, this.value1, this.value2, this.value3);
}
