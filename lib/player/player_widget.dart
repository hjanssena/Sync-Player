import 'package:flutter/material.dart';

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Container(
        color: ThemeData.dark().scaffoldBackgroundColor,
        child: Card(
          color: ThemeData.dark().focusColor,
          child: InkWell(child: Text("Hola"), onTap: () {}),
        ),
      ),
    );
  }
}
