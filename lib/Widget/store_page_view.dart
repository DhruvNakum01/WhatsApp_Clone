import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class StoryViewPage extends StatefulWidget {
  @override
  _StoryViewPageState createState() => _StoryViewPageState();
}

class _StoryViewPageState extends State<StoryViewPage> {
  final _storyController = StoryController();

  String user = FirebaseAuth.instance.currentUser.uid;
  String check;
  String name, data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(user)
        .collection("Story")
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                setState(() {
                  name = element.get("Name");
                });
              })
            });
    getimage().then((value) => {
          setState(() {
            data = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    final controller = StoryController();
    final List<StoryItem> storyItems = [
      StoryItem.pageImage(url: data, controller: _storyController),
    ];
    return Material(
      child: StoryView(
        storyItems: storyItems,
        controller: controller,
        inline: false,
        repeat: true,
      ),
    );
  }

  Future<String> getimage() async {
    return await firebase_storage.FirebaseStorage.instance
        .ref('$user/Story/$name')
        .getDownloadURL();
  }
}
