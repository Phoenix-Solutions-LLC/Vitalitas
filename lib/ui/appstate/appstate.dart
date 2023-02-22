import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

abstract class AppState {
  Widget? getBody(State state);
  GButton getNavButton();
}
