import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
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

  static double getTodaysHealthScore() {
    double nowScore = -1;
    DateTime now = DateTime.now();
    for (DateTime date in healthScores.keys) {
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        nowScore = healthScores[date]!;
      }
    }
    return nowScore;
  }

  @override
  Widget? getBody(State state) {
    double nowScore = getTodaysHealthScore();
    List<DateTime> dates = healthScores.keys.toList();
    dates.sort(
      (a, b) {
        return a.compareTo(b);
      },
    );

    List<Drug> addedDrugs = [];
    Drug.drugs.forEach((drug) {
      if (drug.added) {
        addedDrugs.add(drug);
      }
    });
    List<Condition> addedConditions = [];
    Condition.conditions.forEach((condition) {
      if (condition.added) {
        addedConditions.add(condition);
      }
    });
    List<Exercise> addedExercises = [];
    Exercise.exercises.forEach((exercise) {
      if (exercise.added) {
        addedExercises.add(exercise);
      }
    });

    return SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(children: [
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
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    SafeArea(
                                        child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            child: Text(
                                                'Take your daily quiz now.'))),
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
                          textStyle: TextStyle(
                              fontFamily: 'Comfort',
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Vitalitas.theme.txt)),
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
                            dataLabelSettings:
                                DataLabelSettings(isVisible: true),
                            enableTooltip: true),
                      ],
                      primaryXAxis: DateTimeCategoryAxis(
                          edgeLabelPlacement: EdgeLabelPlacement.shift),
                    )),
              ]),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: Vitalitas.theme.acc,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 20, color: Colors.black.withOpacity(0.1))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    mutableList(state, 'My Prescriptions', addedDrugs),
                    mutableList(state, 'My Conditions', addedConditions),
                    mutableList(
                        state, 'My Preferred Exercises', addedExercises),
                  ]),
            ),
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

  static Widget mutableList(State state, String title, List<dynamic> obj) {
    List<Widget> li = [];
    obj.forEach((i) {
      li.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: DefaultTextStyle(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Comfort',
                          fontSize: 18,
                          color: Vitalitas.theme.txt),
                      child: Text(
                        i.name,
                        textAlign: TextAlign.left,
                      )),
                ),
                SizedBox(
                  width: 25,
                ),
                AnimatedButton(
                  text: 'Remove',
                  textStyle: TextStyle(
                    fontFamily: 'Comfort',
                    color: Vitalitas.theme.txt,
                    fontSize: 25,
                  ),
                  onPress: () {
                    i.added = false;
                    String id = i is Exercise ? i.id : i.pocId;
                    String dataType = 'PreferredExercises';
                    if (i is Drug) {
                      dataType = 'Drugs';
                    } else if (i is Condition) {
                      dataType = 'Conditions';
                    }
                    state.setState(() {
                      Data.getUserField(dataType).then((value) {
                        value.remove(id);
                        Data.setUserField(dataType, value);
                      });
                    });
                  },
                  animatedOn: AnimatedOn.onHover,
                  height: 50,
                  width: 150,
                  borderWidth: 4,
                  borderRadius: 25,
                  backgroundColor: Vitalitas.theme.acc,
                  selectedBackgroundColor: Vitalitas.theme.fg,
                  selectedTextColor: Vitalitas.theme.bg,
                  borderColor: Vitalitas.theme.bg,
                )
              ])));
    });
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: DefaultTextStyle(
              style: TextStyle(
                  fontFamily: 'Comfort',
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Vitalitas.theme.txt),
              child: Text(
                title,
                textAlign: TextAlign.left,
              )),
        ),
        SizedBox(
          height: 20,
        ),
        Column(
          children: li,
        ),
        SizedBox(
          height: 30,
        )
      ],
    );
  }
}
