import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/random_string.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/model/user_notification.dart';
import 'package:wigoyu/model/user_voucher.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';

class PaymentConfirm extends StatefulWidget {
  const PaymentConfirm({super.key, required this.title});
  static const String routeName = '/payment-confirm';
  final int title;

  @override
  State<PaymentConfirm> createState() => _PaymentConfirmState();
}

class _PaymentConfirmState extends State<PaymentConfirm> {
  late User user;
  Future<Map<String, dynamic>>? _paymentResult;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<User>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        context.pushReplacementTransition(
            child: BottomNavigation(), type: PageTransitionType.rightToLeft);
        return;
      }
      user = userProvider;
    });
    _paymentResult = _checkPayment();
  }

  Future<Map<String, dynamic>> _checkPayment() async {
    UserVoucher? voucher = await _getVoucher(widget.title);

    if (voucher == null) {
      user.updateNotification(
          user.userId!,
          UserNotification(
              name: "Pembayaran Gagal",
              text: "Voucher tidak ditemukan",
              open: false,
              id: generateRandomNumberString(6)));
      return {"CODE": "VOUCHER_NOT_FOUND", "message": "Produk tidak ditemukan"};
    }

    int userSaldo = int.parse(user.saldo ?? '0'); // Ambil saldo user
    int hargaVoucher = voucher.price!; // Harga voucher

    if (userSaldo < hargaVoucher) {
      user.updateNotification(
          user.userId!,
          UserNotification(
              name: "Pembayaran Gagal",
              text: "Saldo tidak mencukupi",
              open: false,
              id: generateRandomNumberString(6)));
      return {
        "CODE": "INSUFFICIENT_BALANCE",
        "message": "Saldo tidak mencukupi"
      };
    }

    // Jika saldo cukup, kurangi saldo user
    final saldoFinal = (userSaldo - hargaVoucher).toString();
    await user.updateSaldo(user.userId!, saldoFinal);
    await user.updateNotification(
        user.userId!,
        UserNotification(
            name: "Pembayaran Berhasil",
            text:
                'Pembayaran berhasil dengan total Rp.${_formatter.format(voucher.price)} sisa saldo kamu saat ini adalah Rp.${_formatter.format(userSaldo - hargaVoucher)}.',
            open: false,
            id: generateRandomNumberString(6)));
    await user.updateNotification(
        user.userId!,
        UserNotification(
            name: "Pembelian Berhasil",
            text:
                'Pembeluan berhasil untuk voucher ${voucher.name} dengan harga Rp.${_formatter.format(voucher.price)} bisa kamu periksa di menu voucher.',
            open: false,
            id: generateRandomNumberString(6)));
    await user.updateVoucher(user.userId!, voucher.id!);
    return {"CODE": "SUCCESS", "message": "Pembayaran berhasil"};
  }

  Future<UserVoucher?> _getVoucher(int voucherId) async {
    await Future.delayed(const Duration(seconds: 1));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();
    for (var product in products) {
      for (var voucher in product.voucher) {
        if (voucher.id == voucherId) {
          return voucher;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.putih,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height < 300
                          ? 300
                          : MediaQuery.of(context).size.height - 200,
                      child: FutureBuilder<Map<String, dynamic>>(
                          future: _paymentResult,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 200,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      )),
                                  Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 300,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      )),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(snapshot.error.toString()),
                              );
                            }
                            final Map<String, dynamic> data = snapshot.data!;
                            if (data['CODE'] == 'VOUCHER_NOT_FOUND') {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 15,
                                children: [
                                  Icon(
                                    Icons.error,
                                    size: 100,
                                    color: Colors.red,
                                  ),
                                  Center(
                                    child: Text(
                                      data['message'],
                                      style: GoogleFonts.poppins(fontSize: 20),
                                    ),
                                  ),
                                ],
                              );
                            }
                            if (data['CODE'] == 'INSUFFICIENT_BALANCE') {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 15,
                                children: [
                                  Icon(
                                    Icons.warning,
                                    size: 100,
                                    color: Colors.orangeAccent,
                                  ),
                                  Center(
                                    child: Text(
                                      data['message'],
                                      style: GoogleFonts.poppins(fontSize: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamedTransition(
                                          routeName: '/top-up',
                                          type: PageTransitionType.rightToLeft);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: AppColors.biruTua,
                                          size: 18,
                                        ),
                                        Text(
                                          'Top Up Saldo',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.biruTua),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }

                            if (data['CODE'] == 'SUCCESS') {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 15,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 100,
                                    color: Colors.green,
                                  ),
                                  Center(
                                    child: Text(
                                      data['message'],
                                      style: GoogleFonts.poppins(fontSize: 20),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamedTransition(
                                          routeName: '/',
                                          type: PageTransitionType.rightToLeft,
                                          arguments: 2);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: AppColors.biruTua,
                                          size: 18,
                                        ),
                                        Text(
                                          'Periksa Voucher',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.biruTua),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['message'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Kembali'),
                                ),
                              ],
                            );
                          }),
                    ),
                  ),
                ],
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.putih,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(100),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: FutureBuilder(
                          future: _paymentResult,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 100,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      )),
                                  Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 100,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      )),
                                ],
                              );
                            }
                            if (snapshot.hasError) {
                              return const SizedBox();
                            }

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    backgroundColor: AppColors.putih,
                                    side: BorderSide(
                                        color: Colors.grey.withAlpha(70)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.pushReplacementTransition(
                                        child: BottomNavigation(),
                                        type: PageTransitionType.rightToLeft);
                                  },
                                  child: Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.home, color: Colors.grey),
                                      Text('Tutup',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                          ))
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    backgroundColor: AppColors.biruTua,
                                    side: BorderSide(
                                        color: Colors.grey.withAlpha(70)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.arrow_back_ios,
                                          color: AppColors.putih, size: 20),
                                      Text('Kembali',
                                          style: GoogleFonts.poppins(
                                              color: AppColors.putih)),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }))),
            ],
          ),
        ));
  }
}
