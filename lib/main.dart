import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:conductor_app/services/ConductorProvider.dart';

void main() async {
  developer.log('Flutter app initialized!');
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Obtener información de la sesión activa
  final prefs = await SharedPreferences.getInstance();
  final conductorId = prefs.getInt('conductorId');
  String? conductorNombre;
  String? conductorEmail;

  if (conductorId != null) {
    // Simulación de una llamada API para obtener datos del conductor
    final response = await http.get(
      Uri.parse('http://192.168.100.141:8000/api/v1/conductores/$conductorId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      conductorNombre = data['nombre'];
      conductorEmail = data['email'];
    }

    // Inicializar servicio de notificaciones
    NotificationService().init(conductorId);
  }

  // Usar MultiProvider para inyectar estado global
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConductorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Manejo de notificaciones en segundo plano
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  developer.log("Notificación recibida en segundo plano: ${message.notification?.title}");
  // Lógica para manejar la notificación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Transportista',
      theme: AppThemes.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService();

  Future<void> init(int conductorId) async {
    await _firebaseMessaging.requestPermission();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse);

    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _sendTokenToServer(conductorId, token, true);
    }

    FirebaseMessaging.onMessage.listen((message) {
      developer.log("Notificación recibida en primer plano: ${message.notification?.title}");
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      developer.log("Notificación abierta por el usuario: ${message.notification?.title}");
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
      developer.log("Datos de la notificación: $data");
    }
  }

  Future<void> _sendTokenToServer(int conductorId, String token, bool isActive) async {
    const serverUrl = "http://192.168.100.141:8001/api/v1/sesion";

    try {
      final body = jsonEncode({
        "conductorId": conductorId,
        "token": token,
        "isActive": isActive,
      });

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        developer.log("Token enviado exitosamente al servidor: $token");
      } else {
        developer.log("Error al enviar el token al servidor: ${response.body}");
      }
    } catch (e) {
      developer.log("Error al enviar el token al servidor: $e");
    }
  }

  Future<void> logout(int conductorId) async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _sendTokenToServer(conductorId, token, false);
    }
  }
}
