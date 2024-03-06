import 'package:bread_units/MainBarPages/bu_calculate.dart';
import 'package:bread_units/MainBarPages/history.dart';
import 'package:bread_units/MainBarPages/object_base.dart';
import 'package:bread_units/MainBarPages/settings.dart';
import 'package:flutter/material.dart';

class MainBarClass extends StatefulWidget {
  const MainBarClass({super.key});

  @override
  State<MainBarClass> createState() => _MainBarClassState();
}

class _MainBarClassState extends State<MainBarClass> {

  var _currentPage = 0;

  final List<Widget> _pages = [
    HistoryClass(),
    BUCalculateClass(),
    ObjectBaseClass(),
    SettingsClass()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_currentPage),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'История',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Калькулятор',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_line_chart),
            label: 'База',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'История',
          ),
        ],
        currentIndex: _currentPage,
        fixedColor: Colors.blueGrey,
        onTap: (int intIndex) {
          setState(() {
            _currentPage = intIndex;
          });
        }),
    );
  }
}
