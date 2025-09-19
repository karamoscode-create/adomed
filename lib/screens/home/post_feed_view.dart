// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Le dégradé utilise les couleurs officielles du thème
  static const Gradient primaryGradient = LinearGradient(
    colors: [AppTheme.primaryColor, AppTheme.secondaryColor], 
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primary = AppTheme.primaryColor;
  static const Color secondary = AppTheme.secondaryColor;
  static const Color success = AppTheme.successColor;
  static const Color warning = AppTheme.warningColor;
  static const Color error = AppTheme.errorColor;
  static const Color info = AppTheme.infoColor;
  static const Color background = AppTheme.backgroundColor;
  static const Color card = AppTheme.cardColor;
  static const Color divider = AppTheme.dividerColor;
  static const Color textPrimary = AppTheme.textPrimaryColor;
  static const Color textSecondary = AppTheme.textSecondaryColor;
  static const Color textHint = AppTheme.textHintColor;
  static const Color cardColor = AppTheme.cardColor;
  static const Color primaryText = AppTheme.textPrimaryColor;
  static const Color secondaryText = AppTheme.textSecondaryColor;
  static const Color shadowColor = Color(0x1A000000); 
}

class AppTheme {
  static const Color primaryColor = Color(0xFF007bff);
  static const Color primaryLightColor = Color(0xFFE7F1FF);
  static const Color primaryDarkColor = Color(0xFF0056b3);
  static const Color secondaryColor = Color(0xFF42A5F5);
  static const Color secondaryLightColor = Color(0xFF80D6FF);
  static const Color secondaryDarkColor = Color(0xFF0077C2);
  static const Color accentColor = Color(0xFF2196F3);
  static const Color accentLightColor = Color(0xFF6EC6FF);
  static const Color accentDarkColor = Color(0xFF0069C0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color backgroundColor = Color(0xFFF7F7F7); 
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFFBDBDBD);
  static const Color textDisabledColor = Color(0xFF9E9E9E);
  static const Color consultationColor = Color(0xFFE3F2FD); 
  static const Color emergencyColor = Color(0xFFFFEBEE);
  static const Color onlineColor = Color(0xFFE8F5E8);
  static const Color offlineColor = Color(0xFFFFF3E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,          
        primaryContainer: primaryLightColor, 
        secondary: secondaryColor,      
        secondaryContainer: secondaryLightColor,
        surface: surfaceColor,
        background: backgroundColor,    
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,  
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor, 
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor, 
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Inter',
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor, 
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2), 
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        labelStyle: const TextStyle(
          color: textSecondaryColor,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
        hintStyle: const TextStyle(
          color: textHintColor,
          fontSize: 16,
          fontFamily: 'Inter',
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimaryColor, fontFamily: 'Inter'),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimaryColor, fontFamily: 'Inter'),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimaryColor, fontFamily: 'Inter'),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimaryColor, fontFamily: 'Inter'),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimaryColor, fontFamily: 'Inter'),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimaryColor, fontFamily: 'Inter'),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimaryColor, fontFamily: 'Inter'),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor, fontFamily: 'Inter'),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryColor, fontFamily: 'Inter'),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimaryColor, fontFamily: 'Inter'),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textPrimaryColor, fontFamily: 'Inter'),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondaryColor, fontFamily: 'Inter'),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimaryColor, fontFamily: 'Inter'),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textSecondaryColor, fontFamily: 'Inter'),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textHintColor, fontFamily: 'Inter'),
      ),
      iconTheme: const IconThemeData(color: textSecondaryColor, size: 24),
      dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1, space: 1),
      extensions: const [
        _CustomColors(
          consultation: consultationColor,
          emergency: emergencyColor,
          online: onlineColor,
          offline: offlineColor,
        ),
      ],
    );
  }
}

class _CustomColors extends ThemeExtension<_CustomColors> {
  final Color consultation;
  final Color emergency;
  final Color online;
  final Color offline;

  const _CustomColors({
    required this.consultation,
    required this.emergency,
    required this.online,
    required this.offline,
  });

  @override
  _CustomColors copyWith({Color? consultation, Color? emergency, Color? online, Color? offline}) {
    return _CustomColors(
      consultation: consultation ?? this.consultation,
      emergency: emergency ?? this.emergency,
      online: online ?? this.online,
      offline: offline ?? this.offline,
    );
  }

  @override
  _CustomColors lerp(ThemeExtension<_CustomColors>? other, double t) {
    if (other is! _CustomColors) {
      return this;
    }
    return _CustomColors(
      consultation: Color.lerp(consultation, other.consultation, t)!,
      emergency: Color.lerp(emergency, other.emergency, t)!,
      online: Color.lerp(online, other.online, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}