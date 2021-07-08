import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import './Color/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wclone/File_Item.dart';
import 'package:intl/intl.dart';

class SingleChatPage extends StatefulWidget {
  final String senderuid;
  final String sendernum;
  final String recivernum;
  final String recivername;

  const SingleChatPage(
      {Key key,
      this.senderuid,
      this.sendernum,
      this.recivernum,
      this.recivername})
      : super(key: key);
  @override
  _SingleChatPageState createState() =>
      _SingleChatPageState(senderuid, sendernum, recivernum, recivername);
}

class _SingleChatPageState extends State<SingleChatPage> {
  TextEditingController _textMessageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  String senderuid, sendernum, recivernum, docid, reciveruid, recivername;
  Stream msgdata;
  FilePickerResult file;
  FileType type = FileType.custom;

  _SingleChatPageState(
      this.senderuid, this.sendernum, this.recivernum, this.recivername);

  @override
  void initState() {
    _textMessageController.addListener(() {
      setState(() {});
    });
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(senderuid)
        .collection("Message")
        .where("To", isEqualTo: recivernum)
        .get()
        .then((value) => {
              value.docs.forEach((element) {
                setState(() {
                  docid = element.id;
                  msgdata = FirebaseFirestore.instance
                      .collection("UserProfile")
                      .doc(senderuid)
                      .collection("Message")
                      .doc(element.id)
                      .collection("msgcollection")
                      .orderBy("Time")
                      .snapshots();
                });
              })
            });
    FirebaseFirestore.instance
        .collection("UserProfile")
        .where("phone", isEqualTo: recivernum)
        .get()
        .then((value) => value.docs.forEach((element) {
              setState(() {
                reciveruid = element.id;
              });
            }));
    /*FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(reciveruid)
        .collection("Message")
        .add({"To": sendernum, "Recentmsg": " "});*/
    super.initState();
  }

  @override
  void dispose() {
    _textMessageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(""),
          automaticallyImplyLeading: false,
          actions: [
            Icon(Icons.videocam),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.call),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.more_vert),
          ],
          flexibleSpace: Container(
            margin: EdgeInsets.only(top: 30),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 22,
                    )),
                Container(
                  height: 40,
                  width: 40,
                  child: Image.asset('assets/profile_default.png'),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  recivername,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        body: _bodyWidget());
  }

  Widget _bodyWidget() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          child: Image.asset(
            "assets/background_wallpaper.png",
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            _messagesListWidget(),
            _sendMessageTextField(),
          ],
        )
      ],
    );
  }

  Widget _messagesListWidget() {
    Timer(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInQuad,
      );
    });
    return Expanded(
      child: StreamBuilder(
        stream: msgdata,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text("Loading..."));
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final message = 0;

              switch (snapshot.data.docs[index].data()["Type"]) {
                case "Text":
                  {
                    if (senderuid == snapshot.data.docs[index].data()["sid"]) {
                      return _messageLayout(
                        color: Colors.lightGreen[400],
                        time: DateTime.now().toString(),
                        align: TextAlign.left,
                        boxAlign: CrossAxisAlignment.start,
                        crossAlign: CrossAxisAlignment.end,
                        nip: BubbleNip.rightTop,
                        text: snapshot.data.docs[index].data()["msg"],
                      );
                    } else {
                      return _messageLayout(
                        color: Colors.white,
                        time: DateTime.now().toString(),
                        align: TextAlign.left,
                        boxAlign: CrossAxisAlignment.start,
                        crossAlign: CrossAxisAlignment.start,
                        nip: BubbleNip.leftTop,
                        text: snapshot.data.docs[index].data()["msg"],
                      );
                    }

                    break;
                  }
                case "File":
                  {
                    if (senderuid == snapshot.data.docs[index].data()["sid"]) {
                      return FileItem(
                        name: snapshot.data.docs[index].data()["msg"],
                        docid: snapshot.data.docs[index].data()["sid"],
                        check: true,
                      );
                    } else {
                      return FileItem(
                        name: snapshot.data.docs[index].data()["msg"],
                        docid: snapshot.data.docs[index].data()["sid"],
                        check: false,
                      );
                    }
                    break;
                  }
              }
            },
          );
        },
      ),
    );
  }

  Widget _sendMessageTextField() {
    return Container(
      margin: EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(80)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        offset: Offset(0.0, 0.50),
                        spreadRadius: 1,
                        blurRadius: 1),
                  ]),
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.insert_emoticon,
                    color: Colors.grey[500],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 60,
                      ),
                      child: Scrollbar(
                        child: TextField(
                          maxLines: null,
                          style: TextStyle(fontSize: 14),
                          controller: _textMessageController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Type a message",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => showModalBottomSheet(
                            context: context,
                            builder: (context) => _BottomSheet(context)),
                        child: Icon(Icons.link),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      _textMessageController.text.isEmpty
                          ? Icon(Icons.camera_alt)
                          : Text(""),
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: () {
              sendmsg("Text");
            },
            child: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(50),
                ),
              ),
              child: Icon(
                _textMessageController.text.isEmpty ? Icons.mic : Icons.send,
                color: textIconColor,
              ),
            ),
          )
        ],
      ),
    );
  }

  Container _BottomSheet(BuildContext context) {
    return Container(
        height: 150,
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            file = await FilePicker.platform
                .pickFiles(type: type, allowedExtensions: ['pdf']);
            StoreFile(
                "File", File(file.files.single.path), file.files.first.name);
          },
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(child: Icon(Icons.folder_rounded)),
              Text("File Manager")
            ],
          )),
        ));
  }

  Widget _messageLayout({
    text,
    time,
    color,
    align,
    boxAlign,
    nip,
    crossAlign,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.90,
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(3),
            child: Bubble(
              color: color,
              nip: nip,
              child: Column(
                crossAxisAlignment: crossAlign,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    text,
                    textAlign: align,
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    time,
                    textAlign: align,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(
                        .4,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void sendmsg(String Type) {
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(senderuid)
        .collection("Message")
        .doc(docid)
        .collection("msgcollection")
        .add({
      'msg': _textMessageController.text.toString(),
      'sid': senderuid,
      "Time": DateTime.now().millisecondsSinceEpoch,
      "Type": Type
    });
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(reciveruid)
        .collection("Message")
        .where("To", isEqualTo: sendernum)
        .get()
        .then((value) => value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("UserProfile")
                  .doc(reciveruid)
                  .collection("Message")
                  .doc(element.id)
                  .collection("msgcollection")
                  .add({
                'msg': _textMessageController.text.toString(),
                'sid': senderuid,
                "Time": DateTime.now().millisecondsSinceEpoch,
                "Type": Type
              });
              _textMessageController.clear();
            }));
  }

  void StoreFile(String Type, File file, String Name) async {
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(senderuid)
        .collection("Message")
        .doc(docid)
        .collection("msgcollection")
        .add({
      'msg': Name,
      'sid': senderuid,
      "Time": DateTime.now().millisecondsSinceEpoch,
      "Type": Type,
      "Url": file.toString()
    });
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(reciveruid)
        .collection("Message")
        .where("To", isEqualTo: sendernum)
        .get()
        .then((value) => value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("UserProfile")
                  .doc(reciveruid)
                  .collection("Message")
                  .doc(element.id)
                  .collection("msgcollection")
                  .add({
                'msg': Name,
                'sid': senderuid,
                "Time": DateTime.now().millisecondsSinceEpoch,
                "Type": Type,
                "Url": file.toString()
              });
              _textMessageController.clear();
            }));

    await FirebaseStorage.instance.ref("$senderuid/$Name").putFile(file);
  }
}
