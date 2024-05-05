import 'package:bread_units/DataBase/data_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../navigation_main.dart';

class ProductBaseClass extends StatefulWidget {
  const ProductBaseClass({super.key});

  @override
  State<ProductBaseClass> createState() => _ProductBaseClassState();
}

class _ProductBaseClassState extends State<ProductBaseClass> {

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  Future<void> _refreshJournals() async {
    final data = await SQLhelper().getProductItem();
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

  double carbohydrates = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _carbohydratesController = TextEditingController();

  void _showForm(int? id) async {
    //если id == 0, то шторка для создания элемента
    if (id != null) {
      final existingJournal = _journals.firstWhere((element) => element['id'] == id);
      _nameController.text = existingJournal['name'];
      _carbohydratesController.text = existingJournal['carbohydrates'].toString();
    }
    showModalBottomSheet(
        context: context,
        elevation: 5, //тень
        isScrollControlled: true,
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
                decoration: const InputDecoration(hintText: 'Название продукта'),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _carbohydratesController,
                keyboardType: TextInputType.numberWithOptions(decimal:true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d{0,2}'))
                ],
                decoration: const InputDecoration(hintText: 'Количество углеводов'),
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (double.parse('${_carbohydratesController.text}') > 100 || double.parse('${_carbohydratesController.text}') < 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ошибка'),
                            content: Text('Было введено неправильное количество углеводов - ${_carbohydratesController.text}. \n Количество углеводов должно не превышать 100 грамм, но и не быть меньше нуля.'),
                            actions: [ElevatedButton(onPressed: () {Navigator.of(context).pop();}, child: Text('Выйти'))]
                          );
                        }
                      );
                    } else if (id == null){
                      await _addItem();
                      // Очистим поле
                      _nameController.text = '';
                      _carbohydratesController.text = '';
                      carbohydrates = 0;
                      await _refreshJournals();
                      // Закрываем шторку
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    } else if (id != null) {
                      await _updateItem(id);
                      // Очистим поле
                      _nameController.text = '';
                      _carbohydratesController.text = '';
                      carbohydrates = 0;
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
    carbohydrates = double.parse('${_carbohydratesController.text}');
    await SQLhelper().createProductItem(_nameController.text, carbohydrates, 0);
    await _refreshJournals();
  }
  //Обновить существующий объект
  Future<void> _updateItem(int id) async {
    carbohydrates= double.parse('${_carbohydratesController.text}');
    await SQLhelper().updateProductItem(id, _nameController.text, carbohydrates);
    await _refreshJournals();
  }
  //Удалить существующий объект
  void _deleteItem(int id) async{
    await SQLhelper().deleteProductItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успешное удаление объекта!'),
    ));
    await _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('База продуктов'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/main_bar', (route) => false);
              //Navigator.push(context, MaterialPageRoute(builder: (context) {return MainBarClass();},),);
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card (
          color: Colors.orange[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Text('${_journals[index]['name']}\n${_journals[index]['carbohydrates']}г углеводов на 100г'),
            subtitle: FutureBuilder<String>(
              future: SQLhelper().getProductBU(_journals[index]['id']),
              builder: (context, snapshot) {
                return Text('${snapshot.data}');},
            ),
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
          setState(() {
            _showForm(null);
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[200],
      ),
    );
  }
}
