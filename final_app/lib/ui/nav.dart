import 'package:final_app/ui/cinema_page.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';
import 'browsing_page.dart';
import 'account_page.dart';

class Nav extends StatefulWidget {
  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    Home(),
    BrowsingPage(),
    CinemaPage(),
    AccountPage(message: ''),
  ];

  double _getIconSize(int index) {
    return index == _selectedIndex ? 36.0 : 24.0;
  }

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green, // Set selected item color to green
        unselectedItemColor: Colors.blue, // Set unselected item color to blue
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: _getIconSize(0),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.movie,
              size: _getIconSize(1),
            ),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
              size: _getIconSize(2),
            ),
            label: 'Cinema Page',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: _getIconSize(3),
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
      ),
    );
  }
}
