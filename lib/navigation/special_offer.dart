import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:corner_ribbon/corner_ribbon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/model/category.dart';
import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/model/user_voucher.dart';

class SpecialOffer extends StatefulWidget {
  const SpecialOffer({super.key});
  @override
  State<SpecialOffer> createState() => _SpecialOfferState();
}

class _SpecialOfferState extends State<SpecialOffer> {
  String title = 'Semua';
  late Future<List<ItemCategory>> _itemCategory;
  late Future<List<ItemProduct>> _itemProduct;
  final formatCurrency = NumberFormat("#,###", "id_ID");

  Future<List<ItemCategory>> _fetchCategory() async {
    final String response =
        await rootBundle.loadString('assets/data/category.json');
    final List<dynamic> data = json.decode(response);

    List<ItemCategory> itemList =
        data.map((json) => ItemCategory.fromJson(json)).toList();

    return itemList;
  }

  // Future<List<ItemCategory>> _fetchCategory() async {
  //   final String response =
  //       await rootBundle.loadString('assets/data/category.json');
  //   final List<dynamic> data = json.decode(response);

  //   List<ItemCategory> itemList =
  //       data.map((json) => ItemCategory.fromJson(json)).toList();

  //   // Menyisipkan kategori baru di awal daftar
  //   itemList.insert(0, ItemCategory(title: "Semua", image: ""));

  //   return itemList;
  // }

  @override
  void initState() {
    super.initState();
    // title = widget.title;
    _itemCategory = _fetchCategory();
    _itemProduct = _fetchSearchItemProduct(title);
  }

  // Future<List<ItemProduct>> _fetchSearchItemProduct(String search) async {
  //   await Future.delayed(const Duration(seconds: 1));
  //   final String response =
  //       await rootBundle.loadString('assets/data/data.json');
  //   final List<dynamic> data = json.decode(response);
  //   final List<ItemProduct> products =
  //       data.map((json) => ItemProduct.fromJson(json)).toList();
  //   final List<ItemProduct> filteredProducts = products
  //       .where((product) =>
  //           product.category.toLowerCase().contains(search.toLowerCase()))
  //       .toList();
  //   return filteredProducts;
  // }

