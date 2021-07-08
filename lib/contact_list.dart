import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wclone/Single_chat_Page.dart';
import 'package:wclone/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:intl/intl.dart';

class ContactListPage extends StatefulWidget {
  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  List<Contact> _contacts;
  String currentname;

  @override
  void initState() {
    super.initState();
    refreshContacts();
    FirebaseFirestore.instance
        .collection("UserProfile")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      setState(() {
        currentname = value.get("Name").toString();
      });
    });
  }

  Future<void> refreshContacts() async {
    // Load without thumbnails initially.
    var contacts =
        (await ContactsService.getContacts(withThumbnails: false)).toList();
//      var contacts = (await ContactsService.getContactsForPhone("8554964652"))
//          .toList();
    setState(() {
      _contacts = contacts;
    });

    // Lazy load thumbnails after rendering initial contacts.
    for (final contact in contacts) {
      ContactsService.getAvatar(contact).then((avatar) {
        if (avatar == null) return; // Don't redraw if no change.
        setState(() => contact.avatar = avatar);
      });
    }
  }

  void updateContact() async {
    Contact ninja = _contacts
        .toList()
        .firstWhere((contact) => contact.familyName.startsWith("Ninja"));
    ninja.avatar = null;
    await ContactsService.updateContact(ninja);

    refreshContacts();
  }

  _openContactForm() async {
    try {
      var contact = await ContactsService.openContactForm();
      refreshContacts();
    } on FormOperationException catch (e) {
      switch (e.errorCode) {
        case FormOperationErrorCode.FORM_OPERATION_CANCELED:
        case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
        case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
        default:
          print(e.errorCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contacts Plugin Example',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.create),
            onPressed: _openContactForm,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed("/add").then((_) {
            refreshContacts();
          });
        },
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts?.elementAt(index);
                  return ListTile(
                    onTap: () {
                      setchat(c.phones.first.value, c.displayName);
                    },
                    leading: (c.avatar != null && c.avatar.length > 0)
                        ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                        : CircleAvatar(child: Text(c.initials())),
                    title: Text(c.displayName ?? ""),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  void contactOnDeviceHasBeenUpdated(Contact contact) {
    this.setState(() {
      var id = _contacts.indexWhere((c) => c.identifier == contact.identifier);
      _contacts[id] = contact;
    });
  }

  void setchat(String num, String name) {
    FirebaseFirestore.instance
        .collection("UserProfile")
        .where("phone", isEqualTo: "+91" + num)
        .get()
        .then((value) => value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("UserProfile")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .collection("Message")
                  .add({"To": "+91" + num, "Name": name, "Recentmsg": " "});
            }));
    FirebaseFirestore.instance
        .collection("UserProfile")
        .where("phone", isEqualTo: "+91" + num)
        .get()
        .then((value) => value.docs.forEach((element) {
              FirebaseFirestore.instance
                  .collection("UserProfile")
                  .doc(element.id)
                  .collection("Message")
                  .add({
                "To": FirebaseAuth.instance.currentUser.phoneNumber,
                "Name": currentname,
                "Recentmsg": " "
              });
            }));
    FirebaseFirestore.instance
        .collection("UserProfile")
        .where("phone", isEqualTo: "+91" + num)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SingleChatPage(
                    senderuid: FirebaseAuth.instance.currentUser.uid,
                    sendernum: FirebaseAuth.instance.currentUser.phoneNumber,
                    recivernum: "+91" + num,
                    recivername: name)));
      }
    });
  }
}
