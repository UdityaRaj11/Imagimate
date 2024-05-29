import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 29, 29, 29),
      body: Center(
          child: Text(
        'Loading..',
        style: TextStyle(color: Colors.white),
      )),
    );
  }
}
