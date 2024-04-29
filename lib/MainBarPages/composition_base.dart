import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../DataBase/data_base.dart';

class CompositionClass extends StatefulWidget {
  CompositionClass({super.key});

  @override
  State<CompositionClass> createState() => CompositionClassState();
}

class CompositionClassState extends State<CompositionClass> {

  String dishName = '';
  int dishId = 0,
      productId = 0;
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _journalsProducts = [];
  bool _isLoading = true;


  Future<void> _refreshJournals() async {
    dishName = await SQLhelper().controlDishName();
    dishId = await SQLhelper().controlDishId(dishName);

    final data = await SQLhelper().controlGetDishItem(dishId);
    final dataProducts = await SQLhelper().getProductItem();
    setState(() {
      if(data != null)
      {
        _journals = data;
      }
      if(dataProducts != null) {
        productId = int.parse('${dataProducts[0]['id']}');
        _journalsProducts = dataProducts;
      }
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  final TextEditingController _gramsController = TextEditingController();

  void _showForm(int? id) async {
    //если id == 0, то шторка для создания элемента
    if (id != null) {
      final existingJournal = _journalsProducts.firstWhere((element) => element['id'] == id);
      _gramsController.text = existingJournal['grams'].toString();
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
                Container(
                  child: Text('Выберите продукт'),
                ),
                //выбор продукта
                DropdownButtonFormField(
                  disabledHint:  Text(_journalsProducts.firstWhere((item) => item["id"] == productId)["name"]),
                  isExpanded: false,
                  value: productId,
                  items: _journalsProducts.map<DropdownMenuItem<int>>((e) {
                    return DropdownMenuItem
                      (
                      child: Text(
                        e["name"],
                      ),
                      value: e["id"],
                    );
                  }).toList(),
                  onChanged: (t) {
                    setState(() {
                      productId = t!;
                      MediaQuery.of(context).viewInsets.bottom;
                    });
                  },
                ),
                // ввод граммов
                TextField(
                  controller: _gramsController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(hintText: 'Граммы'),
                ),
                const SizedBox(
                  height: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (id == null){
                      await _addItem();
                    } else if (id != null) {
                      await _updateItem(id);
                    }
                    _gramsController.text = '';
                    await _refreshJournals();
                    // Закрываем шторку
                    if (!mounted) return;
                    Navigator.of(context).pop();
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
    await SQLhelper().createCompositionItem(dishId, productId, double.parse('${_gramsController.text}'));
    await _refreshJournals();
  }
  //Обновить существующий объект
  Future<void> _updateItem(int id) async {
    await SQLhelper().updateDishItem(id, _gramsController.text);
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
        title: Text('${dishName}: ингредиенты', style: TextStyle(fontSize: 20),),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card (
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title:  FutureBuilder<String>(
                        future: SQLhelper().controlGetGrams(_journals[index]['id_comp'], dishId),
                         builder: (context, snapshot) {
                          return Text('${_journals[index]['name_product']}\n${snapshot.data} грамм(ов)', style: TextStyle(fontSize: 18));
                          }
                      ),
              subtitle: FutureBuilder<String>(
                  future: SQLhelper().controlGetBU(_journals[index]['id_comp'], dishId),
                  builder: (context, snapshot) {
                    return Text('${snapshot.data} ХЕ', style: TextStyle(fontSize: 18));
                  }
              ),
              trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _showForm(_journals[index]['id_comp']);
                            });
                          },
                          icon: const Icon(Icons.edit)
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _deleteItem(_journals[index]['id_comp']);
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
          if (_journalsProducts == null) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Ошибка!', textAlign: TextAlign.center,),
                    content: Text('Нет продуктов!'),
                    actions: [
                      TextButton(onPressed: () { Navigator.of(context).pop(); }, child: Text('Ща добавлю', style: TextStyle(color: Colors.black),))
                    ],
                  );
                }
            );
          }
          else {
            _showForm(null);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
