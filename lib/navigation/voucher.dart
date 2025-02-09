import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:wigoyu/model/user_voucher.dart';
import 'package:wigoyu/page/payment.dart';

class Voucher extends StatefulWidget {
  const Voucher({super.key});

  @override
  State<Voucher> createState() => _VoucherState();
}

class _VoucherState extends State<Voucher> with SingleTickerProviderStateMixin {
  final formatCurrency = NumberFormat("#,###", "id_ID");
  List menu = ["Voucher", "Sudah Digunakan"];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _tabController = TabController(length: menu.length, vsync: this);
    }
  }

  Future<ItemProduct?> _getParentProduct(int voucherId) async {
    await Future.delayed(Duration(seconds: 1));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();

    for (var product in products) {
      for (var voucher in product.voucher) {
        if (voucher.id == voucherId) {
          return product;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: AppColors.putih,
          body: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.hijauMuda, AppColors.biruMuda],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  top: true,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      TabBar(
                        indicatorColor: AppColors.putih,
                        physics: ScrollPhysics(),
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: AppColors.putih,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        labelColor: AppColors.hijauMuda,
                        unselectedLabelColor: AppColors.abuMuda,
                        overlayColor:
                            WidgetStatePropertyAll(AppColors.hijauMuda),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Voucher',
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Tab(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20), // Pastikan tinggi cukup
                              child: Text('Digunakan',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    menu.length,
                    (index) => Consumer<User>(builder: (context, user, child) {
                      if (!user.isLoggedIn) {
                        return Center(
                          child: Text(
                            "Tiada data",
                            style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.hijauMuda),
                          ),
                        );
                      }
                      if (user.voucher == null || user.voucher!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Voucher Kosong",
                                style: GoogleFonts.poppins(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }

                      if (index == 0) {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              spacing: 20,
                              children: List.generate(user.voucher?.length ?? 0,
                                  (index) {
                                return FutureBuilder<ItemProduct?>(
                                  future:
                                      _getParentProduct(user.voucher![index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ));
                                    } else if (snapshot.hasError) {
                                      return Text(
                                          "Error: ${snapshot.error}"); // Menampilkan error
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Text(
                                          "Voucher tidak ditemukan"); // Jika data kosong/null
                                    }
                                    final parentData = snapshot.data!;
                                    final UserVoucher voucher = parentData
                                        .voucher
                                        .firstWhere((element) =>
                                            element.id == user.voucher![index]);

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.putih,
                                        borderRadius: BorderRadius.circular(10),
                                        border: BoxBorder.lerp(
                                            Border.all(
                                                color: AppColors.abuMuda
                                                    .withAlpha(200),
                                                width: 1),
                                            Border.all(
                                                color: AppColors.abuMuda
                                                    .withAlpha(200),
                                                width: 1),
                                            0.5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          spacing: 10,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                context.pushNamedTransition(
                                                  routeName: '/product',
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  arguments: {
                                                    "title": parentData.name
                                                  },
                                                );
                                              },
                                              child: Row(
                                                spacing: 10,
                                                children: [
                                                  CircleAvatar(
                                                    radius:
                                                        20, // Ukuran lingkaran
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            parentData.image[0],
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Shimmer.fromColors(
                                                                baseColor:
                                                                    Colors.grey[
                                                                        300]!,
                                                                highlightColor:
                                                                    Colors.grey[
                                                                        100]!,
                                                                child:
                                                                    Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                )),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    parentData.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            CouponCard(
                                                height: 130,
                                                curveAxis: Axis.vertical,
                                                curvePosition: 200,
                                                // backgroundColor: AppColors.hijauMuda,
                                                decoration: BoxDecoration(
                                                    color: AppColors.putih),
                                                firstChild: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          AppColors.hijauMuda),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "${voucher.discount}%",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      AppColors
                                                                          .putih,
                                                                  fontSize: 35,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        Divider(
                                                          color:
                                                              AppColors.putih,
                                                        ),
                                                        Text(
                                                          voucher.name!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color:
                                                                AppColors.putih,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                secondChild: Container(
                                                  decoration: BoxDecoration(
                                                      color: AppColors.hijauMuda
                                                          .withAlpha(120)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              overlayColor:
                                                                  AppColors
                                                                      .putih,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .biruMuda
                                                                      .withAlpha(
                                                                          180),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          5),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10)))),
                                                          onPressed: () {
                                                            context
                                                                .pushNamedTransition(
                                                              routeName:
                                                                  '/change-qris',
                                                              type: PageTransitionType
                                                                  .rightToLeftWithFade,
                                                              arguments:
                                                                  voucher.id,
                                                            );
                                                          },
                                                          child: Text(
                                                            "Gunakan",
                                                            style: GoogleFonts.barlow(
                                                                color: AppColors
                                                                    .putih,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ))
                                                    ],
                                                  ),
                                                )),
                                            voucher.price == 0
                                                ? Text(
                                                    "Gratis",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        color:
                                                            AppColors.biruMuda,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Rp. ",
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .biruMuda),
                                                      ),
                                                      Text(
                                                        formatCurrency.format(
                                                            voucher.price),
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 22,
                                                                color: AppColors
                                                                    .biruMuda,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              spacing: 20,
                              children: List.generate(
                                  user.historyVoucher?.length ?? 0, (index) {
                                return FutureBuilder<ItemProduct?>(
                                  future:
                                      _getParentProduct(user.voucher![index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 220,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ));
                                    } else if (snapshot.hasError) {
                                      return Text(
                                          "Error: ${snapshot.error}"); // Menampilkan error
                                    } else if (!snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Text(
                                          "Voucher tidak ditemukan"); // Jika data kosong/null
                                    }
                                    final parentData = snapshot.data!;
                                    final UserVoucher voucher = parentData
                                        .voucher
                                        .firstWhere((element) =>
                                            element.id == user.voucher![index]);

                                    return Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.putih,
                                        borderRadius: BorderRadius.circular(10),
                                        border: BoxBorder.lerp(
                                            Border.all(
                                                color: AppColors.abuMuda
                                                    .withAlpha(200),
                                                width: 1),
                                            Border.all(
                                                color: AppColors.abuMuda
                                                    .withAlpha(200),
                                                width: 1),
                                            0.5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          spacing: 10,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                context.pushNamedTransition(
                                                  routeName: '/product',
                                                  type: PageTransitionType
                                                      .rightToLeftWithFade,
                                                  arguments: {
                                                    "title": parentData.name
                                                  },
                                                );
                                              },
                                              child: Row(
                                                spacing: 10,
                                                children: [
                                                  CircleAvatar(
                                                    radius:
                                                        20, // Ukuran lingkaran
                                                    child: ClipOval(
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            parentData.image[0],
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context,
                                                                url) =>
                                                            Shimmer.fromColors(
                                                                baseColor:
                                                                    Colors.grey[
                                                                        300]!,
                                                                highlightColor:
                                                                    Colors.grey[
                                                                        100]!,
                                                                child:
                                                                    Container(
                                                                  width: 50,
                                                                  height: 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                )),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    parentData.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            CouponCard(
                                                height: 130,
                                                curveAxis: Axis.vertical,
                                                curvePosition: 200,
                                                // backgroundColor: AppColors.hijauMuda,
                                                decoration: BoxDecoration(
                                                    color: AppColors.putih),
                                                firstChild: Container(
                                                  decoration: BoxDecoration(
                                                      color:
                                                          AppColors.hijauMuda),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "${voucher.discount}%",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color:
                                                                      AppColors
                                                                          .putih,
                                                                  fontSize: 35,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                        ),
                                                        Divider(
                                                          color:
                                                              AppColors.putih,
                                                        ),
                                                        Text(
                                                          voucher.name!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            color:
                                                                AppColors.putih,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                secondChild: Container(
                                                  decoration: BoxDecoration(
                                                      color: AppColors.hijauMuda
                                                          .withAlpha(120)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                              overlayColor:
                                                                  AppColors
                                                                      .putih,
                                                              backgroundColor:
                                                                  AppColors
                                                                      .abuMuda
                                                                      .withAlpha(
                                                                          180),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          5,
                                                                      vertical:
                                                                          5),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              10)))),
                                                          onPressed: () {},
                                                          child: Text(
                                                            "Sudah Digunakan",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: GoogleFonts.barlow(
                                                                color: AppColors
                                                                    .putih,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ))
                                                    ],
                                                  ),
                                                )),
                                            voucher.price == 0
                                                ? Text(
                                                    "Gratis",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        color:
                                                            AppColors.biruMuda,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Rp. ",
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .biruMuda),
                                                      ),
                                                      Text(
                                                        formatCurrency.format(
                                                            voucher.price),
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 22,
                                                                color: AppColors
                                                                    .biruMuda,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                      ),
                                                    ],
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        );
                      }
                    }),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
