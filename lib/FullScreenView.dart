import 'package:flutter/material.dart';

class FullScreen extends StatelessWidget {
  String url;
  FullScreen({this.url});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 0.1, color: Colors.black),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54, blurRadius: 7, spreadRadius: 0)
                ]),
            child: InteractiveViewer(
              panEnabled: false,
              boundaryMargin: EdgeInsets.all(10),
              minScale: 0.5,
              maxScale: 4,
              child: Image(
                image: NetworkImage(url),
                alignment: Alignment.center,
                fit: BoxFit.fitWidth,
              ),
            )),
      ),
    );
  }
}
