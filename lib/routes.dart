import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';
import 'package:wigoyu/page/category.dart';
import 'package:wigoyu/page/login.dart';
import 'package:wigoyu/page/payment.dart';
import 'package:wigoyu/page/product.dart';
import 'package:wigoyu/page/register.dart';
import 'package:wigoyu/page/scan_qr.dart';
import 'package:wigoyu/page/search.dart';
import 'package:wigoyu/page/verify_email.dart';
import 'package:wigoyu/profile/my_profile.dart';

Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId') != null;
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case BottomNavigation.routeName:
      final args = settings.arguments as int?;
      return MaterialPageRoute(
        builder: (context) => BottomNavigation(
          initialIndex: args,
        ),
      );
    case Payment.routeName:
      final args = settings.arguments as int;
      return MaterialPageRoute(
        builder: (context) => Payment(
          title: args,
        ),
      );

    case MyProfile.routeName:
      return MaterialPageRoute(
        builder: (context) => MyProfile(),
      );
    case SearchPage.routeName:
      return MaterialPageRoute(
        builder: (context) => SearchPage(),
      );
    case ScannerScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => ScannerScreen(),
      );
    case Product.routeName:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(
        builder: (context) => Product(
          title: args['title']!,
        ),
      );
    case Login.routeName:
      return MaterialPageRoute(
        builder: (context) => Login(),
      );
    case Category.routeName:
      final args = settings.arguments as Map<String, String?>;
      return MaterialPageRoute(
        builder: (context) => Category(
          title: args['title']!,
        ),
      );
    case Register.routeName:
      return MaterialPageRoute(builder: (context) {
        final userState = Provider.of<User>(context);
        if (userState.isLoggedIn) {
          return BottomNavigation();
        }
        return Register();
      });
    case VerifyEmail.routeName:
      final args = settings.arguments as Map<String, String>;
      return MaterialPageRoute(
        builder: (context) => VerifyEmail(
            token: args['token']!, email: args['email']!, id: args['id']!),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Text('404: Page not found'),
          ),
        ),
      );
  }
}
