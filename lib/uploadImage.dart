import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import './Database.dart';
import './UserTypeHome.dart';

import 'Loading.dart';

// ignore: must_be_immutable
class ImageUpload extends StatefulWidget {
  String phone;
  String email;
  ImageUpload({this.phone, this.email});
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final noteController = TextEditingController();
  bool loading = false;
  File sampleImage;
  String note;
  String url;
  final formKey = GlobalKey<FormState>();
  bool uploadingPage = false;
  @override
  // ignore: override_on_non_overriding_member
  Future getImage() async {
    // ignore: deprecated_member_use
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

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
        await Database(uid: widget.email).savefileToDatabase(
            'jpg', '${timeKey.toString()} .jpg', url, noteController.text);
        FirebaseUser user = await FirebaseAuth.instance.currentUser();
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
              child:
                  sampleImage == null ? Text('upload Image') : enableUpload(),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: getImage,
            ));
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(
                height: 70,
              ),
              Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 0.1, color: Colors.black),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black54, blurRadius: 7, spreadRadius: 0)
                    ]),
                child: loading
                    ? Loading()
                    : Image.file(
                        sampleImage,
                        height: 400,
                        width: 400,
                      ),
              ),
              SizedBox(
                height: 40,
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
                          color: Colors.black54, blurRadius: 7, spreadRadius: 0)
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
              FloatingActionButton.extended(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
