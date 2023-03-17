import 'dart:convert';
import 'dart:math';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:vitalitas/data/bodybuilding/impl/workout.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/healthdex.dart';

class Exercise {
  static Uri api = Uri.https(
      'www.patetlex.com', '/webapps/vitalitas/api/exercises/data.json');
  static Future<void> load() async {
    var doc = await http.get(api);
    var json = jsonDecode(doc.body);
    dynamic edata = await Data.getUserField('PreferredExercises');
    if (edata == null) {
      Data.setUserField('PreferredExercises', []);
      edata = [];
    }
    int i = 0;
    while (i < json.length) {
      Map<String, dynamic> obj = json[i];
      if (obj['name'] == null ||
          obj['id'] == null ||
          obj['muscleGroup'] == null ||
          obj['equipmentType'] == null ||
          obj['exerciseType'] == null) {
        print('Cannot parse required elements for ' +
            (obj['name'] ?? 'unnamed') +
            ' of id ' +
            (obj['id'] ?? 'no id') +
            '.');
        continue;
      }
      Exercise e = Exercise(
        name: obj['name'].toString(),
        id: obj['id'].toString(),
        muscleGroup: obj['muscleGroup'].toString(),
        equipmentType: obj['equipmentType'].toString(),
        exerciseType: obj['exerciseType'].toString(),
      );
      e.added = edata.contains(obj['id'].toString());
      exercises.add(e);
      i++;
    }
    print('Loaded ' + i.toString() + ' exercises.');

    dynamic res = await Data.getUserField('Workouts');
    if (res == null) {
      Data.setUserField('Workouts', {});
      res = {};
    }
    for (String key in res.keys) {
      workouts[DateTime.parse(key)] =
          Workout.fromJson(jsonDecode(utf8.decode(base64Decode(res[key]))));
    }
    Workout? yesterdaysWorkout;
    for (DateTime date in workouts.keys) {
      if (date.day == DateTime.now().day &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year) {
        todaysWorkout = workouts[date];
      } else if (date.day == DateTime.now().day - 1 &&
          date.month == DateTime.now().month &&
          date.year == DateTime.now().year) {
        yesterdaysWorkout = workouts[date];
      }
    }
    if (todaysWorkout == null) {
      List<String> lowerBody = [
        'abductors',
        'adductors',
        'glutes',
        'abdominals',
        'calves',
        'hamstrings',
        'quadriceps',
        'lower-back'
      ];
      List<String> upperBody = [
        'chest',
        'forearms',
        'lats',
        'middle-back',
        'neck',
        'triceps',
        'traps',
        'shoulders',
        'biceps'
      ];
      double intensity = 1;
      if (yesterdaysWorkout != null) {
        if (yesterdaysWorkout.intensity >= 1.3) {
          intensity = 0.7;
        } else {
          intensity = yesterdaysWorkout.intensity + 0.1;
        }
      }
      if (yesterdaysWorkout == null ||
          lowerBody.contains(
              yesterdaysWorkout.sets[0].exercises[0].exercise.muscleGroup)) {
        todaysWorkout = Workout.build(3, 3, intensity, upperBody);
      } else {
        todaysWorkout = Workout.build(3, 3, intensity, lowerBody);
      }
      workouts[DateTime.now()] = todaysWorkout!;
      Map<String, String> data = {};
      for (DateTime date in workouts.keys) {
        data[date.toString()] =
            base64Encode(utf8.encode(jsonEncode(workouts[date])));
      }
      Data.setUserField('Workouts', data);
    }
  }

