import 'dart:io';
import 'dart:typed_data';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:wigoyu/app_color.dart';
import 'dart:ui' as ui;

class ChangeQris extends StatefulWidget {
  const ChangeQris({super.key, this.title});
  static const String routeName = '/change-qris';
  final int? title;

  @override
  State<ChangeQris> createState() => _ChangeQrisState();
}

class _ChangeQrisState extends State<ChangeQris> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.title == null) {
        Navigator.pop(context);
        CherryToast.warning(
          animationDuration: Duration(milliseconds: 500),
          animationType: AnimationType.fromTop,
          title: Text(
            'Perhatian',
            style: GoogleFonts.jaldi(fontSize: 16),
          ),
          action: Text(
            "Maaf terjadi kesalahan",
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.hitam.withAlpha(90)),
          ),
        ).show(context);
      }
    });
  }

  final GlobalKey _globalKey = GlobalKey();

  // Fungsi untuk menangkap gambar dari widget
  Future<void> _captureImage() async {
    try {
      // Ambil tangkapan gambar dari widget yang dibungkus dengan RepaintBoundary
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert gambar ke bytes
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      // Simpan gambar ke file (misalnya di folder aplikasi)
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/qr_code_image.png');
      await file.writeAsBytes(uint8List);

      // Menampilkan lokasi file
      print('Gambar berhasil disimpan di: ${file.path}');
    } catch (e) {
      print('Error saat mengambil gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hijauMuda,
      appBar: AppBar(),
      body: Column(
        children: [
          RepaintBoundary(
            key: _globalKey,
            child: Text(
              'Change QRIS',
              style: GoogleFonts.jaldi(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.putih),
            ),
          ),
          IconButton(
              onPressed: () {
                _captureImage();
              },
              icon: Icon(Icons.download)),
          SizedBox(
            height: 100,
          ),
          Center(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                  color: AppColors.putih,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.hitam.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ]),
              child: Center(
                child: SizedBox(
                    width: 300,
                    child: PrettyQrView.data(
                      errorBuilder: (context, error, stackTrace) {
                        return const Text('Something went wrong!');
                      },
                      errorCorrectLevel: QrErrorCorrectLevel.H,
                      data: 'lorem ipsum dolor sit amet',
                      decoration: const PrettyQrDecoration(
                        background: AppColors.putih,
                        image: PrettyQrDecorationImage(
                          filterQuality: FilterQuality.high,
                          image: AssetImage('assets/icons/home.png'),
                        ),
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
