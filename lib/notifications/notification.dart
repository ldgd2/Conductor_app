import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:conductor_app/config/config.dart';
import 'package:http/http.dart' as http; // Importa la librería HTTP
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init(int conductorId) async {
    // Solicitar permisos para notificaciones
    await _messaging.requestPermission();

    // Inicializar el canal de notificaciones locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse);

    // Obtener el token de FCM
    String? token = await _messaging.getToken();
    print("FCM Token: $token");

    // Envía el token al servidor
    if (token != null) {
      await _sendTokenToServer(conductorId, token, true);
    }

    // Configurar el manejo de notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((message) {
      _showNotification(message);
    });

    // Manejar clics en notificaciones
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notificación abierta: ${message.data}");
    });
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'main_channel',
        'Main Channel',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
      );

      const iosDetails = DarwinNotificationDetails();
      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      final data = jsonDecode(payload);
      print("Datos de la notificación: $data");
      // Aquí puedes manejar la lógica de "Aceptar" o "Cancelar"
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
}
