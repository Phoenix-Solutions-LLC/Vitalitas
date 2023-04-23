import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/src/gbutton.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/monetization/ads.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HealthdexAppState extends VitalitasAppState {
  static dynamic currentScreen = 'main';
  static BannerAd? bannerAd0;

  @override
  void changeDependencies() {
    bannerAd0 = Monetization.loadNewBanner();
  }

  @override
  void dispose() {
    if (bannerAd0 != null) {
      bannerAd0!.dispose();
      bannerAd0 = null;
    }
  }

  @override
  Widget? getBody(State state) {
    print(bannerAd0);
    var main = Center(
        child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 50, bottom: 50),
                child: DefaultTextStyle(
                    style: TextStyle(
                        fontFamily: 'Comfort',
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Vitalitas.theme.txt),
                    child: AnimatedTextKit(totalRepeatCount: 1, animatedTexts: [
                      TypewriterAnimatedText(
                          'What would you like to learn more about?',
                          speed: const Duration(milliseconds: 40),
                          textAlign: TextAlign.left,
                          cursor: '')
                    ]))),
            Expanded(
                child: GridView.count(
              crossAxisCount: 2,
              children: [
                Padding(
                  padding: EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () {
                      state.setState(() {
                        currentScreen = 'Drug';
                      });
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.science_outlined,
                            size: 65,
                          ),
                          Text('Drugs',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Comfort',
                                  fontSize: 25))
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () {
                      state.setState(() {
                        currentScreen = 'Condition';
                      });
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.accessibility_outlined,
                            size: 65,
                          ),
                          Text('Conditions',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Comfort',
                                  fontSize: 25))
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: InkWell(
                    onTap: () {
                      state.setState(() {
                        currentScreen = 'Exercise';
                      });
                    },
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(
                            Icons.run_circle_outlined,
                            size: 65,
                          ),
                          Text('Exercises',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Comfort',
                                  fontSize: 25))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )),
            SizedBox(
              height: 20,
            ),
            (bannerAd0 != null
                ? Center(
                    child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: SafeArea(
                        child: SizedBox(
                      width: bannerAd0!.size.width.toDouble(),
                      height: bannerAd0!.size.height.toDouble(),
                      child: AdWidget(ad: bannerAd0!),
                    )),
                  ))
                : Container()),
            SizedBox(
              height: 20,
            ),
          ]),
    ));
    if (currentScreen is String) {
      Map<String, Widget> vals = {
        'main': main,
        'Drug': Drug.getGrid(state),
        'Condition': Condition.getGrid(state),
        'Exercise': Exercise.getGrid(state)
      };
      return vals[currentScreen];
    } else if (currentScreen is Condition) {
      return currentScreen.getDetails(state);
    } else if (currentScreen is Drug) {
      return currentScreen.getDetails(state);
    } else if (currentScreen is Exercise) {
      return currentScreen.getDetails(state);
    }
    return main;
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
