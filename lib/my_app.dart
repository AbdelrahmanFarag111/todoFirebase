import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tododb/view/splash_screen/splash_screen.dart';
import 'package:tododb/view_mode/cubits/auth_cubit/auth_cubit.dart';
import 'package:tododb/view_mode/cubits/tasks_cubit/tasks_cubit.dart';
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
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(),
            ),
            BlocProvider(
              create: (context) => TasksCubit(),
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: 'ToDo',
            // You can use the library anywhere in the app even in theme
            theme: lightTheme,
            home: child,
          ),
        );
      },
      child: const SplashScreen(),
    );
  }
}
