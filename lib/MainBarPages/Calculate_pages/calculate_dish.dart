import 'package:flutter/material.dart';

import '../../DataBase/data_base.dart';

class CalculateDishClass extends StatefulWidget {
  const CalculateDishClass({super.key});

  @override
  State<CalculateDishClass> createState() => _CalculateDishClassState();
}

class _CalculateDishClassState extends State<CalculateDishClass> {

  String setName = '';
  int setId = 0,
      dishId = 0;
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _journalsDish = [];
  bool _isLoading = true;

  Future<void> _refreshJournals() async {
    setName = await SQLhelper().controlSetName();
    setId = await SQLhelper().controlSetId(setName);

    final data = await SQLhelper().controlGetSetDishItem(setId);
    final dataDish = await SQLhelper().getDishItem();
    setState(() {
      if(data != null)
      {
        _journals = data;
      }
      if(dataDish != null) {
        dishId = int.parse('${dataDish[0]['id']}');
        _journalsDish = dataDish;
      }
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }



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