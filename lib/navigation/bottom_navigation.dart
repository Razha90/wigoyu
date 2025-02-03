import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/navigation/home.dart';
import 'package:wigoyu/navigation/profile.dart';
import 'package:wigoyu/navigation/voucher.dart';
import 'package:wigoyu/page/special_offer.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, this.initialIndex});
  static const String routeName = '/';
  final int? initialIndex;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Home(),
    SpecialOffer(),
    Voucher(),
    Profile(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      _currentIndex = widget.initialIndex!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Menjaga halaman yang sedang aktif
        children: _pages,
      ), // Menampilkan halaman berdasarkan indeks
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
            icon: Image.asset(
              'assets/icons/spesial_biru.png',
              width: 22,
              fit: BoxFit.contain,
            ),
            label: 'Spesial Offer',
            activeIcon: Image.asset(
              'assets/icons/spesial_hijau.png',
              width: 22,
              fit: BoxFit.contain,
            ),
          ),
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
