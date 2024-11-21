import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conductor_app/main.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationService();

  Future<void> init() async {
    // Inicializar Awesome Notifications usando el canal de notificaciones de `AppThemes`
    await AwesomeNotifications().initialize(
      null,
      [AppThemes.notificationChannel], // Usar el canal definido en theme.dart
    );

    // Pedir permisos de notificaciones
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Configurar el manejo de notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleNotificationAction();
    });

    // Configurar el manejo de notificaciones al abrir la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationAction();
    });

    // Configurar el listener de acciones de Awesome Notifications
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );
  }

  void _handleNotificationAction() {
    // Acceder al contexto actual de la aplicación
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Navegar directamente a RutaPedidosScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RutaPedidosScreen()),
        (route) => false, // Remover todas las pantallas previas de la pila
      );
    });
  }

  void handleIncomingNotificationFromAction(ReceivedAction action) {
    // Acceder al contexto actual de la aplicación
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Navegar directamente a RutaPedidosScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RutaPedidosScreen()),
        (route) => false, // Remover todas las pantallas previas de la pila
      );
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Navegar directamente a RutaPedidosScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RutaPedidosScreen()),
        (route) => false, // Remover todas las pantallas previas de la pila
      );
    });
  }
}
