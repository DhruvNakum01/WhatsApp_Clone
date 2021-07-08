import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wclone/Color/style.dart';
import 'package:wclone/Single_Story_Page.dart';
import 'package:wclone/Widget/store_page_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  FilePickerResult file;
  FileType type = FileType.custom;

  String user = FirebaseAuth.instance.currentUser.uid;
  String check;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(user)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        setState(() {
          check = snapshot.get("Story").toString();
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _customFloatingActionButton(),
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _storyWidget(context),
                SizedBox(
                  height: 8,
                ),
                _recentTextWidget(),
                SizedBox(
                  height: 8,
                ),
                _listStories(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _customFloatingActionButton() {
    return Positioned(
      right: 10,
      bottom: 15,
      child: Column(
        children: <Widget>[
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 4.0),
                    blurRadius: 0.50,
                    color: Colors.black.withOpacity(.2),
                    spreadRadius: 0.10)
              ],
            ),
            child: Icon(
              Icons.edit,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          GestureDetector(
            onTap: () async {},
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 4.0),
                      blurRadius: 0.50,
                      color: Colors.black.withOpacity(.2),
                      spreadRadius: 0.10)
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _storyWidget(BuildContext ctx) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 4),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              if (check == "false") {
                file = await FilePicker.platform
                    .pickFiles(type: type, allowedExtensions: ['jpg', 'png']);
                storeimage(File(file.files.first.path), file.files.first.name);
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => StoryViewPage()));
              }
            },
            child: Container(
              height: 55,
              width: 55,
              child: Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Image.asset("assets/profile_default.png"),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "My Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                "Tap to add status update",
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _recentTextWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Text("Recent updates"),
    );
  }

  Widget _listStories() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return SingleItemStoryPage();
      },
    );
  }

  void storeimage(File data, String name) async {
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(user)
        .collection("Story")
        .add({"Name": name, "Type": "Image"});

    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(user)
        .update({"Story": "True"});

    await FirebaseStorage.instance.ref("$user/Story/$name").putFile(data);
  }
}
