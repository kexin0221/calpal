
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CalPal());
}

class CalPal extends StatelessWidget {
  const CalPal({super.key});

  // ==================== 浅色模式 ====================
  static const lightBackground = Color(0xffF5F5F7);
  static const lightSurface = Colors.white;
  static const lightPrimary = Colors.black;
  static const lightOnPrimary = Colors.white;
  static const lightOnSurface = Colors.black;
  static const lightOutline = Color(0xffD1D5DB);

  // ==================== 深色模式 ====================
  static const darkBackground = Color(0xff111113);
  static const darkSurface = Color(0xff1C1C1E);
  static const darkCard = Color(0xff2C2C2E);
  static const darkPrimary = Color(0xff3A3A3C);
  static const darkOnPrimary = Colors.white;
  static const darkOnSurface = Colors.white;
  static const darkOutline = Color(0xff3A3A3C);

  ThemeData _buildTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;

    final background = isDark ? darkBackground : lightBackground;
    final surface = isDark ? darkSurface : lightSurface;
    final primary = isDark ? darkPrimary : lightPrimary;
    final onPrimary = isDark ? darkOnPrimary : lightOnPrimary;
    final onSurface = isDark ? darkOnSurface : lightOnSurface;
    final outline = isDark ? darkOutline : lightOutline;

    final colorScheme = ColorScheme(
      brightness: brightness,

      // 主要按钮、选中状态
      primary: primary,
      onPrimary: onPrimary,

      // 次要强调色
      secondary: primary,
      onSecondary: onPrimary,

      // 错误
      error: Colors.red,
      onError: Colors.white,

      // 页面及卡片背景
      surface: surface,
      onSurface: onSurface,

      // 边框
      outline: outline,

      // 固定背景及前景
      surfaceDim: isDark
          ? const Color(0xff0A0A0C)
          : const Color(0xffE8E8ED),
      surfaceBright: isDark
          ? const Color(0xff3A3A3C)
          : Colors.white,

      // Material 3 不同层级的表面颜色
      surfaceContainerLowest: isDark
          ? const Color(0xff0B0B0D)
          : Colors.white,
      surfaceContainerLow: isDark
          ? const Color(0xff161618)
          : const Color(0xffFAFAFC),
      surfaceContainer: isDark
          ? const Color(0xff1C1C1E)
          : const Color(0xffF5F5F7),
      surfaceContainerHigh: isDark
          ? const Color(0xff252527)
          : const Color(0xffEEEEF2),
      surfaceContainerHighest: isDark
          ? darkCard
          : const Color(0xffE5E5EA),

      // 禁止 Material 3 自动叠加表面色调
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,

      // ==================== AppBar ====================
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      // ==================== Card ====================
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ==================== Dialog ====================
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: onSurface.withValues(alpha: .87),
        ),
      ),

      // ==================== Bottom Sheet ====================
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),

      // ==================== Popup Menu ====================
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: TextStyle(
          color: onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ==================== Filled Button ====================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ==================== Elevated Button ====================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),

      // ==================== Outlined Button ====================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      // ==================== 输入框 ====================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
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
          borderSide: BorderSide(
            color: primary,
            width: 1.2,
          ),
        ),
        hintStyle: TextStyle(
          color: onSurface.withValues(alpha: .5),
        ),
        labelStyle: TextStyle(
          color: onSurface.withValues(alpha: .7),
        ),
      ),

      // ==================== Checkbox ====================
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(onPrimary),
        side: BorderSide(color: outline),
      ),

      // ==================== SnackBar ====================
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? darkCard : Colors.grey.shade900,
        contentTextStyle: const TextStyle(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      // ==================== Divider ====================
      dividerTheme: DividerThemeData(
        color: outline,
        thickness: 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalPal',

      theme: _buildTheme(
        brightness: Brightness.light,
      ),

      darkTheme: _buildTheme(
        brightness: Brightness.dark,
      ),

      // 默认跟随系统
      themeMode: ThemeMode.system,

      home: const HomePage(),
    );
  }
}