import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CalPal());
}

class CalPal extends StatelessWidget {
  const CalPal({super.key});

  @override
  Widget build(BuildContext context) {
    const black = Colors.black;
    const white = Colors.white;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalPal',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xffF5F5F7),

        // ===== 全局黑白配色 =====
        colorScheme: const ColorScheme.light(
          primary: black,
          onPrimary: white,
          secondary: black,
          surface: white,
          onSurface: black,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xffF5F5F7),
          foregroundColor: black,
          elevation: 0,
          centerTitle: true,
        ),

        // ===== iOS 风格弹窗 =====
        dialogTheme: DialogThemeData(
          backgroundColor: white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: black,
          ),
          contentTextStyle: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
        ),

        // ===== 底部弹窗 =====
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
        ),

        // ===== 下拉菜单 =====
        popupMenuTheme: PopupMenuThemeData(
          color: white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            color: black,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),

        // ===== 黑色主按钮 =====
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: black,
            foregroundColor: white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: black,
            foregroundColor: white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: black,
            side: const BorderSide(color: Color(0xffD1D5DB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        // ===== 输入框 =====
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(
              color: black,
              width: 1.2,
            ),
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.grey.shade900,
          contentTextStyle: const TextStyle(color: white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}