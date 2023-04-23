import 'dart:ui';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_network/image_network.dart';
import 'package:number_inc_dec/number_inc_dec.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:vitalitas/authentification/auth.dart';
import 'package:vitalitas/ui/auth/landing.dart';
import 'package:vitalitas/ui/auth/reset.dart';

class AccountAppState extends VitalitasAppState {
  static Future<void> load() async {
    dynamic uName = await Data.getUserField('Username');
    if (!(uName is String)) {
      uName = 'Unnamed';
      await Data.setUserField('Username', 'Unnamed');
    }
    username = uName;
  }

  static String? username;
  static Map<String, bool> currentToggle = Map();
  Widget toggle(
      State state, String dataField, String text, String t, String f) {
    Data.getUserField(dataField).then((value) {
      if (value != null && !currentToggle.containsKey(dataField)) {
        currentToggle[dataField] = value;
      }
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 15, color: Vitalitas.theme.txt),
        ),
        SizedBox(width: 50),
        AnimatedToggleSwitch.dual(
          current: currentToggle[dataField] ?? false,
          first: true,
          second: false,
          dif: 50.0,
          borderColor: Colors.transparent,
          borderWidth: 5.0,
          height: 55,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1.5),
            ),
          ],
          onChanged: (b) {
            currentToggle[dataField] = b;
            state.setState(() {
              Data.setUserField(dataField, currentToggle[dataField]);
            });
          },
          colorBuilder: (b) => b ? Vitalitas.theme.acc : Vitalitas.theme.fg,
          iconBuilder: (value) => value
              ? Icon(Icons.public_outlined,
                  color: HSLColor.fromColor(Vitalitas.theme.acc)
                      .withLightness(0.4)
                      .toColor())
              : Icon(
                  Icons.public_off_outlined,
                  color: HSLColor.fromColor(Vitalitas.theme.fg)
                      .withLightness(0.2)
                      .toColor(),
                ),
          textBuilder: (value) =>
              value ? Center(child: Text(f)) : Center(child: Text(t)),
        )
      ],
    );
  }

  static List<Widget>? bodyWidgets;
  @override
  Widget? getBody(State state) {
    if (Authentification.currentUser == null) {
      return Container(
          child: Center(
              child: Text('Login for Account Settings',
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontWeight: FontWeight.bold,
                      fontSize: 45,
                      color: Vitalitas.theme.txt))));
    }

    if (bodyWidgets == null) {
      bodyWidgets = [];
      Data.getUserField('Age').then((age) {
        Data.getUserField('Height').then((height) {
          Data.getUserField('Weight').then((weight) {
            if (age is int) {
              bodyWidgets!.add(Center(
                child: Text(
                  'Age',
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 20,
                      color: Vitalitas.theme.txt),
                ),
              ));
              bodyWidgets!.add(SizedBox(
                height: 3,
              ));
              bodyWidgets!.add(Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: NumberInputPrefabbed.roundedButtons(
                    controller: TextEditingController(),
                    incDecBgColor: Vitalitas.theme.fg,
                    incIconColor: Vitalitas.theme.bg,
                    decIconColor: Vitalitas.theme.bg,
                    initialValue: age,
                    buttonArrangement: ButtonArrangement.incLeftDecRight,
                    onChanged: (num) {
                      Data.setUserField('Age', num);
                    },
                    onIncrement: (num) {
                      Data.setUserField('Age', num);
                    },
                    onDecrement: (num) {
                      Data.setUserField('Age', num);
                    },
                    min: 0,
                    max: 100,
                  )));
              bodyWidgets!.add(SizedBox(
                height: 5,
              ));
            }
            if (height is int) {
              bodyWidgets!.add(Center(
                child: Text(
                  'Height',
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 20,
                      color: Vitalitas.theme.txt),
                ),
              ));
              bodyWidgets!.add(SizedBox(
                height: 3,
              ));
              bodyWidgets!.add(Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: NumberInputPrefabbed.roundedButtons(
                    controller: TextEditingController(),
                    incDecBgColor: Vitalitas.theme.fg,
                    incIconColor: Vitalitas.theme.bg,
                    decIconColor: Vitalitas.theme.bg,
                    initialValue: height,
                    buttonArrangement: ButtonArrangement.incLeftDecRight,
                    onChanged: (num) {
                      Data.setUserField('Height', num);
                    },
                    onIncrement: (num) {
                      Data.setUserField('Height', num);
                    },
                    onDecrement: (num) {
                      Data.setUserField('Height', num);
                    },
                    min: 36,
                    max: 96,
                  )));
              bodyWidgets!.add(SizedBox(
                height: 5,
              ));
            }
            if (weight is int) {
              bodyWidgets!.add(Center(
                child: Text(
                  'Weight',
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontSize: 20,
                      color: Vitalitas.theme.txt),
                ),
              ));
              bodyWidgets!.add(SizedBox(
                height: 3,
              ));
              bodyWidgets!.add(Padding(
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  child: NumberInputPrefabbed.roundedButtons(
                    controller: TextEditingController(),
                    incDecBgColor: Vitalitas.theme.fg,
                    incIconColor: Vitalitas.theme.bg,
                    decIconColor: Vitalitas.theme.bg,
                    initialValue: weight,
                    buttonArrangement: ButtonArrangement.incLeftDecRight,
                    onChanged: (num) {
                      Data.setUserField('Weight', num);
                    },
                    onIncrement: (num) {
                      Data.setUserField('Weight', num);
                    },
                    onDecrement: (num) {
                      Data.setUserField('Weight', num);
                    },
                    min: 50,
                    max: 350,
                  )));
              bodyWidgets!.add(SizedBox(
                height: 5,
              ));
            }
            state.setState(() {});
          });
        });
      });
    }

    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 30),
      Center(
        child: Text(
          username!,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Comfort',
              fontSize: 35,
              color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 10,
      ),
      Center(
          child: ClipOval(
              child: SizedBox.fromSize(
                  size: Size.fromRadius(100),
                  child: Authentification.currentUser!.photoURL != null
                      ? ImageNetwork(
                          image: Authentification.currentUser!.photoURL!,
                          height: 200,
                          width: 200,
                        )
                      : Icon(
                          Icons.account_circle_outlined,
                          size: 200,
                        )))),
      SizedBox(height: 50),
      Center(
        child: Text(
          'Exercise',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Comfort',
              fontSize: 35,
              color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 15,
      ),
      Center(
        child: Text(
          'Sets Per Workout',
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 20, color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 3,
      ),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 80),
          child: NumberInputPrefabbed.roundedButtons(
            controller: TextEditingController(),
            incDecBgColor: Vitalitas.theme.fg,
            incIconColor: Vitalitas.theme.bg,
            decIconColor: Vitalitas.theme.bg,
            initialValue: Exercise.setsPerWorkout!,
            buttonArrangement: ButtonArrangement.incLeftDecRight,
            onChanged: (num) {
              Data.setUserField('WorkoutsSets', num);
              Exercise.setsPerWorkout = num as int;
            },
            onIncrement: (num) {
              Data.setUserField('WorkoutsSets', num);
              Exercise.setsPerWorkout = num as int;
            },
            onDecrement: (num) {
              Data.setUserField('WorkoutsSets', num);
              Exercise.setsPerWorkout = num as int;
            },
            min: 1,
            max: 5,
          )),
      SizedBox(
        height: 5,
      ),
      Center(
        child: Text(
          'Exercises Per Set',
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 20, color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 3,
      ),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 80),
          child: NumberInputPrefabbed.roundedButtons(
            controller: TextEditingController(),
            incDecBgColor: Vitalitas.theme.fg,
            incIconColor: Vitalitas.theme.bg,
            decIconColor: Vitalitas.theme.bg,
            initialValue: Exercise.exercisesPerSetPerWorkout!,
            buttonArrangement: ButtonArrangement.incLeftDecRight,
            onChanged: (num) {
              Data.setUserField('WorkoutsExercisesPerSet', num);
              Exercise.exercisesPerSetPerWorkout = num as int;
            },
            onIncrement: (num) {
              Data.setUserField('WorkoutsExercisesPerSet', num);
              Exercise.exercisesPerSetPerWorkout = num as int;
            },
            onDecrement: (num) {
              Data.setUserField('WorkoutsExercisesPerSet', num);
              Exercise.exercisesPerSetPerWorkout = num as int;
            },
            min: 1,
            max: 5,
          )),
      SizedBox(
        height: 20,
      ),
      Center(
        child: Text(
          'Account',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Comfort',
              fontSize: 35,
              color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 15,
      ),
      Column(
        children: bodyWidgets!,
      ),
      SizedBox(
        height: 5,
      ),
      AnimatedButton(
        text: 'Reset Password',
        textStyle: TextStyle(
          fontFamily: 'Comfort',
          color: Vitalitas.theme.txt,
          fontSize: 16,
        ),
        onPress: () {
          if (Authentification.currentUser != null) {
            Navigator.push(state.context,
                MaterialPageRoute(builder: (context) => ResetPage()));
          }
        },
        animatedOn: AnimatedOn.onHover,
        height: 50,
        width: 150,
        borderWidth: 4,
        borderRadius: 25,
        backgroundColor: Vitalitas.theme.acc,
        selectedBackgroundColor: Vitalitas.theme.fg,
        selectedTextColor: Vitalitas.theme.bg,
        borderColor: Vitalitas.theme.fg,
      ),
      SizedBox(
        height: 10,
      ),
      AnimatedButton(
        text: 'Log out',
        textStyle: TextStyle(
          fontFamily: 'Comfort',
          color: Vitalitas.theme.txt,
          fontSize: 20,
        ),
        onPress: () {
          if (Authentification.currentUser != null) {
            Authentification.signOut();
            Navigator.push(state.context,
                MaterialPageRoute(builder: (context) => LandingPage()));
          }
        },
        animatedOn: AnimatedOn.onHover,
        height: 50,
        width: 150,
        borderWidth: 4,
        borderRadius: 25,
        backgroundColor: Vitalitas.theme.acc,
        selectedBackgroundColor: Vitalitas.theme.fg,
        selectedTextColor: Vitalitas.theme.bg,
        borderColor: Vitalitas.theme.fg,
      ),
      SizedBox(
        height: 10,
      ),
      AnimatedButton(
        text: 'Delete Data',
        textStyle: TextStyle(
          fontFamily: 'Comfort',
          color: Vitalitas.theme.txt,
          fontSize: 20,
        ),
        onPress: () {
          if (Authentification.currentUser != null) {
            Data.currentUserDoc().then((doc) {
              if (doc != null) {
                doc.delete();
              }
            });
            Navigator.push(state.context,
                MaterialPageRoute(builder: (context) => LandingPage()));
          }
        },
        animatedOn: AnimatedOn.onHover,
        height: 50,
        width: 150,
        borderWidth: 4,
        borderRadius: 25,
        backgroundColor: Vitalitas.theme.acc,
        selectedBackgroundColor: Vitalitas.theme.fg,
        selectedTextColor: Vitalitas.theme.bg,
        borderColor: Vitalitas.theme.fg,
      ),
      SizedBox(
        height: 20,
      ),
      Center(
        child: Text(
          'Contact:',
          style: TextStyle(
              fontFamily: 'Comfort',
              fontSize: 25,
              color: Vitalitas.theme.txt,
              fontWeight: FontWeight.bold),
        ),
      ),
      Center(
        child: Text(
          'support@patetlex.com',
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 15, color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 20,
      )
      // SizedBox(
      //   height: 20,
      // ),
      // Center(
      //     child: toggle(state, 'PublicHealthScore', "HealthScore Scope:",
      //         'Private', 'Public')),
    ]));
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.account_circle_outlined,
        text: 'Account',
        iconActiveColor: HSLColor.fromColor(Color.fromARGB(255, 255, 215, 0))
            .withLightness(0.2)
            .toColor(),
        backgroundColor: HSLColor.fromColor(Color.fromARGB(255, 255, 215, 0))
            .withLightness(0.8)
            .toColor(),
        iconColor: Vitalitas.theme.bg);
  }
}
