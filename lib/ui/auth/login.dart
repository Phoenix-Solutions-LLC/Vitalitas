import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitalitas/breakpoint.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/ui/appstate/home.dart';
import 'package:vitalitas/auth/auth.dart';
import 'package:vitalitas/ui/auth/register.dart';
import 'package:vitalitas/ui/auth/verify.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  Map<String, TextEditingController> fields = new Map();

  Widget entryField(String title, {bool isPassword = false}) {
    TextEditingController controller = TextEditingController();
    fields[title] = controller;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
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
              obscureText: isPassword,
              cursorColor: Vitalitas.theme.fg,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget submitButton() {
    return InkWell(
        onTap: () {
          Authentification.signIn(
                  email: fields['Email']!.text.trim(),
                  password: fields['Password']!.text.trim())
              .then((value) {
            if (Authentification.currentUser != null) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => VerifyPage()));
            }
          });
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
            'Login',
            style: TextStyle(
                fontSize: 20, fontFamily: 'Comfort', color: Vitalitas.theme.bg),
          ),
        ));
  }

  Widget divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget googleButton({required BuildContext context}) {
    return InkWell(
        onTap: () {
          Authentification.signInWithGoogle(context: context).then((value) => {
                if (Authentification.currentUser != null)
                  {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomePage()))
                  }
              });
        },
        child: Container(
          height: 50,
          margin: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        topLeft: Radius.circular(5)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.login_outlined),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xff2872ba),
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(5),
                        topRight: Radius.circular(5)),
                  ),
                  alignment: Alignment.center,
                  child: Text('Log in with Google',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w400)),
                ),
              ),
            ],
          ),
        ));
  }

  Widget createAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account?',
              style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Comfort',
                  color: Vitalitas.theme.txt,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Register',
              style: TextStyle(
                  color: Vitalitas.theme.fg,
                  fontSize: 13,
                  fontFamily: 'Comfort',
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
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
            SizedBox(height: 50),
            Column(
              children: [
                entryField("Email"),
                entryField("Password", isPassword: true),
              ],
            ),
            SizedBox(height: 20),
            submitButton(),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerRight,
              child: Text('Forgot Password ?',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Comfort',
                      color: Vitalitas.theme.fg,
                      fontWeight: FontWeight.w500)),
            ),
            divider(),
            googleButton(context: context),
            createAccountLabel(),
          ],
        )),
      ),
    );
  }
}
