import 'package:flutter/material.dart';
import 'package:wigoyu/app_color.dart';

class SpecialOffer extends StatefulWidget {
  const SpecialOffer({super.key});

  @override
  State<SpecialOffer> createState() => _SpecialOfferState();
}

class _SpecialOfferState extends State<SpecialOffer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      body: Center(
        child: Text('Special Offer Page'),
      ),
    );
  }
}
