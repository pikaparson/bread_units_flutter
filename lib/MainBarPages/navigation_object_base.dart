import 'package:flutter/material.dart';

import 'ObjectBasePages/dish_base.dart';
import 'ObjectBasePages/product_base.dart';
class ObjectBaseClass extends StatefulWidget {
  const ObjectBaseClass({super.key});

  @override
  State<ObjectBaseClass> createState() => _ObjectBaseClassState();
}

class _ObjectBaseClassState extends State<ObjectBaseClass> {

  var _currentPage = 0;
  final List<Widget> _pages = [
    ProductBaseClass(),
    DishBaseClass(),
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