  Future<List<ItemProduct>> _fetchSearchItemProduct(String search) async {
    await Future.delayed(const Duration(seconds: 1));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();

    // Jika search adalah "Semua", kembalikan semua produk
    if (search.toLowerCase() == "semua" || search.isEmpty) {
      return products;
    }

    final List<ItemProduct> filteredProducts = products
        .where((product) =>
            product.category.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return filteredProducts;
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _itemProduct = _fetchSearchItemProduct(title);
    });
  }

  double _calculateFinalPrice(UserVoucher voucher) {
    double discountAmount =
        voucher.price! * (voucher.discount! / 100); // Hitung diskon persentase
    double finalPrice = voucher.price! - discountAmount;
    return finalPrice < 0 ? 0 : finalPrice; // Pastikan harga tidak negatif
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.putih,
        body: SafeArea(
          top: true,
          child: RefreshIndicator(
            displacement: 20,
            color: AppColors.hijauMuda,
            onRefresh: () => _refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      height: 95,
                      child: FutureBuilder<List<ItemCategory>>(
                          future: _itemCategory,
                          builder: (builder, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                color: AppColors.hijauMuda,
                              ));
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Gagal memuat data'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Data tidak ditemukan'));
                            } else {
                              return ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  List<ItemCategory> sortedData =
                                      List.from(snapshot.data!);
                                  sortedData.sort((a, b) {
                                    if (a.title == "Semua" &&
                                        title == "Semua") {
                                      return -1;
                                    }
                                    if (b.title == "Semua" &&
                                        title == "Semua") {
                                      return 1;
                                    }
                                    if (a.title == title) return -1;
                                    if (b.title == title) return 1;
                                    return 0;
                                  });

                                  final ItemCategory item = sortedData[index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        title = item.title;
                                      });
                                      _refresh();
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: index == 0 ? 12 : 8,
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? AppColors.hijauMuda
                                                .withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          AnimatedScale(
                                            scale: index == 0 ? 1.2 : 1.0,
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                            child: Image.asset(
                                              item.image,
                                              width: 50,
                                            ),
                                          ),
                                          AnimatedDefaultTextStyle(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            style: GoogleFonts.jaldi(
                                              fontSize: index == 0 ? 14 : 12,
                                              color: index == 0
                                                  ? AppColors.hijauMuda
                                                  : AppColors.hitam,
                                              fontWeight: index == 0
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                            child: Text(item.title),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Text("Harga Terbaik Selalu untuk Kamu",
                        style: GoogleFonts.jaldi(
                            fontSize: 20.0,
                            color: AppColors.biruTua,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: FutureBuilder(
                          future: _itemProduct,
                          builder: (builder, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Wrap(
                                  spacing: 10,
                                  runSpacing: 20,
                                  children: List.generate(6, (index) {
                                    return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 180,
                                          height: 230,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ));
                                  }));
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Gagal memuat data'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Center(
                                  child: Text('Data tidak ditemukan'));
                            } else {
                              final items = snapshot.data!;

                              return Wrap(
                                spacing: 10,
                                runSpacing: 20,
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.start,
                                children: List.generate(items.length, (index) {
                                  final ItemProduct item = items[index];
                                  final UserVoucher? bestVoucher = item
                                          .voucher.isNotEmpty
                                      ? item.voucher.reduce((curr, next) {
                                          double currFinalPrice =
                                              _calculateFinalPrice(curr);
                                          double nextFinalPrice =
                                              _calculateFinalPrice(next);

                                          if (currFinalPrice < nextFinalPrice) {
                                            return curr; // Pilih yang lebih murah
                                          } else if (currFinalPrice ==
                                              nextFinalPrice) {
                                            return curr.discount! >=
                                                    next.discount!
                                                ? curr
                                                : next; // Pilih diskon lebih besar jika harga sama
                                          } else {
                                            return next;
                                          }
                                        })
                                      : null;
                                  final Random random = Random();
                                  int randomInterval =
                                      5000 + random.nextInt(5001);

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/product',
                                          arguments: {'title': item.name});
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5)),
                                              color: AppColors.putih,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey
                                                      .withAlpha(100),
                                                  spreadRadius: 1,
                                                  blurRadius: 3,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ]),
                                          width: 180,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ImageSlideshow(
                                                  indicatorBackgroundColor:
                                                      Colors.transparent,
                                                  height: 180,
                                                  isLoop: item.image.length > 1,
                                                  indicatorColor:
                                                      Colors.transparent,
                                                  autoPlayInterval:
                                                      randomInterval,
                                                  children: List.generate(
                                                      item.image.length,
                                                      (index) {
                                                    return ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5)),
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl:
                                                            item.image[index],
                                                        placeholder:
                                                            (context, url) {
                                                          return Shimmer
                                                              .fromColors(
                                                                  baseColor:
                                                                      Colors.grey[
                                                                          300]!,
                                                                  highlightColor:
                                                                      Colors.grey[
                                                                          100]!,
                                                                  child:
                                                                      Container(
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                    height: MediaQuery.of(context).size.height <
                                                                            250
                                                                        ? 250
                                                                        : MediaQuery.of(context).size.height *
                                                                            0.3,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ));
                                                        },
                                                      ),
                                                    );
                                                  })),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Text(item.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color:
                                                              AppColors.hitam,
                                                        )),
                                                    Text(item.category,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize: 10,
                                                                color: AppColors
                                                                    .hitam
                                                                    .withAlpha(
                                                                        150))),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 5),
                                                              child: Text(
                                                                "Rp. ",
                                                                style: GoogleFonts.jaldi(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    fontSize:
                                                                        10),
                                                              ),
                                                            ),
                                                            Text(
                                                              formatCurrency.format(
                                                                  bestVoucher!
                                                                      .price),
                                                              style: GoogleFonts.jaldi(
                                                                  fontSize: 24,
                                                                  color: Colors
                                                                      .redAccent),
                                                            ),
                                                          ],
                                                        ),
                                                        Icon(
                                                          Icons.thumb_up_alt,
                                                          size: 30,
                                                          color: AppColors
                                                              .hijauMuda,
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: CornerRibbon(
                                                cornerOffset: 50,
                                                ribbonStroke: 40,
                                                position:
                                                    RibbonPosition.topRight,
                                                ribbonColor: Colors.yellowAccent
                                                    .withAlpha(200),
                                                text: bestVoucher != null
                                                    ? "${bestVoucher.discount}%"
                                                    : "0%",
                                                textStyle: GoogleFonts.poppins(
                                                    fontSize: 24,
                                                    color: Colors.redAccent,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                child: SizedBox()))
                                      ],
                                    ),
                                  );
                                }),
                              );
                            }
                          })),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 50,
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
