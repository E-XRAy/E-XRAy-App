import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './UserTypeHome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'Database.dart';
import 'OnBoardingScreen.dart';
import 'main.dart';

// ignore: must_be_immutable
class App extends StatefulWidget {
  final String email;
  FirebaseUser user;
  final String phone;
  UserTypes userTypes;
  App({this.email, this.phone, this.user, this.userTypes});

  @override
  _AppState createState() => _AppState(phone: phone);
}

enum AuthStatus { signedIn, notSignedIn }

class _AppState extends State<App> {
  String phone;
  _AppState({this.phone});
  AuthStatus status = AuthStatus.notSignedIn;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

    if (_user != null) {
      status = AuthStatus.signedIn;
    } else {
      status = AuthStatus.notSignedIn;
    }
  }

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser _user;
  getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) {
      UserTypes userTypes;
      setState(() {
        _user = user;
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String userType = sharedPreferences.get('UserType');
      String emailid = sharedPreferences.get('email');
      if (userType == 'Doctor') {
        setState(() {
          userTypes = UserTypes.doctor;
        });
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserType(
                      email: user.email,
                      user: user,
                      userTypes: userTypes,
                    )));
      } else if (userType == 'Patient') {
        setState(() {
          userTypes = UserTypes.patient;
        });
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserType(
                      email: user.email,
                      user: user,
                      userTypes: userTypes,
                    )));
      } else if (userType == 'Radiologist') {
        setState(() {
          userTypes = UserTypes.radiologist;
        });
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserType(
                      email: user.email,
                      user: user,
                      userTypes: userTypes,
                    )));
      }
    }

    if (user == null) {
      Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    UserTypes types;
    return Scaffold(
        body: FutureBuilder(
            future: Firestore.instance
                .collection('Users')
                .document(_user.email)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(snapshot.data['UserType']);
                if (snapshot.data['UserType'] == 'Doctor') {
                  types = UserTypes.doctor;
                } else if (snapshot.data['UserType'] == 'Patient') {
                  types = UserTypes.patient;
                } else if (snapshot.data['UserType'] == 'Radiologist') {
                  types = UserTypes.radiologist;
                }
                return Container(
                  child: _user != null
                      ? UserType(
                          email: _user.email,
                          phone: snapshot.data['Phone'],
                          user: _user,
                          userTypes: types,
                        )
                      : LoginRegister(),
                );
              }
              return Container();
            }));
  }
}
