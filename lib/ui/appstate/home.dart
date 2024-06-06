import 'dart:convert';
import 'dart:io';

// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:like_button/like_button.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/bodybuilding/impl/workout.dart';
import 'package:vitalitas/data/data.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
import 'package:vitalitas/data/misc/quote.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/monetization/ads.dart';
import 'package:vitalitas/ui/appstate/account.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:vitalitas/ui/appstate/appstate.dart';
import 'package:vitalitas/ui/appstate/bot.dart';
import 'package:vitalitas/ui/appstate/health.dart';
import 'package:vitalitas/ui/appstate/healthdex.dart';
import 'package:vitalitas/ui/loading.dart';
import 'package:vitalitas/ui/widgets/clip/wave.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class HomePage extends StatefulWidget {
  static List<VitalitasAppState> appStates = [];

  // static StatefulWidget load() {
  //   return LoadingPage(
  //     task: () async {
  //       if (!HomeAppState.built) {
  //         HomeAppState.built = true;

  //         await Condition.load();
  //         await Drug.load();
  //         await Exercise.load();
  //         await Quote.load();
  //         await HealthAppState.load();
  //         await BotAppState.load();
  //         await AccountAppState.load();

  //         HomeAppState.profile = await Adapty().getProfile();

  //         print('Finished Initial Building.');

  //         dynamic pS = await Data.getUserField('SurveyFeedback');
  //         if (pS is String) {
  //           HomeAppState.surveyFeedback = pS;
  //         }

  //         appStates.add(HomeAppState());
  //         appStates.add(HealthAppState());
  //         appStates.add(HealthdexAppState());
  //         appStates.add(AccountAppState());
  //         appStates.add(BotAppState());
  //       }

  //       return HomePage();
  //     },
  //   );
  // }

  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeAppState extends VitalitasAppState {
  static bool initalBuilt = false;
  // static AdaptyProfile? profile;
  static bool bypassIntendedObstacles = false;

  static String? surveyFeedback;
  // static BannerAd? bannerAd0;
  // static BannerAd? bannerAd1;
  // static InterstitialAd? interstitialAd0;

  static void load() {
    // if (!(HomeAppState.profile?.accessLevels['premium']?.isActive ??
    //     false || HomeAppState.bypassIntendedObstacles)) {
    //   Monetization.loadNewInterstitial().future.then((ad) {
    //     interstitialAd0 = ad;
    //   });
    // }
  }

  @override
  void changeDependencies() {
    // if (!(HomeAppState.profile?.accessLevels['premium']?.isActive ??
    //     false || HomeAppState.bypassIntendedObstacles)) {
    //   bannerAd0 = Monetization.loadNewBanner();
    //   bannerAd1 = Monetization.loadNewBanner();
    // }
  }

  @override
  void dispose() {
    // if (bannerAd0 != null) {
    //   bannerAd0!.dispose();
    //   bannerAd0 = null;
    // }
    // if (bannerAd1 != null) {
    //   bannerAd1!.dispose();
    //   bannerAd1 = null;
    // }
  }

  @override
  Widget? getBody(State state) {
    Size screen = MediaQuery.of(state.context).size;

    String splashText = '';
    double brightness;
    DateTime time = DateTime.now();
    if (time.hour > 4 && time.hour <= 11) {
      splashText = 'Good Morning';
      brightness = 1.1;
    } else if (time.hour > 11 && time.hour < 17) {
      splashText = 'Good Afternoon';
      brightness = 0.9;
    } else {
      splashText = 'Good Night';
      brightness = 0.7;
    }

    if (HealthAppState.getTodaysHealthScore() == -1) {
      splashText = splashText + ' - Take Survey';
    }

    Quote? quote;
    for (DateTime date in Quote.quotes.keys) {
      if (date.day == DateTime.now().day &&
          date.month == DateTime.now().month) {
        quote = Quote.quotes[date];
        break;
      }
    }

    List<Widget> extraForYou = [];
    if (surveyFeedback != null) {
      extraForYou.add(
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Watch out for your feedback:',
              style: TextStyle(
                  fontFamily: 'Comfort',
                  fontSize: 25,
                  color: Vitalitas.theme.txt),
            )),
      );
      extraForYou.add(SizedBox(
        height: 10,
      ));
      extraForYou.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            surveyFeedback!,
            style: TextStyle(
              fontFamily: 'Comfort',
              fontSize: 16,
              color: Vitalitas.theme.txt,
            ),
          )));
    }

    return SingleChildScrollView(
        child: SizedBox(
            child: Column(
      children: [
        ClipPath(
            clipper: WaveClipper(),
            child: Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 20, color: Colors.black.withOpacity(0.1))
                  ],
                  gradient: LinearGradient(colors: [
                    Vitalitas.theme.acc!,
                    HSLColor.fromColor(Vitalitas.theme.acc!)
                        .withLightness(
                            HSLColor.fromColor(Vitalitas.theme.acc!).lightness *
                                brightness)
                        .toColor()
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(children: [
                SizedBox(
                  height: 50,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 100),
                    child: Center(
                        child: Image.asset('assets/resources/logo.png'))),
                SizedBox(
                  height: 40,
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 36),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle(
                          style: TextStyle(
                              fontFamily: 'Comfort',
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: HSLColor.fromColor(Vitalitas.theme.acc!)
                                  .withLightness(0.97)
                                  .toColor()),
                          child: AnimatedTextKit(
                              onTap: () {
                                state.setState(() {
                                  HomeState._index = 1;
                                });
                              },
                              totalRepeatCount: 2,
                              animatedTexts: [
                                WavyAnimatedText(splashText,
                                    speed: Duration(milliseconds: 125))
                              ])),
                    )),
                SizedBox(
                  height: 175,
                ),
              ]),
            )),
        // (bannerAd0 != null
        //     ? Center(
        //         child: Padding(
        //         padding: EdgeInsets.symmetric(vertical: 10),
        //         child: SafeArea(
        //             child: SizedBox(
        //           width: bannerAd0!.size.width.toDouble(),
        //           height: bannerAd0!.size.height.toDouble(),
        //           child: AdWidget(ad: bannerAd0!),
        //         )),
        //       ))
        //     : Container()),
        Container(),
        Padding(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'For you',
                      style: TextStyle(
                          fontFamily: 'Comfort',
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Vitalitas.theme.txt),
                    )),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Live your day with some inspiration:',
                      style: TextStyle(
                          fontFamily: 'Comfort',
                          fontSize: 25,
                          color: Vitalitas.theme.txt),
                    )),
                SizedBox(
                  height: 30,
                ),
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(40)),
                        color: const Color.fromARGB(255, 221, 221, 221),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 20,
                              color: Colors.black.withOpacity(0.1))
                        ]),
                    child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(children: [
                          (quote != null
                              ? Text(
                                  quote.quote,
                                  style: TextStyle(
                                      fontFamily: 'Comfort',
                                      fontSize: 20,
                                      color: Vitalitas.theme.txt),
                                )
                              : Text(
                                  'Have a great day today!',
                                  style: TextStyle(
                                      fontFamily: 'Comfort',
                                      fontSize: 20,
                                      color: Vitalitas.theme.txt),
                                )),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: (quote != null
                                  ? Text(
                                      '- ' + quote.name,
                                      style: TextStyle(
                                          fontFamily: 'Comfort',
                                          fontSize: 16,
                                          color: Vitalitas.theme.txt),
                                    )
                                  : Text(
                                      '- Vitalitas Team',
                                      style: TextStyle(
                                          fontFamily: 'Comfort',
                                          fontSize: 16,
                                          color: Vitalitas.theme.txt),
                                    ))),
                        ]))),
                SizedBox(
                  height: 35,
                ),
                Column(
                  children: extraForYou,
                )
              ],
            )),
        // (bannerAd1 != null
        //     ? Center(
        //         child: Padding(
        //         padding: EdgeInsets.symmetric(vertical: 10),
        //         child: SafeArea(
        //             child: SizedBox(
        //           width: bannerAd1!.size.width.toDouble(),
        //           height: bannerAd1!.size.height.toDouble(),
        //           child: AdWidget(ad: bannerAd1!),
        //         )),
        //       ))
        //     : Container()),
        Container(),
        SizedBox(
          height: 50,
        ),
        getWorkoutWidget(state, Exercise.todaysWorkout!)
      ],
    )));
  }

  @override
  GButton getNavButton() {
    return GButton(
      icon: Icons.home_outlined,
      text: 'Home',
      iconActiveColor:
          HSLColor.fromColor(Vitalitas.theme.fg!).withLightness(0.2).toColor(),
      backgroundColor: Vitalitas.theme.fg,
      iconColor: Vitalitas.theme.bg,
    );
  }

  Widget getWorkoutWidget(State state, Workout workout) {
    List<Widget> sets = [];
    for (Set set in workout.sets) {
      List<Widget> exercises = [];
      for (Repetition exercise in set.exercises) {
        exercises.add(InkWell(
            onTap: () {
              state.setState(() {
                HomeState._index = 2;
                HealthdexAppState.currentScreen = exercise.exercise;
              });
            },
            child: exercise.exercise.added
                ? Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Color.fromARGB(255, 255, 215, 0),
                        size: 15,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        (exercise.exercise.name),
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Vitalitas.theme.txt),
                      )
                    ],
                  )
                : Text(
                    (exercise.exercise.name),
                    style: TextStyle(
                        fontFamily: 'Comfort',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Vitalitas.theme.txt),
                  )));
        exercises.add(SizedBox(
          height: 5,
        ));
        exercises.add(Text(
          (exercise.repetitions.toString() + ' ' + exercise.units),
          style: TextStyle(
              fontFamily: 'Comfort', fontSize: 12, color: Vitalitas.theme.txt),
        ));
        exercises.add(SizedBox(
          height: 15,
        ));
      }
      sets.add(
        Container(
          padding: const EdgeInsets.all(35),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            boxShadow: [
              BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
            ],
            gradient: LinearGradient(colors: [
              (set.exercises[0].exercise.exerciseType == 'cardio' ||
                      set.exercises[0].exercise.exerciseType == 'stretching')
                  ? Vitalitas.theme.fg!
                  : Vitalitas.theme.acc!,
              set.complete ? Colors.grey.shade400 : Colors.white
            ], stops: [
              0.07,
              0
            ], begin: Alignment.centerLeft, end: Alignment.centerRight),
          ),
          child: Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        (set.sets.toString() + ' sets'),
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Vitalitas.theme.txt),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        (set.exercises.length.toString() + ' exercises'),
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 12,
                            color: Vitalitas.theme.txt),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        ((set.exercises[0].exercise.exerciseType == 'cardio' ||
                                set.exercises[0].exercise.exerciseType ==
                                    'stretching')
                            ? 'Warm-Up'
                            : set.exercises[0].exercise.muscleGroup
                                    .substring(0, 1)
                                    .toUpperCase() +
                                set.exercises[0].exercise.muscleGroup
                                    .substring(1)
                                    .toLowerCase()),
                        style: TextStyle(
                            fontFamily: 'Comfort',
                            fontSize: 12,
                            color: Vitalitas.theme.txt),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      LikeButton(
                        size: 40,
                        isLiked: set.complete,
                        circleColor: CircleColor(
                            start: Colors.lightGreen, end: Colors.green),
                        bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.green,
                            dotSecondaryColor: Colors.lightGreen),
                        likeBuilder: (bool isLiked) {
                          return Icon(
                            Icons.check_circle_outline_rounded,
                            color:
                                isLiked ? Colors.green.shade600 : Colors.grey,
                            size: 40,
                          );
                        },
                        onTap: (isLiked) async {
                          state.setState(() {
                            set.complete = !isLiked;
                          });
                          // if (interstitialAd0 != null) {
                          //   interstitialAd0!.show().then((v) {
                          //     interstitialAd0 = null;
                          //     Monetization.loadNewInterstitial()
                          //         .future
                          //         .then((ad) {
                          //       interstitialAd0 = ad;
                          //     });
                          //   });
                          // }
                          Workout.update();
                          return !isLiked;
                        },
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                    children: exercises,
                  ))
                ],
              )),
        ),
      );
      sets.add(SizedBox(
        height: 25,
      ));
    }
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: const Color.fromARGB(255, 221, 221, 221),
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
          ]),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(35),
            child: Text(
              'Today\'s Workout',
              style: TextStyle(
                  fontFamily: 'Comfort',
                  color: Vitalitas.theme.txt,
                  fontWeight: FontWeight.bold,
                  fontSize: 45),
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: sets,
            ))
      ]),
    );
  }
}

