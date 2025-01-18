import 'package:flutter/material.dart';
import 'package:wigoyu/app_color.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  static const String routeName = '/login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double sizeScreen = MediaQuery.of(context).size.height;
    // print(sizeScreen / 2);

    return Scaffold(
        backgroundColor: AppColors.putih,
        body: Center(
          child: SafeArea(
            bottom: false,
            left: false,
            right: false,
            top: true,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: [
                          Image.asset(
                            'assets/bg/wigoyu.png',
                            fit: BoxFit.fill,
                          ),
                          Positioned(
                            top: 200,
                            left: -50,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                  width: 100, // Lebar lingkaran
                                  height: 100, // Tinggi lingkaran
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.biruMuda, // Warna lingkaran
                                    shape: BoxShape
                                        .circle, // Membuat bentuk lingkaran
                                  )),
                            ),
                          )
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/');
                        },
                        child: const Text('Go to Search Page'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
