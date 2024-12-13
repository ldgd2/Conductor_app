import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/main.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conductor_app/main.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/screen/ListaRutaScreen.dart';
import 'package:conductor_app/screen/home_screen_delivery.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../main.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  NotificationService();

  Future<void> init(GlobalKey<NavigatorState> navigatorKey, BuildContext context) async {

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notificaciones básicas',
          importance: NotificationImportance.High,
          defaultColor: Colors.blue,
          ledColor: Colors.white,
        ),
      ],
    );

    // Pedir permisos de notificaciones
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Configurar listener de notificaciones (usando método estático)
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) => onActionReceived(receivedAction, navigatorKey),  // Pasar navigatorKey aquí
    );
  }

  // Método de instancia para manejar las acciones de la notificación
  void _onActionReceived(ReceivedAction receivedAction, GlobalKey<NavigatorState> navigatorKey) {
    final String tipo = receivedAction.payload?['tipo'] ?? 'default';
    final String? tipoPayload = receivedAction.payload?['tipoConductor'];

    if (tipo == "recogo") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const ListaRutaScreen()),
      );
    } else if (tipo == "delivery") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreenDelivery()),
      );
    } else if (tipoPayload != null) {
      if (tipoPayload == "recogo") {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const ListaRutaScreen()),
        );
      } else if (tipoPayload == "delivery") {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreenDelivery()),
        );
      }
    }
  }

  void _showAwesomeNotification(Map<String, dynamic> data, String? tipoConductor) {

    final String title = data['title'] ?? 'Título de notificación';
    final String body = data['body'] ?? 'Cuerpo de la notificación';
    final String tipo = data['tipo'] ?? 'default';

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {'tipo': tipo, 'tipoConductor': tipoConductor ?? 'default'},
      ),
    );
  }

  void _handleNotificationAction(
      BuildContext context, Map<String, dynamic> data, String? tipoConductor) {

    final String tipo = data['tipo'] ?? 'default';

    if (tipo == "recogo") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListaRutaScreen()),
      );
    } else if (tipo == "delivery") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenDelivery()),
      );
    } else if (tipoConductor != null) {
      if (tipoConductor == "recogo") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListaRutaScreen()),
        );
      } else if (tipoConductor == "delivery") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreenDelivery()),
        );
      }
    }
  }

 
 // Método estático para manejar las acciones de la notificación
@pragma('vm:entry-point')
  static Future<void> onActionReceived(ReceivedAction receivedAction, GlobalKey<NavigatorState> navigatorKey) async {
    // Extraer el tipo de la acción recibida
    final String tipo = receivedAction.payload?['tipo'] ?? 'default';
    final String? tipoPayload = receivedAction.payload?['tipoConductor'];

    if (tipo == "recogo") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => ListaRutaScreen()),
      );
    } else if (tipo == "delivery") {
      navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreenDelivery()),
      );
    } else if (tipoPayload != null) {
      if (tipoPayload == "recogo") {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => ListaRutaScreen()),
        );
      } else if (tipoPayload == "delivery") {
        navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreenDelivery()),
        );
      }
    }
  }




  Future<String?> getConductorTipo(int conductorId) async {
 
    final url = Uri.parse('$urlapi/conductores/$conductorId');
    debugPrint("URL para obtener detalles del conductor: $url");

    try {

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        final tipo = data['tipo'];
        debugPrint("Tipo del conductor obtenido: $tipo");
        return tipo;
      } else {

        debugPrint("Error al obtener detalles del conductor:");
        debugPrint("Status Code: ${response.statusCode}");
        debugPrint("Response Body: ${response.body}");
        return null;
      }
    } catch (e) {

      debugPrint("Excepción al obtener detalles del conductor: $e");
      return null;
    }
  }

}