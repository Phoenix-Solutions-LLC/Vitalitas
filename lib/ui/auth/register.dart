import 'package:flutter/material.dart';
import 'package:vitalitas/main.dart';
import 'package:vitalitas/auth/auth.dart';
import 'package:vitalitas/ui/auth/login.dart';
import 'package:vitalitas/ui/auth/verify.dart';

class RegisterPage extends StatefulWidget {
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  Map<String, TextEditingController> fields = new Map();

  Widget entryField(String title, {bool isPassword = false}) {
    TextEditingController controller = TextEditingController();
    fields[title] = controller;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
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
          Authentification.create(
                  email: fields['Email']!.text.trim(),
                  password: fields['Password']!.text.trim())
              .then((value) {
            if (Authentification.currentUser != null) {
              Authentification.currentUser!
                  .updateDisplayName(fields['Username']!.text.trim());
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
            'Register',
            style: TextStyle(
                fontSize: 20, fontFamily: 'Comfort', color: Vitalitas.theme.bg),
          ),
        ));
  }

  Widget loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account?',
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
              'Login',
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

  Widget emailPasswordWidget() {
    return Column(
      children: [
        entryField("Username"),
        entryField("Email"),
        entryField("Password", isPassword: true),
      ],
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
            SizedBox(
              height: 50,
            ),
            emailPasswordWidget(),
            SizedBox(
              height: 20,
            ),
            submitButton(),
            loginAccountLabel(),
          ],
        )),
      ),
    );
  }
}
