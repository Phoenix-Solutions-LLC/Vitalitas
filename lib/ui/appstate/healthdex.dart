import 'package:flutter/material.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';

class HealthdexAppState extends AppState {
  @override
  Widget? getBody(State state) {
    return Container(
      child: Text('Healthdex'),
    );
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.list_alt_outlined,
        text: 'Healthdex',
        iconActiveColor:
            HSLColor.fromColor(Colors.white).withLightness(0.2).toColor(),
        backgroundColor: Colors.white,
        iconColor: Vitalitas.theme.bg);
  }
}
