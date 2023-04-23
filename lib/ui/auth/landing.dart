import 'package:flutter/material.dart';
import 'package:vitalitas/authentification/auth.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/ui/auth/login.dart';
import 'package:vitalitas/ui/auth/register.dart';
import 'package:vitalitas/ui/auth/verify.dart';

class LandingPage extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Vitalitas.theme.fg, Vitalitas.theme.acc],
                stops: [0.1, 0.9])),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.white),
                child: Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Comfort',
                      color: Vitalitas.theme.fg),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 13),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border.all(color: Vitalitas.theme.bg, width: 2),
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Comfort',
                      color: Vitalitas.theme.bg),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
