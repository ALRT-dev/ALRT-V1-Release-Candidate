import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hazard_app/others/app_colors.dart';

class AppTheme {
  /// The app reads in the platform's own sans rather than Poppins.
  ///
  /// Poppins is a geometric display face: near-circular letterforms, tight
  /// apertures, and a single-storey a. It looks smart in a mock and gets
  /// noticeably harder to read at 11 to 13sp, which is most of this app,
  /// and hardest for exactly the people the safety profile exists for.
  /// Arial resolves to Helvetica on iOS and Roboto on Android, both of
  /// which are designed for small sizes on screens.
  static String? get defaultFontFamily => 'Arial';

  /// Aptos first where it exists, then the platform sans. Flutter walks
  /// this list when a glyph or the family itself is missing.
  static const fontFallbacks = <String>[
    'Aptos',
    'Helvetica Neue',
    'Helvetica',
    'Roboto',
    'San Francisco',
  ];

  /// Dark palette tokens, shared with widgets that need to look right in
  /// Dark mode outside of what a plain ThemeData lookup gives them for
  /// free (see AppSurfaceColors) — one set of dark tones, not two. Anchored
  /// to colours already locked elsewhere in the design system rather than
  /// invented fresh: darkSurface is the "dark surface #23252B" the plain-
  /// terms summary already uses, and darkBorder matches HomeTabbar's own
  /// active-circle tone, so the floating nav pill and the rest of the app
  /// read as one palette in Dark mode.
  static const Color darkScaffold = Color(0xFF17181C);
  static const Color darkSurface = Color(0xFF23252B);
  static const Color darkSurfaceRaised = Color(0xFF2C2E35);
  static const Color darkBorder = Color(0xFF3A3D45);
  static const Color darkTextPrimary = Color(0xFFF5F6F7);
  static const Color darkTextSecondary = Color(0xFFAEB4BD);

