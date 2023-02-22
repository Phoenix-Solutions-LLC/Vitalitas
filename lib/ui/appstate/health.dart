import 'package:flutter/material.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';

class HealthAppState extends AppState {
  @override
  Widget? getBody(State state) {
    return Container(
      child: Text('My Health'),
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
