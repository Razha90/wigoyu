import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/notification.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/category.dart';
import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/model/new_merchant.dart';
import 'package:wigoyu/page/login.dart';
import 'package:wigoyu/page/scan_qr.dart';
import 'package:wigoyu/page/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final notification = NotificationService();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();
  double widthIcon = 50.0;
  double fontSizeIcon = 12.0;
  double sizedboxIcon = 8.0;
  late Future<List<List<ItemCategory>>> _futureData;
  late Future<List<ItemProduct>> _futureItemProduct;
  late Future<List<NewMerchant>> _futureNewMerchant;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");

  final List<String> imageUrls = [
    'https://wigoyu.com/img/banner/202408231133KOPI%20KUNI%20LITE.webp', // Ganti dengan URL gambar Anda
    'https://wigoyu.com/img/banner/202408231134HEAD%20TO%20TOE.webp',
    'https://wigoyu.com/img/banner/202408240821KOMANG.webp',
  ];

  Future<List<ItemProduct>> fetchItemProduct() async {
    await Future.delayed(Duration(seconds: 2, milliseconds: 500));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    // log(jsonEncode(data));
    return data.map((json) => ItemProduct.fromJson(json)).toList();
  }

  Future<List<NewMerchant>> fetchNewMerchant() async {
    await Future.delayed(Duration(seconds: 2)); // Simulasi loading
    final String response =
        await rootBundle.loadString('assets/data/new_merchant.json');

    // Decode JSON string menjadi List<dynamic>
    final List<dynamic> jsonData = json.decode(response);

    // Map data JSON menjadi List<NewMerchant>
    return jsonData.map((json) => NewMerchant.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();
    _futureData = fetchItems();
    _futureItemProduct = fetchItemProduct();
    _futureNewMerchant = fetchNewMerchant();
  }

  Future<void> refreshData() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _futureData = fetchItems();
      _futureItemProduct = fetchItemProduct();
      _futureNewMerchant = fetchNewMerchant();
    });
  }

  Future<List<List<ItemCategory>>> fetchItems() async {
    final String response =
        await rootBundle.loadString('assets/data/category.json');
    final List<dynamic> data = json.decode(response);
    List<ItemCategory> itemList =
        data.map((json) => ItemCategory.fromJson(json)).toList();
    List<List<ItemCategory>> stackedData = [];
    for (int i = 0; i < itemList.length; i += 10) {
      int end = (i + 10 < itemList.length) ? i + 10 : itemList.length;
      stackedData.add(itemList.sublist(i, end));
    }
    return stackedData;
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<User>(context);
    return Scaffold(
      backgroundColor: AppColors.putih,
      body: RefreshIndicator(
        color: AppColors.hijauMuda,
        onRefresh: refreshData,
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
                SliverToBoxAdapter(
                    child: Stack(
                  children: [
                    Container(
                      height: 190,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.putih,
                            AppColors.hijauMuda,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Hey! Welcome to",
                                    style: GoogleFonts.baloo2(
                                        color: AppColors.biruTua,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                              color: AppColors.putih,
                                              blurRadius: 3,
                                              offset: Offset(3, 3))
                                        ]),
                                  ),
                                  Image.asset('assets/wigoyu.png',
                                      height: 35,
                                      key: PageStorageKey<String>(
                                          'wigoyuImage')),
                                ],
                              ),
                              Consumer<User>(builder: (context, user, child) {
                                if (user.isLoggedIn) {
                                  return SizedBox(
                                    width: 80.0,
                                    child: Text(
                                      '${user.name}',
                                      style: GoogleFonts.jaldi(
                                        color: AppColors.biruMuda,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  );
                                } else {
                                  return ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all(
                                                AppColors.biruTua),
                                        padding: WidgetStateProperty.all(
                                            EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10))),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: Login(),
                                              duration:
                                                  Duration(milliseconds: 400),
                                              alignment: Alignment.center));
                                    },
                                    child: Text(
                                      'Login',
                                      style: GoogleFonts.daysOne(
                                          color: AppColors.putih),
                                    ),
                                  );
                                }
                              }),
                            ],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    onTap: () {
                                      // Navigator.pushNamed(context, '/search');
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                            duration:
                                                Duration(milliseconds: 400),
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: SearchPage(),
                                          ));
                                    },
                                    readOnly: true,
                                    maxLength: 50,
                                    style: GoogleFonts.barlow(fontSize: 14),
                                    keyboardType: TextInputType.text,
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 5),
                                      counterText: '',
                                      filled: true,
                                      fillColor: AppColors.putih,
                                      hintText: 'Mau kemana nih?',
                                      prefixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Stack(
                                children: [
                                  IconButton(
                                    style: ButtonStyle(
                                        backgroundColor: WidgetStatePropertyAll(
                                            Colors.transparent),
                                        padding: WidgetStatePropertyAll(
                                            EdgeInsets.zero),
                                        elevation: WidgetStateProperty.all(0)),
                                    onPressed: () {
                                      context.pushNamedTransition(
                                          routeName: '/notification-page',
                                          type: PageTransitionType.rightToLeft);
                                    },
                                    icon: Icon(
                                      Icons.notifications,
                                      size: 40,
                                      color: Colors.orangeAccent,
                                    ),
                                  ),
                                  Consumer<User>(
                                      builder: (context, user, child) {
                                    final int notificationCount =
                                        user.notification == null
                                            ? 0 // Jika null, kembalikan 0
                                            : user.notification!
                                                .where((element) =>
                                                    element.open == false)
                                                .length;

                                    if (notificationCount > 0) {
                                      return Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$notificationCount',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return SizedBox();
                                  }),
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.biruMuda,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Saldo Voucher',
                                        style: GoogleFonts.jaldi(
                                          color: AppColors.putih,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Consumer<User>(
                                        builder: (context, user, child) {
                                          if (user.isLoggedIn) {
                                            return Text(
                                              'Rp. ${_formatter.format(int.parse(user.saldo!))}',
                                              style: GoogleFonts.jaldi(
                                                color: AppColors.putih,
                                                fontSize: 16,
                                              ),
                                            );
                                          }
                                          return Text(
                                            '--',
                                            style: GoogleFonts.jaldi(
                                              color: AppColors.putih,
                                              fontSize: 12,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .fade,
                                                        duration: Duration(
                                                            milliseconds: 400),
                                                        child:
                                                            ScannerScreen()));
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.transparent),
                                                  padding:
                                                      WidgetStatePropertyAll(
                                                          EdgeInsets.all(0)),
                                                  elevation:
                                                      WidgetStateProperty.all(
                                                          0)),
                                              child: Icon(
                                                Icons.qr_code,
                                                size: 30,
                                                color: AppColors.putih,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Scan QR',
                                            style: GoogleFonts.jaldi(
                                                color: AppColors.putih,
                                                fontSize: 10),
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 30,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                context.pushNamedTransition(
                                                    routeName: '/top-up',
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    duration: Duration(
                                                        milliseconds: 450));
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                          Colors.transparent),
                                                  padding:
                                                      WidgetStatePropertyAll(
                                                          EdgeInsets.all(0)),
                                                  elevation:
                                                      WidgetStateProperty.all(
                                                          0)),
                                              child: Icon(
                                                Icons.wallet_outlined,
                                                size: 30,
                                                color: AppColors.putih,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            'Top Up',
                                            style: GoogleFonts.jaldi(
                                                color: AppColors.putih,
                                                fontSize: 10),
                                          )
                                        ],
                                      ),
                                      // Column(
                                      //   children: [
                                      //     SizedBox(
                                      //       height: 30,
                                      //       child: ElevatedButton(
                                      //         onPressed: () {
                                      //           Navigator.pushNamed(
                                      //               context, '/transaction');
                                      //         },
                                      //         style: ButtonStyle(
                                      //             backgroundColor:
                                      //                 WidgetStatePropertyAll(
                                      //                     Colors.transparent),
                                      //             padding:
                                      //                 WidgetStatePropertyAll(
                                      //                     EdgeInsets.all(0)),
                                      //             elevation:
                                      //                 WidgetStateProperty.all(
                                      //                     0)),
                                      //         child: Icon(
                                      //           Icons.history_edu_outlined,
                                      //           size: 30,
                                      //           color: AppColors.putih,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Text(
                                      //       'Transaksi',
                                      //       style: GoogleFonts.jaldi(
                                      //           color: AppColors.putih,
                                      //           fontSize: 10),
                                      //     )
                                      //   ],
                                      // ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height:
                            MediaQuery.of(context).size.width > 600 ? 110 : 180,
                        child: FutureBuilder<List<List<ItemCategory>>>(
                          future: _futureData,
                          builder: (context, snapshot) {
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
                              final stackedData = snapshot.data!;
                              return Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: stackedData.length,
                                    itemBuilder: (context, pageIndex) {
                                      final pageItems = stackedData[pageIndex];
                                      return Wrap(
                                        runSpacing: 10,
                                        alignment: WrapAlignment.center,
                                        spacing: 8,
                                        children: List.generate(
                                            pageItems.length,
                                            (index) => SizedBox(
                                                  width: 62,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent, // Latar belakang transparan
                                                              shadowColor: Colors
                                                                  .transparent,
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(0)),
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/category',
                                                            arguments: {
                                                              'title':
                                                                  pageItems[
                                                                          index]
                                                                      .title
                                                            });
                                                      },
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            pageItems[index]
                                                                .image,
                                                            width: widthIcon,
                                                          ),
                                                          Text(
                                                              pageItems[index]
                                                                  .title,
                                                              style: GoogleFonts.jaldi(
                                                                  fontSize:
                                                                      fontSizeIcon,
                                                                  color: AppColors
                                                                      .hitam))
                                                        ],
                                                      )),
                                                )),
                                      );
                                    }),
                              );
                            }
                          },
                        ),
                      ),
                      Center(
                        child: SmoothPageIndicator(
                          controller: _pageController, // PageController
                          count: 2,
                          effect: ExpandingDotsEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: AppColors.hijauMuda,
                            dotColor: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Merchant Baru',
                            style: GoogleFonts.jaldi(
                                fontSize: 16,
                                color: AppColors.hitam,
                                fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 120,
                          child: FutureBuilder<List<NewMerchant>>(
                            future: _futureNewMerchant,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<NewMerchant>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 5,
                                    itemBuilder: (BuildContext context, index) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              width: 200,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            )),
                                      );
                                    });
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.isEmpty) {
                                return Center(
                                  child: Text('No merchants available'),
                                );
                              } else {
                                final merchants = snapshot.data!;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: merchants.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final merchant = merchants[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, '/product',
                                            arguments: {
                                              'title': merchant.title
                                            });
                                      },
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 200,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: CachedNetworkImage(
                                                imageUrl: merchant.image,
                                                placeholder: (context, url) =>
                                                    Center(
                                                  child: Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        width: 200,
                                                        height: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      )),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merchan Lain',
                          style: GoogleFonts.jaldi(
                              fontSize: 16,
                              color: AppColors.hitam,
                              fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<List<ItemProduct>>(
                          future: _futureItemProduct,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Wrap(
                                  alignment: WrapAlignment.spaceAround,
                                  spacing: 20,
                                  runSpacing: 20,
                                  children: List.generate(6, (index) {
                                    return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          width: 160,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ));
                                  }),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Center(child: Text('No data available'));
                            } else {
                              final items = snapshot.data!;
                              return SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: Wrap(
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
                                                        BorderRadius.circular(
                                                            8),
                                                    child: CachedNetworkImage(
                                                      fit: BoxFit.fill,
                                                      imageUrl: item.image[0],
                                                      placeholder:
                                                          (context, url) =>
                                                              Center(
                                                        child:
                                                            Shimmer.fromColors(
                                                                baseColor:
                                                                    Colors.grey[
                                                                        300]!,
                                                                highlightColor:
                                                                    Colors.grey[
                                                                        100]!,
                                                                child:
                                                                    Container(
                                                                  width: 160,
                                                                  height: 100,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                )),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        item.name,
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .hitam,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      Text(
                                                        item.shortDetail,
                                                        style:
                                                            GoogleFonts.jaldi(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .hitam),
                                                        overflow: TextOverflow
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
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            userState.logout();
                          },
                          child: Text("Logout")),
                      ElevatedButton(
                          onPressed: () async {
                            await UserPreferences.deleteAllUsers();
                          },
                          child: Text('Clear User')),
                      ElevatedButton(
                          onPressed: () async {
                            Navigator.pushNamed(context, '/', arguments: 3);
                          },
                          child: Text('Go To Profile'))
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            userState.logout();
                          },
                          child: Text("Logout")),
                      ElevatedButton(
                          onPressed: () async {
                            await UserPreferences.deleteAllUsers();
                          },
                          child: Text('Clear User'))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickyHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60.0; // Tinggi maksimal header
  @override
  double get minExtent => 60.0; // Tinggi minimal saat di-scroll
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}


//  Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     Consumer<User>(builder: (context, user, child) {
//                       if (user.isLoggedIn) {
//                         return Text('Welcome, ${user.name}');
//                       } else {
//                         return ElevatedButton(
//                           onPressed: () {
//                             user.login('John Doe', 'user123');
//                           },
//                           child: Text('Login'),
//                         );
//                       }
//                     }),
//                     ElevatedButton(
//                       onPressed: () {
//                         bool? lawak = userState.isLoggedIn;
//                         print(lawak);
//                       },
//                       child: const Text('Check'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         notification.showNotification(
//                             id: 1, title: "sasa", body: "Sasas");
//                       },
//                       child: const Text('Go to Search Page'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         // await UserPreferences.deleteAllUsers();
//                         final lawak = await UserPreferences.getAllUsers();
//                         for (var user in lawak) {
//                           print(
//                               'User ID: ${user.id}, Name: ${user.name}, email: ${user.email}, verified: ${user.verified}');
//                         }
//                       },
//                       child: const Text('Go to Search Page'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () async {
//                         Navigator.pushNamed(context, '/');
//                       },
//                       child: const Text('Home'),
//                     )
//                   ],
//                 ),
//               ),

