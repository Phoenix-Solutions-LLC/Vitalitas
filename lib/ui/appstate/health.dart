import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';

class HealthAppState extends AppState {
  static Future<void> load() async {
    dynamic res = await Data.getUserField('HealthScores');
    if (res == null) {
      Data.setUserField('HealthScores', {});
      res = {};
    }
    for (String key in res.keys) {
      healthScores[DateTime.parse(key)] = res[key];
    }
  }

  static Map<DateTime, double> healthScores = {};

  @override
  Widget? getBody(State state) {
    double nowScore = -1;
    DateTime now = DateTime.now();
    for (DateTime date in healthScores.keys) {
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        nowScore = healthScores[date]!;
      }
    }
    List<DateTime> dates = healthScores.keys.toList();
    dates.sort(
      (a, b) {
        return a.compareTo(b);
      },
    );
    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
            ),
            Center(
              child: CircularPercentIndicator(
                radius: 100,
                lineWidth: 20,
                percent: nowScore == -1 ? 1 : nowScore,
                center: nowScore == -1
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.purple,
                            size: 35,
                          ),
                          SizedBox(
                            height: 7,
                          ),
                          Text(
                            '!',
                            style: TextStyle(
                                fontFamily: 'Comfort',
                                fontSize: 35,
                                color: Colors.purple),
                          )
                        ],
                      )
                    : Icon(
                        Icons.favorite,
                        color: Vitalitas.theme.fg,
                        size: 70,
                      ),
                progressColor:
                    nowScore == -1 ? Colors.purple : Vitalitas.theme.fg,
                backgroundColor: Colors.grey,
                circularStrokeCap: CircularStrokeCap.round,
                animateFromLastPercent: true,
                animation: nowScore != -1,
                animationDuration: 500,
                header: Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Daily Health Score',
                      style: TextStyle(
                          fontFamily: 'Comfort',
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Vitalitas.theme.txt),
                    )),
              ),
            ),
            (nowScore != -1
                ? const Center()
                : Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: InkWell(
                        onTap: () {
                          state.setState(() {
                            healthScores[DateTime.now()] = 0.78;
                            Map<String, double> data = {};
                            for (DateTime date in healthScores.keys) {
                              data[date.toString()] = healthScores[date]!;
                            }
                            Data.setUserField('HealthScores', data);
                          });
                        },
                        child: Card(
                          child: Column(children: [
                            SizedBox(
                                width: 250,
                                height: 50,
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'resources/heart.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    DefaultTextStyle(
                                        style: TextStyle(
                                            fontFamily: 'Comfort',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Vitalitas.theme.txt),
                                        child: AnimatedTextKit(
                                            totalRepeatCount: 1,
                                            animatedTexts: [
                                              TypewriterAnimatedText(
                                                  'How do you feel?',
                                                  speed: const Duration(
                                                      milliseconds: 40),
                                                  textAlign: TextAlign.left,
                                                  cursor: '')
                                            ]))
                                  ],
                                )),
                            Center(
                                child: DefaultTextStyle(
                                    style: TextStyle(
                                        fontFamily: 'Comfort',
                                        fontSize: 15,
                                        color: Vitalitas.theme.txt),
                                    child: Text('Take your daily quiz now.'))),
                            SizedBox(
                              height: 15,
                            )
                          ]),
                        ),
                      ),
                    ),
                  )),
            SizedBox(
              height: 30,
            ),
            DefaultTextStyle(
                style: TextStyle(
                    fontFamily: 'Comfort', color: Vitalitas.theme.txt),
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Trend',
                      textStyle:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  zoomPanBehavior: ZoomPanBehavior(
                      enablePanning: true,
                      enablePinching: true,
                      enableMouseWheelZooming: true),
                  series: [
                    LineSeries<DateTime, DateTime>(
                        name: 'Health Score',
                        color: Vitalitas.theme.fg,
                        dataSource: dates,
                        xValueMapper: (DateTime date, int index) {
                          return date;
                        },
                        yValueMapper: (DateTime date, int index) {
                          return (healthScores[date]! * 100).round();
                        },
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                        enableTooltip: true),
                  ],
                  primaryXAxis: DateTimeCategoryAxis(
                      edgeLabelPlacement: EdgeLabelPlacement.shift),
                ))
          ]),
    );
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.favorite_outline,
        text: 'Health',
        iconActiveColor:
            HSLColor.fromColor(Colors.purple).withLightness(0.2).toColor(),
        backgroundColor: Colors.purple,
        iconColor: Vitalitas.theme.bg);
  }
}
