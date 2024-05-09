import 'package:flutter/material.dart';

import '../../DataBase/data_base.dart';

class CalculateProductClass extends StatefulWidget {
  const CalculateProductClass({super.key});

  @override
  State<CalculateProductClass> createState() => _CalculateProductClassState();
}

class _CalculateProductClassState extends State<CalculateProductClass> {

  String setName = '';
  int setId = 0,
      productId = 0;
  List<Map<String, dynamic>> _journals = [];
  List<Map<String, dynamic>> _journalsProducts = [];
  bool _isLoading = true;

  Future<void> _refreshJournals() async {
    setName = await SQLhelper().controlSetName();
    setId = await SQLhelper().controlSetId(setName);

    final data = await SQLhelper().controlGetSetProductItem(setId);
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
      final help = _journals.firstWhere((element) => element['id_set'] == id);
      _gramsController.text = help['grams'].toString();
      productId = help['id_product'];
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
                  disabledHint: productId != null //можно удалить
                      ? Text(_journalsProducts.firstWhere((item) => item["id"] == productId)["name"])
                      : null,
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
                      await _updateItem(id, productId, int.parse('${_gramsController.text}'));
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
    await SQLhelper().createSetProduct(setId, productId, int.parse('${_gramsController.text}'));
    await _refreshJournals();
  }
  //Обновить существующий объект
  Future<void> _updateItem(int id, int id_pr, int g) async {
    await SQLhelper().updateSetProductItem(id, id_pr, g);
    await _refreshJournals();
  }
  //Удалить существующий объект
  void _deleteItem(int id) async{
    await SQLhelper().deleteSetProductItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Успешное удаление объекта!'),
    ));
    await _refreshJournals();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${setName}: добавить продукты'),
        centerTitle: true,
        backgroundColor: Colors.orange[200],
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/main_bar', (route) => false);
            },
            icon: Icon(Icons.arrow_back)),
      ),

      body: _isLoading ? const Center(child: CircularProgressIndicator(),) : ListView.builder(
          itemCount: _journals.length,
          itemBuilder: (context, index) => Card (
            color: Colors.orange[200],
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title:  FutureBuilder<String>(
                  future: SQLhelper().getSetProductName(int.parse('${_journals[index]['id_product']}')),
                  builder: (context, snapshot) {
                    return Text('${snapshot.data}\n${_journals[index]['grams']} грамм(а/ов)', style: TextStyle(fontSize: 18));
                  }
              ),
              subtitle: FutureBuilder<String>(
                  future: SQLhelper().getSetProductBU(setId, int.parse('${_journals[index]['id_product']}')),
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
