import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wclone/registration_screen.dart';
import 'package:wclone/HomeScreen.dart';
import 'package:wclone/Database/phoneauth.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  var user = new PhoneAuth();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Welcome to WhatsApp Clone",
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(76, 175, 80, 1),
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              height: 290,
              width: 290,
              child: Image.asset("assets/brand.png"),
            ),
            Column(
              children: <Widget>[
                Text(
                  "Read our Privacy Policy Tap, 'Agree and continue' to accept the Terms of Service",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 30,
                ),
                MaterialButton(
                  color: Color.fromRGBO(76, 175, 80, 1),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegistrationScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "AGREE AND CONTINUE",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
