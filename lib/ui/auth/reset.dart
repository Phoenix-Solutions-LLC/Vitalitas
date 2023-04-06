import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/auth/auth.dart';
import 'package:vitalitas/ui/auth/login.dart';

class ResetPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ResetPageState();
  }
}

class ResetPageState extends State<ResetPage> {
  TextEditingController controller = TextEditingController();
  Widget sendButton() {
    return InkWell(
        onTap: () {
          Authentification.sendPasswordResetEmail(
              email: controller.text.trim());
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
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
            'Send Password Reset Email',
            style: TextStyle(
                fontSize: 20, fontFamily: 'Comfort', color: Vitalitas.theme.bg),
          ),
        ));
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
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Comfort',
                        fontSize: 15),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                      controller: controller,
                      obscureText: false,
                      cursorColor: Vitalitas.theme.fg,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          fillColor: Color(0xfff3f3f4),
                          filled: true))
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            sendButton()
          ],
        )),
      ),
    );
  }
}
