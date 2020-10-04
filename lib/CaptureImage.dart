import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './Database.dart';
import './UserTypeHome.dart';

import 'Loading.dart';

// ignore: must_be_immutable
class CaptureImage extends StatefulWidget {
  String phone;
  String email;
  CaptureImage({this.phone, this.email});
  @override
  _CaptureImageState createState() => _CaptureImageState();
}

class _CaptureImageState extends State<CaptureImage> {
  final noteController = TextEditingController();
  final patController = TextEditingController();
  final radController = TextEditingController();
  bool loading = false;
  File sampleImage;
  String note;
  String url;
  final formKey = GlobalKey<FormState>();
  bool uploadingPage = false;
  @override
  // ignore: override_on_non_overriding_member
  void captureImage() async {
    // ignore: deprecated_member_use
    var tempImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      sampleImage = tempImage;
    });
  }

  final nameController = TextEditingController();

  uploadImages() async {
    if (validateAndSave()) {
      try {
        final StorageReference imageRef =
            FirebaseStorage.instance.ref().child('Uploaded Images');
        var timeKey = DateTime.now();
        final StorageUploadTask uploadTask =
            imageRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);
        var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
        url = imageUrl.toString();
        final patName = patController.text;
        final radName = radController.text;
        await Database(uid: widget.email).savefileToDatabase(
            selected,
            '${nameController.text}',
            url,
            noteController.text,
            null,
            patName,
            radName);
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
        Timer(Duration(seconds: 2), () {
          return showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  content: Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Center(
                      child: Text('Upload Completed'),
                    ),
                  ),
                );
              });
        });
        setState(() {
          loading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserType(
                      user: user,
                      userTypes: UserTypes.radiologist,
                      phone: widget.phone,
                      email: widget.email,
                    )));
      } catch (e) {
        return showDialog(
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
    }
  }

  String selected;
  List types = ['Xray', 'MRI', 'UltraSound'];

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Center(
              child: sampleImage == null
                  ? FloatingActionButton.extended(
                      heroTag: '9',
                      label: Text('Open Camera'),
                      onPressed: captureImage,
                    )
                  : enableUpload(),
            ),
          );
  }

  Widget enableUpload() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0.1, color: Colors.black),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 7,
                            spreadRadius: 0)
                      ]),
                  child: loading
                      ? Loading()
                      : Image.file(
                          sampleImage,
                          height: 300,
                          width: 400,
                        ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          spreadRadius: 1,
                        )
                      ],
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
                    child: TextFormField(
                      autofocus: false,
                      validator: (val) {
                        return val.isEmpty ? 'fileName Required' : null;
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black),
                          fillColor: Colors.white,
                          labelStyle: TextStyle(color: Colors.black),
                          labelText: 'FileName',
                          hintText: "FileName"),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0.1, color: Colors.black),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 7,
                            spreadRadius: 0)
                      ]),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: TextFormField(
                            controller: patController,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                                hintText: 'Enter Patient Name',
                                hintStyle: TextStyle(fontSize: 19),
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0.1, color: Colors.black),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 7,
                            spreadRadius: 0)
                      ]),
                  child: Center(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: TextFormField(
                            controller: radController,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                                hintText: 'Enter Your Name',
                                hintStyle: TextStyle(fontSize: 19),
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          spreadRadius: 1,
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                    child: DropdownButton(
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down),
                        iconSize: 35,
                        hint: Text("Select Type"),
                        isExpanded: true,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        items: types.map((value) {
                          return DropdownMenuItem(
                              value: value, child: Text(value));
                        }).toList(),
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            selected = value;
                          });
                        }),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(width: 0.1, color: Colors.black),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black54,
                            blurRadius: 7,
                            spreadRadius: 0)
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: noteController,
                      decoration: InputDecoration(
                          border: InputBorder.none, labelText: 'Notes'),
                      onSaved: (value) {
                        return note = value;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.36,
                  child: FloatingActionButton.extended(
                    heroTag: '11',
                    label: Text('Upload'),
                    elevation: 10.0,
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      await uploadImages();
                      setState(() {
                        loading = false;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
