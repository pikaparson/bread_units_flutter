import 'package:flutter/material.dart';

class CalculateDishClass extends StatefulWidget {
  const CalculateDishClass({super.key});

  @override
  State<CalculateDishClass> createState() => _CalculateDishClassState();
}

class _CalculateDishClassState extends State<CalculateDishClass> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(': добавить блюдо'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/main_bar', (route) => false);
            },
            icon: Icon(Icons.arrow_back)),
      ),

      //body

      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.orange[200],
          child: Icon(Icons.add),
      ),
    );
  }
}