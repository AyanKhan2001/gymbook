import 'dart:async';

import 'package:flutter/material.dart';

import 'home.dart';



class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) =>ClockInOutScreen()),
      );
    });

    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/ss.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
