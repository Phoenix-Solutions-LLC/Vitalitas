import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentification {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static User? get currentUser => auth.currentUser;

  static Stream<User?> get authStateChanges => auth.authStateChanges();

  static Future<void> signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (authException) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Column(
            children: [
              Text(authException.message!),
            ],
          ),
          actions: [
            CupertinoButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      );
    } catch (e) {
      debugPrint('SignIn for ${e.toString()}');
    }
  }

  static Future<void> create(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (authException) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Column(
            children: [
              Text(authException.message!),
            ],
          ),
          actions: [
            CupertinoButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        ),
      );
    } catch (e) {
      debugPrint('SignIn for ${e.toString()}');
    }
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> signInWithGoogle({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        await auth.signInWithCredential(credential);
      } on FirebaseAuthException catch (authException) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Column(
              children: [
                Text(authException.message!),
              ],
            ),
            actions: [
              CupertinoButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
            ],
          ),
        );
      } catch (e) {
        debugPrint('SignIn for ${e.toString()}');
      }
    }
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }
}
