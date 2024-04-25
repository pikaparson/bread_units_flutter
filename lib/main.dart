import 'package:bread_units/MainBarPages/bu_calculate.dart';
import 'package:bread_units/MainBarPages/composition_base.dart';
import 'package:bread_units/MainBarPages/history.dart';
import 'package:bread_units/MainBarPages/navigation_main.dart';
import 'package:bread_units/MainBarPages/navigation_object_base.dart';
import 'package:bread_units/MainBarPages/settings.dart';
import 'package:flutter/material.dart';

import 'MainBarPages/ObjectBasePages/dish_base.dart';
import 'MainBarPages/ObjectBasePages/product_base.dart';

//void main() => runApp(MaterialApp(
//  home: какой-то класс
//));

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Хлебные единицы',
    initialRoute: 'main_bar',
    routes: {
      'main_bar': (context) => MainBarClass(), // нижняя панель навигации основного меню
      'bu_calculate': (context) => BUCalculateClass(), // калькулятор ХЕ, создание приема пищи
      'object_base': (context) => ObjectBaseClass(), // база продуктов и блюд
      'history': (context) => HistoryClass(), // сохранение истории потребления
      'settings': (context) => SettingsClass(), // настройки
      'product_base': (context) => ProductBaseClass(), // база продуктов
      'dish_base': (context) => DishBaseClass(), // база блюд
      'composition_base': (context) => CompositionClass(),
    //  'create_set': (context) =>
    },
  ));
}
