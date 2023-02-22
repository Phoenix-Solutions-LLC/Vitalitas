import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitalitas/auth/auth.dart';

class Data {
  static final FirebaseFirestore store = FirebaseFirestore.instance;

  static Future<DocumentReference<Object?>?> currentUserDoc() async {
    CollectionReference users = store.collection('Users');
    DocumentReference doc = users.doc(Authentification.currentUser!.uid);
    DocumentSnapshot snapshot = await doc.get();
    if (snapshot == null || !snapshot.exists) {
      await doc.set({
        'Username': Authentification.currentUser!.displayName,
        'Email': Authentification.currentUser!.email,
      });
    }
    return doc;
  }

  static Future<dynamic> getUserField(String field) async {
    DocumentReference? doc = await currentUserDoc();
    DocumentSnapshot snapshot = await doc!.get();
    Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;
    if (currentData.containsKey(field)) {
      return currentData[field];
    } else {
      return null;
    }
  }

  static void setUserField(String field, dynamic value) async {
    DocumentReference? doc = await currentUserDoc();
    DocumentSnapshot snapshot = await doc!.get();
    Map<String, dynamic> currentData = snapshot.data() as Map<String, dynamic>;
    currentData[field] = value;
    doc.set(currentData);
  }
}
