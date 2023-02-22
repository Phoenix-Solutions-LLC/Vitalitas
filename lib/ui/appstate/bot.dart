import 'package:flutter/material.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';

class BotAppState extends AppState {
  @override
  Widget? getBody(State state) {
    return Container(
      child: Text('Bot'),
    );
  }

  @override
  GButton getNavButton() {
    return GButton(
        icon: Icons.message_outlined,
        text: 'Bot',
        iconActiveColor:
            HSLColor.fromColor(Colors.grey).withLightness(0.2).toColor(),
        backgroundColor:
            HSLColor.fromColor(Colors.grey).withLightness(0.8).toColor(),
        iconColor: Vitalitas.theme.bg);
  }
}