  static String search = '';
  static Widget getGrid(State state) {
    List<Widget> elements = [];
    exercises.forEach((exercise) {
      bool flag = true;
      if (search.isNotEmpty) {
        if (!exercise.name
            .trim()
            .toLowerCase()
            .contains(search.trim().toLowerCase())) {
          flag = false;
        }
        [
          exercise.equipmentType,
          exercise.exerciseType,
          exercise.muscleGroup,
          exercise.id
        ].forEach((type) {
          if (!flag) {
            flag = true;
            if (!type
                .toString()
                .trim()
                .toLowerCase()
                .contains(search.trim().toLowerCase())) {
              flag = false;
            }
          }
        });
      }
      if (flag) {
        elements.add(
          Padding(
            padding: EdgeInsets.all(15),
            child: InkWell(
              onTap: () {
                state.setState(() {
                  HealthdexAppState.currentScreen = exercise;
                });
              },
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Icon(
                      Icons.run_circle_outlined,
                      size: 25,
                    ),
                    Text(exercise.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Comfort',
                            fontSize: 8))
                  ],
                ),
              ),
            ),
          ),
        );
      }
    });
    return Center(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                state.setState(() {
                  HealthdexAppState.currentScreen = 'main';
                });
              },
              child: Padding(
                  padding: EdgeInsets.only(bottom: 10, top: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(children: [
                        Icon(Icons.arrow_back_ios_new_outlined),
                        DefaultTextStyle(
                            style: TextStyle(
                                fontFamily: 'Comfort',
                                fontSize: 10,
                                color: Vitalitas.theme.txt),
                            child: Text(
                              'Back',
                              textAlign: TextAlign.center,
                            ))
                      ]))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50, bottom: 50),
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Vitalitas.theme.txt),
                  child: Text(
                    'Exercises',
                    textAlign: TextAlign.center,
                  )),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: TextStyle(fontFamily: 'Comfort', fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      onChanged: (v) {
                        state.setState(() {
                          search = v.trim();
                        });
                      },
                      cursorColor: Vitalitas.theme.fg,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true))
                ],
              ),
            ),
            Expanded(
                child: GridView.count(
              crossAxisCount: 3,
              children: elements,
            ))
          ]),
    ));
  }

  static Workout? todaysWorkout;
  static Map<DateTime, Workout> workouts = {};

  static List<Exercise> exercises = [];

  final String name;
  final String id;
  final String muscleGroup;
  final String equipmentType;
  final String exerciseType;

  Exercise(
      {required this.name,
      required this.id,
      required this.muscleGroup,
      required this.equipmentType,
      required this.exerciseType});

  bool added = false;
  Widget getDetails(State state) {
    List<Widget> extraInfo = [];
    extraInfo.addAll(createInformationWidget(
        'Muscle Groups',
        [
          (this.muscleGroup.substring(0, 1).toUpperCase() +
              this.muscleGroup.substring(1))
        ],
        Icons.group_outlined));
    extraInfo.addAll(createInformationWidget(
        'Equipment Required', [this.equipmentType], Icons.settings_outlined));
    extraInfo.addAll(createInformationWidget(
        'Exercise Type',
        [
          (this.exerciseType.substring(0, 1).toUpperCase() +
              this.exerciseType.substring(1))
        ],
        Icons.run_circle_outlined));
    extraInfo.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Prefer this Exercise?',
          style: TextStyle(
              fontFamily: 'Comfort',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Vitalitas.theme.txt),
        ),
        SizedBox(width: 25),
        AnimatedToggleSwitch.dual(
          current: added,
          first: true,
          second: false,
          dif: 50.0,
          borderColor: Colors.transparent,
          borderWidth: 5.0,
          height: 55,
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1.5),
            ),
          ],
          onChanged: (b) {
            added = b;
            state.setState(() {
              Data.getUserField('PreferredExercises').then((value) {
                if (b) {
                  value.add(id);
                } else {
                  value.remove(id);
                }
                Data.setUserField('PreferredExercises', value);
              });
            });
          },
          colorBuilder: (b) => b ? Colors.greenAccent : Vitalitas.theme.fg,
          iconBuilder: (value) => value
              ? Icon(Icons.check, color: Colors.green)
              : Icon(
                  Icons.clear,
                  color: Colors.red,
                ),
          textBuilder: (value) =>
              value ? Center(child: Text('Yes')) : Center(child: Text('No')),
        )
      ],
    ));
    extraInfo.add(SizedBox(
      height: 20,
    ));
    extraInfo.add(Center(
        child: DefaultTextStyle(
            style: TextStyle(
                fontFamily: 'Comfort',
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Vitalitas.theme.txt),
            child: InkWell(
                onTap: () {
                  launchUrl(Uri.parse(
                      'https://www.bodybuilding.com/exercises/' + id));
                },
                child: Text(
                  'Learn More',
                  textAlign: TextAlign.center,
                )))));
    return Container(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Vitalitas.theme.acc,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 20, color: Colors.black.withOpacity(0.1))
                  ]),
              child: Column(children: [
                SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                      onTap: () {
                        state.setState(() {
                          HealthdexAppState.currentScreen = 'Exercise';
                        });
                      },
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: 30,
                      )),
                ),
                Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontWeight: FontWeight.bold,
                            fontSize: 60,
                            color: Vitalitas.theme.txt),
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                        ))),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Vitalitas.theme.txt),
                        child: Text(
                          id,
                          textAlign: TextAlign.center,
                        ))),
                SizedBox(
                  height: 15,
                ),
              ]),
            ),
            SizedBox(
              height: 30,
            ),
            Column(
              children: extraInfo,
            )
          ],
        ),
      ),
    );
  }

  static List<Widget> createInformationWidget(
      String title, List<dynamic> info, IconData bullet) {
    List<Widget> extraInfo = [];
    List<Widget> li = [];
    info.forEach((i) {
      li.add(Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Icon(bullet),
            SizedBox(
              width: 5,
            ),
            Expanded(
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 14,
                      color: Vitalitas.theme.txt),
                  child: Text(
                    i,
                    textAlign: TextAlign.left,
                  )),
            ),
            SizedBox(
              height: 5,
            )
          ])));
    });
    extraInfo.add(Column(
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
    ));
    return extraInfo;
  }
}
