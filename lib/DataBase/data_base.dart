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
      await database.execute("""CREATE TABLE control(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        text TEXT NOT NULL,
        dish INTEGER REFERENCES dishes (id)
      )
      """);
    });
  }

  Future<int> controlDish(int d) async {
    final data = {'text': 'a', 'dish': d};
    final Database? db = await database;
    return db!.insert('control', data, conflictAlgorithm: ConflictAlgorithm.replace);
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
    return await db?.update('products', data, where: "id = ?", whereArgs: [id]);
  }
  // Удалить по id
  Future<void> deleteDishItem(int id) async {
    final Database? db = await database;
    try {
      await db?.delete("dishes", where: "id = ?", whereArgs: [id]);
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

  // COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION --- COMPOSITION
  // Создание нового объекта блюда
  Future<int> createCompositionItem(int d, int p, double g) async {
    final data = {'dish': d, 'product': p, 'grams':g};
    final Database? db = await database;
    return db!.insert('compositions', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Прочитать все элементы по блюду (журнал)
  Future<List<Map<String, dynamic>>?> getCompositionItem(int id) async {
    final Database? db = await database;
    return db!.rawQuery('SELECT *FROM compositions WHERE dish = ?', [id]);
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
  // Вывод ХЕ блюда
  Future<String> returnDishBU(int idD) async {
    final Database? db = await database;
    final helper = await db?.rawQuery('SELECT product, grams FROM compositions WHERE id = ?', [idD]);

    double BUhelper = 0;
    int idP = 0;
    double grams = 0;
    bool key = false;
    var helperBU;
    for (int? i = 0; i! < helper!.length; i++) {
      idP = int.parse('${helper[i]['product']}');
      grams = double.parse('${helper[i]['grams']}');
      helperBU = await db?.rawQuery('SELECT carbohydrates FROM products WHERE id = ?', [idP]);
      BUhelper = BUhelper + (double.parse('${helperBU[0]['carbohydrates']}') * grams / 100 / 12);
      key = true;
    }
    if (key == true) {
      return '$BUhelper';
    }
    return Future.value('Нет данных');
  }
}
