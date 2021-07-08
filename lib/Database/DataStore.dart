import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class DataStore {

  FirebaseFirestore db = FirebaseFirestore.instance;
  String user = FirebaseAuth.instance.currentUser.uid;
  String phone = FirebaseAuth.instance.currentUser.phoneNumber;

  Future<void> setuserprofile(String username)
  async {

   return await db.collection("UserProfile").doc(user).set({ "Name" : username , "phone" : phone});

  }
  addnewchat(String number){

    db
        .collection("UserProfile")
        .where("phone", isEqualTo: number)
        .get()
        .then((value) => value.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection("UserProfile")
          .doc(element.id)
          .collection("Message")
          .add({"To": phone, "Recentmsg": " "});
    }));
    db.collection("UserProfile").doc(user)
    .collection("Message").add(({"To":number , "Recentmsg": " " }));
  }

  getlist(String senderuid)
  async {
    return db.collection("UserProfile").doc(senderuid).collection("Message").snapshots();

  }



  Future<void> getmymsg(String senderuid , String recivernum)
  async {
    return await db.collection("UserProfile").doc(senderuid).collection("Message").where("To" == recivernum);
  }

  addAssignment(
      String recivernum,String docid, String reciveruid,String title, File fileUrl, docId, context) async {

    db
        .collection("UserProfile")
        .doc(user)
        .collection("Message")
        .doc(docid)
        .collection("msgcollection")
        .add({'Title': title, 'sid': user , "Time":DateTime.now().millisecondsSinceEpoch});
   db
        .collection("UserProfile")
        .doc(recivernum)
        .collection("Message")
        .where("To", isEqualTo: phone)
        .get()
        .then((value) => value.docs.forEach((element) {
      FirebaseFirestore.instance
          .collection("UserProfile")
          .doc(reciveruid)
          .collection("Message")
          .doc(element.id)
          .collection("msgcollection")
          .add({
        'Title': title,
        'sid': user,
        "Time":DateTime.now().millisecondsSinceEpoch
      });
    }));

      // String filepath = "$uid/$className";
      // StorageReference store = FirebaseStorage.instance
      //     .ref()
      //     .child(filepath)
      //     .child("Assignments")
      //     .child("$title.pdf");
      // StorageUploadTask task = store.putFile(fileUrl);
      // Firestore.instance
      //     .collection("Classes")
      //     .where("ClassName", isEqualTo: className)
      //     .getDocuments()
      //     .then((doc) {
      //   Firestore.instance
      //       .document("Classes/${doc.documents[0].documentID}")
      //       .collection("Assignments")
      //       .document()
      //       .setData({"Title": title, "Assignment-url": fileUrl.toString()});
      // });
  }




}