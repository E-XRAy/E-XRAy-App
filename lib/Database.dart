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

  savefileToDatabase(
      String filetype, String filename, String url, String note) async {
    return await fileCollection.document(uid).collection('files').add({
      'filename': filename,
      'filetype': filetype,
      'url': url,
      'content': note
    });
  }

  //for senting file
  sentFile(String recieverId, String filename, String filetype, String content,
      String url) async {
    return await fileCollection.document(recieverId).collection('files').add({
      'filename': filename,
      'fileType': filetype,
      'content': content,
      'url': url
    });
  }

  currentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return user.uid;
  }

  Stream<UserData> get userData {
    return userCollection.document(uid).snapshots().map(userDataFromSnapshots);
  }

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
  Files({this.filename, this.filetype, this.url, this.note});
}
