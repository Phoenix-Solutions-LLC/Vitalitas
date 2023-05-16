import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/main.dart';

class AnimatedBotScreen extends StatefulWidget {
  final String animatedText;
  final double width;
  final double height;

  AnimatedBotScreen(
      {required this.animatedText, this.width = 200, this.height = 600});

  @override
  State<StatefulWidget> createState() {
    return AnimatedBotState(
        animatedText: animatedText, width: width, height: height);
  }
}

class AnimatedBotState extends State<AnimatedBotScreen> {
  final String animatedText;
  final double width;
  final double height;

  AnimatedBotState(
      {required this.animatedText, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30), color: Vitalitas.theme.bg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(25),
              child: DefaultTextStyle(
                  style: TextStyle(
                      fontFamily: 'Comfort',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Vitalitas.theme.txt),
                  child: AnimatedTextKit(animatedTexts: [
                    TypewriterAnimatedText(
                      animatedText,
                      speed: const Duration(milliseconds: 80),
                      textAlign: TextAlign.left,
                    )
                  ])),
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 60,
                width: const Size.fromHeight(60).width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Vitalitas.theme.acc!, width: 5)),
                child: Center(
                    child: DefaultTextStyle(
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontWeight: FontWeight.bold,
                            fontSize: 40,
                            color: Vitalitas.theme.txt),
                        child: AnimatedTextKit(animatedTexts: [
                          WavyAnimatedText('...',
                              speed: const Duration(milliseconds: 400))
                        ]))),
              ),
            )
          ],
        ));
  }
}
