import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import './Database.dart';
import './UserTypeHome.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'App.dart';
import 'Loading.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Splashscreen(),
  ));
}

class Splashscreen extends StatefulWidget {
  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) => App()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.black),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 90.0,
                          child: Image(
                            image: AssetImage('images/icon.png'),
                            fit: BoxFit.cover,
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 20.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class LoginRegister extends StatefulWidget {
  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

enum FormType {
  login,
  register,
}

class _LoginRegisterState extends State<LoginRegister> {
  FormType formType = FormType.login;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  String selectedvalue;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  // ignore: missing_return
  Future<bool> signIn(String email, String password) async {
    //function for sign in
    try {
      AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
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
  }

  //funcion for signup
  // ignore: missing_return
  Future<bool> signUp(String email, String password) async {
    if (validateAndSave()) {
      try {
        AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
            email: email, password: password);

        FirebaseAnalytics analytics = FirebaseAnalytics();
        FirebaseUser user = await FirebaseAuth.instance.currentUser();

        final phone = phoneController.text.trim();
        final name = nameController.text.trim();
        // ignore: unused_local_variable

        final userType = selected;

        analytics.setUserId(phone);
        await Database(uid: email) //for saving user details
            .saveToDatabase(name, email, phone, userType, phone);

        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        sharedPreferences.setString('email', email);
        sharedPreferences.setString('password', password);
        sharedPreferences.setString('phone', phone);
        sharedPreferences.setString('UserType', selected);
        if (user != null) {
          if (userType == 'Doctor') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserType(
                          phone: phone,
                          email: email,
                          user: user,
                          userTypes: UserTypes.doctor,
                        )));
          } else if (userType == 'Patient') {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserType(
                          phone: phone,
                          email: email,
                          user: user,
                          userTypes: UserTypes.patient,
                        )));
          } else {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserType(
                          phone: phone,
                          email: email,
                          user: user,
                          userTypes: UserTypes.radiologist,
                        )));
          }
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
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

  void moveToLogin() {
    _formKey.currentState.reset();
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    phoneController.clear();
    setState(() {
      formType = FormType.login;
    });
  }

  void moveToRegister() {
    _formKey.currentState.reset();
    emailController.clear();
    passwordController.clear();
    setState(() {
      formType = FormType.register;
    });
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

  @override
  Widget build(BuildContext context) {
    // ignore: missing_required_param
    return WillPopScope(
      onWillPop: _onPressed,
      child: loading
          ? Loading()
          : Scaffold(
              body: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [Colors.black26, Colors.black45, Colors.black],
                      stops: [
                        0.1,
                        0.4,
                        0.7,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    )),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: inputs() + buttons(),
                        ))),
              ),
            ),
    );
  }

  Widget logo() {
    return Hero(
        tag: 'icon',
        child: CircleAvatar(
          radius: 55,
          backgroundColor: Colors.black,
          child: Image(
            image: AssetImage("images/icon.png"),
            fit: BoxFit.fill,
          ),
        ));
  }

  List types = ['Doctor', 'Patient', 'Radiologist'];
  String selected;

  List<Widget> inputs() {
    if (formType == FormType.register) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.12,
        ),
        logo(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
                onPressed: moveToRegister,
                child: Text(
                  'SignUp',
                  style: TextStyle(
                      fontSize: 25,
                      fontFamily: 'KellySlab',
                      shadows: [
                        BoxShadow(
                            blurRadius: 5,
                            color: Colors.black,
                            spreadRadius: 5),
                      ],
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
            ),
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.25,
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  onPressed: moveToLogin,
                  label: Text('Login',
                      style: TextStyle(
                        color: Colors.blue,
                      ))),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.04,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                return val.isEmpty ? ' Name Required' : null;
              },
              controller: nameController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Name',
                  hintText: "Name"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                return val.isEmpty && !val.contains('@')
                    ? 'Email Required'
                    : null;
              },
              controller: emailController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Email',
                  hintText: "Email"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                if (val.isEmpty &&
                    val.length < 5 &&
                    !val.contains('123456789')) {
                  return 'Strong password Required';
                } else {
                  return null;
                }
              },
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Password',
                  hintText: "Password"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: Colors.white54, borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
            child: DropdownButton(
                dropdownColor: Colors.white70,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 35,
                hint: Text("Select Type"),
                isExpanded: true,
                style: TextStyle(
                  color: Colors.black54,
                ),
                items: types.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                value: selected,
                onChanged: (value) {
                  setState(() async {
                    selected = value;
                  });
                }),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                if (val.isEmpty && val.length < 10 && val.length > 13) {
                  return 'valid phoneNumber Required';
                } else {
                  return null;
                }
              },
              controller: phoneController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Phone Number',
                  hintText: "Phone Number"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
      ];
    } else {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.16,
        ),
        logo(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton(
                onPressed: moveToLogin,
                child: Text('Login',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.black,
                              spreadRadius: 5)
                        ],
                        fontFamily: 'KellySlab',
                        color: Colors.white))),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
            ),
            SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.25,
              child: FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  onPressed: moveToRegister,
                  label: Text('Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                      ))),
            ),
          ],
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                return val.isEmpty && !val.contains('@')
                    ? 'Email Required'
                    : null;
              },
              controller: emailController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Email',
                  hintText: "Email"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.015,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white54),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            child: TextFormField(
              autofocus: false,
              validator: (val) {
                return val.isEmpty && val.length < 5
                    ? 'Strong password Required'
                    : null;
              },
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white30),
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.white),
                  labelText: 'Password',
                  hintText: "Password"),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
      ];
    }
  }

  List<Widget> buttons() {
    if (formType == FormType.login) {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: FloatingActionButton.extended(
                heroTag: '1',
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  if (validateAndSave()) {
                    FirebaseUser user =
                        await FirebaseAuth.instance.currentUser();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    await signIn(email, password);
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => App(
                                  email: email,
                                  user: user,
                                )));
                  }
                  setState(() {
                    loading = false;
                  });
                },
                label: Text("Login"))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
      ];
    } else {
      return [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: FloatingActionButton.extended(
                heroTag: '10',
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  FirebaseUser user = await FirebaseAuth.instance.currentUser();
                  final email = emailController.text.trim();
                  final password = passwordController.text.trim();
                  final phone = phoneController.text.trim();
                  final name = nameController.text.trim();
                  final userType = selected;
                  print(phone);

                  signUp(email, password);

                  print(userType);

                  setState(() {
                    loading = false;
                  });
                },
                label: Text("Sign Up"))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        )
      ];
    }
  }
}
