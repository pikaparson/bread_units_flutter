import 'package:flutter/material.dart';

import '../DataBase/data_base.dart';

class CompositionClass extends StatefulWidget {
  const CompositionClass({super.key});
  @override
  State<CompositionClass> createState() => _CompositionClassState();
}

class _CompositionClassState extends State<CompositionClass> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(
       // title: // FutureBuilder<String>(
          // future: SQLhelper().getDishName(),
          // builder: (context, snapshot) {
          //  return Text('${snapshot.data}');},
       // ),
      );
  }
}
