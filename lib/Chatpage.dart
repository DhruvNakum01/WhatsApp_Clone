import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wclone/Color/style.dart';
import 'package:wclone/Single_chat_Page.dart';
import 'package:wclone/chat_list_item.dart';
import 'package:wclone/Database/DataStore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wclone/contact_list.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String user = FirebaseAuth.instance.currentUser.uid;

  var data = new DataStore();
  Stream listdata;
  ProgressDialog progress;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _num = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      listdata = FirebaseFirestore.instance
          .collection("UserProfile")
          .doc(user)
          .collection("Message")
          .snapshots();
    });
    super.initState();
  }

  Future<void> _askPermissions(String routeName) async {
    PermissionStatus permissionStatus = await _getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      if (routeName != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ContactListPage()));
      }
    } else {
      _handleInvalidPermissions(permissionStatus);
    }
  }

  Future<PermissionStatus> _getContactPermission() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      PermissionStatus permissionStatus = await Permission.contacts.request();
      return permissionStatus;
    } else {
      return permission;
    }
  }

  void _handleInvalidPermissions(PermissionStatus permissionStatus) {
    if (permissionStatus == PermissionStatus.denied) {
      final snackBar = SnackBar(content: Text('Access to contact data denied'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      final snackBar =
          SnackBar(content: Text('Contact data not available on device'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _myChatList(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          _askPermissions("hello");
        },
        child: Icon(Icons.chat),
      ),
    );
  }

  _addClass(BuildContext context) async {
    progress = ProgressDialog(context, type: ProgressDialogType.Normal);
    progress.style(
      message: "Staring conversation",
    );
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("New Chat"),
            content: SizedBox(
                height: 130.0,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _num,
                        decoration: InputDecoration(labelText: "Phone Number"),
                      )
                    ],
                  ),
                )),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      String code = _num.text;
                      progress.show();
                      data.addnewchat(code);
                      Future.delayed(Duration(seconds: 2)).then((onValue) {
                        progress.update(message: "Initializing Conversation");
                      });
                      Future.delayed(Duration(seconds: 3)).then((onValue) {
                        progress.hide().whenComplete(() {
                          Navigator.of(context).pop();
                        });
                      });
                      _formKey.currentState.reset();
                    }
                  },
                  child: Text("Ok")),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              )
            ],
          );
        });
  }

  Widget _emptyListDisplayMessageWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: greenColor.withOpacity(.5),
            borderRadius: BorderRadius.all(Radius.circular(100)),
          ),
          child: Icon(
            Icons.message,
            color: Colors.white.withOpacity(.6),
            size: 40,
          ),
        ),
        Align(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "Start chat with your friends and family,\n on WhatsApp Clone",
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 14, color: Colors.black.withOpacity(.4)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _myChatList() {
    if (listdata != null) {
      return StreamBuilder(
        stream: listdata,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text("Loading..."));
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data.docs.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SingleChatPage(
                          senderuid: user,
                          sendernum:
                              FirebaseAuth.instance.currentUser.phoneNumber,
                          recivernum: snapshot.data.docs[index].data()['To'],
                          recivername: snapshot.data.docs[index].data()['Name'],
                        ),
                      ));
                },
                child: SingleItemChatUserPage(
                  name: snapshot.data.docs[index].data()["Name"],
                  recentSendMessage:
                      snapshot.data.docs[index].data()["Recentmsg"],
                  time: DateFormat('hh:mm a').format(DateTime.now()),
                ),
              );
            },
          );
        },
      );
    }
  }

  Widget _loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  // Widget _assignment() {
  //   if (assignment != null) {
  //     return StreamBuilder(
  //       stream: assignment,
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) return Center(child: SpinKitChasingDots(color: Colors.brown,));
  //         return ListView.builder(
  //           padding: const EdgeInsets.all(10),
  //           itemCount: snapshot.data.documents.length,
  //           itemBuilder: (BuildContext context, int index) {
  //             return Card(
  //               child: Column(
  //                 children: <Widget>[
  //                   ListTile(
  //                     title: Text("Assignment",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
  //                     subtitle: Text(snapshot.data.documents[index].data['Title']),
  //                   ),
  //                   Align(
  //                     alignment: Alignment.center,
  //                     child: Icon(Icons.picture_as_pdf,size:50.0,color: Colors.grey[500]),
  //                   ),
  //                   Padding(padding: EdgeInsets.only(bottom: 40.0),),
  //                   Container(
  //                     height: 40.0,
  //                     child: RaisedButton(
  //                       onPressed: () async {
  //                         String filepath = "$docs/$className";
  //                         StorageReference store = FirebaseStorage.instance
  //                             .ref()
  //                             .child(filepath)
  //                             .child("Assignments")
  //                             .child("${snapshot.data.documents[index].data['Title']}.pdf");
  //                         String path = await store.getDownloadURL();
  //                         _launchUniversalLinkIos(path.toString());
  //                       },
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: <Widget>[
  //                           Text("Download"),
  //                           Icon(Icons.file_download),
  //                         ],
  //                       ),
  //                     ),
  //                   )
  //                 ],
  //               ),
  //               color: Colors.white70,
  //             );
  //           },
  //         );
  //       },
  //     );
  //   } else {
  //     return Center(child: SpinKitChasingDots(color: Colors.brown));
  //   }
  // }
}
