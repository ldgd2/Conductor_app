import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class AppThemes {
  // Definición de colores principales
  static const Color primaryColor = Colors.red; // Color rojo resaltante
  static const Color secondaryColor = Colors.white;
  static const Color backgroundColor = Color(0xFF121212); // Fondo oscuro
  static const Color cardColor = Color(0xFF1E1E1E); // Color para tarjetas y contenedores
  static const Color surfaceColor = Color(0xFF2C2C2C); // Superficie secundaria
  static const Color textColor = Colors.white;
  static const Color hintColor = Colors.grey;
  static const Color borderColor = Color(0xFF3E3E3E);

  // Definición de tema oscuro
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      onPrimary: secondaryColor,
      onSecondary: backgroundColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    hintColor: hintColor,
    dividerColor: borderColor,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    textButtonTheme: _textButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
    iconTheme: _iconThemeData,
    bottomNavigationBarTheme: _bottomNavTheme,
    snackBarTheme: _snackBarTheme,
    dialogTheme: _dialogTheme,
    tooltipTheme: _tooltipTheme,
  );

  // Estilo de texto
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: textColor),
    displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: textColor),
    displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: textColor),
    headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600, color: textColor),
    headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: textColor),
    titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, color: textColor),
    bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400, color: textColor),
    bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: textColor),
    labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: secondaryColor),
    bodySmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: hintColor),
  );

  // Estilo de AppBar
  static const AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: backgroundColor,
    elevation: 4.0,
    iconTheme: IconThemeData(color: secondaryColor),
    titleTextStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: secondaryColor),
  );

  // Estilo de ElevatedButton
  static final ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );

  // Estilo de TextButton
  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
    ),
  );

  // Estilo de OutlinedButton
  static final OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: BorderSide(color: primaryColor, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    ),
  );

  // Estilo de InputDecoration (Campos de texto)
  static final InputDecorationTheme _inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: surfaceColor,
    hintStyle: TextStyle(color: hintColor),
    labelStyle: TextStyle(color: textColor),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: primaryColor),
    ),
  );

  // Estilo de Iconos
  static const IconThemeData _iconThemeData = IconThemeData(
    color: secondaryColor,
    size: 24.0,
  );

  // Estilo de BottomNavigationBar
  static final BottomNavigationBarThemeData _bottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: backgroundColor,
    selectedItemColor: primaryColor,
    unselectedItemColor: hintColor,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
  );

  // Estilo de SnackBar
  static const SnackBarThemeData _snackBarTheme = SnackBarThemeData(
    backgroundColor: primaryColor,
    contentTextStyle: TextStyle(color: secondaryColor, fontSize: 14.0),
    actionTextColor: secondaryColor,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
  );

  // Estilo de Diálogos
  static const DialogTheme _dialogTheme = DialogTheme(
    backgroundColor: surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ),
    titleTextStyle: TextStyle(color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
    contentTextStyle: TextStyle(color: textColor, fontSize: 16.0),
  );

  // Estilo de Tooltip
  static const TooltipThemeData _tooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: primaryColor,
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    textStyle: TextStyle(color: secondaryColor, fontSize: 12.0),
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    waitDuration: Duration(milliseconds: 500),
    showDuration: Duration(seconds: 2),
  );

  // ------------------------------
  // ESTILOS DE NOTIFICACIONES
  // ------------------------------

  // Canal principal de notificaciones
  static NotificationChannel notificationChannel = NotificationChannel(
    channelKey: 'main_channel',
    channelName: 'Main Channel',
    channelDescription: 'Canal principal para notificaciones importantes',
    defaultColor: primaryColor,
    ledColor: secondaryColor,
    importance: NotificationImportance.Max,
    playSound: true,
    enableLights: true,
    enableVibration: true,
  );

  // Notificación con texto expandido
  static NotificationContent createBigTextNotification(
      {required String title, required String body}) {
    return NotificationContent(
      id: 1,
      channelKey: 'main_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.BigText,
      backgroundColor: backgroundColor,
    );
  }

  // Notificación con imagen
  static NotificationContent createImageNotification(
      {required String title, required String body, required String imageUrl}) {
    return NotificationContent(
      id: 2,
      channelKey: 'main_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.BigPicture,
      bigPicture: imageUrl,
      backgroundColor: backgroundColor,
    );
  }

  // Notificación con ícono grande
  static NotificationContent createLargeIconNotification(
      {required String title, required String body}) {
    return NotificationContent(
      id: 3,
      channelKey: 'main_channel',
      title: title,
      body: body,
      notificationLayout: NotificationLayout.Default,
      largeIcon: 'resource://drawable/res_app_icon',
      backgroundColor: backgroundColor,
    );
  }
}
