import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_network/image_network.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:vitalitas/auth/auth.dart';

class AccountAppState extends AppState {
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
              color: Colors.black38,
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
    return SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: 50),
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
          'Privacy',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Comfort',
              fontSize: 35,
              color: Vitalitas.theme.txt),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      Center(
          child: toggle(state, 'PublicHealthScore', "HealthScore Scope:",
              'Private', 'Public')),
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
