import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/authentification/auth.dart';

class VerifyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return VerifyPageState();
  }
}

class VerifyPageState extends State<VerifyPage> {
  bool verified = false;
  Timer? verificationTimer;

  Widget resendButton() {
    return InkWell(
        onTap: () {
          if (Authentification.currentUser != null) {
            Authentification.currentUser!.sendEmailVerification();
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Vitalitas.theme.fg, Vitalitas.theme.acc],
                  stops: [0.1, 0.9])),
          child: Text(
            'Resend Verification',
            style: TextStyle(
                fontSize: 20, fontFamily: 'Comfort', color: Vitalitas.theme.bg),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    if (Authentification.currentUser != null) {
      verified = Authentification.currentUser!.emailVerified;
      if (!verified) {
        Authentification.currentUser!.sendEmailVerification();

        verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
          await Authentification.currentUser!.reload();

          verified = Authentification.currentUser!.emailVerified;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePage.load()));

          if (verified) {
            timer.cancel();
          }
        });
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage.load()));
      }
    }
  }

  @override
  void dispose() {
    verificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(top: 50),
              width: 200,
              height: 120,
              child: Image.asset('assets/resources/heart.png'),
            ),
            SizedBox(
              height: 50,
            ),
            resendButton()
          ],
        )),
      ),
    );
  }
}
