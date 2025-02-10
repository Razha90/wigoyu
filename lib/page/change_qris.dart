import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_store/flutter_media_store.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/user.dart';
import 'dart:ui' as ui;

import 'package:wigoyu/model/item_product.dart';
import 'package:wigoyu/model/user_voucher.dart';
import 'package:wigoyu/model/voucher_used.dart';

class ChangeQris extends StatefulWidget {
  const ChangeQris({super.key, this.title});
  static const String routeName = '/change-qris';
  final int? title;

  @override
  State<ChangeQris> createState() => _ChangeQrisState();
}

class _ChangeQrisState extends State<ChangeQris> {
  late Future<ItemProduct?> _product;
  late User user;
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
    _product = _getParentProduct(widget.title!);
    user = Provider.of<User>(context, listen: false);
  }

  Future<ItemProduct?> _getParentProduct(int voucherId) async {
    await Future.delayed(Duration(seconds: 1));
    final String response =
        await rootBundle.loadString('assets/data/data.json');
    final List<dynamic> data = json.decode(response);
    final List<ItemProduct> products =
        data.map((json) => ItemProduct.fromJson(json)).toList();

    for (var product in products) {
      for (var voucher in product.voucher) {
        if (voucher.id == voucherId) {
          return product;
        }
      }
    }
    if (mounted) {
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
    return null;
  }

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _captureImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();

      String fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';

      // Simpan ke folder Download
      Directory? externalDir = Directory('/storage/emulated/0/Download');
      if (!externalDir.existsSync()) {
        externalDir.createSync(recursive: true);
      }

      final file = File('${externalDir.path}/$fileName');
      await file.writeAsBytes(uint8List);
      final flutterMediaStorePlugin = FlutterMediaStore();
      await flutterMediaStorePlugin.saveFile(
        fileData: uint8List,
        fileName: fileName,
        mimeType: 'image/png', // Tipe file gambar
        rootFolderName:
            'Download', // Nama folder root (bisa diubah sesuai keinginan)
        folderName: 'MyImages', // Nama folder tempat gambar disimpan
        onSuccess: (uri, filePath) {
          print("File berhasil disimpan dan terdeteksi.");
        },
        onError: (error) {
          print("Terjadi error: $error");
        },
      );

      if (mounted) {
        CherryToast.success(
          animationDuration: Duration(milliseconds: 500),
          animationType: AnimationType.fromTop,
          title: Text(
            'Gambar Berhasil Disimpan',
            style: GoogleFonts.jaldi(fontSize: 16),
          ),
          action: Text(
            "Gambar berhasil disimpan di folder Download",
            style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.hitam.withAlpha(200)),
          ),
        ).show(context);
      }
    } catch (e) {
      print('Error saat menyimpan gambar: $e');
      if (mounted) {
        CherryToast.error(
          animationDuration: Duration(milliseconds: 500),
          animationType: AnimationType.fromTop,
          title: Text(
            'Gagal Simpan Gambar',
            style: GoogleFonts.jaldi(fontSize: 16),
          ),
          action: Text(
            "Maaf terjadi kesalahan saat menyimpan gambar",
            style: GoogleFonts.poppins(
                fontSize: 12, color: Colors.redAccent.withAlpha(200)),
          ),
        ).show(context);
      }
    }
  }

  Future<void> _shareImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List uint8List = byteData!.buffer.asUint8List();
      Directory appDir = await getApplicationDocumentsDirectory();
      String filePath = '${appDir.path}/qr_code_image.png';
      final file = File(filePath);
      await file.writeAsBytes(uint8List);
      ItemProduct? getProduct = await _product;
      UserVoucher getVoucher = getProduct!.voucher
          .firstWhere((element) => element.id == widget.title);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Silahkan scan QR Code ini di merchant ${getProduct.name} untuk mendapatkan diskon ${getVoucher.discount}%.\nDapatkan voucher lainnya di aplikasi Wigoyu.\nKunjungi https://wigoyu.com/',
        sharePositionOrigin: Rect.zero,
        subject: 'QR Code',
      );
    } catch (e) {
      print('Error saat menyimpan gambar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.hijauMuda,
      appBar: AppBar(
        leadingWidth: 70,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.putih),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Kembali',
          style: GoogleFonts.jaldi(color: AppColors.putih),
        ),
        backgroundColor: AppColors.hijauMuda,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Text("Scan QR Code di Merchant",
              style: GoogleFonts.jaldi(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.putih)),
          SizedBox(
            height: 30,
          ),
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                    color: AppColors.putih,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.hitam.withAlpha(50),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: FutureBuilder<ItemProduct?>(
                        future: _product,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppColors.hijauMuda,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (snapshot.hasData) {
                            final UserVoucher voucher = snapshot.data!.voucher
                                .firstWhere(
                                    (element) => element.id == widget.title);
                            VoucherUsed voucherUsed =
                                VoucherUsed.fromUserVoucher(
                                    voucher, user.name!);
                            return PrettyQrView.data(
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Something went wrong!');
                              },
                              errorCorrectLevel: QrErrorCorrectLevel.H,
                              data: jsonEncode(voucherUsed),
                              decoration: const PrettyQrDecoration(
                                background: AppColors.putih,
                                image: PrettyQrDecorationImage(
                                  filterQuality: FilterQuality.high,
                                  image: AssetImage('assets/icons/home.png'),
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: Text('Data tidak ditemukan'),
                            );
                          }
                        }),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 320,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.putih,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      backgroundColor: AppColors.biruMuda),
                  onPressed: _captureImage,
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        Icons.download,
                        color: AppColors.putih,
                      ),
                      Text(
                        'Simpan Gambar',
                        style: GoogleFonts.poppins(color: AppColors.putih),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.putih,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.redAccent),
                    onPressed: () {
                      _shareImage();
                    },
                    child: Row(
                      spacing: 10,
                      children: [
                        Icon(Icons.share, color: AppColors.putih),
                        Text("Bagikan",
                            style: GoogleFonts.poppins(color: AppColors.putih)),
                      ],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
