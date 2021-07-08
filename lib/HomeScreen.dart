import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wclone/Chatpage.dart';
import 'package:wclone/Widget/Status_page.dart';
import 'package:wclone/Widget/custom_tab_bar.dart';
import 'package:wclone/Color/style.dart';
import 'package:wclone/Single_chat_Page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearch = false;

  _buildSearch() {
    return Container(
      height: 45,
      margin: EdgeInsets.only(top: 25),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(.3),
            spreadRadius: 1,
            offset: Offset(0.0, 0.50))
      ]),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          prefixIcon: InkWell(
            onTap: () {
              //TODO:
              setState(() {
                _isSearch = false;
              });
            },
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          automaticallyImplyLeading: false,
          backgroundColor:
              _isSearch == false ? primaryColor : Colors.transparent,
          title: _isSearch == false
              ? Text("WhatsApp Clone")
              : Container(
                  height: 0.0,
                  width: 0.0,
                ),
          flexibleSpace: _isSearch == false
              ? Container(
                  height: 0.0,
                  width: 0.0,
                )
              : _buildSearch(),
          actions: <Widget>[
            InkWell(
              onTap: () {},
              child: Image.asset("assets/color_wheel_48px.png"),
            ),
            InkWell(
                onTap: () {
                  setState(() {
                    _isSearch = true;
                  });
                },
                child: Icon(Icons.search)),
            SizedBox(
              width: 5,
            ),
            InkWell(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                },
                child: Icon(Icons.more_vert))
          ],
          bottom: TabBar(tabs: <Widget>[
            Tab(
              text: "CHAT",
            ),
            Tab(
              text: "Status",
            ),
            Tab(
              text: "Call",
            ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            ChatPage(),
            StatusPage(),
            Center(
              child: Text("Call"),
            ),
          ],
        ),
      ),
    );
  }
}
