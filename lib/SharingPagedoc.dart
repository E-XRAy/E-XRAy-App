import 'package:flutter/material.dart';

import 'Database.dart';
import 'FullScreenView.dart';

// ignore: must_be_immutable
class SharingPage extends StatefulWidget {
  String filename;
  String filetype;
  String phone;
  String note;
  String url;
  String dicomUrl;
  String radName;
  String patName;
  String userType;
  String email;
  SharingPage(
      {this.filename,
      this.filetype,
      this.phone,
      this.url,
      this.email,
      this.note,
      this.dicomUrl,
      this.patName,
      this.radName,
      this.userType});
  @override
  _SharingPageState createState() => _SharingPageState();
}

class _SharingPageState extends State<SharingPage> {
  final recieveridController = TextEditingController();
  final noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.black26, Colors.black45, Colors.black],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          )),
          child: Column(
            children: input() + button(),
          ),
        ),
      ),
    );
  }

  List<Widget> input() {
    return [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.1,
      ),
      Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.1, color: Colors.black),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 7, spreadRadius: 0)
            ]),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
                width: MediaQuery.of(context).size.width * 0.6,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextFormField(
                      autofocus: false,
                      controller: recieveridController,
                      style: TextStyle(fontSize: 20),
                      decoration: InputDecoration(
                          hintText: 'Enter email ',
                          hintStyle: TextStyle(fontSize: 19),
                          border: InputBorder.none),
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.search,
                size: 30,
              ),
            ],
          ),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
      ),
      GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FullScreen(
                        url: widget.url,
                      )));
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 0.1, color: Colors.black),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black54, blurRadius: 7, spreadRadius: 0)
              ]),
          child: Center(
            child: Center(
              child: widget.url != null
                  ? Image(
                      image: NetworkImage(widget.url),
                      fit: BoxFit.fitWidth,
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: MediaQuery.of(context).size.width * 0.9,
                    )
                  : Text(widget.filename),
            ),
          ),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
      ),
      Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.1, color: Colors.black),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 7, spreadRadius: 0)
            ]),
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 2),
                child: TextFormField(
                  initialValue:
                      widget.note == null ? ' Add Note ' : widget.note,
                  maxLength: 100,
                  maxLines: 5,
                  controller: noteController,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                      hintText: ' Add Note ',
                      hintStyle: TextStyle(fontSize: 19),
                      border: InputBorder.none),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> button() {
    return [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
      ),
      Padding(
        padding: const EdgeInsets.only(right: 40),
        child: Align(
          alignment: Alignment.bottomRight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.37,
            child: FloatingActionButton.extended(
                heroTag: '3',
                backgroundColor: Colors.black54,
                onPressed: () async {
                  final recieverId = recieveridController.text.trim();
                  final content = noteController.text;
                  final phone = widget.phone;
                  try {
                    print(phone);
                    print(recieverId);
                    if (recieverId != widget.email) {
                      await Database().sentFile(
                          recieverId,
                          widget.filename,
                          widget.filetype,
                          content == '' ? widget.note : content,
                          widget.url,
                          widget.dicomUrl,
                          widget.patName,
                          widget.radName);
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            content: Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: Center(
                                child: Text(e.toString()),
                              ),
                            ),
                          );
                        });
                  }
                },
                label: Text('Share')),
          ),
        ),
      )
    ];
  }
}
