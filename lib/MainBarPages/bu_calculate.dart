import 'package:flutter/material.dart';

import '../DataBase/data_base.dart';

class BUCalculateClass extends StatefulWidget {
  const BUCalculateClass({super.key});

  @override
  State<BUCalculateClass> createState() => _BUCalculateClassState();
}

class _BUCalculateClassState extends State<BUCalculateClass> {
  int idHelper = 0;
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  Future<void> _refreshJournals() async {
    final data = await SQLhelper().getSetItem();
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
                  decoration: const InputDecoration(hintText: 'Название набора'),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _controlName();
                    if (id == null){
                      await _addItem();
                    }
                    else if (id != null) {
                      await _updateItem(id);
                    }
                    // Очистим поле
                    _nameController.text = '';
                    await _refreshJournals();
                    // Закрываем шторку
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    setState(() {
                      //Navigator.pushNamedAndRemoveUntil(context, '/composition_base', (route) => false);
                    });
                  },
                  child: Text('Продолжить', style: TextStyle(color: Colors.black)),
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

//добавить имя блюда в контроллер
  Future<void> _controlName() async {
    await SQLhelper().controlInsertSetName(_nameController.text);
  }
  //Вставить новый объект в базу данных
  Future<void> _addItem() async {
    await SQLhelper().createSetItem(_nameController.text);
    await _refreshJournals();
  }
  //Обновить существующий объект
  Future<void> _updateItem(int id) async {
    await SQLhelper().updateSetItem(id, _nameController.text);
    await _refreshJournals();
  }
  //Удалить существующий объект
  void _deleteItem(int id) async{
    await SQLhelper().deleteSetItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успешное удаление объекта!'),
    ));
    await _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор наборов'),
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
            //  subtitle: FutureBuilder<double>(
            //      future: SQLhelper().calculateBu(int.parse(_journals[index]['id'].toString())),
            //      builder: (context, snapshot) {
            //        return Text('${snapshot.data?.toStringAsFixed(2)} ХЕ на 100 грамм');
            //      }
            //  ),
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
        backgroundColor: Colors.orange[200],
        child: Icon(Icons.add),
        onPressed: () {
          _showForm(null);
        },
      ),
    );
  }
}
