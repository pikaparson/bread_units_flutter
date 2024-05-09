import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class SQLhelper {

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await db();
    return _database;
  }

  Future<Database?> db() async {
    final Directory dir = await getApplicationDocumentsDirectory(); //path_provider.dart
    final String path = '${dir.path}/db.sqlite';
    return await openDatabase(path, version: 1, onCreate: (Database database, int version) async {
      await database.execute("""CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        carbohydrates REAL NOT NULL,
        main INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """);
      await database.execute("""CREATE TABLE dishes(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
        """);
      await database.execute("""CREATE TABLE compositions(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        dish INTEGER REFERENCES dishes (id) NOT NULL,
        product INTEGER REFERENCES products (id) NOT NULL,
        grams INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """);
      await database.execute("""CREATE TABLE sets(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """);
      await database.execute("""CREATE TABLE set_dish(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        dish INTEGER REFERENCES dishes (id) NOT NULL,
        setID INTEGER REFERENCES sets (id) NOT NULL,
        grams INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """);
      await database.execute("""CREATE TABLE set_product(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        setID INTEGER REFERENCES sets (id) NOT NULL,
        product INTEGER REFERENCES products (id) NOT NULL,
        grams INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """);
      await database.execute("""CREATE TABLE control(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        flag TEXT NOT NULL,
        text TEXT NOT NULL,
        dish INTEGER REFERENCES dishes (id)
      )
      """);
    });
  }
  // SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET ----- SET
  // Создание нового объекта блюда
  Future<int> createSetItem(String n) async {
    final data = {'name': n};
    final Database? db = await database;
    return db!.insert('sets', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Прочитать все элементы (журнал)
  Future<List<Map<String, dynamic>>?> getSetItem() async {
    final Database? db = await database;
    return db!.query('sets', orderBy: 'id');
  }
  // Обновление объекта по id
  Future<int?> updateSetItem(int id, String n) async {
    final Database? db = await database;
    final data = {
      'name': n,
      'createdAt': DateTime.now().toString()
    };
    return await db?.update('sets', data, where: "id = ?", whereArgs: [id]);
  }
  // Удалить по id
  Future<void> deleteSetItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("sets", where: "id = ?", whereArgs: [id]);
      await db?.delete("set_product", where: "setID = ?", whereArgs: [id]);
      await db?.delete("set_dish", where: "setID = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  // Добавление имени сета в контроль
  Future<int> controlInsertSetName(String s) async {
    String t = 't';
    final Database? db = await database;
    await db?.delete("control", where: "flag = ?", whereArgs: [t]); //удаление старого имени
    final data = {'text': s, 'flag': t};//добавление нового имени
    return await db!.insert('control', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Вернуть имя сета из контроля для AppBar и других функций
  Future<String> controlSetName() async {
    final Database? db = await database;
    String t = 't';
    final help = await db!.rawQuery('SELECT *FROM control WHERE flag = ?', [t]);
    String h = help[0]['text'].toString();
    if (help != null) {
      return h;
    }
    return Future.value('ERROR!');
  }
  // Вернуть id набора по имени
  Future<int> controlSetId(String d) async {
    final Database? db = await database;
    final help = await db!.rawQuery('SELECT *FROM sets WHERE name = ?', [d]);
    int a = await int.parse(help[0]['id'].toString());
    return a;
  }

  // Прочитать все элементы продуктов по id набора
  Future<List<Map<String, dynamic>>?> controlGetSetProductItem(int idSet) async {
    final Database? db = await database;
    //final h = await db!.rawQuery('SELECT * FROM set_product WHERE setID = ?', [idSet]);
    final h = await db!.rawQuery('SELECT set_product.id AS id,set_product.setID AS id_set,set_product.product AS id_product,set_product.grams AS grams,products.name AS name_product, products.carbohydrates AS carb_product FROM set_product JOIN products ON set_product.product = products.id WHERE set_product.setID = ?', [idSet]);
    return h;
  }
  // Прочитать все элементы блюда по id набора
  Future<List<Map<String, dynamic>>?> controlGetSetDishItem(int idSet) async {
    final Database? db = await database;
    final h = await db!.rawQuery('SELECT set_dish.id AS id, set_dish.setID AS id_set, set_dish.dish AS id_dish, set_dish.grams AS grams, dishes.name AS name_dish FROM set_dish JOIN dishes ON set_dish.dish = dishes.id WHERE set_dish.setID = ?', [idSet]);
    return h;
  }

  // Добавление продукта в набор
  Future<int> createSetProduct(int idSet, int idProduct, int grams) async {
    final Database? db = await database;
    final data = {'setID': idSet, 'product': idProduct, 'grams': grams};
    return await db!.insert('set_product', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Добавление продукта в набор
  Future<int> createSetDish(int idSet, int idDish, int grams) async {
    final Database? db = await database;
    final data = {'setID': idSet, 'dish': idDish, 'grams': grams};
    return await db!.insert('set_dish', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Обновление продукта из набора по его id
  Future<int?> updateSetProductItem(int idSet, int idProduct, int grams) async {
    final Database? db = await database;
    final data = {'product': idProduct, 'grams': grams};
    return await db?.update('set_product', data, where: "setID = ?", whereArgs: [idSet]);
  }
  // Обновление блюда из набора по его id
  Future<int?> updateSetDishItem(int idSet, int idDish, int grams) async {
    final Database? db = await database;
    final data = {'dish': idDish, 'grams': grams};
    return await db?.update('set_dish', data, where: "setID = ?", whereArgs: [idSet]);
  }

  // Удалить продукт из набора по id
  Future<void> deleteSetProductItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("set_product", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  // Удалить блюдо из набора по id
  Future<void> deleteSetDishItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("set_dish", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  // Вернуть имя продукта из набора
  Future<String> getSetProductName(int idP) async {
    final Database? db = await database;
    final d = await db?.rawQuery('SELECT * FROM products WHERE id = ?', [idP]);
    if (d != null) {
      return '${d[0]['name'].toString()}';
    }
    return Future.value('Ошибка');
  }
  // Вернуть имя продукта из набора
  Future<String> getSetDishName(int idD) async {
    final Database? db = await database;
    final d = await db?.rawQuery('SELECT * FROM dishes WHERE id = ?', [idD]);
    if (d != null) {
      return '${d[0]['name'].toString()}';
    }
    return Future.value('Ошибка');
  }
  // Вывести ХЕ продукта в наборе
  Future<String> getSetProductBU(int id, int idP) async {
    final Database? db = await database;
    final grams = await db?.rawQuery('SELECT grams FROM set_product WHERE id = ?', [id]);
    final c = await db?.rawQuery('SELECT carbohydrates FROM products WHERE id = ?', [idP]);

    if (grams != null && c != null) {
      double helperDouble = double.parse('${grams[0]['grams']}') * double.parse('${c[0]['carbohydrates']}')/ 100 / 12;
      return '${helperDouble.toStringAsFixed(2)}';
    }
    return Future.value('');
  }
  // Вывести ХЕ блюда в наборе
  Future<String> getSetDishBU(int id, int idD) async {
    final Database? db = await database;
    final gramsSetDish = await db?.rawQuery('SELECT grams FROM set_dish WHERE id = ?', [id]);
    final comp = await controlGetDishItem(idD);
    double gramsDish = 0, c = 0, helper;
    if (comp != null && gramsSetDish != null) {
      for (int i = 0; i < comp.length; i++) {
        gramsDish = gramsDish + double.parse('${comp[i]['grams']}');
        c = c + double.parse('${comp[i]['grams']}') * double.parse('${comp[i]['carb_product']}') / 100;
      }
      helper = double.parse('${gramsSetDish[0]['grams']}') * c / gramsDish / 12;
      return '${helper.toStringAsFixed(2)}';
    }
    return Future.value('');
  }
  // вывод всех элементов набора в карточке
  Future<String> textFromSetElements(int id) async {
    String help = '';
    final Database? db = await database;
    final prod = await db?.rawQuery('SELECT set_product.id AS id,set_product.setID AS id_set,set_product.product AS id_product,set_product.grams AS grams,products.name AS name_product, products.carbohydrates AS carb_product FROM set_product JOIN products ON set_product.product = products.id WHERE set_product.setID = ?', [id]);
    final dish = await db?.rawQuery('SELECT set_dish.id AS id, set_dish.setID AS id_set, set_dish.dish AS id_dish, set_dish.grams AS grams, dishes.name AS name_dish FROM set_dish JOIN dishes ON set_dish.dish = dishes.id WHERE set_dish.setID = ?', [id]);
    var comp;
    if (prod != null) {
      for (int i = 0; i < prod.length; i++) {
        comp = await getSetDishBU(id, int.parse('${prod[i]['id_product']}'));
        help = help + '${prod[i]['name_product'].toString()} - ${(comp.toString())} ХЕ';
        if (i + 1 != prod.length || dish != null) {
          help = help + '\n';
        }
      }
    }
    if (dish != null) {
      for (int i = 0; i < dish.length; i++) {
        comp = await getSetDishBU(id, int.parse('${dish[i]['id_dish']}'));
        help = help + '${dish[i]['name_dish']} - ${comp.toString()} ХЕ';
        if (i + 1 != dish.length) {
          help = help + '\n';
        }
      }
    }
    return help;
  }

  // COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION
  // Добавление имени блюда в контроль
  Future<int> controlInsertDishName(String d) async {
    String t = 't';
    final Database? db = await database;
    await db?.delete("control", where: "flag = ?", whereArgs: [t]); //удаление старого имени
    final data = {'text': d, 'flag': t};//добавление нового имени
    return await db!.insert('control', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Вернуть имя блюда из контроля для AppBar и других функций
  Future<String> controlDishName() async {
    final Database? db = await database;
    String t = 't';
    final help = await db!.rawQuery('SELECT *FROM control WHERE flag = ?', [t]);
    String h = help[0]['text'].toString();
    if (help != null) {
      return h;
    }
    return Future.value('ERROR!');
  }
  // Вернуть id блюда по имени
  Future<int> controlDishId(String d) async {
    final Database? db = await database;
    final help = await db!.rawQuery('SELECT *FROM dishes WHERE name = ?', [d]);
    int a = await int.parse(help[0]['id'].toString());
    return a;
  }
  // Прочитать все элементы композиции по id блюда
  Future<List<Map<String, dynamic>>?> controlGetDishItem(int idDish) async {
    final Database? db = await database;
    final h = await db!.rawQuery('SELECT compositions.id AS id_comp,compositions.dish AS id_dish,compositions.product AS id_product,compositions.grams AS grams,products.name AS name_product,products.carbohydrates AS carb_product FROM compositions JOIN products ON compositions.product = products.id WHERE compositions.dish = ?', [idDish]);
    return h;
  }
  // Вывод граммов ингредиента
  Future<String> controlGetGrams(int idComp, int idDish) async {
    final Database? db = await database;
    final h = await db!.rawQuery('SELECT compositions.id AS id_comp,compositions.dish AS id_dish,compositions.product AS id_product,compositions.grams AS grams,products.name AS name_product,products.carbohydrates AS carb_product FROM compositions JOIN products ON compositions.product = products.id WHERE compositions.dish = ? AND compositions.id = ?', [idDish, idComp]);
    if (h != null) {
      return h[0]['grams'].toString();
    }
    return Future.value('ERROR');
  }
  //Вывод ХЕ на 100 г блюда
  Future<double> calculateBu(int dishId) async {
    double bu = 0;
    int weight = 0;
    final composition = await controlGetDishItem(dishId);
    if (composition != null) {
      for (var product in composition) {
        bu += double.parse(product['grams'].toString()) / 100 * double.parse(product['carb_product'].toString()) / 12;
        weight += int.parse(product['grams'].toString());
      }
    }
    return bu * 100 / weight;
  }
  // Вывод ХЕ ингредиента
  Future<String> controlGetBU(int idComp, int idDish) async {
    final Database? db = await database;
    final g = await db!.rawQuery('SELECT *FROM compositions WHERE product = ?', [idComp]);
    final c = await db!.rawQuery('SELECT *FROM products WHERE id = ?', [idComp]);
    final h = await db!.rawQuery('SELECT compositions.id AS id_comp,compositions.dish AS id_dish,compositions.product AS id_product,compositions.grams AS grams,products.name AS name_product,products.carbohydrates AS carb_product FROM compositions JOIN products ON compositions.product = products.id WHERE compositions.dish = ? AND compositions.id = ?', [idDish, idComp]);
    double BU = 0;
    if (h != null) {
      BU = double.parse(h[0]['grams'].toString()) * double.parse(h[0]['carb_product'].toString()) / 100 / 12;
    }
    var helper = double.parse(BU.toStringAsFixed(2));
    return '${helper}';
  }
  // Создание нового объекта композиции
  Future<int> createCompositionItem(int idDish, int idProduct, int grams) async {
    final Database? db = await database;
    final data = {'dish': idDish, 'product': idProduct, 'grams': grams};
    return await db!.insert('compositions', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Обновление объекта по id
  Future<int?> updateCompositionItem(int id, int d, int p, double g) async {
    final Database? db = await database;
    final data = {
      'dish': d,
      'product': p,
      'grams': g,
      'createdAt': DateTime.now().toString()
    };
    return await db?.update('compositions', data, where: "id = ?", whereArgs: [id]);
  }
  // Удалить по id
  Future<void> deleteCompositionItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("compositions", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS --- PRODUCTS
  // Создание нового объекта продукта
  Future<int> createProductItem(String n, double c, int m) async {
    final data = {'name': n, 'carbohydrates': c, 'main': m};
    final Database? db = await database;
    return db!.insert('products', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Прочитать все элементы (журнал)
  Future<List<Map<String, dynamic>>?> getProductItem() async {
    final Database? db = await database;
    return db!.query('products', orderBy: 'id');
  }
  // Обновление объекта по id
  Future<int?> updateProductItem(int id, String n, double c) async {
    final Database? db = await database;
    final data = {
      'name': n,
      'carbohydrates': c,
      'createdAt': DateTime.now().toString()
    };
    return await db?.update('products', data, where: "id = ?", whereArgs: [id]);
  }
  // Удалить по id
  Future<void> deleteProductItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("products", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
  // Вывести ХЕ
  Future<String> getProductBU(int id) async {
    final Database? db = await database;
    final helper = await db?.rawQuery('SELECT carbohydrates FROM products WHERE id = ?', [id]);
    if (helper != null) {
      double helperDouble = double.parse(helper[0]['carbohydrates'].toString()) / 12;
      return '${helperDouble.toStringAsFixed(2)} ХЕ на 100г';
    }
    return Future.value('');
  }

  // DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH --- DISH
  // Создание нового объекта блюда
  Future<int> createDishItem(String n) async {
    final data = {'name': n};
    final Database? db = await database;
    return db!.insert('dishes', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Прочитать все элементы (журнал)
  Future<List<Map<String, dynamic>>?> getDishItem() async {
    final Database? db = await database;
    return db!.query('dishes', orderBy: 'id');
  }
  // Обновление объекта по id
  Future<int?> updateDishItem(int id, String n) async {
    final Database? db = await database;
    final data = {
      'name': n,
      'createdAt': DateTime.now().toString()
    };
    return await db?.update('dishes', data, where: "id = ?", whereArgs: [id]);
  }
  // Удалить по id
  Future<void> deleteDishItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("dishes", where: "id = ?", whereArgs: [id]);
      await db?.delete('compositions', where: 'dish = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // Название блюда по id
  Future<String> getDishName(int id) async {
    final Database? db = await database;
    final dbHelp = await db!.rawQuery('SELECT name FROM dishes WHERE id = ?', [id]);
    return dbHelp[0]['name'].toString();
  }

  //вернуть id по имени
  Future<int> getNewDishId(String n) async {
    final Database? db = await database;
    final dbHelp = await db?.rawQuery('SELECT id FROM dishes WHERE name = ?', [n]);
    if (dbHelp != null) {
      return int.parse('${dbHelp[0]['id'].toString()}');
    }
    return Future.value(0);
  }

}
