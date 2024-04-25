import 'package:bread_units/MainBarPages/bu_calculate.dart';
import 'package:bread_units/MainBarPages/history.dart';
import 'package:bread_units/MainBarPages/navigation_object_base.dart';
import 'package:bread_units/MainBarPages/settings.dart';
import 'package:flutter/material.dart';

class MainBarClass extends StatefulWidget {
  const MainBarClass({super.key});

  @override
  State<MainBarClass> createState() => _MainBarClassState();
}

class _MainBarClassState extends State<MainBarClass> {

  void _onItemTapped(int index) {
    if (index == 3) {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ObjectBaseClass();
            },
          ),
        );
      });
    };
  }

  var _currentPage = 2;
  final List<Widget> _pages = [
    SettingsClass(),
    HistoryClass(),
    BUCalculateClass(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_currentPage),
      ),

      bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.orange[200],
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.orange[200],
            icon: Icon(Icons.settings,
           //   color: Colors.black,
            ),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.orange[200],
              icon: Icon(Icons.history,
             //   color: Colors.black,
              ),
              label: 'История',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.orange[200],
            icon: Icon(Icons.calculate,
           //   color: Colors.black,
            ),
            label: 'Калькулятор',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.orange[200],
            icon: Icon(Icons.stacked_line_chart,
           //   color: Colors.black,
            ),
            label: 'База',
          ),
        ],
        currentIndex: _currentPage,
        selectedItemColor: Colors.orange[900],
        unselectedItemColor: Colors.white,
       // fixedColor: Colors.white,
        onTap: (int intIndex) {
          setState(() {
            if (intIndex == 3)
              {
                _onItemTapped(3);
                _currentPage = 0;
              }
            else {
              _currentPage = intIndex;
            }
          });
        }),
    );
  }
}