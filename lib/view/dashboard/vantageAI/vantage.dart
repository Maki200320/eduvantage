import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tech_media/res/fonts.dart';
import 'package:tech_media/view/dashboard/vantageAI/Task%20Completion.dart';
import 'package:tech_media/view/dashboard/vantageAI/UsageHours.dart';

void main() {
  runApp(MaterialApp(
    home: Vantage(),
  ));
}

class Vantage extends StatefulWidget {
  @override
  _VantageState createState() => _VantageState();
}

class _VantageState extends State<Vantage> {
  String selectedTimeRange = 'Weekly'; // Default selected time range
  String subheading = 'Weekly'; // Default subheading

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 5.0),
            child: IconButton(
              icon: Icon(Icons.insert_chart_rounded),
              iconSize: 30,
              color: Colors.blueAccent,
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: TaskCompletion(),
                  withNavBar: false,
                );
              },
            ),
          ),
          // Add more buttons as needed
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Overall Performance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            IconButton(
              icon: Icon(Icons.access_time_filled_rounded),
              iconSize: 30,
              color: Colors.pinkAccent, // Replace with your desired icon
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AppUsageScreen(),
                  withNavBar: false,
                );
              },
            )
          ],
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
            SizedBox(height: 100),
            Container(
              height: 300,
              margin: EdgeInsets.all(16),
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 0),
                ),
                tooltipBehavior: TooltipBehavior(enable: true), // Enable tooltip
                zoomPanBehavior: ZoomPanBehavior(
                  enableDoubleTapZooming: true,
                  enablePinching: true,
                  enablePanning: true,
                ), // Enable zooming and panning
                series: <CartesianSeries>[ // Use CartesianSeries instead of ChartSeries
                  ColumnSeries<ChartData, String>( // Use ColumnSeries for vertical bar graph
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    color: Colors.green,
                    dataSource: getData(selectedTimeRange),
                    xValueMapper: (ChartData data, _) => data.day,
                    yValueMapper: (ChartData data, _) => data.value1,
                  ),
                ],
                // Remove isTransposed property, as ColumnSeries already creates a vertical bar graph
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RoundedButton(
                  label: 'Weekly',
                  isActive: selectedTimeRange == 'Weekly',
                  onPressed: () {
                    updateChart('Weekly');
                  },
                ),
                RoundedButton(
                  label: 'Monthly',
                  isActive: selectedTimeRange == 'Monthly',
                  onPressed: () {
                    updateChart('Monthly');
                  },
                ),
                RoundedButton(
                  label: 'Semestral',
                  isActive: selectedTimeRange == 'Semestral',
                  onPressed: () {
                updateChart('Semestral');
                },
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
      // Update subheading based on the selected time range
      switch (timeRange) {
        case 'Weekly':
          subheading = 'Weekly';
          break;
        case 'Monthly':
          subheading = 'Monthly';
          break;
        case 'Semestral':
          subheading = 'Semestral';
          break;
      }
    });
  }

  List<ChartData> getData(String timeRange) {
    switch (timeRange) {
      case 'Weekly':
        return [
          ChartData('Week 1', 5),
          ChartData('Week 2', 16),
          ChartData('Week 3', 18),
          ChartData('Week 4', 20),
          ChartData('Week 5', 17),
        ];
      case 'Monthly':
      // Implement logic to get monthly data
        return [
          ChartData('M1', 15),
          ChartData('M2', 26),
          ChartData('M3', 28),
          ChartData('M4', 30),
          ChartData('M5', 27),
        ];
      case 'Semestral':
      // Implement logic to get semestral data
        return [
          ChartData('Semester 1', 35),
          ChartData('Semester 2', 46),
        ];
      default:
        return [];
    }
  }
}

class ChartData {
  final String day;
  final num value1;

  ChartData(this.day, this.value1);
}

class RoundedButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onPressed;

  RoundedButton({required this.label, this.isActive = false, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: isActive ? Colors.green : Colors.black87,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isActive ? Colors.green : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.alatsiRegular,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}
