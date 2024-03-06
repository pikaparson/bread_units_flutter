import 'package:flutter/material.dart';

class HistoryClass extends StatefulWidget {
  const HistoryClass({super.key});

  @override
  State<HistoryClass> createState() => _HistoryStateClass();
}

class _HistoryStateClass extends State<HistoryClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('История'),
        centerTitle: true,
      ),
    );
  }
}
