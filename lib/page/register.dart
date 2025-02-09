import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/notification.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';
import 'package:wigoyu/page/verify_email.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const String routeName = '/register';

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>(); // Key untuk form
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  bool isChecked = false;
  String? asyncErrorMessage;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    double sizeWidth = MediaQuery.of(context).size.width;
    double sizeScreen = MediaQuery.of(context).size.height;
    double contentHeight = sizeScreen < 825 ? 825 : sizeScreen;
    double maxWidth = 500;
    double containerWidth = sizeWidth > maxWidth ? maxWidth : sizeWidth - 40;
    final notification = NotificationService();

    Future<Map<String, String>> register(String name, String email,
        String phone, String password, String? referral) async {
      // Generate ID dan token unik
      String id = await UserPreferences.generateUniqueId();
      String token = await UserPreferences.generateUniqueToken();

      Users newUser = Users(
          id: id,
          token: token,
          name: name,
          email: email,
          phone: phone,
          password: password,
          referral: referral,
          saldo: '0',
          verified: 'false',
          history: [],
          photo: "",
          pin: "");

      await UserPreferences.registerUser(newUser);
      notification.showNotification(id: 2, title: "Email Token", body: token);
      return {'token': token, 'email': email, 'id': id};
    }

    Future<void> checkEmailAvailability(String email) async {
      final users = await UserPreferences.getAllUsers();
      final emailExists = users.any((user) => user.email == email);

      setState(() {
        if (emailExists) {
          asyncErrorMessage = 'Email sudah digunakan';
        } else {
          asyncErrorMessage = null;
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.putih,
      body: SafeArea(
          top: true,
          bottom: false,
          left: false,
          right: false,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: CustomScrollView(slivers: [
              SliverToBoxAdapter(
                  child: Column(children: [
                Stack(children: [
                  Container(
                    height: contentHeight,
                  ),
                  Positioned(
                    left: -20,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 130, // Lebar lingkaran
                        height: 130, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.hijauMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -80,
                    bottom: contentHeight / 2,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 220, // Lebar lingkaran
                        height: 220, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.biruMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: contentHeight / 2 + -40,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 100, // Lebar lingkaran
                        height: 100, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.hijauMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -90,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 220, // Lebar lingkaran
                        height: 220, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.biruMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: 50,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 100, // Lebar lingkaran
                        height: 100, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.biruMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -70,
                    bottom: contentHeight / 2 + 80,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 220, // Lebar lingkaran
                        height: 220, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.hijauMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    top: contentHeight / 2 + 80,
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        width: 150, // Lebar lingkaran
                        height: 150, // Tinggi lingkaran
                        decoration: BoxDecoration(
                          color: AppColors.hijauMuda, // Warna lingkaran
                          shape: BoxShape.circle, // Membuat bentuk lingkaran
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: contentHeight / 8,
                      left: 50,
                      right: 50,
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                cursorColor: AppColors.putih,
                                style:
                                    GoogleFonts.barlow(color: AppColors.putih),
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
                                  fillColor: AppColors.biruTua,
                                  hintText: 'Nama',
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
                                    return 'Nama tidak boleh kosong';
                                  }
                                  if (value.length < 7) {
                                    return 'Nama harus memiliki minimal 7 karakter';
                                  }
                                  if (value.length > 50) {
                                    return 'Nama tidak boleh lebih dari 50 karakter';
                                  }
                                  if (value.trim() != value) {
                                    return 'Nama tidak boleh ada spasi di awal atau di akhir';
                                  }
                                  return null; // Validasi lolos
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _emailController,
                                cursorColor: AppColors.putih,
                                style:
                                    GoogleFonts.barlow(color: AppColors.putih),
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
                                  fillColor: AppColors.biruTua,
                                  hintText: 'Email',
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
                                  checkEmailAvailability(value ?? '');

                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (value.length < 7) {
                                    return 'Email harus memiliki minimal 7 karakter';
                                  }
                                  if (value.length > 70) {
                                    return 'Email tidak boleh lebih dari 70 karakter';
                                  }
                                  if (value.trim() != value) {
                                    return 'Email tidak boleh ada spasi di awal atau di akhir';
                                  }
                                  final regex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                  if (!regex.hasMatch(value)) {
                                    return 'Masukkan alamat email yang valid';
                                  }
                                  return asyncErrorMessage; // Validasi lolos
                                },
                                onChanged: (value) =>
                                    checkEmailAvailability(value),
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                  keyboardType: TextInputType.phone,
                                  maxLength: 13,
                                  controller: _phoneController,
                                  cursorColor: AppColors.putih,
                                  style: GoogleFonts.barlow(
                                      color: AppColors.putih),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(
                                          14.0), // Sesuaikan padding sesuai keinginan
                                      child: Text(
                                        "+62",
                                        style: TextStyle(
                                          color: AppColors
                                              .putih, // Mengubah warna teks prefix
                                          fontSize:
                                              16, // Menyesuaikan ukuran font
                                        ),
                                      ),
                                    ),
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
                                    fillColor: AppColors.biruTua,
                                    hintText: 'Nomor Handphone',
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
                                      return 'Nomor handphone tidak boleh kosong';
                                    }
                                    if (value.trim() != value) {
                                      return 'Nomor handphone tidak boleh ada spasi di awal atau di akhir';
                                    }
                                    if (value.length < 7) {
                                      return 'Nomor handphone harus memiliki minimal 7 karakter';
                                    }
                                    if (value.length > 14) {
                                      return 'Nomor handphone tidak boleh lebih dari 14 karakter';
                                    }
                                    if (!value.startsWith('08')) {
                                      return 'Nomor handphone harus dimulai dengan 08';
                                    }
                                    final regex = RegExp(r'^[0-9]+$');
                                    if (!regex.hasMatch(value)) {
                                      return 'Nomor handphone hanya boleh mengandung angka';
                                    }
                                    return null;
                                  }),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                cursorColor: AppColors.putih,
                                style:
                                    GoogleFonts.barlow(color: AppColors.putih),
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
                                  fillColor: AppColors.biruTua,
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
                                  if (value.length < 8) {
                                    return 'Password harus memiliki minimal 8 karakter';
                                  }
                                  if (value.length > 30) {
                                    return 'Password tidak boleh lebih dari 30 karakter';
                                  }
                                  return null; // Password valid
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordConfirmationController,
                                obscureText: true,
                                cursorColor: AppColors.putih,
                                style:
                                    GoogleFonts.barlow(color: AppColors.putih),
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
                                  fillColor: AppColors.biruTua,
                                  hintText: 'Konfirmasi Password',
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
                                    return 'Konfirmasi password tidak boleh kosong';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Password dan konfirmasi password tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 15),
                              TextFormField(
                                controller: _referralController,
                                cursorColor: AppColors.putih,
                                style:
                                    GoogleFonts.barlow(color: AppColors.putih),
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
                                  fillColor: AppColors.biruTua,
                                  hintText: 'Referral (Jika memiliki)',
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
                                  if (value != null && value.isNotEmpty) {
                                    if (value.length < 6) {
                                      return 'Kode referal minimal 6 karakter';
                                    }
                                    if (value.length > 12) {
                                      return 'Kode referal maksimal 12 karakter';
                                    }
                                  }
                                  return null; // Validasi lolos jika kosong atau sesuai dengan ketentuan
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              InkWell(
                                  onTap: () async {
                                    if (isChecked) {
                                      if (_formKey.currentState!.validate()) {
                                        Map<String, String> token =
                                            await register(
                                                _nameController.text,
                                                _emailController.text,
                                                _phoneController.text,
                                                _passwordController.text,
                                                _referralController.text);
                                        checkEmailAvailability(
                                            _emailController.text);
                                        if (context.mounted) {
                                          QuickAlert.show(
                                            onConfirmBtnTap: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      VerifyEmail(
                                                    token: token['token'] ?? '',
                                                    email: token['email'] ?? '',
                                                    id: token['id'] ?? '',
                                                  ),
                                                ),
                                                (route) =>
                                                    false, // Hapus semua halaman sebelumnya
                                              );
                                            },
                                            disableBackBtn: false,
                                            context: context,
                                            type: QuickAlertType.success,
                                            title: 'Berhasil',
                                            text:
                                                'Periksa email Anda untuk verifikasi akun',
                                          );
                                        }
                                      }
                                    } else {
                                      QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: 'Maaf',
                                        text:
                                            'Anda harus menyetujui syarat dan ketentuan serta kebijakan privasi',
                                      );
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  splashColor: AppColors.biruMuda,
                                  child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                          horizontal: containerWidth / 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.hijauMuda,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey
                                                .withValues(alpha: 10),
                                            spreadRadius: 1,
                                            blurRadius: 2,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Daftar",
                                        style: GoogleFonts.daysOne(
                                            color: AppColors.putih,
                                            fontSize: 18),
                                      ))),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    activeColor: AppColors.biruMuda,
                                    value: isChecked,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text:
                                              "Dengan mendaftar, Anda menyetujui ",
                                          style:
                                              GoogleFonts.baloo2(fontSize: 11)),
                                      TextSpan(
                                          text: "Syarat dan Ketentuan",
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, '/terms');
                                            },
                                          style: GoogleFonts.baloo2(
                                              fontSize: 11,
                                              color: AppColors.biruMuda)),
                                      TextSpan(
                                          text: " serta",
                                          style:
                                              GoogleFonts.baloo2(fontSize: 11)),
                                      TextSpan(
                                          text: " Kebijakan dan Privasi",
                                          style: GoogleFonts.baloo2(
                                              fontSize: 11,
                                              color: AppColors.biruMuda),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              Navigator.pushNamed(
                                                  context, '/privacy');
                                            }),
                                      TextSpan(
                                          text: " dari Wigoyu",
                                          style:
                                              GoogleFonts.baloo2(fontSize: 11)),
                                    ])),
                                  ),
                                ],
                              )
                            ],
                          ))),
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
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    child: SizedBox(
                      width: sizeWidth,
                      child: Center(
                        child: Text(
                          "Daftarkan Akun",
                          style: GoogleFonts.barlow(
                              fontSize: 30, color: AppColors.hitam),
                        ),
                      ),
                    ),
                  )
                ])
              ]))
            ]),
          )),
    );
  }
}
