import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/page/login.dart';

class MakePin extends StatefulWidget {
  const MakePin({
    super.key,
  });
  static const String routeName = '/make_pin';
  @override
  State<MakePin> createState() => _MakePinState();
}

class _MakePinState extends State<MakePin> {
  late User user;
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  String pin = '';
  bool enabled = true;
  bool enabledConfirm = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<User>(context, listen: false);
      if (!userProvider.isLoggedIn) {
        context.pushReplacementTransition(
            child: Login(), type: PageTransitionType.rightToLeft);
        // context.pushNamedTransition(
        //     routeName: '/login', type: PageTransitionType.rightToLeft);
        return;
      }
      setState(() {
        user = userProvider;
      });
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

  Future<void> _savePin(String myPin) async {
    try {
      await user.updatePin(user.userId!, myPin);
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil',
          text: 'Pin berhasil diubah',
          disableBackBtn: true,
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.putih,
          title: Text(
            'Buat Pin',
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
                      Text(pin == "" ? "Buat Pin Baru" : "Konfirmasi Pin",
                          style: TextStyle(
                              color: AppColors.hijauMuda,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      pin == ""
                          ? Directionality(
                              textDirection: TextDirection.ltr,
                              child: Pinput(
                                obscuringCharacter: '*',
                                obscureText: true,
                                enabled: enabled,
                                disabledPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: AppColors.biruMuda.withAlpha(100),
                                  ),
                                ),
                                controller: _pinController,
                                length: 5,
                                defaultPinTheme: defaultPinTheme,
                                separatorBuilder: (index) =>
                                    const SizedBox(width: 8),
                                validator: (value) {
                                  if (!RegExp(r'^\d+$').hasMatch(value!)) {
                                    return 'Hanya boleh angka';
                                  }
                                  return null;
                                },
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                onCompleted: (value) async {
                                  if (RegExp(r'^\d+$').hasMatch(value)) {
                                    setState(() {
                                      enabled = false;
                                    });
                                    await Future.delayed(
                                        const Duration(milliseconds: 1500));
                                    setState(() {
                                      pin = value;
                                    });
                                  } else {
                                    _pinController.clear();
                                    return;
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
                                    decoration:
                                        defaultPinTheme.decoration!.copyWith(
                                  color: AppColors.hijauMuda.withAlpha(50),
                                )),
                                submittedPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: AppColors.hijauMuda.withAlpha(50),
                                    borderRadius: BorderRadius.circular(19),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.hijauMuda,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),
                                errorPinTheme: defaultPinTheme.copyBorderWith(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.red, // Warna garis bawah
                                      width: 2.0, // Ketebalan garis bawah
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Directionality(
                              textDirection: TextDirection.ltr,
                              child: Pinput(
                                obscuringCharacter: '*',
                                obscureText: true,
                                disabledPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: AppColors.biruMuda.withAlpha(100),
                                  ),
                                ),
                                controller: _pinConfirmController,
                                enabled: enabledConfirm,
                                length: 5,
                                defaultPinTheme: defaultPinTheme,
                                separatorBuilder: (index) =>
                                    const SizedBox(width: 8),
                                validator: (value) {
                                  if (!RegExp(r'^\d+$').hasMatch(value!)) {
                                    return 'Hanya boleh angka';
                                  }
                                  if (value != pin) {
                                    return 'Pin tidak sama';
                                  }
                                  return null;
                                },
                                hapticFeedbackType:
                                    HapticFeedbackType.lightImpact,
                                onCompleted: (value) async {
                                  if (RegExp(r'^\d+$').hasMatch(value)) {
                                    setState(() {
                                      enabledConfirm = false;
                                    });
                                    await Future.delayed(
                                        const Duration(milliseconds: 1500));
                                    if (value == pin) {
                                      await _savePin(pin);
                                      return;
                                    } else {
                                      _pinConfirmController.clear();
                                      setState(() {
                                        enabledConfirm = true;
                                      });
                                      return;
                                    }
                                  } else {
                                    _pinConfirmController.clear();
                                    setState(() {
                                      enabledConfirm = true;
                                    });
                                    return;
                                  }
                                },
                                onChanged: (value) {
                                  debugPrint('onChanged: $value');
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
                                    decoration:
                                        defaultPinTheme.decoration!.copyWith(
                                  color: AppColors.hijauMuda.withAlpha(50),
                                )),
                                submittedPinTheme: defaultPinTheme.copyWith(
                                  decoration:
                                      defaultPinTheme.decoration!.copyWith(
                                    color: AppColors.hijauMuda.withAlpha(50),
                                    borderRadius: BorderRadius.circular(19),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors
                                            .hijauMuda, // Warna garis bawah
                                        width: 2.0, // Ketebalan garis bawah
                                      ),
                                    ),
                                  ),
                                ),
                                errorPinTheme: defaultPinTheme.copyBorderWith(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.red, // Warna garis bawah
                                      width: 2.0, // Ketebalan garis bawah
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      GestureDetector(
                        onTap: () {
                          if (pin.isNotEmpty) {
                            _pinController.clear();
                            _pinConfirmController.clear();
                            setState(() {
                              pin = '';
                              enabled = true;
                              enabledConfirm = true;
                            });
                            return;
                          }

                          // _savePin();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            Text(
                              "Ulang Pin",
                              style:
                                  GoogleFonts.poppins(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
