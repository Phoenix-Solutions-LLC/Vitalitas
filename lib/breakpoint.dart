import 'package:flutter/material.dart';

class Breakpoint {
  final double minWidth;
  final double maxWidth;
  Breakpoint({required this.minWidth, this.maxWidth = 0});

  static Breakpoint mobile = Breakpoint(minWidth: 0, maxWidth: 641);
  static Breakpoint tablet = Breakpoint(minWidth: 641, maxWidth: 1007);
  static Breakpoint computer = Breakpoint(minWidth: 1008);

  static List<Breakpoint> viewports =
      List.of({mobile, tablet, computer}, growable: true);

  static Breakpoint currentViewport(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    for (Breakpoint vp in viewports) {
      if (vp.minWidth < width && (vp.maxWidth == 0 || vp.maxWidth >= width)) {
        return vp;
      }
    }
    return tablet;
  }
}
