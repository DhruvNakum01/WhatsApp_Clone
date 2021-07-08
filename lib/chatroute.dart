import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class chatroute extends StatefulWidget {
  final String num;
  const chatroute({Key key,this.num}):super(key: key);
  @override
  _chatrouteState createState() => _chatrouteState(num);
}

class _chatrouteState extends State<chatroute> {
  String number;

  _chatrouteState(number);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
