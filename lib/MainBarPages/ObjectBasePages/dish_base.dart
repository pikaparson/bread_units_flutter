import 'package:flutter/material.dart';

class DishBaseClass extends StatefulWidget {
  const DishBaseClass({super.key});

  @override
  State<DishBaseClass> createState() => _DishBaseClassState();
}

class _DishBaseClassState extends State<DishBaseClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('База блюд'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
      ),
      body: Center(
        child: Column(
          children: [
            Text('Вывод блюд в карточках'),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange[200],
        child: Icon(Icons.add),
      ),
    );
  }
}
