import 'dart:io';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class FileItem extends StatelessWidget {
  final String name;
  final String docid;
  final bool check;

  const FileItem({Key key, this.name, this.docid, this.check})
      : super(key: key);

  Future<void> _launchUniversalLinkIos(String url) async {
    if (await canLaunch(url)) {
      final bool nativeAppLaunchSucceeded = await launch(
        url,
        forceSafariVC: false,
        universalLinksOnly: true,
      );
      if (!nativeAppLaunchSucceeded) {
        await launch(url, forceSafariVC: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: Column(
        children: [
          Row(
            children: [
              Card(
                  color: Colors.green,
                  child: Center(
                    child: Row(
                      children: [
                        Padding(padding: EdgeInsets.all(20)),
                        Icon(Icons.file_present),
                        Padding(padding: EdgeInsets.only(right: 10)),
                        Container(
                          child: Text(name),
                        ),
                        if (!check)
                          IconButton(
                            icon: Icon(Icons.download_rounded),
                            onPressed: () async {
                              String data = await firebase_storage
                                  .FirebaseStorage.instance
                                  .ref('$docid/$name')
                                  .getDownloadURL();
                              _launchUniversalLinkIos(data.toString());
                            },
                            alignment: Alignment.center,
                          ),
                        Padding(padding: EdgeInsets.only(right: 15))
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                    ),
                  )),
            ],
            mainAxisAlignment:
                check ? MainAxisAlignment.end : MainAxisAlignment.start,
          ),
        ],
      ),
    );
  }
}
