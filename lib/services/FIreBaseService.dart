import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Firebaseservice {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference parcels = FirebaseFirestore.instance.collection('Parcels');
  String? verificationId; // зберігається глобально або в state

  Future<QuerySnapshot<Object?>> getParcels(String phone) async {
   try {
    QuerySnapshot snapshot = await parcels.where('phone', isEqualTo: phone).get();
    print("Snapshot data: ${snapshot.docs}");
    return snapshot;
  } catch (e) {
    print("Error getting parcels: $e");
    return Future.error("Error getting parcels");
  }
  }

  void sendSMS(String phoneNumber) async {
  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("✅ Автовхід");
    },
    verificationFailed: (FirebaseAuthException e) {
      print("❌ Помилка: ${e.message}");
    },
    codeSent: (String verificationId, int? resendToken) {
      print("📩 Код надіслано. verificationId: $verificationId");
    },
    codeAutoRetrievalTimeout: (String verificationId) {
      print("⌛ Тайм-аут");
    },
  );
}
}