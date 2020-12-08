import 'package:flutter/material.dart';

import 'tetris_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TetrisHomePage(),
    );
  }
}

class TetrisHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _raisedButton(context, '易しい' , 3),
            _raisedButton(context, '普通' , 2),
            _raisedButton(context, '難しい' , 1),
          ],
        ),
      ),
    );
  }

  Widget _raisedButton(BuildContext context, String label, int fallSpeed) {
    return RaisedButton(
      child: Text(label),
      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute<void>(builder: (context) => TetrisPlayPage(fallSpeed, label))),
    );
  }
}