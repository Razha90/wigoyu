import 'dart:convert';
import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:simple_numpad/simple_numpad.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/payment_method_dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';

class TopupSection extends StatefulWidget {
  const TopupSection({super.key, required this.title});
  static const String routeName = '/topup-section';
  final int title;

  @override
  State<TopupSection> createState() => _TopupSectionState();
}

class _TopupSectionState extends State<TopupSection> {
  late Future<PaymentMethod?> _futurePaymentMethod;
  final NumberFormat _formatter = NumberFormat("#,###", "id_ID");
  bool _isOpened = false;
  final TextEditingController _fieldText = TextEditingController();
  late User user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<User>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        context.pushReplacementTransition(
            child: BottomNavigation(), type: PageTransitionType.rightToLeft);
        return;
      } else {
        user = userProvider;
      }
    });

    _futurePaymentMethod = fetchNewMerchant(widget.title);
  }

  // Future<PaymentMethod?> fetchNewMerchant(int id) async {
  //   final String response =
  //       await rootBundle.loadString('assets/data/payment.json');
  //   final List<dynamic> jsonData = json.decode(response);
  //   try {
  //     return jsonData
  //         .map((json) => PaymentMethod.fromJson(json))
  //         .firstWhere((payment) => payment.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<PaymentMethod> fetchNewMerchant(int id) async {
    if (id == 6565) {
      return PaymentMethod(
          id: 0,
          name: 'Developer Mode',
          icon: 'assets/images/gopay.png',
          accountName: "",
          accountNumber: "",
          type: "developer");
    }
    final String response =
        await rootBundle.loadString('assets/data/payment.json');

    final List<dynamic> jsonData = json.decode(response);
    final List<PaymentMethod> paymentMethods =
        jsonData.map((json) => PaymentMethod.fromJson(json)).toList();

    final PaymentMethod paymentMethod = paymentMethods.firstWhere((payment) {
      return payment.id == id;
    });
    return paymentMethod;
  }

  void _updateText(String str) {
    String rawText = _fieldText.text.replaceAll('.', '') + str;

    int? parsedValue = int.tryParse(rawText);
    if (parsedValue == null) return;

    String formattedValue = _formatter.format(parsedValue);

    setState(() {
      _fieldText.text = formattedValue;
      _fieldText.selection =
          TextSelection.collapsed(offset: formattedValue.length);
    });
  }

  void _handleBackspace() {
    String rawText = _fieldText.text.replaceAll('.', '');
    if (rawText.isEmpty) return;
    String newValue = rawText.substring(0, rawText.length - 1);
    if (newValue.isEmpty) {
      setState(() {
        _fieldText.text = '';
      });
      return;
    }
    int? parsedValue = int.tryParse(newValue);
    if (parsedValue == null) return;

    String formattedValue = _formatter.format(parsedValue);

    setState(() {
      _fieldText.text = formattedValue;
      _fieldText.selection =
          TextSelection.collapsed(offset: formattedValue.length);
    });
  }

  bool _shouldClearText() {
    String rawText = _fieldText.text.replaceAll('.', '');
    int? value = int.tryParse(rawText);
    print(value != null && value > 1000);
    return value != null && value > 1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.putih,
        appBar: AppBar(
          backgroundColor: AppColors.putih,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text('Mode Developer'),
          titleSpacing: 0,
        ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isOpened = false;
                });
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: FutureBuilder<PaymentMethod?>(
                        future: _futurePaymentMethod,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error'),
                            );
                          } else {
                            final data = snapshot.data;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Column(
                                children: [
                                  Consumer<User>(
                                    builder: (context, user, child) {
                                      if (user.isLoggedIn) {
                                        final images = File(user.photo!);
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                            color: AppColors.hijauMuda
                                                .withAlpha(70),
                                          ),
                                          child: Row(
                                            spacing: 15,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    AppColors.putih,
                                                backgroundImage: (user.photo ??
                                                                "")
                                                            .isNotEmpty &&
                                                        user.photo != null &&
                                                        images.existsSync()
                                                    ? FileImage(images)
                                                    : null,
                                                child: (user.photo ?? "")
                                                            .isNotEmpty &&
                                                        user.photo != null &&
                                                        images.existsSync()
                                                    ? null
                                                    : Icon(
                                                        Icons.person,
                                                        size: 35,
                                                        color:
                                                            AppColors.hijauMuda,
                                                      ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.name!,
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        size: 20,
                                                        color:
                                                            AppColors.hijauMuda,
                                                      ),
                                                      Text(
                                                        data!.name,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                  )
                                ],
                              ),
                            );
                          }
                        }),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.hijauMuda.withAlpha(70),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                                height: 60,
                                child: TextField(
                                  controller: _fieldText,
                                  readOnly: true,
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    setState(() {
                                      _isOpened = !_isOpened;
                                    });
                                  },
                                  style: GoogleFonts.poppins(
                                      color: AppColors.hijauMuda, fontSize: 30),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    ThousandSeparatorInputFormatter()
                                  ],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    filled: true,
                                    fillColor: AppColors.putih,
                                    hintText: '0',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("Rp.",
                                          style: GoogleFonts.poppins(
                                              color: AppColors.hijauMuda,
                                              fontSize: 25)),
                                    ),
                                    hintStyle: GoogleFonts.poppins(
                                        color: AppColors.hijauMuda,
                                        fontSize: 30),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.putih,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.putih,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.putih,
                                      ),
                                    ),
                                  ),
                                )),
                            Wrap(
                              spacing: 10,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('25000');
                                  },
                                  child: Text(
                                    "Rp. 25.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('50000');
                                  },
                                  child: Text(
                                    "Rp. 50.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('100000');
                                  },
                                  child: Text(
                                    "Rp. 100.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('200000');
                                  },
                                  child: Text(
                                    "Rp. 200.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('500000');
                                  },
                                  child: Text(
                                    "Rp. 500.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 0),
                                    overlayColor: AppColors.hijauMuda,
                                    backgroundColor: AppColors.putih,
                                  ),
                                  onPressed: () {
                                    _fieldText.text = '';
                                    _updateText('1000000');
                                  },
                                  child: Text(
                                    "Rp. 1.000.000",
                                    style: GoogleFonts.jaldi(
                                        fontSize: 16,
                                        color: AppColors.hijauMuda),
                                  ),
                                )
                              ],
                            ),
                            Consumer<User>(builder: (context, user, child) {
                              if (user.isLoggedIn) {
                                return Row(
                                  children: [
                                    Text('Saldo Anda: Rp. ',
                                        style: GoogleFonts.poppins(
                                            color: AppColors.biruMuda,
                                            fontSize: 14)),
                                    Text(
                                      _formatter.format(
                                          int.tryParse(user.saldo!) ?? 0),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.biruMuda,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                );
                              }
                              return SizedBox();
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                        color: AppColors.hijauMuda,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _shouldClearText()
                              ? AppColors.hijauMuda
                              : Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        onPressed: () {
                          if (_shouldClearText()) {
                            final saldo = _fieldText.text.replaceAll('.', '');
                            final newSaldo = int.tryParse(saldo)! +
                                int.tryParse(user.saldo!)!;
                            user.updateSaldo(user.userId!, newSaldo.toString());
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              title: "Topup Berhasil",
                              text:
                                  "Saldo anda telah ditambahkan sebesar Rp. ${_fieldText.text}",
                            );
                            _fieldText.text = '';
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
            Positioned(
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width,
                  height: _isOpened ? 330 : 0,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(50),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: AppColors.putih,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SimpleNumpad(
                      buttonWidth: 100,
                      buttonHeight: 60,
                      gridSpacing: 5,
                      buttonBorderRadius: 8,
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.hijauMuda.withAlpha(200),
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                      ),
                      useBackspace: true,
                      optionText: 'clear',
                      onPressed: (str) {
                        if (str == 'clear') {
                          _fieldText.text = '';
                        } else if (str == 'BACKSPACE') {
                          _handleBackspace();
                        } else {
                          _updateText(str);
                        }
                      },
                    ),
                  ),
                ))
          ],
        ));
  }
}

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat("#,###", "id_ID"); // Format ribuan dengan titik

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String filteredValue =
        newValue.text.replaceAll('.', ''); // Hapus titik lama

    if (filteredValue.isEmpty) return newValue.copyWith(text: '');

    int? number = int.tryParse(filteredValue); // Konversi ke angka

    if (number == null) return oldValue; // Cegah input non-angka

    String newText = _formatter.format(number); // Format angka dengan titik

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
          offset: newText.length), // Posisikan kursor di akhir
    );
  }
}
