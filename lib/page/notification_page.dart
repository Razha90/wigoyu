import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/random_string.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/model/user_notification.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const String routeName = '/notification-page';

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late User user;
  String expanded = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = Provider.of<User>(context, listen: false);
    });
  }

  // void saveNotification() {
  //   final String id = generateRandomNumberString(6);
  //   user.updateNotification(
  //       user.userId!,
  //       UserNotification(
  //           name: "Notifikasi 1",
  //           text:
  //               "Ini adalah notifikasi 1 lorem ipsum dolor sit amet 1 idsfodsfndsfkndsfdsn dsfdsfldskflkdsnfslndfknsfdsflk lsdknfldsmfldsflkdslfndslkfndslnflkdsnflkdsnfdsnfdsnfldsnf lkdsnfldsnflkdsnflkndsfoids cdsl lkfldsnflkdsnfodsnf lds ndsf ds nfdslk nfdsl nflds n",
  //           open: false,
  //           id: id));
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        backgroundColor: AppColors.putih,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.hitam),
        title: Text(
          "Notifikasi",
          style: GoogleFonts.jaldi(color: AppColors.hitam, fontSize: 25),
        ),
      ),
      body: SafeArea(
        top: true,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            user.deleteAllNotifications(user.userId!);
                          },
                          child: Text("Hapus Semua",
                              style: GoogleFonts.jaldi(
                                  color: Colors.redAccent, fontSize: 15)),
                        )
                      ],
                    ),
                  ),
                  Consumer<User>(
                    builder: (context, user, child) {
                      // print(user.notification);
                      if (user.notification?.isEmpty ?? true) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(child: Text("Tidak ada notifikasi")),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(user.notification!.length, (index) {
                          final UserNotification notification =
                              user.notification![index];
                          final isExpanded = expanded == notification.id;
                          return GestureDetector(
                              onTap: () {
                                if (!notification.open!) {
                                  user.openNotification(
                                      user.userId!, notification.id!);
                                }
                                if (expanded == notification.id) {
                                  setState(() {
                                    expanded = '';
                                  });
                                } else {
                                  setState(() {
                                    expanded = notification.id!;
                                  });
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(10),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: notification.open!
                                        ? AppColors.putih
                                        : Colors.orangeAccent.withAlpha(20),
                                    border: Border(
                                      bottom: BorderSide(
                                          color:
                                              AppColors.hitam.withAlpha(100)),
                                    )),
                                child: AnimatedSize(
                                  curve: Curves.easeInOut,
                                  duration: const Duration(milliseconds: 300),
                                  child: Stack(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(notification.name!),
                                          isExpanded
                                              ? Text(
                                                  notification.text!,
                                                )
                                              : Text(
                                                  notification.text!,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                          if (isExpanded)
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: IconButton(
                                                  onPressed: () {
                                                    user.deleteNotification(
                                                        user.userId!,
                                                        notification.id!);
                                                  },
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.redAccent,
                                                  )),
                                            )
                                        ],
                                      ),
                                      if (!notification.open!)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                shape: BoxShape.circle),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ));
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
