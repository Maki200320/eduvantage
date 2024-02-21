import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tech_media/res/fonts.dart';

void main() {
  runApp(MaterialApp(
    home: AdminVantage(),
  ));
}

class AdminVantage extends StatefulWidget {
  @override
  _AdminVantageState createState() => _AdminVantageState();
}

class _AdminVantageState extends State<AdminVantage> {
  String selectedTimeRange = 'Active'; // Default selected time range
  String subheading = 'Active Users'; // Default subheading
  late List<ChartData> chartData = []; // Initialize chartData as empty list
  String selectedCategory = ''; // Store selected category

  @override
  void initState() {
    super.initState();
    // Initialize data for the pie chart
    chartData = getChartData('Active');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFe5f3fd),
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'User Engagement',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFe5f3fd),
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.black, // Change the color of the back button
        ),
        actions: [],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                subheading,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Container(
                    height: 300,
                    child: SfCircularChart(
                      series: <CircularSeries>[
                        PieSeries<ChartData, String>(
                          dataSource: chartData,
                          xValueMapper: (ChartData data, _) => data.category,
                          yValueMapper: (ChartData data, _) => data.value,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(color: Colors.black),
                          ),
                          pointColorMapper: (ChartData data, _) {
                            switch (data.category) {
                              case 'Active':
                                return Colors.blueAccent;
                              case 'Moderate':
                                return Colors.deepOrange;
                              case 'Inactive':
                                return Colors.black;
                              default:
                                return Colors.black;
                            }
                          },
                          selectionBehavior: SelectionBehavior(
                            enable: true,
                            selectedBorderColor: Colors.black,
                            selectedColor: Colors.grey.withOpacity(0.1),
                          ),
                          // Event to handle selection change
                        ),
                      ],
                      legend: Legend(isVisible: true), // Add legend here
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display details of selected pie
            selectedCategory.isNotEmpty
                ? Text(
              'Selected Category: $selectedCategory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
                : Container(),
            SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    updateChart('Weekly');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedTimeRange == 'Weekly' ? Colors.green : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: selectedTimeRange == 'Weekly' ? Colors.green : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'Weekly',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateChart('Monthly');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedTimeRange == 'Monthly' ? Colors.green : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: selectedTimeRange == 'Monthly' ? Colors.green : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateChart('Semestral');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedTimeRange == 'Semestral' ? Colors.green : Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: selectedTimeRange == 'Semestral' ? Colors.green : Colors.transparent,
                        width: 2.0,
                      ),
                    ),
                  ),
                  child: Text(
                    'Semestral',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.white,
                      fontFamily: AppFonts.alatsiRegular,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateChart(String timeRange) {
    setState(() {
      selectedTimeRange = timeRange;
      switch (timeRange) {
        case 'Weekly':
          subheading = 'Weekly Users';
          chartData = getChartData('Weekly');
          break;
        case 'Monthly':
          subheading = 'Monthly Users';
          chartData = getChartData('Monthly');
          break;
        case 'Semestral':
          subheading = 'Semestral Users';
          chartData = getChartData('Semestral');
          break;
      }
    });
  }

  List<ChartData> getChartData(String timeRange) {
    switch (timeRange) {
      case 'Weekly':
        return [
          ChartData('Active', 20),
          ChartData('Moderate', 10),
          ChartData('Inactive', 5),
        ];
      case 'Monthly':
        return [
          ChartData('Active', 50),
          ChartData('Moderate', 30),
          ChartData('Inactive', 20),
        ];
      case 'Semestral':
        return [
          ChartData('Active', 40),
          ChartData('Moderate', 40),
          ChartData('Inactive', 10),
        ];
      default:
        return [];
    }
  }
}

class ChartData {
  final String category;
  final num value;

  ChartData(this.category, this.value);
}
