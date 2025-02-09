import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/navigation/home.dart';
import 'package:wigoyu/navigation/profile.dart';
import 'package:wigoyu/navigation/special_offer.dart';
import 'package:wigoyu/navigation/voucher.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, this.initialIndex});
  static const String routeName = '/';
  final int? initialIndex;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  final List<Widget?> _pages = [null, null, null, null];

  // final List<Widget> _pages = [
  //   Home(),
  //   SpecialOffer(),
  //   Voucher(),
  //   Profile(),
  // ];

  @override
  void initState() {
    super.initState();
    // if (widget.initialIndex != null) {
    //   _currentIndex = widget.initialIndex!;
    // }

    if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!;
    }
    _pages[_currentIndex] = _buildPage(_currentIndex);
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return Home();
      case 1:
        return SpecialOffer();
      case 2:
        return Voucher();
      case 3:
        return Profile();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        // index: _currentIndex,
        // children: _pages,
        index: _currentIndex,
        children: List.generate(_pages.length, (index) {
          return _pages[index] ?? SizedBox();
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.hijauMuda),
        unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.biruMuda),
        selectedItemColor: AppColors.hijauMuda,
        unselectedItemColor: AppColors.biruMuda,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex, // Indeks aktif
        onTap: (index) {
          // setState(() {
          //   _currentIndex = index;
          // });
          setState(() {
            _currentIndex = index;
            if (_pages[index] == null) {
              _pages[index] = _buildPage(index);
            }
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
              icon: Icon(Icons.thumb_up),
              label: 'Spesial Offer',
              activeIcon: Icon(Icons.thumb_up)),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined),
              label: 'Voucher',
              activeIcon: Icon(Icons.local_offer)),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Saya',
          ),
        ],
        backgroundColor: AppColors.putih,
        selectedFontSize: 12,
        unselectedFontSize: 10,
      ),
    );
  }
}
