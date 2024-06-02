import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tododb/view/splash_screen/splash_screen.dart';
import 'package:tododb/view_mode/themes/light_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ToDo',
          // You can use the library anywhere in the app even in theme
          theme: lightTheme,
          home: child,
        );
      },
      child: const SplashScreen(),
    );
  }
}
