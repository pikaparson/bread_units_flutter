import 'package:flutter/material.dart';

class ObjectBaseClass extends StatefulWidget {
  const ObjectBaseClass({super.key});

  @override
  State<ObjectBaseClass> createState() => _ObjectBaseClassState();
}

class _ObjectBaseClassState extends State<ObjectBaseClass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Продукты и блюда'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
      ),
      body: Container(
        child: Column(
          children: [
            Text('Вот тут тоже будет бар, который перекидывает на продукты или блюда')
          ],
        ),
      ),
    );
  }
}
