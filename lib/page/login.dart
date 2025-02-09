import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';

class Login extends StatefulWidget {
  const Login({super.key, this.title});
  static const String routeName = '/login';
  final String? title;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<User>(context, listen: false);
      if (userProvider.isLoggedIn) {
        context.pushReplacementTransition(
            child: BottomNavigation(), type: PageTransitionType.rightToLeft);
        return;
      }
      if (widget.title != null) {
        CherryToast.warning(
          animationDuration: Duration(milliseconds: 500),
          animationType: AnimationType.fromTop,
          title: Text(
            'Perhatian',
            style: GoogleFonts.jaldi(fontSize: 16),
          ),
          action: Text(
            widget.title!,
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.hitam.withAlpha(90)),
          ),
        ).show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeScreen = MediaQuery.of(context).size.height;
    double contentHeight = sizeScreen < 825 ? 825 : sizeScreen;
    double maxWidth = 500;
    double containerWidth = sizeWidth > maxWidth ? maxWidth : sizeWidth - 40;

    Future<bool> login(String email, String password) async {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => Users(
            id: '',
            name: '',
            email: '',
            phone: '',
            password: '',
            token: '',
            verified: '',
            saldo: '',
            history: [],
            photo: '',
            pin: '',
            notifications: []),
      );
      if (user.id.isEmpty) {
        return false;
      }
      if (context.mounted) {
        final userProvider = Provider.of<User>(context, listen: false);
        userProvider.login(user.name!, user.id, user.history!, user.email!);
      }
      return true;
    }

    return Scaffold(
      backgroundColor: AppColors.putih,
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        top: true,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: contentHeight,
                      ),
                      Image.asset(
                        'assets/bg/wigoyu.png',
                        height: 200,
                        width: sizeWidth,
                        // fit: BoxFit.fill,
                      ),
                      Positioned(
                        top: contentHeight / 2 - 150,
                        left: -104,
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 223, // Lebar lingkaran
                            height: 233, // Tinggi lingkaran
                            decoration: BoxDecoration(
                              color: AppColors.biruMuda, // Warna lingkaran
                              shape:
                                  BoxShape.circle, // Membuat bentuk lingkaran
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: contentHeight / 2 - 200,
                        right: -30,
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 98, // Lebar lingkaran
                            height: 94, // Tinggi lingkaran
                            decoration: BoxDecoration(
                              color: AppColors.hijauMuda, // Warna lingkaran
                              shape:
                                  BoxShape.circle, // Membuat bentuk lingkaran
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: -104,
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 223, // Lebar lingkaran
                            height: 233, // Tinggi lingkaran
                            decoration: BoxDecoration(
                              color: AppColors.biruMuda, // Warna lingkaran
                              shape:
                                  BoxShape.circle, // Membuat bentuk lingkaran
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: contentHeight / 2 - 200,
                        right: -40,
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 160, // Lebar lingkaran
                            height: 160, // Tinggi lingkaran
                            decoration: BoxDecoration(
                              color: AppColors.hijauTua, // Warna lingkaran
                              shape:
                                  BoxShape.circle, // Membuat bentuk lingkaran
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                          top: contentHeight / 2 - 100,
                          left: 50,
                          right: 50,
                          child: SizedBox(
                            width: containerWidth,
                            child: Form(
                                key: _formKey,
                                child: Column(children: [
                                  TextFormField(
                                    controller: _emailController,
                                    cursorColor: AppColors.putih,
                                    style: GoogleFonts.barlow(
                                        color: AppColors.putih),
                                    decoration: InputDecoration(
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat tidak aktif
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide(
                                            color: Colors.red,
                                            width:
                                                2), // Menghilangkan border saat tidak aktif
                                      ),
                                      labelStyle: TextStyle(
                                        color: AppColors.putih,
                                      ),
                                      hintStyle: TextStyle(
                                        color: AppColors.putih,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.hijauMuda,
                                      hintText: 'Enter your email',
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat tidak aktif
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut saat fokus
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat fokus
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Tolong masukkan email kamu.';
                                      }
                                      final regex = RegExp(
                                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                      if (!regex.hasMatch(value)) {
                                        return 'Masukkan alamat email yang valid'; // Pesan jika format salah
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    controller: _passwordController,
                                    cursorColor: AppColors.putih,
                                    style: GoogleFonts.barlow(
                                        color: AppColors.putih),
                                    decoration: InputDecoration(
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat tidak aktif
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide(
                                            color: Colors.red,
                                            width:
                                                2), // Menghilangkan border saat tidak aktif
                                      ),
                                      labelStyle: TextStyle(
                                        color: AppColors.putih,
                                      ),
                                      hintStyle: TextStyle(
                                        color: AppColors.putih,
                                      ),
                                      filled: true,
                                      fillColor: AppColors.hijauMuda,
                                      hintText: 'Password',
                                      border: InputBorder.none,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat tidak aktif
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            18), // Radius sudut saat fokus
                                        borderSide: BorderSide
                                            .none, // Menghilangkan border saat fokus
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password tidak boleh kosong';
                                      }
                                      if (value.length < 7) {
                                        return 'Password harus memiliki minimal 7 karakter';
                                      }
                                      if (value.length > 50) {
                                        return 'Password tidak boleh lebih dari 50 karakter';
                                      }
                                      return null;
                                    },
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/forgot-password');
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text(
                                            "Lupa password?",
                                            style: GoogleFonts.barlow(
                                                decoration:
                                                    TextDecoration.underline),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  InkWell(
                                      onTap: () async {
                                        if (_formKey.currentState!.validate()) {
                                          Future<bool> checkLogin = login(
                                              _emailController.text,
                                              _passwordController.text);
                                          if (await checkLogin) {
                                            if (context.mounted) {
                                              QuickAlert.show(
                                                onConfirmBtnTap: () {
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BottomNavigation()),
                                                    (route) =>
                                                        false, // Hapus semua halaman sebelumnya
                                                  );
                                                },
                                                disableBackBtn: false,
                                                context: context,
                                                type: QuickAlertType.success,
                                                title: 'Berhasil',
                                              );
                                            }
                                          } else {
                                            if (context.mounted) {
                                              QuickAlert.show(
                                                disableBackBtn: false,
                                                context: context,
                                                type: QuickAlertType.error,
                                                title: 'Gagal',
                                                text:
                                                    'Periksa kembali email dan password Anda.',
                                              );
                                            }
                                          }
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      splashColor: AppColors.biruMuda,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12,
                                              horizontal: containerWidth / 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.biruMuda,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withValues(alpha: 10),
                                                spreadRadius: 1,
                                                blurRadius: 2,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            "Masuk",
                                            style: GoogleFonts.daysOne(
                                                color: AppColors.putih,
                                                fontSize: 18),
                                          ))),
                                  Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: "Belum punya akun?  ",
                                          style:
                                              GoogleFonts.baloo2(fontSize: 10)),
                                      TextSpan(
                                          text: "Daftar Sekarang",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, '/register');
                                            },
                                          style: GoogleFonts.baloo2(
                                              fontSize: 10,
                                              color: AppColors.biruMuda)),
                                    ])),
                                  )
                                ])),
                          )),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: 40, // Lebar lingkaran
                          height: 40, // Tinggi lingkaran
                          decoration: BoxDecoration(
                            color: AppColors.putih, // Warna lingkaran
                            shape: BoxShape.circle, // Membuat bentuk lingkaran
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            color: AppColors.biruMuda,
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(context, "/");
                              }
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: contentHeight / 3.5,
                        child: SizedBox(
                          width: sizeWidth,
                          child: Center(
                            child: Text(
                              "Selamat Datang, di Wigoyu!",
                              style: GoogleFonts.barlow(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.hitam),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
