import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conductor_app/main.dart';
import 'package:conductor_app/themes/theme.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
 // Asegúrate de que esta ruta es correcta
import 'dart:convert';
import 'package:conductor_app/services/SavePoints.dart';
import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:conductor_app/model/RutaOferta.dart';
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
Function(Map<String, dynamic>)? onNotificationReceived;


  NotificationService();

  Future<void> init() async {
    // Inicializar Awesome Notifications
    await AwesomeNotifications().initialize(
      null,
      [AppThemes.notificationChannel], // Usar el canal definido en AppThemes
    );

    // Pedir permisos de notificaciones
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Configurar el manejo de notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Notificación recibida en primer plano: ${message.data}");
      _handleNotificationAction(message.data);
    });

    // Configurar el manejo de notificaciones al abrir la app desde la notificación
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("App abierta desde una notificación: ${message.data}");
      _handleNotificationAction(message.data);
    });

    // Configurar el listener de acciones de Awesome Notifications
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );
  }

void handleIncomingNotification(Map<String, dynamic> data) {
}
void _handleNotificationAction(Map<String, dynamic> data) async {
}

@pragma('vm:entry-point')
static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {

}
  }