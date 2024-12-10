import 'package:conductor_app/screen/home_screen_delivery.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/screen/ListaRutaScreen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/notifications/notification.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:conductor_app/model/NewRoutesNotifier.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  developer.log('Flutter app initialized!');
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar servicio de notificaciones globalmente
  final notificationService = NotificationService();

  // Crear un contexto inicial para pasar a init
  final navigatorKey = GlobalKey<NavigatorState>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<StatusModel>(create: (_) => StatusModel()),
        ChangeNotifierProvider<ConductorProvider>(create: (_) => ConductorProvider()),
        ChangeNotifierProvider<NewRoutesNotifier>(create: (_) => NewRoutesNotifier()),
      ],
      child: Builder(
        builder: (BuildContext context) {
          notificationService.init(navigatorKey, context);
          return MyApp(notificationService: notificationService);
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final ReceivedAction? initialNotification;

  MyApp({
    super.key,
    required this.notificationService,
    this.initialNotification,
  });

  @override
  Widget build(BuildContext context) {
    // Manejar notificación inicial si existe
    if (initialNotification != null) {
      _handleNotificationAction(context, initialNotification!);
    }

    return MaterialApp(
      title: 'Registro de Transportista',
      theme: AppThemes.darkTheme,
      navigatorKey: navigatorKey, // Aquí está el navigatorKey
      home: const LoginScreen(), // Inicio en la pantalla de Login
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/route': (context) => const ListaRutaScreen(),
      },
    );
  }


  void _handleNotificationAction(BuildContext context, ReceivedAction action) async {
    // Extraer datos específicos de la notificación
    final payload = action.payload ?? {};
    final tipo = payload['tipo'];

    // Obtener el tipo de conductor
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;
    final conductorTipo = conductorId != null
        ? await notificationService.getConductorTipo(conductorId)
        : null;

    if (tipo == "recogo") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ListaRutaScreen()),
      );
    } else if (tipo == "delivery" || conductorTipo == "delivery") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenDelivery()),
      );
    }
  }
}
