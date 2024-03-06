import 'package:flutter/material.dart';

class BUCalculateClass extends StatefulWidget {
  const BUCalculateClass({super.key});

  @override
  State<BUCalculateClass> createState() => _BUCalculateClassState();
}

class _BUCalculateClassState extends State<BUCalculateClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор'),
        centerTitle: true,
      ),
    );
  }
}
