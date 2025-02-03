import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/model/category.dart';
import 'package:wigoyu/model/item_product.dart';

class Category extends StatefulWidget {
  const Category({super.key, required this.title});
  static const String routeName = '/category';
  final String title;
  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  String title = '';
  late Future<List<ItemCategory>> _itemCategory;
  late Future<List<ItemProduct>> _itemProduct;

  Future<List<ItemCategory>> _fetchCategory() async {
    final String response =
        await rootBundle.loadString('assets/data/category.json');
    final List<dynamic> data = json.decode(response);

    List<ItemCategory> itemList =
        data.map((json) => ItemCategory.fromJson(json)).toList();

    return itemList;
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    _itemCategory = _fetchCategory();
    _itemProduct = _fetchSearchItemProduct(widget.title);
  }

  Future<List<ItemProduct>> _fetchSearchItemProduct(String search) async {
    await Future.delayed(const Duration(seconds: 1));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();
    final List<ItemProduct> filteredProducts = products
        .where((product) =>
            product.category.toLowerCase().contains(search.toLowerCase()))
        .toList();
    return filteredProducts;
  }

  Future<void> _refresh() async {
    setState(() {
      _itemProduct = _fetchSearchItemProduct(title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.putih,
        body: RefreshIndicator(
          onRefresh: () => _refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: SafeArea(
                top: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios,
                              color: AppColors.hitam, size: 20.0)),
                      Text("Kategori Merchant",
                          style: GoogleFonts.barlow(
                              fontSize: 20.0,
                              color: AppColors.hitam,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              )),
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
                                sortedData.sort((a, b) => a.title == title
                                    ? -1
                                    : (b.title == title ? 1 : 0));

                                final ItemCategory item = sortedData[index];

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      title = item.title;
                                    });
                                    _refresh();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: index == 0 ? 12 : 8,
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? AppColors.hijauMuda.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        AnimatedScale(
                                          scale: index == 0 ? 1.2 : 1.0,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                          child: Image.asset(
                                            item.image,
                                            width: 50,
                                          ),
                                        ),
                                        AnimatedDefaultTextStyle(
                                          duration:
                                              const Duration(milliseconds: 300),
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
                  padding: const EdgeInsets.only(top: 20),
                  child: FutureBuilder<List<ItemProduct>>(
                    future: _itemProduct,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 150,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: AppColors.hijauMuda,
                          )),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        final items = snapshot.data!;
                        return Wrap(
                          spacing: 8,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            items.length,
                            (index) {
                              final item = items[index];
                              return GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, '/product',
                                    arguments: {'title': item.name}),
                                child: Card(
                                  shadowColor: AppColors.hitam,
                                  color: AppColors.putih,
                                  child: SizedBox(
                                    width: 160,
                                    height: 170,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 160,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: item.image[0],
                                              placeholder: (context, url) =>
                                                  Center(
                                                      child: Shimmer.fromColors(
                                                          baseColor:
                                                              Colors.grey[300]!,
                                                          highlightColor:
                                                              Colors.grey[100]!,
                                                          child: Container(
                                                            width: 160,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ))),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: GoogleFonts.jaldi(
                                                    fontSize: 14,
                                                    color: AppColors.hitam,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              Text(
                                                item.shortDetail,
                                                style: GoogleFonts.jaldi(
                                                    fontSize: 12,
                                                    color: AppColors.hitam),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
