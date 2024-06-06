import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vitalitas/authentification/auth.dart';
import 'package:vitalitas/data/bodybuilding/exercise.dart';
import 'package:vitalitas/data/mayoclinic/conditon.dart';
import 'package:vitalitas/data/mayoclinic/drug.dart';
import 'package:vitalitas/ui/appstate/health.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/ui/auth/landing.dart';
// import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'firebase_options.dart';

import 'package:vitalitas/ui/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
  //   MobileAds.instance.initialize();
  //   Adapty().activate();
  //   Adapty().setLogLevel(AdaptyLogLevel.verbose);
  // }
  runApp(const Vitalitas());
}

class Vitalitas extends StatelessWidget {
  static AppTheme theme = AppTheme();
  const Vitalitas({super.key});
  @override
  Widget build(BuildContext context) {
    theme.bg = Colors.white;
    theme.fg = Colors.red[800];
    theme.acc = Colors.red[200];
    theme.txt = Colors.black;

    Widget page = LandingPage();
    if (Authentification.currentUser != null &&
        Authentification.currentUser!.emailVerified) {
      page = HomePage();
    }
    return MaterialApp(
      title: 'Vitalitas',
      theme: ThemeData(
          fontFamily: 'Comfort',
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              primary: Vitalitas.theme.fg!,
              onPrimary: Vitalitas.theme.fg!,
              secondary: Vitalitas.theme.acc!,
              onSecondary: Vitalitas.theme.acc!,
              error: Vitalitas.theme.acc!,
              onError: Vitalitas.theme.acc!,
              background: Vitalitas.theme.bg!,
              onBackground: Vitalitas.theme.bg!,
              surface: Colors.black12,
              onSurface: Colors.black12)),
      home: page,
    );
  }
}

class AppTheme {
  Color? bg;
  Color? fg;
  Color? acc;
  Color? txt;
}
