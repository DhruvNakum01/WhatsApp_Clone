import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneAuth {

  signin(String _verificationCode,String pin) async {
      return await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: pin));
  }


}
