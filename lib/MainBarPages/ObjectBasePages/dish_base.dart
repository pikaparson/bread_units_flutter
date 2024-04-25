import 'package:bread_units/MainBarPages/composition_base.dart';
import 'package:flutter/material.dart';

import '../../DataBase/data_base.dart';

class DishBaseClass extends StatefulWidget {
  const DishBaseClass({super.key});

  @override
  State<DishBaseClass> createState() => DishBaseClassState();
}

class DishBaseClassState extends State<DishBaseClass> {
  String? get newDishName {
    return _newDishName;
  }

  int idHelper = 0;
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  Future<void> _refreshJournals() async {
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

  String _newDishName = '';
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
                      _newDishName = _nameController.text;
                      await _addItem();
                      // Очистим поле
                      _nameController.text = '';
                      await _refreshJournals();
                      // Закрываем шторку
                      if (!mounted) return;
                      Navigator.of(context).pop();
                      setState(() {
                        _newDishName = _nameController.text;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CompositionClass();
                            },
                          ),
                        );
                      });
                    } else if (id != null) {
                      await _updateItem(id);
                      // Очистим поле
                      _nameController.text = '';
                      await _refreshJournals();
                      // Закрываем шторку
                      if (!mounted) return;
                      Navigator.of(context).pop();
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

 //Вставить новый объект в базу данных
  Future<void> _addItem() async {
    await SQLhelper().createDishItem(_nameController.text);
    await _refreshJournals();
  }
  //Обновить существующий объект
  Future<void> _updateItem(int id) async {
    await SQLhelper().updateDishItem(id, _nameController.text);
    await _refreshJournals();
  }
  //Удалить существующий объект
  void _deleteItem(int id) async{
    await SQLhelper().deleteDishItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успешное удаление объекта!'),
    ));
    await _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('База блюд'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card (
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text('${_journals[index]['name']}'),
              trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _showForm(_journals[index]['id']);
                            });
                          },
                          icon: const Icon(Icons.edit)
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _deleteItem(_journals[index]['id']);
                            });
                          },
                          icon: const Icon(Icons.delete)
                      ),
                    ],
                  )
              ),
            ),
          )
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showForm(null);
        },
        backgroundColor: Colors.orange[200],
        child: Icon(Icons.add),
      ),
    );
  }


}