  /// The default (light) theme settings of the app.
  static ThemeData get _defaultTheme {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.spMin),
    );

    return ThemeData(
      scaffoldBackgroundColor: AppColors.extraLightGrey,
      fontFamily: defaultFontFamily,
      fontFamilyFallback: fontFallbacks,
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          padding: EdgeInsets.all(15.spMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
          elevation: 0.0,
          disabledBackgroundColor: AppColors.lightGrey,
          disabledForegroundColor: AppColors.grey,
          foregroundColor: AppColors.white,
          textStyle: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(15.spMin),
          side: const BorderSide(
            width: 1.2,
            color: AppColors.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          foregroundColor: AppColors.black,
          textStyle: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: 10.spMin,
            horizontal: 13.spMin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: defaultFontFamily,
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.extraLightGrey,
        disabledColor: AppColors.extraLightGrey,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: defaultFontFamily,
          overflow: TextOverflow.ellipsis,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.spMin),
          side: BorderSide(
            width: 0.0,
            color: AppColors.transparent,
          ),
        ),
      ),
      textTheme:
          TextTheme(
            displayLarge: TextStyle(
              letterSpacing: 0.0,
            ),
            displayMedium: TextStyle(
              letterSpacing: 0.0,
            ),
            displaySmall: TextStyle(
              letterSpacing: 0.0,
            ),
            headlineLarge: TextStyle(
              letterSpacing: 0.0,
            ),
            headlineMedium: TextStyle(
              letterSpacing: 0.0,
            ),
            headlineSmall: TextStyle(
              letterSpacing: 0.0,
            ),
            titleLarge: TextStyle(
              letterSpacing: 0.0,
            ),
            titleMedium: TextStyle(
              letterSpacing: 0.0,
            ),
            titleSmall: TextStyle(
              letterSpacing: 0.0,
            ),
            bodyLarge: TextStyle(
              letterSpacing: 0.0,
            ),
            bodyMedium: TextStyle(
              letterSpacing: 0.0,
            ),
            bodySmall: TextStyle(
              letterSpacing: 0.0,
            ),
          ).apply(
            fontFamily: defaultFontFamily,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0.4,
        scrolledUnderElevation: 1.5,
        shadowColor: AppColors.lightGrey.withValues(alpha: 0.5),
        surfaceTintColor: AppColors.white,
        titleTextStyle: TextStyle(
          fontSize: 20.spMin,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          fontFamily: defaultFontFamily,
          letterSpacing: 0.0,
        ),
        centerTitle: true,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.primary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.extraLightGrey,
        dayBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.extraLightGrey;
        }),
        dayShape: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5.spMin),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5.spMin),
          );
        }),
        yearBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.extraLightGrey;
        }),
        yearShape: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5.spMin),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5.spMin),
          );
        }),
        todayBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.extraLightGrey;
        }),
        todayForegroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.primary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10.spMin),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightGrey.withValues(alpha: 0.7),
        foregroundColor: AppColors.black,
        elevation: 0.0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        splashBorderRadius: BorderRadius.circular(10.spMin),
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.primary,
        overlayColor: WidgetStateProperty.all(
          AppColors.primary.withValues(alpha: 0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.white;
        }),
        side: BorderSide(
          color: AppColors.white,
          width: 2.0,
        ),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.lightGrey,
          ),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.orange,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.orange,
            width: 1.2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.spMin,
          horizontal: 20.spMin,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontFamily: defaultFontFamily,
          fontWeight: FontWeight.w500,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: inputBorder,
          enabledBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: AppColors.lightGrey,
            ),
          ),
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: AppColors.black,
            ),
          ),
          focusedErrorBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: AppColors.black,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.spMin,
            horizontal: 20.spMin,
          ),
        ),
      ),
    );
  }

  /// The dark theme settings of the app - a genuine dark palette, not the
  /// light theme again. Mirrors [_defaultTheme]'s structure field for
  /// field so the two stay easy to compare; every colour that meant
  /// "white card" or "black ink" in light mode has a real dark
  /// counterpart here instead of being silently reused.
  static ThemeData get _darkTheme {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.spMin),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkScaffold,
      canvasColor: darkScaffold,
      cardColor: darkSurface,
      dividerColor: darkBorder,
      fontFamily: defaultFontFamily,
      fontFamilyFallback: fontFallbacks,
      splashColor: darkTextPrimary.withValues(alpha: 0.08),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          padding: EdgeInsets.all(15.spMin),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.spMin),
          ),
          elevation: 0.0,
          disabledBackgroundColor: darkBorder,
          disabledForegroundColor: darkTextSecondary,
          foregroundColor: AppColors.white,
          textStyle: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.all(15.spMin),
          side: BorderSide(
            width: 1.2,
            color: darkTextPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          foregroundColor: darkTextPrimary,
          textStyle: TextStyle(
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
            fontFamily: defaultFontFamily,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: 10.spMin,
            horizontal: 13.spMin,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.spMin),
          ),
          foregroundColor: darkTextPrimary,
          textStyle: TextStyle(
            fontFamily: defaultFontFamily,
            fontSize: 16.spMin,
            fontWeight: FontWeight.w600,
            height: 0.0,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceRaised,
        disabledColor: darkSurfaceRaised,
        selectedColor: darkTextPrimary,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: defaultFontFamily,
          overflow: TextOverflow.ellipsis,
          color: darkTextPrimary,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.spMin),
          side: BorderSide(
            width: 0.0,
            color: AppColors.transparent,
          ),
        ),
      ),
      textTheme:
          TextTheme(
            displayLarge: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            displayMedium: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            displaySmall: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            headlineLarge: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            headlineMedium: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            headlineSmall: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            titleLarge: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            titleMedium: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            titleSmall: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            bodyLarge: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            bodyMedium: TextStyle(
              letterSpacing: 0.0,
              color: darkTextPrimary,
            ),
            bodySmall: TextStyle(
              letterSpacing: 0.0,
              color: darkTextSecondary,
            ),
          ).apply(
            fontFamily: defaultFontFamily,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0.4,
        scrolledUnderElevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        surfaceTintColor: darkSurface,
        titleTextStyle: TextStyle(
          fontSize: 20.spMin,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          fontFamily: defaultFontFamily,
          letterSpacing: 0.0,
        ),
        centerTitle: true,
      ),
      // Every showModalBottomSheet(...) call in the app that doesn't pass
      // its own backgroundColor (all of Profile's sheets included) picks
      // this up automatically - the single place that makes "sheets"
      // respect Dark mode without touching every call site.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        modalBackgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24.spMin),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        surfaceTintColor: darkSurface,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(darkTextPrimary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkTextPrimary,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: darkSurface,
        dayBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return darkTextPrimary;
          }
          return darkSurfaceRaised;
        }),
        dayShape: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5.spMin),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5.spMin),
          );
        }),
        yearBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return darkTextPrimary;
          }
          return darkSurfaceRaised;
        }),
        yearShape: WidgetStateProperty.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(5.spMin),
            );
          }
          return RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(5.spMin),
          );
        }),
        todayBackgroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return darkTextPrimary;
          }
          return darkSurfaceRaised;
        }),
        todayForegroundColor: WidgetStateColor.resolveWith((state) {
          if (state.contains(WidgetState.selected)) {
            return darkScaffold;
          }
          return darkTextPrimary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(10.spMin),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSurfaceRaised,
        foregroundColor: darkTextPrimary,
        elevation: 0.0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: darkTextPrimary,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        splashBorderRadius: BorderRadius.circular(10.spMin),
        labelColor: darkTextPrimary,
        unselectedLabelColor: darkTextSecondary,
        indicatorColor: darkTextPrimary,
        overlayColor: WidgetStateProperty.all(
          darkTextPrimary.withValues(alpha: 0.1),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.orange,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkScaffold;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkTextPrimary;
          }
          return darkScaffold;
        }),
        side: BorderSide(
          color: darkTextPrimary,
          width: 2.0,
        ),
        shape: CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        enabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: darkBorder,
          ),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.orange,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.orange,
            width: 1.2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 10.spMin,
          horizontal: 20.spMin,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 14.sp,
          fontFamily: defaultFontFamily,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: inputBorder,
          enabledBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: darkBorder,
            ),
          ),
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: darkTextPrimary,
            ),
          ),
          focusedErrorBorder: inputBorder.copyWith(
            borderSide: BorderSide(
              color: darkTextPrimary,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.spMin,
            horizontal: 20.spMin,
          ),
        ),
      ),
    );
  }

  /// The light theme palette of the app when the system is in light mode.
  static ThemeData get lightPalette {
    return _defaultTheme;
  }

  /// The dark theme palette of the app when the system is in dark mode.
  static ThemeData get darkPalette {
    return _darkTheme;
  }
}

final textShadow = Shadow(
  offset: Offset(0.0, 0.0),
  blurRadius: 10.0,
  color: AppColors.black.withValues(alpha: 0.4),
);
