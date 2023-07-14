import 'dart:math';

import 'package:flutter/material.dart';

class ProfileIconCreator extends StatelessWidget {
  final String name;
  final double size;
  ProfileIconCreator({super.key, required this.name, this.size = 50});
  List<Color> colors = const [
    Colors.redAccent,
    Colors.lightBlue,
    Colors.amber,
  ];
  Random randomNumber = new Random();

  @override
  Widget build(BuildContext context) {
    // print('name ${name[0]}');
    int index = randomNumber.nextInt(colors.length);
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[index]),
      child: Text(
        name.isEmpty ? name : name[0].toUpperCase(),
        style: TextStyle(fontSize: size * .8, fontWeight: FontWeight.bold),
      ),
    );
  }
}
