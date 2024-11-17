import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/notifications/notification.dart';
import 'package:conductor_app/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:conductor_app/config/config.dart';
Future<void> main() async {
  developer.log('Flutter app initialized!');
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Crear instancias de StatusModel y ConductorProvider
  final statusModel = StatusModel();
  final conductorProvider = ConductorProvider();

  // Verificar sesión activa desde almacenamiento local
  final prefs = await SharedPreferences.getInstance();
  final conductorId = prefs.getInt('conductorId');
  final token = prefs.getString('token');

  NotificationService? notificationService;

  if (conductorId != null && token != null) {
    // Actualizar StatusModel con los datos de la sesión activa
    statusModel.setStatus(conductorId, token, true);

    // Obtener datos adicionales del conductor
    final response = await _fetchConductorData(conductorId);
    if (response != null) {
      conductorProvider.setConductor(
        conductorId,
        response['nombre'] ?? '',
        response['email'] ?? '',
      );
    }

    // Enviar estado de sesión al servidor
    await _sendSessionStatus(conductorId, token, true);
  }
  // Verificar si la app fue abierta desde una notificación
  final initialNotification = await AwesomeNotifications()
      .getInitialNotificationAction(removeFromActionEvents: true);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatusModel>.value(value: statusModel),
        ChangeNotifierProvider<ConductorProvider>.value(value: conductorProvider),
        ChangeNotifierProvider<NewRoutesNotifier>(create: (_) => NewRoutesNotifier()),
      ],
      child: MyApp(
        initNotifications: (BuildContext context) async {
          // Inicializar el servicio de notificaciones con el contexto
          notificationService = NotificationService(context);
          if (conductorId != null) {
            await notificationService!.init(conductorId);
          }
          
        },
        initialNotification: initialNotification,
      ),
      
    ),
  );
}

// Manejo de notificaciones en segundo plano
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  developer.log("Notificación recibida en segundo plano: ${message.notification?.title}");
}

// Enviar estado de la sesión al servidor
Future<void> _sendSessionStatus(int conductorId, String token, bool isActive) async {
  const serverUrl = notificationUrl;

  final body = jsonEncode({
    "conductorId": conductorId,
    "token": token,
    "isActive": isActive,
  });

  developer.log("Enviando estado de sesión con cuerpo: $body");

  try {
    final response = await http.post(
      Uri.parse(serverUrl),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      developer.log("Estado de sesión enviado correctamente para Conductor ID $conductorId.");
    } else {
      developer.log("Error al enviar estado de sesión: ${response.body}");
      throw Exception("Error al enviar estado de sesión");
    }
  } catch (e) {
    developer.log("Error al enviar estado de sesión: $e");
  }
}

// Obtener datos adicionales del conductor desde la API
Future<Map<String, dynamic>?> _fetchConductorData(int conductorId) async {
  const serverUrl = urlapi+"conductores/";

  try {
    final response = await http.get(Uri.parse("$serverUrl$conductorId"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      developer.log("Error al obtener datos del conductor: ${response.body}");
    }
  } catch (e) {
    developer.log("Excepción al obtener datos del conductor: $e");
  }
  return null;
}

class MyApp extends StatelessWidget {
  final Future<void> Function(BuildContext) initNotifications;
final ReceivedAction? initialNotification;
  const MyApp({super.key, required this.initNotifications, this.initialNotification});

  @override
  Widget build(BuildContext context) {
    // Inicializar las notificaciones después de que el contexto esté disponible
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initNotifications(context);

      // Redirigir si la app fue abierta desde una notificación
      if (initialNotification != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/route',
          (route) => false, // Cierra cualquier ruta anterior
        );
      }
    });

    return MaterialApp(
      title: 'Registro de Transportista',
      theme: AppThemes.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/route': (context) => const RutaPedidosScreen(),
      },
    );
  }
}
