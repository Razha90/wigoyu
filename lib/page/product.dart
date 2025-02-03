import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/page/payment.dart';

class Product extends StatefulWidget {
  const Product({super.key, required this.title});
  static const String routeName = '/product';
  final String title;
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late Future<List<ItemProduct>> _futureProducts;
  bool _isDetail = false;
  final ScrollController _scrollController = ScrollController();
  final DraggableScrollableController _scrollModal =
      DraggableScrollableController();

  Future<List<ItemProduct>> _fetchSearchItemProduct(String search) async {
    await Future.delayed(Duration(seconds: 2));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();
    final List<ItemProduct> filteredProducts = products
        .where((product) =>
            product.name.toLowerCase().contains(search.toLowerCase()))
        .toList();
    return filteredProducts;
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureProducts = _fetchSearchItemProduct(widget.title);
    });
  }

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;
    final totalRating = reviews.fold<double>(
      0,
      (sum, review) => sum + (review.rating),
    );
    final averageRating = totalRating / reviews.length;
    return (averageRating * 2).round() / 2;
  }

  final formatCurrency = NumberFormat("#,###", "id_ID");

  void _displayVoucher() {
    showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return DraggableScrollableSheet(
            controller: _scrollModal,
            expand: false,
            snap: true,
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: FutureBuilder<List<ItemProduct>>(
                    future: _futureProducts,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('No Data'),
                        );
                      } else {
                        final product = snapshot.data![0];
                        final rating = _calculateAverageRating(product.review);
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 0, top: 10),
                          child: Column(
                            children: [
                              Container(
                                width: 40.0,
                                height: 3.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                spacing: 10,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    clipBehavior: Clip.hardEdge,
                                    child: CachedNetworkImage(
                                      imageUrl: product.image[0],
                                      width: 75,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        product.name,
                                        style: GoogleFonts.jaldi(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Row(
                                        children: List.generate(5, (index) {
                                          if (index < rating.floor()) {
                                            return Icon(
                                              Icons.star,
                                              color: Colors.orangeAccent,
                                            );
                                          } else if (index == rating.floor() &&
                                              rating % 1 >= 0.5) {
                                            return Icon(
                                              Icons.star_half,
                                              color: Colors.orangeAccent,
                                            );
                                          } else {
                                            return Icon(
                                              Icons.star_border,
                                              color: Colors.grey,
                                            );
                                          }
                                        }),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height - 200,
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment.center,
                                    children: List.generate(
                                        product.voucher.length, (indexFac) {
                                      if (product.voucher[indexFac].discount !=
                                          0) {
                                        return CouponCard(
                                            height: 130,
                                            curveAxis: Axis.vertical,
                                            curvePosition: 200,
                                            // backgroundColor: AppColors.hijauMuda,
                                            decoration: BoxDecoration(
                                                color: AppColors.putih),
                                            firstChild: Container(
                                              decoration: BoxDecoration(
                                                  color: AppColors.hijauMuda),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${product.voucher[indexFac].discount}%",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: AppColors
                                                                  .putih,
                                                              fontSize: 35,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    Divider(
                                                      color: AppColors.putih,
                                                    ),
                                                    Text(
                                                      product.voucher[indexFac]
                                                          .name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.poppins(
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
                                                  color: AppColors.hijauMuda
                                                      .withAlpha(120)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Rp.${formatCurrency.format(product.voucher[indexFac].price)}",
                                                    style: GoogleFonts.poppins(
                                                        color:
                                                            AppColors.hijauTua,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16),
                                                  ),
                                                  ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          overlayColor:
                                                              AppColors.putih,
                                                          backgroundColor:
                                                              AppColors.biruMuda
                                                                  .withAlpha(
                                                                      180),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      30,
                                                                  vertical: 5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)))),
                                                      onPressed: () {
                                                        Navigator.push(
                                                            context,
                                                            PageTransition(
                                                                type: PageTransitionType
                                                                    .rightToLeft,
                                                                child: Payment(
                                                                    title: product
                                                                        .voucher[
                                                                            indexFac]
                                                                        .id)));
                                                      },
                                                      child: Text(
                                                        "Beli",
                                                        style:
                                                            GoogleFonts.barlow(
                                                                color: AppColors
                                                                    .putih,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                      ))
                                                ],
                                              ),
                                            ));
                                      } else {
                                        return SizedBox();
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
              );
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _futureProducts = _fetchSearchItemProduct(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.putih,
        body: RefreshIndicator(
          displacement: 10,
          color: AppColors.hijauMuda,
          onRefresh: _refreshData,
          child: Stack(
            children: [
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: FutureBuilder<List<ItemProduct>>(
                      future: _futureProducts,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Column(
                            children: [
                              Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height <
                                            250
                                        ? 250
                                        : MediaQuery.of(context).size.height *
                                            0.3,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 100,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(20),
                                                    bottomRight:
                                                        Radius.circular(20)),
                                              ),
                                            )),
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 120,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            )),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 170,
                                          height: 25,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            )),
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  70,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          height: 500,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      spacing: 10,
                                      children: [
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: ((MediaQuery.of(context)
                                                              .size
                                                              .width -
                                                          40) /
                                                      2) -
                                                  10,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            )),
                                        Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      40) /
                                                  2,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                              ),
                                            ))
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ))
                                  ],
                                ),
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering_error_rounded_outlined,
                                  color: Colors.redAccent, size: 60),
                              Text('No Internet Connection',
                                  style: TextStyle(color: Colors.redAccent)),
                              SizedBox(
                                width: 125,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back_ios,
                                            color: Colors.redAccent),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Kembali',
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          );
                        } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering_error_rounded_outlined,
                                  color: Colors.redAccent, size: 60),
                              Text('No Internet Connection',
                                  style: TextStyle(color: Colors.redAccent)),
                              SizedBox(
                                width: 125,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back_ios,
                                            color: Colors.redAccent),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Kembali',
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          );
                        } else if (snapshot.hasData) {
                          final product = snapshot.data![0];
                          final rating =
                              _calculateAverageRating(product.review);

                          return Column(
                            children: [
                              ImageSlideshow(
                                  height:
                                      MediaQuery.of(context).size.height < 250
                                          ? 250
                                          : MediaQuery.of(context).size.height *
                                              0.3,
                                  isLoop: product.image.length > 1,
                                  indicatorColor: product.image.length > 1
                                      ? AppColors.putih
                                      : Colors.transparent,
                                  autoPlayInterval: 5000,
                                  children: List.generate(product.image.length,
                                      (index) {
                                    return CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: product.image[index],
                                      placeholder: (context, url) {
                                        return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .height <
                                                      250
                                                  ? 250
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.3,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ));
                                      },
                                    );
                                  })),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 7,
                                              right: 20,
                                              top: 5,
                                              bottom: 5),
                                          decoration: BoxDecoration(
                                              color: AppColors.hijauMuda,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                          child: Text(product.category,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.putih,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              children:
                                                  List.generate(5, (index) {
                                                if (index < rating.floor()) {
                                                  return Icon(
                                                    Icons.star,
                                                    color: Colors.orangeAccent,
                                                  );
                                                } else if (index ==
                                                        rating.floor() &&
                                                    rating % 1 >= 0.5) {
                                                  return Icon(
                                                    Icons.star_half,
                                                    color: Colors.orangeAccent,
                                                  );
                                                } else {
                                                  return Icon(
                                                    Icons.star_border,
                                                    color: Colors.grey,
                                                  );
                                                }
                                              }),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Text(
                                                '${product.review.length} review',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      product.name,
                                      style: GoogleFonts.jaldi(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.redAccent, size: 20),
                                        Expanded(
                                          child: Text(product.alamat,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.jaldi(
                                                  fontSize: 14,
                                                  color: Colors.grey)),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: AppColors.hijauMuda
                                              .withAlpha(210),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Deksripsi Singkat",
                                                style: GoogleFonts.barlow(
                                                    fontSize: 14,
                                                    color: AppColors.putih,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              product.shortDetail,
                                              style: GoogleFonts.barlow(
                                                  fontSize: 12,
                                                  color: AppColors.putih),
                                            ),
                                            Divider(
                                              color: AppColors.putih,
                                            ),
                                            Text("Jam Operasional",
                                                style: GoogleFonts.barlow(
                                                    fontSize: 14,
                                                    color: AppColors.putih,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                              '${product.open.startTime.substring(0, product.open.startTime.length - 3)} WIB - ${product.open.endTime.substring(0, product.open.endTime.length - 3)} WIB',
                                              style: GoogleFonts.barlow(
                                                  fontSize: 14,
                                                  color: AppColors.putih),
                                            ),
                                            Divider(
                                              color: AppColors.putih,
                                            ),
                                            Text("Fasilitas",
                                                style: GoogleFonts.barlow(
                                                    fontSize: 14,
                                                    color: AppColors.putih,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Wrap(
                                              spacing: 5,
                                              alignment: WrapAlignment.center,
                                              children: List.generate(
                                                  product.facility.length,
                                                  (indexFac) {
                                                return Chip(
                                                    color:
                                                        WidgetStatePropertyAll(
                                                            AppColors
                                                                .hijauMuda),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: AppColors
                                                                    .putih),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .zero),
                                                    label: Text(
                                                      product
                                                          .facility[indexFac],
                                                      style: GoogleFonts.barlow(
                                                          fontSize: 12,
                                                          color:
                                                              AppColors.putih),
                                                    ));
                                              }),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Tentang",
                                            style: GoogleFonts.jaldi(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Divider(
                                          color: AppColors.biruMuda,
                                        ),
                                        AnimatedSize(
                                          duration: Duration(milliseconds: 300),
                                          child: _isDetail
                                              ? Text(product.detailt,
                                                  style: GoogleFonts.barlow(
                                                      fontSize: 14,
                                                      color: AppColors.hitam
                                                          .withAlpha(230)))
                                              : Text(product.detailt,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.barlow(
                                                      fontSize: 14,
                                                      color: AppColors.hitam
                                                          .withAlpha(230))),
                                        ),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isDetail = !_isDetail;
                                              });
                                            },
                                            child: Text(
                                                _isDetail
                                                    ? "Sembunyikan"
                                                    : "Selengkapnya",
                                                style: GoogleFonts.jaldi(
                                                    fontSize: 16,
                                                    color: AppColors.biruMuda,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Review Pengunjung",
                                              style: GoogleFonts.jaldi(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: AppColors.biruMuda,
                                        ),
                                        SizedBox(
                                          height: 110,
                                          child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: product.review.length,
                                              itemBuilder:
                                                  (BuildContext contextReview,
                                                      indexRev) {
                                                final review =
                                                    product.review[indexRev];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Container(
                                                    width: 230,
                                                    decoration: BoxDecoration(
                                                        color: AppColors.putih,
                                                        border: Border.all(
                                                            color: Colors
                                                                .grey.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        spacing: 8,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                spacing: 5,
                                                                children: [
                                                                  CircleAvatar(
                                                                    radius: 15,
                                                                    child:
                                                                        CachedNetworkImage(
                                                                      imageUrl:
                                                                          review
                                                                              .image,
                                                                      placeholder:
                                                                          (context,
                                                                              url) {
                                                                        return Shimmer.fromColors(
                                                                            baseColor: Colors.grey[300]!,
                                                                            highlightColor: Colors.grey[100]!,
                                                                            child: Container(
                                                                              width: 25,
                                                                              height: 25,
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                            ));
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                      review
                                                                          .name,
                                                                      style: GoogleFonts.jaldi(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: List
                                                                    .generate(5,
                                                                        (index) {
                                                                  if (index <
                                                                      review
                                                                          .rating
                                                                          .floor()) {
                                                                    return Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .orangeAccent,
                                                                      size: 20,
                                                                    );
                                                                  } else if (index ==
                                                                          review
                                                                              .rating
                                                                              .floor() &&
                                                                      review.rating %
                                                                              1 >=
                                                                          0.5) {
                                                                    return Icon(
                                                                      Icons
                                                                          .star_half,
                                                                      color: Colors
                                                                          .orangeAccent,
                                                                      size: 20,
                                                                    );
                                                                  } else {
                                                                    return Icon(
                                                                      Icons
                                                                          .star_border,
                                                                      color: Colors
                                                                          .grey,
                                                                      size: 20,
                                                                    );
                                                                  }
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                          Text(review.comment,
                                                              maxLines: 3,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: GoogleFonts.jaldi(
                                                                  fontSize: 12,
                                                                  color: AppColors
                                                                      .hitam
                                                                      .withAlpha(
                                                                          230))),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Lokasi",
                                            style: GoogleFonts.jaldi(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Divider(
                                          color: AppColors.biruMuda,
                                        ),
                                        SizedBox(
                                          height: 200,
                                          child: WebViewWidget(
                                            controller: WebViewController()
                                              ..setJavaScriptMode(
                                                  JavaScriptMode.unrestricted)
                                              ..loadHtmlString(product.map),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    if (product.video.isNotEmpty)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Video",
                                              style: GoogleFonts.jaldi(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)),
                                          Divider(
                                            color: AppColors.biruMuda,
                                          ),
                                          SizedBox(
                                            height: 200,
                                            child: WebViewWidget(
                                              controller: WebViewController()
                                                ..setJavaScriptMode(
                                                    JavaScriptMode.unrestricted)
                                                ..loadHtmlString(product.video),
                                            ),
                                          )
                                        ],
                                      )
                                  ],
                                ),
                              )
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering_error_rounded_outlined,
                                  color: Colors.redAccent, size: 60),
                              Text('No Internet Connection',
                                  style: TextStyle(color: Colors.redAccent)),
                              SizedBox(
                                width: 125,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back_ios,
                                            color: Colors.redAccent),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Kembali',
                                          style: TextStyle(
                                              color: Colors.redAccent),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      height: 100,
                    ),
                  )
                ],
              ),
              Positioned(
                top: 0,
                child: AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      bool isOpacity = _scrollController.offset > 200;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          boxShadow: [
                            if (isOpacity)
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                          ],
                          color:
                              isOpacity ? AppColors.putih : Colors.transparent,
                        ),
                        child: SafeArea(
                          top: true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                height: 45,
                                width: 45,
                                margin: EdgeInsets.only(left: 15),
                                padding: EdgeInsets.only(left: 6),
                                decoration: BoxDecoration(
                                  color: isOpacity
                                      ? Colors.transparent
                                      : AppColors.hitam.withValues(alpha: 0.40),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: isOpacity
                                        ? AppColors.hitam
                                        : AppColors.putih,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FutureBuilder(
                            future: _futureProducts,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 150,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ));
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text('No Data'),
                                );
                              } else {
                                return IconButton(
                                    style: ButtonStyle(
                                        overlayColor: WidgetStateProperty.all(
                                            AppColors.biruMuda),
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                AppColors.biruTua)),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    onPressed: () {
                                      _displayVoucher();
                                    },
                                    icon: Row(
                                      spacing: 5,
                                      children: [
                                        Icon(
                                          Icons.local_offer,
                                          color: AppColors.putih,
                                        ),
                                        Text('Get Voucher',
                                            style: GoogleFonts.jaldi(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.putih))
                                      ],
                                    ));
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class VoucherClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Mulai dari sudut kiri atas
    path.moveTo(0, 0);

    // Gambar sisi kiri cekung
    path.quadraticBezierTo(10, 0, 20, 20); // Sudut cekung kiri atas

    // Sisi kanan cekung
    path.lineTo(size.width - 20, 0); // Sisi kanan atas
    path.quadraticBezierTo(
        size.width - 10, 0, size.width, 20); // Sudut cekung kanan atas

    // Bawah kanan
    path.lineTo(size.width, size.height - 20); // Sisi bawah kanan
    path.quadraticBezierTo(size.width - 10, size.height, size.width - 20,
        size.height); // Cekung kanan bawah

    // Bawah kiri
    path.lineTo(20, size.height); // Sisi bawah kiri
    path.quadraticBezierTo(
        10, size.height, 0, size.height - 20); // Cekung kiri bawah

    // Kembali ke posisi awal
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // Tidak perlu melakukan reclip, kecuali jika ukuran atau path berubah
  }
}
