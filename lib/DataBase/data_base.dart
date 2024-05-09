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
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      """);
      await database.execute("""CREATE TABLE set_product(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        setID INTEGER REFERENCES sets (id) NOT NULL,
        product INTEGER REFERENCES products (id) NOT NULL,
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
  Future<int> createCompositionItem(int idDish, int idProduct, double grams) async {
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
