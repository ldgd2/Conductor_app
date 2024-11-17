import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:conductor_app/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:provider/provider.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  late BuildContext _context;

  NotificationService(BuildContext context) {
    _context = context;
  }

  Future<void> init(int conductorId) async {
    // Inicializar Awesome Notifications
    await AwesomeNotifications().initialize(
      null, // Usa el ícono por defecto de la app
      [
        NotificationChannel(
          channelKey: 'main_channel',
          channelName: 'Main Channel',
          channelDescription: 'Canal principal para notificaciones',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          onlyAlertOnce: true,
        ),
      ],
    );

    // Pedir permisos de notificaciones
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Obtener token de FCM
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // Enviar token al servidor
    if (token != null) {
      await _sendTokenToServer(conductorId, token, true);
    }

    // Configurar el manejo de notificaciones de Firebase
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToPedidosOfertas(_context); // Redirigir al abrir la notificación
    });

    // Configurar el listener de acciones de Awesome Notifications
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: message.hashCode,
          channelKey: 'main_channel',
          title: notification.title ?? 'Nueva notificación',
          body: notification.body ?? 'Tienes una nueva notificación.',
          payload: message.data.map((key, value) => MapEntry(key, value.toString())),
        ),
      );
    }
  }

  Future<void> _sendTokenToServer(int conductorId, String token, bool isActive) async {
    const url = notificationUrl;

    final body = jsonEncode({
      "conductorId": conductorId,
      "token": token,
      "isActive": isActive,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print("Estado de sesión enviado correctamente.");
      } else {
        print("Error al enviar estado de sesión: ${response.body}");
      }
    } catch (e) {
      print("Excepción al enviar estado de sesión: $e");
    }
  }

  Future<void> logout(int conductorId) async {
    String? token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToServer(conductorId, token, false);
    }
  }

  static void _navigateToPedidosOfertas(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/route',
      (route) => false, // Cierra cualquier ruta anterior
    );
  }

  /// Método estático para manejar las acciones de los botones
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Este método se ejecuta al interactuar con una notificación
    // Puedes usar `receivedAction.payload` para manejar datos específicos

    final context = AwesomeNotifications().currentContext;
    if (context != null) {
      _navigateToPedidosOfertas(context);
    }
  }
}

extension on AwesomeNotifications {
   get currentContext => null;
}
