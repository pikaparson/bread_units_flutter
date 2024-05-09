import 'package:flutter/material.dart';

import 'calculate_dish.dart';
import 'calculate_product.dart';

class CalculateNavigationClass extends StatefulWidget {
  const CalculateNavigationClass({super.key});

  @override
  State<CalculateNavigationClass> createState() => _CalculateNavigationClassState();
}

class _CalculateNavigationClassState extends State<CalculateNavigationClass> {

  var _currentPage = 1;
  final List<Widget> _pages = [
    CalculateProductClass(),
    CalculateDishClass(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: _pages.elementAt(_currentPage)
      ),

      bottomNavigationBar: BottomNavigationBar(
        // type: BottomNavigationBarType.shifting,
        backgroundColor: Colors.orange[200],
        items: [
          BottomNavigationBarItem(
              icon: ImageIcon(AssetImage('assets/icons/carrot_icon.png'),
                //  color: Colors.white,
              ),
              backgroundColor: Colors.orange[200],
              label: 'Продукты'
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/icons/dish_icon.png'),
              //  color: Colors.white,
            ),
            backgroundColor: Colors.orange[200],
            label: 'Блюда',
          )
        ],
        currentIndex: _currentPage,
        selectedItemColor: Colors.orange[900],
        unselectedItemColor: Colors.white,
        //fixedColor: Colors.white,
        onTap: (int intIndex) {
          setState(() {
            _currentPage = intIndex;
          });
        },
      ),
    );
  }
}
