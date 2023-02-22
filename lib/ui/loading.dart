import 'package:flutter/material.dart';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:vitalitas/breakpoint.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/widgets/animated_bot_screen.dart';

class LoadingPage extends StatelessWidget {
  Function? task;

  LoadingPage({this.task});

  @override
  Widget build(BuildContext context) {
    if (task != null) {
      task!().then((p) {
        task = null;
        Navigator.push(context, MaterialPageRoute(builder: (ctx) => p));
      });
    }
    var c = [
      Expanded(
        child: Center(
            child: Padding(
                padding: EdgeInsets.all(50),
                child: Image.asset('assets/resources/logo.png'))),
      ),
      Expanded(
          child: Padding(
              padding: EdgeInsets.only(
                  right: 50,
                  left: 50,
                  bottom: 50,
                  top: Breakpoint.currentViewport(context) == Breakpoint.mobile
                      ? 0
                      : 50),
              child: AnimatedBotScreen(
                animatedText:
                    "Vitalitas is loading.\nPlease be patient.\n\nVitalitas aims to solve all of your home health needs.\nFor serious inquiries, contact a doctor.",
              )))
    ];
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Vitalitas.theme.fg, Vitalitas.theme.acc],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: [0.1, 0.9])),
            child: Breakpoint.currentViewport(context) == Breakpoint.mobile
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center, children: c)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center, children: c)));
  }
}