class HomeState extends State<HomePage> {
  static int _index = 0;
  static bool? loading;

  @override
  void initState() {
    super.initState();
    if (!HomeAppState.initalBuilt) {
      HomePage.appStates.add(HomeAppState());
      HomePage.appStates.add(HealthAppState());
      HomePage.appStates.add(HealthdexAppState());
      HomePage.appStates.add(AccountAppState());
      HomePage.appStates.add(BotAppState());
    }
    () async {
      setState(() {
        loading = true;
      });

      // if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      //   if (HomeAppState.profile == null) {
      //     HomeAppState.profile = await Adapty().getProfile();
      //     dynamic prem = await Data.getUserField('Premium');
      //     if (prem != null && prem is bool) {
      //       HomeAppState.bypassIntendedObstacles = prem;
      //     }
      //   }
      // }

      print("Start Initial Building.");

      print("Conditions Loading");
      await Condition.load();
      print("Drugs Loading");
      await Drug.load();
      print("Exercises Loading");
      await Exercise.load();
      print("Quotes Loading");
      await Quote.load();
      await HealthAppState.load();
      await BotAppState.load();
      await AccountAppState.load();
      HomeAppState.load();

      print('Finished Initial Building.');

      dynamic pS = await Data.getUserField('SurveyFeedback');
      if (pS is String) {
        HomeAppState.surveyFeedback = pS;
      }

      setState(() {
        loading = false;
      });
    }();
    if (!HomeAppState.initalBuilt) {
      HomeAppState.initalBuilt = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // () async {
    //   if (HomeAppState.profile == null) {
    //     HomeAppState.profile = await Adapty().getProfile();
    //     dynamic prem = await Data.getUserField('Premium');
    //     if (prem != null && prem is bool) {
    //       HomeAppState.bypassIntendedObstacles = prem;
    //     }
    //   }
    //   for (VitalitasAppState state in HomePage.appStates) {
    //     state.changeDependencies();
    //   }
    // }();
  }

  @override
  void dispose() {
    for (VitalitasAppState state in HomePage.appStates) {
      state.dispose();
    }
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    if (loading ?? true) {
      return LoadingPage();
    }

    List<GButton> gButtons = [];
    for (VitalitasAppState state in HomePage.appStates) {
      gButtons.add(state.getNavButton());
    }

    return Scaffold(
      body: HomePage.appStates[_index].getBody(this),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Vitalitas.theme.acc, boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1))
          ]),
          child: SafeArea(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: GNav(
                    gap: 8,
                    textStyle:
                        const TextStyle(fontFamily: 'Comfort', fontSize: 10),
                    iconSize: 24,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    selectedIndex: _index,
                    rippleColor: Vitalitas.theme.acc!,
                    hoverColor: Vitalitas.theme.acc!,
                    tabBackgroundColor: Vitalitas.theme.acc!,
                    padding: EdgeInsets.all(16),
                    tabs: gButtons,
                    onTabChange: (index) {
                      setState(() {
                        _index = index;
                      });
                    },
                  )))),
    );
  }
}
