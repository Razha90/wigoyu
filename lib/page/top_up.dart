import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/model/payment_method_dart';

class TopUp extends StatefulWidget {
  const TopUp({super.key});
  static const String routeName = '/top-up';

  @override
  State<TopUp> createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  late Future<List<PaymentMethod>> _futureTopUp;
  String _isOpened = "";
  int _selectedPayment = 0;

  @override
  void initState() {
    super.initState();
    _futureTopUp = fetchNewMerchant();
  }

  Future<List<PaymentMethod>> fetchNewMerchant() async {
    final String response =
        await rootBundle.loadString('assets/data/payment.json');

    final List<dynamic> jsonData = json.decode(response);
    return jsonData.map((json) => PaymentMethod.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        shadowColor: Colors.grey.withAlpha(150),
        backgroundColor: AppColors.putih,
        title: Text('Isi Saldo'),
      ),
      body: SafeArea(
        top: true,
        bottom: true,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                    child: FutureBuilder<List<PaymentMethod>>(
                        future: _futureTopUp,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            final List<PaymentMethod> bankList = snapshot.data!
                                .where((item) => item.type == "bank")
                                .toList();
                            final List<PaymentMethod> primaryList = snapshot
                                .data!
                                .where((item) => item.type == "primary")
                                .toList();
                            final List<PaymentMethod> walletList = snapshot
                                .data!
                                .where((item) => item.type == "wallet")
                                .toList();

                            return Column(children: [
                              GestureDetector(
                                onTap: () {
                                  if (_isOpened == "bank") {
                                    setState(() {
                                      _isOpened = "";
                                      _selectedPayment = 0;
                                    });
                                  } else {
                                    setState(() {
                                      _isOpened = "bank";
                                      _selectedPayment = 0;
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                      color: _isOpened == "bank"
                                          ? AppColors.hijauMuda.withAlpha(50)
                                          : AppColors.putih,
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withAlpha(50))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          spacing: 10,
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  AppColors.hijauMuda,
                                              child: Image.asset(
                                                'assets/icons/bank.png',
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                            Text(
                                              'Bank',
                                              style: GoogleFonts.jaldi(
                                                fontSize: 22,
                                              ),
                                            )
                                          ],
                                        ),
                                        AnimatedRotation(
                                          turns: _isOpened == "bank"
                                              ? -0.50
                                              : -0.25, // 0.5 berarti 180 derajat
                                          duration: Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons
                                                .keyboard_arrow_left, // Gunakan satu ikon dan rotasi saja
                                            color: AppColors.hijauMuda,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _isOpened == "bank"
                                    ? Column(
                                        children: bankList
                                            .map((item) => ListTile(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 40, right: 20),
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedPayment =
                                                          item.id;
                                                    });
                                                  },
                                                  leading: Image.asset(
                                                      item.icon,
                                                      width: 40,
                                                      height: 40),
                                                  title: Text(item.name),
                                                  selected: item.id ==
                                                      _selectedPayment,
                                                  selectedTileColor: AppColors
                                                      .hijauMuda
                                                      .withAlpha(50),
                                                  hoverColor:
                                                      AppColors.hijauMuda,
                                                  splashColor: AppColors
                                                      .hijauMuda
                                                      .withAlpha(50),
                                                  selectedColor:
                                                      AppColors.hijauMuda,
                                                  trailing: item.id ==
                                                          _selectedPayment
                                                      ? Icon(
                                                          Icons.check_circle,
                                                          size: 20,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .radio_button_unchecked,
                                                          size: 20,
                                                          color: Colors.green
                                                              .withAlpha(100),
                                                        ),
                                                ))
                                            .toList(),
                                      )
                                    : SizedBox(), // Jika tidak terbuka, ukuran menjadi 0
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (_isOpened == "wallet") {
                                    setState(() {
                                      _isOpened = "";
                                      _selectedPayment = 0;
                                    });
                                  } else {
                                    setState(() {
                                      _isOpened = "wallet";
                                    });
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                      color: _isOpened == "wallet"
                                          ? AppColors.hijauMuda.withAlpha(50)
                                          : AppColors.putih,
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey.withAlpha(50))),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          spacing: 10,
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  AppColors.hijauMuda,
                                              child: Icon(
                                                Icons.account_balance_wallet,
                                                color: AppColors.putih,
                                                size: 25,
                                              ),
                                            ),
                                            Text(
                                              'E-Wallet',
                                              style: GoogleFonts.jaldi(
                                                fontSize: 22,
                                              ),
                                            )
                                          ],
                                        ),
                                        AnimatedRotation(
                                          turns: _isOpened == "wallet"
                                              ? -0.50
                                              : -0.25, // 0.5 berarti 180 derajat
                                          duration: Duration(milliseconds: 300),
                                          child: Icon(
                                            Icons
                                                .keyboard_arrow_left, // Gunakan satu ikon dan rotasi saja
                                            color: AppColors.hijauMuda,
                                            size: 30,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: _isOpened == "wallet"
                                    ? Column(
                                        children: walletList
                                            .map((item) => ListTile(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          left: 40, right: 20),
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedPayment =
                                                          item.id;
                                                    });
                                                  },
                                                  leading: Image.asset(
                                                      item.icon,
                                                      width: 40,
                                                      height: 40),
                                                  title: Text(item.name),
                                                  selected: item.id ==
                                                      _selectedPayment,
                                                  selectedTileColor: AppColors
                                                      .hijauMuda
                                                      .withAlpha(50),
                                                  hoverColor:
                                                      AppColors.hijauMuda,
                                                  splashColor: AppColors
                                                      .hijauMuda
                                                      .withAlpha(50),
                                                  selectedColor:
                                                      AppColors.hijauMuda,
                                                  trailing: item.id ==
                                                          _selectedPayment
                                                      ? Icon(
                                                          Icons.check_circle,
                                                          size: 20,
                                                        )
                                                      : Icon(
                                                          Icons
                                                              .radio_button_unchecked,
                                                          size: 20,
                                                          color: Colors.green
                                                              .withAlpha(100),
                                                        ),
                                                ))
                                            .toList(),
                                      )
                                    : SizedBox(), // Jika tidak terbuka, ukuran menjadi 0
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Column(
                                  children: primaryList
                                      .map((item) => ListTile(
                                            contentPadding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            onTap: () {
                                              setState(() {
                                                _selectedPayment = item.id;
                                              });
                                              if (_isOpened.isNotEmpty) {
                                                setState(() {
                                                  _isOpened = "";
                                                });
                                              }
                                            },
                                            leading: Image.asset(item.icon,
                                                width: 40, height: 40),
                                            title: Text(item.name),
                                            selected:
                                                item.id == _selectedPayment,
                                            selectedTileColor: AppColors
                                                .hijauMuda
                                                .withAlpha(50),
                                            hoverColor: AppColors.hijauMuda,
                                            splashColor: AppColors.hijauMuda
                                                .withAlpha(50),
                                            selectedColor: AppColors.hijauMuda,
                                            trailing:
                                                item.id == _selectedPayment
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        size: 20,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .radio_button_unchecked,
                                                        size: 20,
                                                        color: Colors.green
                                                            .withAlpha(100),
                                                      ),
                                          ))
                                      .toList(),
                                ), // Jika tidak terbuka, ukuran menjadi 0
                              ),
                              AnimatedSize(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: ListTile(
                                    contentPadding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    onTap: () {
                                      setState(() {
                                        _selectedPayment = 6565;
                                      });
                                      if (_isOpened.isNotEmpty) {
                                        setState(() {
                                          _isOpened = "";
                                        });
                                      }
                                    },
                                    leading: Icon(
                                      Icons.add,
                                      size: 40,
                                      color: AppColors.hijauMuda,
                                    ),
                                    title: Text("Developer Mode"),
                                    selected: 6565 == _selectedPayment,
                                    selectedTileColor:
                                        AppColors.hijauMuda.withAlpha(50),
                                    hoverColor: AppColors.hijauMuda,
                                    splashColor:
                                        AppColors.hijauMuda.withAlpha(50),
                                    selectedColor: AppColors.hijauMuda,
                                    trailing: 6565 == _selectedPayment
                                        ? Icon(
                                            Icons.check_circle,
                                            size: 20,
                                          )
                                        : Icon(
                                            Icons.radio_button_unchecked,
                                            size: 20,
                                            color: Colors.green.withAlpha(100),
                                          ),
                                  ))
                            ]);
                          }
                        }))
              ],
            ),
            Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  height: 70,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(150),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                    color: AppColors.putih,
                  ),
                  child: Align(
                      child: SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width > 360
                        ? 360
                        : MediaQuery.of(context).size.width,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _selectedPayment == 0
                            ? Colors.grey.shade400
                            : AppColors.hijauMuda,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor: Colors.transparent,
                        ),
                        onPressed: () {
                          // Navigator.pushNamed(context, '/payment');
                          if (_selectedPayment == 6565) {
                            context.pushNamedTransition(
                                routeName: '/topup-section',
                                type: PageTransitionType.rightToLeft,
                                arguments: _selectedPayment);
                          } else {
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.info,
                              title: "Tahap Pengembangan",
                              text:
                                  "Mohon maaf, fitur ini masih dalam tahap pengembangan. Saat ini hanya fitur Developer Mode yang dapat digunakan.",
                            );
                            setState(() {
                              _selectedPayment = 6565;
                              _isOpened = "";
                            });
                          }
                        },
                        child: Text(
                          'Konfirmasi',
                          style: GoogleFonts.poppins(
                              color: AppColors.putih, fontSize: 18),
                        ),
                      ),
                    ),
                  )),
                )),
          ],
        ),
      ),
    );
  }
}
