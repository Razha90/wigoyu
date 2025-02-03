import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickalert/quickalert.dart';
import 'package:wigoyu/app_color.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  static const String routeName = '/scanner';

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controllerScan = MobileScannerController();
  bool _flashOn = false;
  // File? _image;
  bool _isScanning = false;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        BarcodeCapture? bordScan =
            await _controllerScan.analyzeImage(pickedFile.path);
        final List<Barcode> codes = bordScan!.barcodes;
        for (final code in codes) {
          final String? rawValue = code.rawValue; // Teks dalam barcode
          if (rawValue!.isNotEmpty) {
            _controllerScan.stop();
            setState(() {
              _isScanning = true;
            });
            await Future.delayed(Duration(seconds: 2));
            setState(() {
              _isScanning = false;
            });
            if (mounted) {
              QuickAlert.show(
                disableBackBtn: true,
                context: context,
                showCancelBtn: true,
                type: QuickAlertType.success,
                onConfirmBtnTap: () {
                  _controllerScan.start();
                  Navigator.pop(context);
                  return;
                },
                onCancelBtnTap: () {
                  Navigator.pushNamed(context, "/");
                },
                confirmBtnText: "Scan Lagi",
                cancelBtnText: "Kembali",
                title: 'Hasil Scan',
                text: rawValue,
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          QuickAlert.show(
            disableBackBtn: true,
            context: context,
            showCancelBtn: true,
            type: QuickAlertType.error,
            onConfirmBtnTap: () {
              _controllerScan.start();
              Navigator.pop(context);
            },
            onCancelBtnTap: () {
              Navigator.pushNamed(context, "/");
            },
            confirmBtnText: "Coba Lagi",
            cancelBtnText: "Kembali",
            title: 'Maaaf',
            text: "Gagal membaca barcode",
          );
        }
      }
    }
  }

  Future<void> _checkCamera() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return;
    }
    if (status.isDenied) {
      if (mounted) {
        QuickAlert.show(
          onConfirmBtnTap: () {
            openAppSettings();
          },
          context: context,
          type: QuickAlertType.warning,
          title: 'Izin Kamera Dibutuhkan',
          text: 'Kami membutuhkan izin kamera untuk melanjutkan',
        );
      }

      return;
    }
  }

  @override
  void initState() {
    _controllerScan.addListener(() {
      if (_controllerScan.autoStart) {
        _checkCamera();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        MobileScanner(
          onDetect: (barcodes) async {
            final List<Barcode> codes = barcodes.barcodes;
            for (final code in codes) {
              final String? rawValue = code.rawValue; // Teks dalam barcode
              if (rawValue!.isNotEmpty) {
                _controllerScan.stop();
                setState(() {
                  _isScanning = true;
                });
                await Future.delayed(Duration(seconds: 2));
                setState(() {
                  _isScanning = false;
                });
                if (context.mounted) {
                  QuickAlert.show(
                    context: context,
                    showCancelBtn: true,
                    type: QuickAlertType.success,
                    onConfirmBtnTap: () {
                      _controllerScan.start();
                      Navigator.pop(context);
                      return;
                    },
                    onCancelBtnTap: () {
                      Navigator.pushNamed(context, "/");
                    },
                    confirmBtnText: "Scan Lagi",
                    cancelBtnText: "Kembali",
                    title: 'Hasil Scan',
                    text: rawValue,
                  );
                }
              }
            }
          },
          controller: _controllerScan,
          overlayBuilder: (context, constraints) {
            final double overlaySize = 270.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 150),
                      BlendMode.srcOut,
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: overlaySize,
                            height: overlaySize,
                            decoration: BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Border kotak fokus
                Center(
                  child: CustomPaint(
                    size: Size(overlaySize + 40, overlaySize + 40),
                    painter: RoundedCornerPainter(),
                  ),
                ),
              ],
            );
          },
        ),
        Positioned(
          top: 20,
          left: 20,
          child: SafeArea(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColors.putih,
                size: 30,
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 50,
            child: SafeArea(
              bottom: true,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.transparent
                          // Mengatur padding agar tombol tidak terlalu besar
                          ),
                      onPressed: () {
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                        _controllerScan.toggleTorch();
                      },
                      child: TweenAnimationBuilder<Color?>(
                        tween: ColorTween(
                          begin: AppColors.putih.withAlpha(200), // Warna awal
                          end: _flashOn
                              ? Colors.orangeAccent.withAlpha(200)
                              : AppColors.putih.withAlpha(200), // Warna tujuan
                        ),
                        duration: Duration(
                            milliseconds: 300), // Durasi transisi warna
                        builder: (context, color, child) {
                          return Icon(
                            _flashOn
                                ? Icons.flashlight_on
                                : Icons.flashlight_off,
                            size: 60,
                            color: color,
                          );
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 10),
                    //   child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //           shape: CircleBorder(),
                    //           padding: EdgeInsets.all(10),
                    //           backgroundColor: AppColors.biruMuda,
                    //           foregroundColor: AppColors.hijauMuda,
                    //           overlayColor: AppColors.hijauMuda,
                    //           surfaceTintColor: AppColors.hijauMuda,
                    //           disabledBackgroundColor: AppColors.hijauMuda),
                    //       onPressed: () async {
                    //         _controllerScan.pause();
                    //         setState(() {
                    //           _isScanning = true;
                    //         });
                    //         await Future.delayed(Duration(seconds: 2));
                    //         _controllerScan.start();
                    //         setState(() {
                    //           _isScanning = false;
                    //         });
                    //       },
                    //       child: Icon(
                    //         Icons.qr_code_scanner,
                    //         size: 55,
                    //         color: AppColors.putih,
                    //       )),
                    // ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          backgroundColor: Colors.transparent
                          // Mengatur padding agar tombol tidak terlalu besar
                          ),
                      onPressed: () {
                        _pickImage();
                      },
                      child: Icon(
                        Icons.image_search,
                        size: 60,
                        color: AppColors.putih.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        if (_isScanning)
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 30,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.hitam.withAlpha(100),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: AppColors.hijauMuda,
                      strokeWidth: 3,
                    ),
                  ),
                  Text("  Memindai...",
                      style: GoogleFonts.jaldi(
                        color: AppColors.putih,
                        fontSize: 18,
                      ))
                ],
              ),
            ),
          )
      ],
    ));
  }
}

class RoundedCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Membuat ujung lebih halus

    final Path path = Path();
    final double cornerRadius = 20; // Radius lengkungan sudut
    final double lineLength =
        size.width * 0.1; // Panjang garis lurus sebelum lengkungan
    final double lineRounded = -20;

    // Garis kiri atas dengan lengkungan
    path.moveTo(0, cornerRadius + lineLength);
    path.lineTo(0, cornerRadius);
    path.arcToPoint(
      Offset(cornerRadius, 0),
      radius: Radius.circular(lineRounded),
      clockwise: true,
    );
    path.lineTo(cornerRadius + lineLength, 0);

    // Garis kanan atas dengan lengkungan
    path.moveTo(size.width - (cornerRadius + lineLength), 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(
      Offset(size.width, cornerRadius),
      radius: Radius.circular(lineRounded),
      clockwise: true,
    );
    path.lineTo(size.width, cornerRadius + lineLength);

    // Garis kanan bawah dengan lengkungan
    path.moveTo(size.width, size.height - (cornerRadius + lineLength));
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(
      Offset(size.width - cornerRadius, size.height),
      radius: Radius.circular(lineRounded),
      clockwise: true,
    );
    path.lineTo(size.width - (cornerRadius + lineLength), size.height);

    // Garis kiri bawah dengan lengkungan
    path.moveTo(cornerRadius + lineLength, size.height);
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(
      Offset(0, size.height - cornerRadius),
      radius: Radius.circular(lineRounded),
      clockwise: true,
    );
    path.lineTo(0, size.height - (cornerRadius + lineLength));

    // Gambar path pada canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
