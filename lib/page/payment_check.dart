import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';
import 'package:wigoyu/page/payment_confirm.dart';

class PaymentCheck extends StatefulWidget {
  const PaymentCheck({super.key, required this.title});
  static const String routeName = '/payment-check';
  final int title;

  @override
  State<PaymentCheck> createState() => _PaymentCheckState();
}

class _PaymentCheckState extends State<PaymentCheck> {
  late User user;
  final TextEditingController _pinController = TextEditingController();

  int wrongPin = 0;

  String pin = '';
  bool enabled = true;
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
  }

  final defaultPinTheme = PinTheme(
    margin: EdgeInsets.all(3),
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.hijauMuda.withAlpha(100), width: 2.0),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  Future<void> _checkPin() async {
    if (wrongPin > 5) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Pin Salah',
          disableBackBtn: true,
          onConfirmBtnTap: () => context.pushReplacementTransition(
              child: BottomNavigation(), type: PageTransitionType.rightToLeft),
          confirmBtnText: 'Kembali',
          confirmBtnColor: Colors.redAccent,
          text: 'Anda sudah salah memasukkan pin lebih dari 5 kali');
    }
    if (_pinController.text == user.pin) {
      setState(() {
        enabled = false;
      });
      await Future.delayed(const Duration(milliseconds: 500, seconds: 1));
      if (mounted) {
        context.pushReplacementTransition(
            child: PaymentConfirm(
              title: widget.title,
            ),
            type: PageTransitionType.rightToLeft);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.putih,
          title: Text(
            'Periksa Pembayaran',
            style: TextStyle(color: AppColors.hitam),
          ),
        ),
        backgroundColor: AppColors.putih,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 50,
                    children: [
                      Text("Konfirmasi Pin",
                          style: TextStyle(
                              color: AppColors.hijauMuda,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Pinput(
                          obscuringCharacter: '*',
                          obscureText: true,
                          enabled: enabled,
                          disabledPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: AppColors.biruMuda.withAlpha(100),
                            ),
                          ),
                          controller: _pinController,
                          length: 5,
                          defaultPinTheme: defaultPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Pin tidak boleh kosong';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Hanya boleh angka';
                            }
                            if (user.pin != value) {
                              setState(() {
                                wrongPin++;
                              });
                              _pinController.clear();
                              return 'Pin salah';
                            }
                            return null;
                          },
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (value) async {
                            if (RegExp(r'^\d+$').hasMatch(value)) {
                              await _checkPin();
                            }
                          },
                          cursor: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(bottom: 9),
                                width: 22,
                                height: 1,
                                color: AppColors.putih,
                              ),
                            ],
                          ),
                          focusedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
                            color: AppColors.hijauMuda.withAlpha(50),
                          )),
                          submittedPinTheme: defaultPinTheme.copyWith(
                            decoration: defaultPinTheme.decoration!.copyWith(
                              color: AppColors.hijauMuda.withAlpha(50),
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                // Menggunakan Border.all untuk menghindari error
                                color: AppColors.hijauMuda,
                                width: 2.0,
                              ),
                            ),
                          ),
                          errorPinTheme: defaultPinTheme.copyBorderWith(
                            border: Border.all(
                              color: Colors.redAccent,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
