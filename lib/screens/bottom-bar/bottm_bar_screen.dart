import 'package:flutter/material.dart';
import 'package:trackora/core/constants/app_colors.dart';

import '../home/home_screen.dart';
import '../more/app_drawer.dart';
import '../tasks/tasks_screen.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  static final scaffoldKey = GlobalKey<ScaffoldState>();
  static void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    Scaffold(body: Center(child: Text('Customers'))),
    TasksScreen(),
  ];

  void _onTabTap(int i) {
    if (i == 3) {
      BottomBarScreen.openDrawer();
      return;
    }
    setState(() => index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: BottomBarScreen.scaffoldKey,
      drawer: const AppDrawer(),
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: _onTabTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.appColor,
        unselectedItemColor: AppColors.textGrey,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Inter_Medium',
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter_Regular',
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
      ),
    );
  }
}