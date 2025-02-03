import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:wigoyu/app_color.dart';
import 'package:wigoyu/help/notification.dart';
import 'package:wigoyu/help/user.dart';
import 'package:wigoyu/routes.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => User()),
    ],
    child: const Starting(),
  ));
}

class Starting extends StatefulWidget {
  const Starting({super.key});
  @override
  State<Starting> createState() => _StartingState();
}

class _StartingState extends State<Starting> {
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.putih,
        selectionColor: AppColors.putih,
        selectionHandleColor: AppColors.putih,
      )),
      initialRoute: '/',
      onGenerateRoute: generateRoute,
    );
  }
}
