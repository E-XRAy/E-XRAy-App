import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_xray/CaptureImage.dart';
import 'package:e_xray/SharingPagePat.dart';
import 'package:e_xray/SharingPagerad.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Database.dart';

import 'FullScreenView.dart';
import 'SharingPagedoc.dart';
import 'main.dart';
import 'uploadImage.dart';

// ignore: must_be_immutable
class UserType extends StatefulWidget {
  UserTypes userTypes;
  UserType({this.userTypes, this.user, this.phone, this.email});

  FirebaseUser user;
  String phone;
  String email;
  @override
  _UserTypeState createState() => _UserTypeState(phone: phone, user: user);
}

String userName;

enum UserTypes { doctor, patient, radiologist }

class _UserTypeState extends State<UserType> {
  Future signOut() async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    FirebaseUser user = await firebaseAuth.currentUser();
    firebaseAuth.signOut();
    if (user == null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginRegister()));
    }
  }

  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onPressed() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are You Sure ?'),
            content: Text("Do You Want To Exit App"),
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('No')),
              FlatButton(
                  onPressed: () {
                    exit(0);
                    return true;
                  },
                  child: Text('Yes'))
            ],
          );
        });
  }

  FirebaseUser user;

  _UserTypeState({this.phone, this.user});
  String phone;

  final searchcontrol = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onPressed,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Builder(
            builder: (BuildContext context) => Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Align(
                    child: Padding(
                        child: IconButton(
                            icon: Icon(
                              Icons.account_circle,
                              size: 45,
                            ),
                            onPressed: () {
                              Scaffold.of(context).openEndDrawer();
                            }),
                        padding: EdgeInsets.only(right: 20, top: 28)),
                    alignment: Alignment.topRight,
                  ),
                  Column(
                    children: home(),
                  )
                ],
              ),
            ),
          ),
        ),
        endDrawer: Drawer(
            elevation: 6,
            child: SafeArea(
              child: FutureBuilder(
                  future: Firestore.instance
                      .collection('Users')
                      .document(widget.email)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      String email = snapshot.data["Email"];
                      userName = snapshot.data["Name"];
                      String phone = snapshot.data["Phone"];
                      print(email);
                      print(userName);
                      print(phone);
                      return Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.transparent,
                            child: Image(
                              image: AssetImage('images/avatar.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.09,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 7,
                                        spreadRadius: 0)
                                  ]),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  initialValue: userName,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Name'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 7,
                                        spreadRadius: 0)
                                  ]),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  initialValue: email,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Email'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: 0.1, color: Colors.black),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54,
                                        blurRadius: 7,
                                        spreadRadius: 0)
                                  ]),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: TextFormField(
                                  initialValue: phone,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Phone Number'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: FloatingActionButton.extended(
                              backgroundColor: Colors.blue,
                              label: Text('Log Out'),
                              onPressed: () async {
                                SharedPreferences sharedPreferences =
                                    await SharedPreferences.getInstance();
                                sharedPreferences.clear();
                                signOut();
                              },
                            ),
                          )
                        ],
                      );
                    }
                    return Container();
                  }),
            )),
        bottomNavigationBar:
            widget.userTypes == UserTypes.radiologist ? navBar() : null,
      ),
    );
  }

  List<Widget> home() {
    if (widget.userTypes == UserTypes.doctor) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 50),
            child: Align(
              child: Text(
                'DOCTOR',
                style: TextStyle(fontSize: 30, fontFamily: 'KellySlab'),
              ),
              alignment: Alignment.topLeft,
            ),
          ),
        ),
        Center(
            child: StreamBuilder<UserData>(
                stream: Database(uid: widget.user.uid).userData,
                builder: (context, snapshot) {
                  return Container(
                      height: MediaQuery.of(context).size.height * 0.78,
                      width: MediaQuery.of(context).size.width * 0.99,
                      color: Colors.transparent,
                      child: Center(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance
                                  .collection('Files')
                                  .document(widget.email)
                                  .collection('files')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data.documents.length == 0) {
                                    return Container(
                                      child: Center(
                                        child: Text('No Data'),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount:
                                        snapshot.data.documents.length == null
                                            ? 0
                                            : snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot file =
                                          snapshot.data.documents[index];

                                      return GestureDetector(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          margin: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.7,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black54),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black54,
                                                  blurRadius: 5,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.12,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, bottom: 5),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        file['filename'],
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontFamily:
                                                                'KellySlab'),
                                                      ),
                                                      Text(
                                                          'Patient Name : ${file['PatName'] == null ? '' : file['PatName']}'),
                                                      Text(
                                                          'Radiologist Name : ${file['RadName'] == null ? '' : file['RadName']}')
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.01),
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert),
                                                  itemBuilder: (BuildContext
                                                          context) =>
                                                      <PopupMenuEntry<String>>[
                                                    PopupMenuItem<String>(
                                                        value: 'View',
                                                        child: Text('View')),
                                                    PopupMenuItem<String>(
                                                        value: 'Share',
                                                        child: Text('Share')),
                                                    PopupMenuItem<String>(
                                                        value: 'Delete',
                                                        child: Text('Delete'))
                                                  ],
                                                  onSelected: (selected) {
                                                    if (selected == 'View') {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  FullScreen(
                                                                      url: file[
                                                                          'url'])));
                                                    } else if (selected ==
                                                        'Share') {
                                                      print(file['RadName']);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      SharingPage(
                                                                        filename:
                                                                            file['filename'],
                                                                        filetype:
                                                                            file['filetype'],
                                                                        note: file[
                                                                            'content'],
                                                                        url: file[
                                                                            'url'],
                                                                        dicomUrl:
                                                                            file['DicomUrl'],
                                                                        email: widget
                                                                            .email,
                                                                        phone: widget
                                                                            .phone,
                                                                        patName:
                                                                            file['PatName'],
                                                                        radName:
                                                                            file['RadName'],
                                                                      )));
                                                    } else if (selected ==
                                                        'Delete') {
                                                      Firestore.instance
                                                          .collection('Files')
                                                          .document(
                                                              widget.email)
                                                          .collection('files')
                                                          .document(
                                                              file.documentID)
                                                          .delete();
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Container();
                              })));
                }))
      ];
    } else if (widget.userTypes == UserTypes.patient) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 50),
            child: Align(
              child: Text(
                'PATIENT',
                style: TextStyle(fontSize: 30, fontFamily: 'KellySlab'),
              ),
              alignment: Alignment.topLeft,
            ),
          ),
        ),
        Center(
            child: Container(
          height: MediaQuery.of(context).size.height * 0.78,
          width: MediaQuery.of(context).size.width * 0.99,
          color: Colors.transparent,
          child: Center(
              child: StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('Files')
                      .document(widget.email)
                      .collection('files')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.documents.length == 0) {
                        return Container(
                          child: Center(
                            child: Text('No Data'),
                          ),
                        );
                      }
                      print(snapshot.data.documents.length);
                      return ListView.separated(
                        itemCount: snapshot.data.documents.length == null
                            ? 0
                            : snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          DocumentSnapshot file =
                              snapshot.data.documents[index];
                          return GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    )
                                  ],
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18)),
                              height: MediaQuery.of(context).size.height * 0.12,
                              child: Center(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, bottom: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              file['filename'],
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'KellySlab'),
                                            ),
                                            Text(
                                                'Patient Name : ${file['PatName'] == null ? '' : file['PatName']}'),
                                            Text(
                                                'Radiologist Name : ${file['RadName'] == null ? '' : file['RadName']}')
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.01),
                                      PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert),
                                        itemBuilder: (BuildContext context) =>
                                            <PopupMenuEntry<String>>[
                                          PopupMenuItem<String>(
                                              value: 'View',
                                              child: Text('View')),
                                          PopupMenuItem<String>(
                                              value: 'Share',
                                              child: Text('Share')),
                                          PopupMenuItem<String>(
                                              value: 'Delete',
                                              child: Text('Delete'))
                                        ],
                                        onSelected: (selected) {
                                          if (selected == 'View') {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FullScreen(
                                                          url: file['url'],
                                                        )));
                                          } else if (selected == 'Share') {
                                            print(file['RadName']);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SharingPagePat(
                                                          filename:
                                                              file['filename'],
                                                          filetype:
                                                              file['filetype'],
                                                          note: file['content'],
                                                          url: file['url'],
                                                          dicomUrl:
                                                              file['DicomUrl'],
                                                          email: widget.email,
                                                          phone: widget.phone,
                                                          radName:
                                                              file['RadName'],
                                                          patName:
                                                              file['PatName'],
                                                        )));
                                          } else if (selected == 'Delete') {
                                            Firestore.instance
                                                .collection('Files')
                                                .document(widget.email)
                                                .collection('files')
                                                .document(file.documentID)
                                                .delete();
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          );
                        },
                      );
                    }
                    return Container(
                      child: Center(
                        child: Text('No Data'),
                      ),
                    );
                  })),
        ))
      ];
    } else {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: Padding(
            padding: const EdgeInsets.only(left: 25, top: 50),
            child: Align(
              child: Text(
                'RADIOLOGIST',
                style: TextStyle(fontSize: 30, fontFamily: 'KellySlab'),
              ),
              alignment: Alignment.topLeft,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 0,
          ),
          child: Align(
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImageUpload(
                                  phone: phone,
                                  email: widget.user.email,
                                )));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7,
                              spreadRadius: 0,
                              color: Colors.black54)
                        ]),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '    Upload\n Xray Image',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  BoxShadow(
                                      blurRadius: 1,
                                      spreadRadius: 1,
                                      color: Colors.black)
                                ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.file_upload,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CaptureImage(
                                  phone: phone,
                                  email: widget.user.email,
                                )));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey, width: 0),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 7,
                              spreadRadius: 0,
                              color: Colors.black54)
                        ]),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              '  Scan\n  Image',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  shadows: [
                                    BoxShadow(
                                        color: Colors.black,
                                        blurRadius: 1,
                                        spreadRadius: 1)
                                  ]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.file_upload,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ];
    }
  }

  Widget navBar() {
    return BottomAppBar(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.09,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                icon: Icon(
                  Icons.file_upload,
                  size: 30,
                  color: Colors.teal,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserType(
                                phone: widget.phone,
                                user: widget.user,
                                userTypes: widget.userTypes,
                                email: widget.email,
                              )));
                }),
            IconButton(
                icon: Icon(
                  Icons.filter,
                  size: 30,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RadFiles(
                              phone: widget.phone,
                              user: widget.user,
                              userTypes: widget.userTypes,
                              email: widget.email)));
                }),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class RadFiles extends StatelessWidget {
  final String phone;
  final UserTypes userTypes;
  String email;
  final FirebaseUser user;
  RadFiles({this.email, this.phone, this.user, this.userTypes});

  @override
  Widget build(BuildContext context) {
    String radName;
    Future signOut() async {
      FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      FirebaseUser user = await firebaseAuth.currentUser();
      firebaseAuth.signOut();
      if (user == null) {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginRegister()));
      }
    }

    Future<bool> _onPressed() {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Are You Sure ?'),
              content: Text("Do You Want To Exit App"),
              actions: [
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      exit(0);
                      return true;
                    },
                    child: Text('Yes'))
              ],
            );
          });
    }

    return WillPopScope(
      onWillPop: _onPressed,
      child: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Stack(
            children: [
              Align(
                child: Padding(
                    child: IconButton(
                        icon: Icon(
                          Icons.account_circle,
                          size: 45,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        }),
                    padding: EdgeInsets.only(right: 15, top: 20)),
                alignment: Alignment.topRight,
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                margin: EdgeInsets.only(top: 100),
                height: MediaQuery.of(context).size.height * 0.78,
                width: MediaQuery.of(context).size.width * 0.99,
                color: Colors.transparent,
                child: Center(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance
                            .collection('Files')
                            .document(email)
                            .collection('files')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data.documents.length == 0) {
                              return Container(
                                child: Center(
                                  child: Text('No Data'),
                                ),
                              );
                            }
                            return ListView.separated(
                              itemCount: snapshot.data.documents.length == null
                                  ? 0
                                  : snapshot.data.documents.length,
                              itemBuilder: (context, index) {
                                if (snapshot.data.documents.length == 0) {
                                  return Container(
                                    child: Center(
                                      child: Text('No Data'),
                                    ),
                                  );
                                } else {
                                  DocumentSnapshot file =
                                      snapshot.data.documents[index];
                                  return GestureDetector(
                                    onLongPress: () {},
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.black54),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                            )
                                          ],
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(18)),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.12,
                                      child: Center(
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15, bottom: 5),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      file['filename'],
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'KellySlab'),
                                                    ),
                                                    Text(
                                                        'Patient Name : ${file['PatName'] == null ? '' : file['PatName']}'),
                                                    Text(
                                                        'Radiologist Name : ${file['RadName'] == null ? '' : file['RadName']}')
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.01),
                                              PopupMenuButton<String>(
                                                icon: Icon(Icons.more_vert),
                                                itemBuilder: (BuildContext
                                                        context) =>
                                                    <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                      value: 'View',
                                                      child: Text('View')),
                                                  PopupMenuItem<String>(
                                                      value: 'Share',
                                                      child: Text('Share')),
                                                  PopupMenuItem<String>(
                                                      value: 'Delete',
                                                      child: Text('Delete'))
                                                ],
                                                onSelected: (selected) {
                                                  if (selected == 'View') {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    FullScreen(
                                                                      url: file[
                                                                          'url'],
                                                                    )));
                                                  } else if (selected ==
                                                      'Share') {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                SharingPageRad(
                                                                  filename: file[
                                                                      'filename'],
                                                                  filetype: file[
                                                                      'filetype'],
                                                                  note: file[
                                                                      'content'],
                                                                  url: file[
                                                                      'url'],
                                                                  dicomUrl: file[
                                                                      'DicomUrl'],
                                                                  email: email,
                                                                  phone: phone,
                                                                  radName: file[
                                                                      'RadName'],
                                                                  patName: file[
                                                                      'PatName'],
                                                                )));
                                                  } else if (selected ==
                                                      'Delete') {
                                                    Firestore.instance
                                                        .collection('Files')
                                                        .document(email)
                                                        .collection('files')
                                                        .document(
                                                            file.documentID)
                                                        .delete();
                                                  }
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.03,
                                );
                              },
                            );
                          }
                          return Container(
                            child: Center(
                              child: Text('No Data'),
                            ),
                          );
                        })),
              ),
            ],
          );
        }),
        endDrawer: Drawer(
            elevation: 6,
            child: SafeArea(
              child: SingleChildScrollView(
                child: FutureBuilder(
                    future: Firestore.instance
                        .collection('Users')
                        .document(email)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String email = snapshot.data["Email"];
                        radName = snapshot.data["Name"];
                        String phone = snapshot.data["Phone"];
                        print(email);
                        print(radName);
                        print(phone);
                        return Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.02,
                            ),
                            CircleAvatar(
                              radius: 70,
                              backgroundColor: Colors.transparent,
                              child: Image(
                                image: AssetImage('images/avatar.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.09,
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 0.1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 7,
                                          spreadRadius: 0)
                                    ]),
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                    initialValue: radName,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Name'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 0.1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 7,
                                          spreadRadius: 0)
                                    ]),
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                    initialValue: email,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Email'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        width: 0.1, color: Colors.black),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black54,
                                          blurRadius: 7,
                                          spreadRadius: 0)
                                    ]),
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                    initialValue: phone,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        labelText: 'Phone Number'),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: FloatingActionButton.extended(
                                backgroundColor: Colors.blue,
                                label: Text('Log Out'),
                                onPressed: () async {
                                  signOut();
                                },
                              ),
                            )
                          ],
                        );
                      }
                      return Container();
                    }),
              ),
            )),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: Icon(
                    Icons.file_upload,
                    size: 30,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserType(
                                  phone: phone,
                                  user: user,
                                  userTypes: userTypes,
                                  email: email,
                                )));
                  }),
              IconButton(
                  icon: Icon(
                    Icons.filter,
                    size: 30,
                    color: Colors.teal,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RadFiles(
                                  phone: phone,
                                  user: user,
                                  userTypes: userTypes,
                                  email: email,
                                )));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
