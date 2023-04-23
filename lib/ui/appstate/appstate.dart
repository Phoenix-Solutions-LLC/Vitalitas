import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

abstract class VitalitasAppState {
  Widget? getBody(State state);
  GButton getNavButton();

  void dispose() {}
  void changeDependencies() {}
}
