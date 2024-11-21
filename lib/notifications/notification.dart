import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conductor_app/main.dart';
import 'package:conductor_app/themes/theme.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart'; // Asegúrate de que esta ruta es correcta
import 'dart:convert';
import 'package:latlong2/latlong.dart' as latLngLib;

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

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

 void _handleNotificationAction(Map<String, dynamic> data) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final String? locationsJson = data['locations'];
  if (locationsJson != null) {
    try {
      final List<dynamic> locations = jsonDecode(locationsJson);

      // Convertir las ubicaciones a `latlong2.LatLng`
      final List<latLngLib.LatLng> points = locations
          .where((location) =>
              location['lat'] != null && location['lon'] != null) // Filtrar nulos
          .map((location) {
            final lat = double.tryParse(location['lat'].toString());
            final lon = double.tryParse(location['lon'].toString());
            if (lat != null && lon != null) {
              return latLngLib.LatLng(lat, lon); // Usar `latlong2.LatLng`
            }
            return null;
          })
          .whereType<latLngLib.LatLng>() // Solo incluir objetos válidos
          .toList();

      if (points.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RutaPedidosScreen(
                notificationCoordinates: points.first,
                notificationRoute: points,
              ),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Error al decodificar las ubicaciones: $e");
    }
  }
}

@pragma('vm:entry-point')
static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  final String? locationsJson = receivedAction.payload?['locations'];
  if (locationsJson != null) {
    try {
      final List<dynamic> locations = jsonDecode(locationsJson);

      // Filtrar y convertir ubicaciones a latlong2.LatLng
      final List<latLngLib.LatLng> points = locations
          .where((location) =>
              location['lat'] != null && location['lon'] != null) // Filtrar nulos
          .map((location) {
            final lat = double.tryParse(location['lat'].toString());
            final lon = double.tryParse(location['lon'].toString());
            if (lat != null && lon != null) {
              return latLngLib.LatLng(lat, lon);
            }
            return null; // Ignorar ubicaciones no válidas
          })
          .whereType<latLngLib.LatLng>() // Solo incluir objetos válidos
          .toList();

      if (points.isNotEmpty) {
        // Redirigir a RutaPedidosScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RutaPedidosScreen(
                notificationCoordinates: points.first, // Primera coordenada
                notificationRoute: points, // Ruta completa
              ),
            ),
          );
        });
      } else {
        debugPrint("No se encontraron ubicaciones válidas en la acción recibida.");
      }
    } catch (e) {
      debugPrint("Error al decodificar las ubicaciones: $e");
    }
  } else {
    debugPrint("El campo 'locations' no está presente en la acción recibida.");
  }
}

}
