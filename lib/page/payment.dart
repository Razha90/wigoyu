import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/item_product.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.title});
  static const String routeName = '/payment';
  final int title;
  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late User user;
  final formatCurrency = NumberFormat("#,###", "id_ID");
  late Future<Voucher?> _setVoucher;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<User>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        context.pushNamedTransition(
            routeName: '/login', type: PageTransitionType.rightToLeft);
        return;
      }
      setState(() {
        user = userProvider;
      });
    });
    _setVoucher = _getVoucher(widget.title);
  }

  Future<Voucher?> _getVoucher(int voucherId) async {
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

  void _checkSaldo() async {
    Voucher? voucher = await _setVoucher; // Tunggu hingga Future selesai

    if (voucher == null) {
      print("Voucher tidak ditemukan.");
      return;
    }

    int saldoUser = int.parse(user.saldo ?? "0");

    if (saldoUser < voucher.price) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Saldo Tidak Cukup'),
              content: Text('Saldo anda tidak mencukupi untuk membeli voucher'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                )
              ],
            );
          },
        );
      }
    }
  }

  void _refreshData() {
    setState(() {
      _setVoucher = _getVoucher(widget.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        backgroundColor: AppColors.putih,
        title: Text("Pembayaran"),
      ),
      body: RefreshIndicator(
        displacement: 20,
        color: AppColors.hijauMuda,
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          _refreshData();
        },
        child: Stack(children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: FutureBuilder<Voucher?>(
                    future: _setVoucher,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 30),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 200,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                              SizedBox(height: 10),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 200,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                              SizedBox(height: 30),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 300,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                              SizedBox(height: 40),
                              Divider(),
                              SizedBox(height: 40),
                              Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.data == null) {
                        return const Center(child: Text('Data not found'));
                      }
                      final Voucher voucher = snapshot.data!;
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Rp.  ${formatCurrency.format(voucher.price)}',
                              style: GoogleFonts.barlow(fontSize: 40),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: AppColors.hitam.withAlpha(150),
                                  size: 20,
                                ),
                                Text(voucher.name, style: GoogleFonts.jaldi()),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              voucher.description,
                              style: GoogleFonts.jaldi(fontSize: 20),
                            ),
                            SizedBox(height: 50),
                            Divider(),
                            SizedBox(height: 50),
                            CouponCard(
                                height: 130,
                                curveAxis: Axis.vertical,
                                curvePosition: 200,
                                // backgroundColor: AppColors.hijauMuda,
                                decoration:
                                    BoxDecoration(color: AppColors.putih),
                                firstChild: Container(
                                  decoration:
                                      BoxDecoration(color: AppColors.hijauMuda),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "${voucher.discount}%",
                                          style: GoogleFonts.poppins(
                                              color: AppColors.putih,
                                              fontSize: 35,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Divider(
                                          color: AppColors.putih,
                                        ),
                                        Text(
                                          voucher.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: AppColors.putih,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                secondChild: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          AppColors.hijauMuda.withAlpha(120)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Rp.${formatCurrency.format(voucher.price)}",
                                        style: GoogleFonts.poppins(
                                            color: AppColors.hijauTua,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ))
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
          Positioned(
              bottom: 0,
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(40),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, -3),
                      ),
                    ],
                    color: AppColors.putih,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: FutureBuilder<Voucher?>(
                          future: _setVoucher,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 130,
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
                                        width: 130,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ))
                                ],
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text(
                                      "Terjadi kesalahan: ${snapshot.error}")); // Error state
                            } else if (!snapshot.hasData ||
                                snapshot.data == null) {
                              return const Center(
                                  child: Text(
                                      "Voucher tidak tersedia")); // Data null
                            } else {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer<User>(
                                      builder: (context, user, child) {
                                    return Row(
                                      children: [
                                        Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(10),
                                              ),
                                              border: Border.all(
                                                  color: AppColors.hitam
                                                      .withAlpha(40)),
                                            ),
                                            child: Icon(Icons.wallet)),
                                        SizedBox(width: 10),
                                        Text(
                                          'Rp. ',
                                          style:
                                              GoogleFonts.jaldi(fontSize: 14),
                                        ),
                                        Text(
                                          formatCurrency.format(
                                              int.parse(user.saldo ?? "0")),
                                          style:
                                              GoogleFonts.jaldi(fontSize: 18),
                                        ),
                                      ],
                                    );
                                  }),
                                  IconButton(
                                      style: ButtonStyle(
                                          overlayColor: WidgetStateProperty.all(
                                              AppColors.biruMuda),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                                  AppColors.biruTua)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      onPressed: () {
                                        _checkSaldo();
                                      },
                                      icon: Row(
                                        spacing: 5,
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            color: AppColors.putih,
                                          ),
                                          Text('Beli Voucher',
                                              style: GoogleFonts.jaldi(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.putih))
                                        ],
                                      ))
                                ],
                              );
                            }
                          }))))
        ]),
      ),
    );
  }
}
