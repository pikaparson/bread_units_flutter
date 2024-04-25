import 'dart:developer';

import 'package:bread_units/MainBarPages/ObjectBasePages/dish_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../DataBase/data_base.dart';

class CompositionClass extends StatefulWidget {
  CompositionClass({super.key});

  @override
  State<CompositionClass> createState() => CompositionClassState();
}

class CompositionClassState extends State<CompositionClass> {

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;


  Future<void> _refreshJournals() async {
  //  idDish = await SQLhelper().getNewDishId(DishBaseClass().newDishName);
    final data = await SQLhelper().getDishItem();
    setState(() {
      if(data != null)
      {
        _journals = data;
      }
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }


  final TextEditingController _nameController = TextEditingController();
  void _showForm(int? id) async {
    //если id == 0, то шторка для создания элемента
    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
    }
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        elevation: 5,
        backgroundColor: Colors.white,
        isDismissible: false,
        builder: (_) => Container(
            padding: EdgeInsets.only(
              top: 15,
              left: 15,
              right: 15,
              // это предотвратит закрытие текстовых полей программной клавиатурой
              bottom: MediaQuery.of(context).viewInsets.bottom + 275,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Название блюда'),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (id == null){
                   //   await _addItem();
                   //   newDishName = _nameController.text;
                      // Очистим поле
                      _nameController.text = '';
                      await _refreshJournals();
                      // Закрываем шторку
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    } else if (id != null) {
                  //    await _updateItem(id);
                      // Очистим поле
                      _nameController.text = '';
                      await _refreshJournals();
                      // Закрываем шторку
                      if (!mounted) return;
                      Navigator.of(context).pop();

                      if (id != null) {
                        setState(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return CompositionClass();
                              },
                            ),
                          );
                        });
                      }
                    }
                  },
                  child: Text('Добавить', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(
                  height: 5,
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Отмена', style: TextStyle(color: Colors.black),))
              ],
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Компоновка блюда'),
        centerTitle: true,
      ),
   //   body: ,
      floatingActionButton: FloatingActionButton(
        onPressed: () {

        },
        child: Icon(Icons.add),
      ),
    );
  }
}
