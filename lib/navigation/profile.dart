import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/page/login.dart';
import 'package:wigoyu/page/register.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late User users;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      users = Provider.of<User>(context, listen: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context, listen: true);

    return Scaffold(
      backgroundColor: AppColors.putih,
      body: CustomScrollView(
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
                Positioned(
                    top: 80,
                    left: 20,
                    child: Consumer<User>(builder: (context, user, child) {
                      final images = File(user.photo ?? "");
                      if (user.isLoggedIn) {
                        return Row(
                          spacing: 15,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: AppColors.putih,
                              backgroundImage: (user.photo ?? "").isNotEmpty &&
                                      user.photo != null &&
                                      images.existsSync()
                                  ? FileImage(images)
                                  : null,
                              child: (user.photo ?? "").isNotEmpty &&
                                      user.photo != null &&
                                      images.existsSync()
                                  ? null
                                  : Icon(
                                      Icons.person,
                                      size: 35,
                                      color: AppColors.hijauMuda,
                                    ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name ?? "",
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.hitam.withAlpha(180)),
                                ),
                                Text(user.email ?? "",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(180))),
                              ],
                            ),
                          ],
                        );
                      }
                      return ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(AppColors.biruTua),
                            padding: WidgetStateProperty.all(
                                EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10))),
                        onPressed: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.scale,
                                  child: Login(),
                                  duration: Duration(milliseconds: 400),
                                  alignment: Alignment.center));
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.daysOne(color: AppColors.putih),
                        ),
                      );
                    }))
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: user.isLoggedIn
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      spacing: 20,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                'Info Akun',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      AppColors.hijauMuda.withAlpha(50)),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.putih),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10))),
                              onPressed: () {
                                context.pushNamedTransition(
                                    routeName: "/my-profile",
                                    type: PageTransitionType.rightToLeft);
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Akun Saya',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(180)),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded)
                                ],
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                'Pengaturan',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      AppColors.hijauMuda.withAlpha(50)),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.putih),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10))),
                              onPressed: () {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    confirmBtnText: "Tungu....",
                                    title: "Coming Soon",
                                    text: "Fitur ini akan segera hadir");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Bahasa',
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                AppColors.hitam.withAlpha(180)),
                                      ),
                                      Text(" - Ind",
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.hitam
                                                  .withAlpha(180))),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded)
                                ],
                              ),
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                'Lainnya',
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      AppColors.hijauMuda.withAlpha(50)),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.putih),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10))),
                              onPressed: () {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    confirmBtnText: "Tungu....",
                                    title: "Coming Soon",
                                    text: "Fitur ini akan segera hadir");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Laporan Masalah',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(180)),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded)
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      AppColors.hijauMuda.withAlpha(50)),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.putih),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10))),
                              onPressed: () {
                                QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    confirmBtnText: "Tungu....",
                                    title: "Coming Soon",
                                    text: "Fitur ini akan segera hadir");
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Dukungan',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(180)),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded)
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  overlayColor: WidgetStatePropertyAll(
                                      AppColors.hijauMuda.withAlpha(50)),
                                  backgroundColor:
                                      WidgetStateProperty.all(AppColors.putih),
                                  padding: WidgetStateProperty.all(
                                      EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10))),
                              onPressed: () async {
                                final String url =
                                    "https://wigoyu.com/contact-us"; // Ganti dengan link tujuan

                                Uri uri = Uri.parse(url);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri,
                                      mode: LaunchMode.externalApplication);
                                } else {
                                  if (context.mounted) {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.error,
                                        title: "Gagal membuka browser",
                                        confirmBtnText: "Tutup",
                                        text:
                                            "Silahkan buka browser dan ketik alamat $url");
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tentang Wigoyu',
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(180)),
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded)
                                ],
                              ),
                            )
                          ],
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              overlayColor: WidgetStatePropertyAll(
                                  AppColors.hijauMuda.withAlpha(50)),
                              backgroundColor:
                                  WidgetStateProperty.all(AppColors.putih),
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10))),
                          onPressed: () {
                            QuickAlert.show(
                                context: context,
                                type: QuickAlertType.warning,
                                onConfirmBtnTap: () {
                                  user.logout();
                                  Navigator.pushNamed(context, '/',
                                      arguments: 0);
                                },
                                cancelBtnText: "Batal",
                                confirmBtnText: "Ya",
                                title: "Keluar",
                                disableBackBtn: true,
                                showCancelBtn: true,
                                confirmBtnColor: Colors.redAccent,
                                text: "Apakah anda yakin ingin keluar?");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Keluar',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                              Icon(Icons.arrow_forward_ios_rounded)
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "Belum punya akun?  ",
                            style: GoogleFonts.baloo2(fontSize: 14)),
                        TextSpan(
                            text: "Daftar Sekarang",
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: Register(),
                                        duration: Duration(milliseconds: 400),
                                        alignment: Alignment.center));
                              },
                            style: GoogleFonts.baloo2(
                                fontSize: 14, color: AppColors.biruMuda)),
                      ])),
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
