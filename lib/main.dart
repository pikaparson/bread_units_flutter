import 'package:bread_units/MainBarPages/bu_calculate.dart';
import 'package:bread_units/MainBarPages/history.dart';
import 'package:bread_units/MainBarPages/main_bar.dart';
import 'package:bread_units/MainBarPages/object_base.dart';
import 'package:bread_units/MainBarPages/settings.dart';
import 'package:flutter/material.dart';

//void main() => runApp(MaterialApp(
//  home: какой-то класс
//));

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Хлебные единицы',
    initialRoute: 'main_bar',
    routes: {
      'main_bar': (context) => MainBarClass(),
      'bu_calculate': (context) => BUCalculateClass(),
      'object_base': (context) => ObjectBaseClass(),
      'history': (context) => HistoryClass(),
      'settings': (context) => SettingsClass(),
    //  'create_set': (context) =>
    },
  ));
}
