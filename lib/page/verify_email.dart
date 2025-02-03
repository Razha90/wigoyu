import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/notification.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/help/user.dart';
import 'package:timer_button/timer_button.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail(
      {super.key, required this.token, required this.email, required this.id});
  final String token;
  final String email;
  final String id;
  static const String routeName = '/verify-email';

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  late String token;
  late String email;
  late String id;
  final TextEditingController pinController = TextEditingController();
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: AppColors.hitam, // Warna garis bawah
          width: 2.0, // Ketebalan garis bawah
        ),
      ),
    ),
  );
  User? user;

  @override
  void initState() {
    super.initState();
    token = widget.token;
    email = widget.email;
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<User>(context, listen: true);
    final notification = NotificationService();
    void loginUser(String id) async {
      try {
        final allUsers = await UserPreferences.getAllUsers();
        final matchingUserIndex = allUsers.indexWhere((user) => user.id == id);
        if (matchingUserIndex != -1) {
          final matchingUser = allUsers[matchingUserIndex];
          final updatedUser = Users(
            id: matchingUser.id,
            name: matchingUser.name,
            email: matchingUser.email,
            phone: matchingUser.phone,
            password: matchingUser.password,
            token: matchingUser.token,
            verified: 'true',
            referral: matchingUser.referral,
            saldo: matchingUser.saldo,
            history: [],
            photo: matchingUser.photo,
          );

          // Memperbarui data pengguna di SharedPreferences
          // updatedUser.history!.removeAt(0);
          allUsers[matchingUserIndex] = updatedUser;

          await UserPreferences.saveAllUsers(allUsers);

          // List<Users> newUsers = await UserPreferences.getAllUsers();
          // Users? newUser = newUsers.firstWhere(
          //   (user) => user.id == matchingUser.id,
          //   orElse: () =>
          //       throw Exception("User with ID $matchingUser.id not found"),
          // );
          // newUser.history!.removeAt(0);
          // await UserPreferences.saveAllUsers(newUsers);

          if (context.mounted) {
            final userProvider = Provider.of<User>(context, listen: false);
            userProvider.login(matchingUser.name!, matchingUser.id,
                matchingUser.history!, matchingUser.email!);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomNavigation()),
              (route) => false,
            );
          }
        } else {
          print("Pengguna dengan ID $id tidak ditemukan.");
        }
      } catch (e) {
        print("Terjadi kesalahan: $e");
      }
    }

    // user.addListener(() {
    //   if (user.isLoggedIn) {
    //     // Pindahkan pengguna ke halaman utama jika login berhasil
    //     Navigator.pushReplacementNamed(context, '/home');
    //   }
    // });

    double sizeWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: AppColors.putih,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
            top: true,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Expanded(
                          child: Text(
                        textAlign: TextAlign.center,
                        'Verifikasi Email',
                        style: GoogleFonts.barlow(fontSize: 25),
                      )),
                      SizedBox(
                        width: sizeWidth / 8,
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child: Form(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Stack(
                          children: [
                            Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 200, // Lebar lingkaran
                                height: 200, // Tinggi lingkaran
                                decoration: BoxDecoration(
                                  color: AppColors.biruMuda, // Warna lingkaran
                                  shape: BoxShape
                                      .circle, // Membuat bentuk lingkaran
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/icons/image50.png',
                              height: 200,
                              // fit: BoxFit.fill,
                            )
                          ],
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          "Tolong masukkan 5 digit kode",
                          style: GoogleFonts.jaldi(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          email,
                          style: GoogleFonts.jaldi(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Pinput(
                            controller: pinController,
                            length: 5,
                            // You can pass your own SmsRetriever implementation based on any package
                            // in this example we are using the SmartAuth
                            // smsRetriever: smsRetriever,
                            // controller: pinController,
                            // focusNode: focusNode,
                            defaultPinTheme: defaultPinTheme,
                            separatorBuilder: (index) =>
                                const SizedBox(width: 8),
                            validator: (value) {
                              // debugPrint('ini token $token ini value $value');
                              if (value == token) {
                                loginUser(id);
                                pinController.clear();
                                return null;
                              }
                              return 'Pin salah';
                            },
                            hapticFeedbackType: HapticFeedbackType.lightImpact,
                            onCompleted: (pin) {
                              // debugPrint('onCompleted: $pin');
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
                              decoration: defaultPinTheme.decoration!.copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors
                                          .biruTua, // Warna garis bawah
                                      width: 2.0, // Ketebalan garis bawah
                                    ),
                                  )),
                            ),
                            submittedPinTheme: defaultPinTheme.copyWith(
                              decoration: defaultPinTheme.decoration!.copyWith(
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
                        SizedBox(
                          height: 50,
                        ),
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: Text(
                        //     'Kirim Ulang Kode',
                        //     style:
                        //         GoogleFonts.jaldi(color: AppColors.hijauMuda),
                        //   ),
                        // )
                        TimerButton.builder(
                          resetTimerOnPressed: true,
                          builder: (context, timeLeft) {
                            // return Text(
                            //   "Custom: $timeLeft",
                            //   style: const TextStyle(color: Colors.red),
                            // );
                            if (timeLeft < 1) {
                              return Text(
                                "Kirim Ulang Kode",
                                style: GoogleFonts.jaldi(
                                    color: AppColors.hijauMuda,
                                    fontStyle: FontStyle.italic),
                              );
                            } else {
                              return Text(
                                "Kirim Ulang Kode: $timeLeft",
                                style: GoogleFonts.jaldi(
                                  color: AppColors.hijauMuda
                                      .withAlpha(80), // Warna teks
                                  fontSize: 14, // Ukuran font
                                ),
                              );
                            }
                          },
                          onPressed: () {
                            QuickAlert.show(
                              autoCloseDuration: Duration(seconds: 3),
                              showConfirmBtn: false,
                              confirmBtnText: "Baiklah",
                              onConfirmBtnTap: () {
                                null;
                              },
                              disableBackBtn: false,
                              context: context,
                              type: QuickAlertType.success,
                              title: 'Kirim Ulang Kode Berhasil',
                              text: 'Periksa email Anda untuk verifikasi akun',
                            );
                            notification.showNotification(
                                id: 3, title: "Email Token", body: token);
                          },
                          timeOutInSeconds: 120,
                        ),
                      ],
                    )),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
