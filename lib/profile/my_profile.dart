import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/register.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/page/login.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});
  static const routeName = '/my-profile';

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late User users;
  String? noTelp;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      users.updateImage(users.userId!, pickedFile.path);
    }
  }

  Future<void> _pickCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      users.updateImage(users.userId!, pickedFile.path);
    }
  }

  void _editName(String name) {
    if (name.isEmpty) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Peringatan',
          text: 'Nama tidak boleh kosong');
      return;
    }

    if (name.length < 7) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Peringatan',
          text: 'Nama tidak boleh kurang dari 7 karakter');
      return;
    }

    if (name.length > 50) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.warning,
          title: 'Peringatan',
          text: 'Nama tidak boleh lebih dari 50 karakter');
      return;
    }

    users.updateName(users.userId!, name);
    Navigator.pop(context);
  }

  Future<String> _getPhone(String userId) async {
    try {
      List<Users> users = await UserPreferences.getAllUsers();
      Users? user = users.firstWhere(
        (user) => user.id == userId,
        orElse: () => throw Exception("User with ID $userId not found"),
      );
      return user.phone!;
    } catch (e) {
      rethrow;
    }
  }

  void _showChooseImage() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 150,
            child: Column(
              children: [
                ListTile(
                  title: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.image),
                      Text(
                        'Gallery',
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  title: Row(
                    spacing: 10,
                    children: [
                      Icon(Icons.camera_alt),
                      Text(
                        'Kamera',
                        style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickCamera();
                  },
                ),
              ],
            ),
          );
        });
  }

  void _showEditName() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: AppColors.putih,
            title: Text(
              "Edit Nama",
              style: GoogleFonts.jaldi(
                color: AppColors.biruTua,
                fontSize: 20,
              ),
            ),
            content: TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: users.name,
                hintStyle: GoogleFonts.jaldi(
                    color: AppColors.hitam.withAlpha(100), fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Batal',
                    style: GoogleFonts.jaldi(
                        color: AppColors.hitam.withAlpha(100), fontSize: 18)),
              ),
              TextButton(
                  onPressed: () {
                    _editName(nameController.text);
                  },
                  child: Text(
                    'Simpan',
                    style: GoogleFonts.jaldi(
                        color: AppColors.hijauMuda, fontSize: 18),
                  )),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      users = Provider.of<User>(context, listen: false);
      _getPhone(users.userId!).then((value) {
        setState(() {
          noTelp = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(
                    height: 230,
                  ),
                  Positioned(
                      top: 120,
                      left: (MediaQuery.of(context).size.width / 2) - 50,
                      child: Consumer<User>(builder: (context, user, child) {
                        final images = File(user.photo!);
                        if (user.isLoggedIn) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(100)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.hitam.withAlpha(60),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      )
                                    ]),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.putih,
                                  backgroundImage:
                                      (user.photo ?? "").isNotEmpty &&
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
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    _showChooseImage();
                                  },
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: AppColors.hijauMuda,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: AppColors.putih,
                                    ),
                                  ),
                                ),
                              )
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
                      })),
                  Positioned(
                      top: 0,
                      child: SafeArea(
                        top: true,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: AppColors.hitam,
                                ),
                              ),
                              Expanded(
                                child: Text("Akun Saya",
                                    style: GoogleFonts.poppins(fontSize: 18)),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Consumer<User>(builder: (context, user, child) {
                if (user.isLoggedIn) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
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
                            _showEditName();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nama',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                              Row(
                                spacing: 20,
                                children: [
                                  Text(
                                    user.name ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(100)),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 20,
                                    color: AppColors.hitam.withAlpha(180),
                                  ),
                                ],
                              )
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
                                title: 'Peringatan',
                                text: 'Fitur belum tersedia');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nomor Telepon',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                              Row(
                                spacing: 20,
                                children: [
                                  Text(
                                    noTelp ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(100)),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 20,
                                    color: AppColors.hitam.withAlpha(180),
                                  ),
                                ],
                              )
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
                                title: 'Peringatan',
                                text: 'Fitur belum tersedia');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Email',
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.hitam.withAlpha(180)),
                              ),
                              Row(
                                spacing: 20,
                                children: [
                                  Text(
                                    user.email ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.hitam.withAlpha(100)),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 20,
                                    color: AppColors.hitam.withAlpha(180),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                }
                return Container();
              }),
            )
          ],
        ));
  }
}
