import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Database {
  final String uid;
  Database({this.uid});

  CollectionReference fileCollection = Firestore.instance.collection('Files');

  CollectionReference userCollection = Firestore.instance.collection('Users');
  saveToDatabase(String name, String email, String phone, String userType,
      String userId) async {
    return await userCollection.document(uid).setData({
      'Name': name,
      'userId': userId,
      'Email': email,
      'Phone': phone,
      'UserType': userType
    });
  }

  savefileToDatabase(String filetype, String filename, String url, String note,
      String dicomUrl, String patName, String radName) async {
    return await fileCollection.document(uid).collection('files').add({
      'filename': filename,
      'filetype': filetype,
      'url': url,
      'content': note,
      'DicomUrl': dicomUrl,
      'RadName': radName,
      'PatName': patName
    });
  }

  //for senting file
  sentFile(String recieverId, String filename, String filetype, String content,
      String url, String dicomUrl, String patName, String radName) async {
    return await fileCollection.document(recieverId).collection('files').add({
      'filename': filename,
      'fileType': filetype,
      'content': content,
      'url': url,
      'DicomUrl': dicomUrl,
      'PatName': patName,
      'RadName': radName
    });
  }

  //for getting current user id
  currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  // to stream user details
  Stream<UserData> get userData {
    return userCollection.document(uid).snapshots().map(userDataFromSnapshots);
  }

  //for streaming files
  Stream<List<Files>> get files {
    return Firestore.instance
        .collection('Files')
        .document(uid)
        .collection('files')
        .snapshots()
        .map(fileSnapshots);
  }

  List<Files> fileSnapshots(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Files(
        filename: doc.data['filename'],
        filetype: doc.data['filetype'],
        url: doc.data['url'],
        note: doc.data['content'] == null ? null : doc.data['content'],
        dicomUrl: doc.data['DicomUrl'] == null ? null : doc.data['DicomUrl'],
        patName: doc.data['PatName'] == null ? null : doc.data['PatName'],
        radName: doc.data['RadName'] == null ? null : doc.data['RadName'],
      );
    }).toList();
  }

  UserData userDataFromSnapshots(DocumentSnapshot snapshot) {
    return UserData(
        email: snapshot.data['email'],
        name: snapshot.data['name'],
        phone: snapshot.data['phone'],
        userType: snapshot.data['userType']);
  }
}

class UserData {
  final String name;
  final String email;
  final String phone;
  final String userType;
  UserData({this.email, this.name, this.phone, this.userType});
}

class Files {
  final String filename;
  final String filetype;
  final String url;
  final String note;
  final String dicomUrl;
  final String patName;
  final String radName;

  Files(
      {this.filename,
      this.filetype,
      this.url,
      this.note,
      this.dicomUrl,
      this.patName,
      this.radName});
}
