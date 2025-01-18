import 'package:flutter/material.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/navigation/home.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});
  static const String routeName = '/';
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    Center(child: Text('Search Page')),
    Center(child: Text('Profile Page')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Menampilkan halaman berdasarkan indeks
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Indeks aktif
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengubah halaman saat item dipilih
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/home.png',
              width: 30,
              fit: BoxFit.contain,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: AppColors.putih,
        selectedFontSize: 12,
        unselectedFontSize: 10,
      ),
    );
  }
}
