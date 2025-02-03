import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/item_product.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  static const String routeName = '/search';
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearch = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(seconds: 1));
      _focusNode.requestFocus();
    });
    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty) {
        setState(() {
          _isSearch = true;
        });
      } else {
        setState(() {
          _isSearch = false;
        });
      }
    });
  }

  Future<List<ItemProduct>> fetchSearchItemProduct(String search) async {
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

  Future<void> _refreshPage() async {
    await Future.delayed(Duration(seconds: 1));
    _searchController.clear();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: true);
    return Scaffold(
        backgroundColor: AppColors.putih,
        body: RefreshIndicator(
          color: AppColors.hijauMuda,
          onRefresh: () {
            return _refreshPage();
          },
          child: SafeArea(
              top: true,
              bottom: false,
              left: false,
              right: false,
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      pinned: true,
                      elevation: 10,
                      backgroundColor: AppColors.putih,
                      foregroundColor: AppColors.putih,
                      surfaceTintColor: AppColors.putih,
                      shadowColor: AppColors.hitam,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 10.0, right: 20.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: SizedBox(
                                  width: 50,
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    size: 20,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 35.0,
                                  child: TextField(
                                    onSubmitted: (value) {
                                      if (value.isNotEmpty) {
                                        user.updateHistory(user.userId!, value);
                                      }
                                    },
                                    focusNode: _focusNode,
                                    maxLength: 100,
                                    style: GoogleFonts.barlow(fontSize: 14),
                                    keyboardType: TextInputType.text,
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      counterText: '',
                                      filled: true,
                                      fillColor: const Color.fromARGB(
                                          255, 236, 235, 235),
                                      hintText: 'Mau kemana nih?',
                                      suffixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<User>(builder: (context, user, child) {
                            return (user.history == null ||
                                    user.history!.isEmpty)
                                ? SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10,
                                        left: 20.0,
                                        right: 20.0,
                                        bottom: 20),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Riwayat Pencarian',
                                          style: GoogleFonts.jaldi(
                                              fontSize: 16,
                                              color: AppColors.hitam,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Wrap(
                                          spacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: List.generate(
                                            user.history!.length,
                                            (index) {
                                              final history =
                                                  user.history![index];
                                              if (history.isEmpty) {
                                                user.deleteHistory(
                                                    user.userId!, history);
                                              }
                                              return GestureDetector(
                                                onTap: () {
                                                  _searchController.text =
                                                      history;
                                                },
                                                child: Chip(
                                                  padding: EdgeInsets.all(5),
                                                  iconTheme: IconThemeData(
                                                      color: Colors.redAccent),
                                                  color: WidgetStatePropertyAll(
                                                      AppColors.putih),
                                                  label: Text(history,
                                                      style: GoogleFonts.jaldi(
                                                          fontSize: 14,
                                                          color:
                                                              AppColors.hitam)),
                                                  onDeleted: () {
                                                    user.deleteHistory(
                                                        user.userId!, history);
                                                    // user.removeHistory(index);
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                          }),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 20.0, right: 20.0, bottom: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isSearch
                                      ? 'Hasil Pencarian'
                                      : 'Merchan yang banyak dicari',
                                  style: GoogleFonts.jaldi(
                                      fontSize: 16,
                                      color: AppColors.hitam,
                                      fontWeight: FontWeight.bold),
                                ),
                                FutureBuilder<List<ItemProduct>>(
                                  future: fetchSearchItemProduct(
                                      _searchController.text),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return SizedBox(
                                        height: 150,
                                        child: Center(
                                            child: CircularProgressIndicator(
                                          color: AppColors.hijauMuda,
                                        )),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return Center(
                                          child: Text('No data available'));
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
                                                  arguments: {
                                                    'title': item.name
                                                  }),
                                              child: Card(
                                                shadowColor: AppColors.hitam,
                                                color: AppColors.putih,
                                                child: SizedBox(
                                                  width: 160,
                                                  height: 170,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 100,
                                                        width: 160,
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child:
                                                              CachedNetworkImage(
                                                            fit: BoxFit.fill,
                                                            imageUrl:
                                                                item.image[0],
                                                            placeholder: (context, url) => Center(
                                                                child: Shimmer.fromColors(
                                                                    baseColor: Colors.grey[300]!,
                                                                    highlightColor: Colors.grey[100]!,
                                                                    child: Container(
                                                                      width:
                                                                          160,
                                                                      height:
                                                                          100,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                    ))),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              item.name,
                                                              style: GoogleFonts.jaldi(
                                                                  fontSize: 14,
                                                                  color:
                                                                      AppColors
                                                                          .hitam,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                            ),
                                                            Text(
                                                              item.shortDetail,
                                                              style: GoogleFonts
                                                                  .jaldi(
                                                                      fontSize:
                                                                          12,
                                                                      color: AppColors
                                                                          .hitam),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
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
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ));
  }
}
