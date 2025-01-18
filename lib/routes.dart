// import 'package:flutter/material.dart';
// import 'package:wigoyu/navigation/bottom_navigation.dart';

// class AppRoutes {
//   static Route? onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case BottomNavigation.routeName:
//         return MaterialPageRoute(builder: (context) => BottomNavigation());
//       default:
//         return null;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:wigoyu/navigation/bottom_navigation.dart';
import 'package:wigoyu/page/login.dart';

// import 'screens/home_screen.dart';
// import 'screens/about_screen.dart';

Route<dynamic>? generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case BottomNavigation.routeName:
      return MaterialPageRoute(
        builder: (context) => BottomNavigation(),
      );
    case Login.routeName:
      return MaterialPageRoute(
        builder: (context) => Login(),
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
