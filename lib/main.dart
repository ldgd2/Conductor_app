import 'package:conductor_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/notifications/notification.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:conductor_app/services/AutoLog.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  developer.log('Flutter app initialized!');
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar servicio de notificaciones globalmente
  final notificationService = NotificationService();
  await notificationService.init();

  // Inicializar Providers
  final statusModel = StatusModel();
  final conductorProvider = ConductorProvider();

  // Obtener notificación inicial si la app fue abierta desde una notificación
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
        notificationService: notificationService,
        initialNotification: initialNotification,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final ReceivedAction? initialNotification;
  final AutoLogin _autoLogin = AutoLogin(); // Instancia del nuevo sistema de autologin

  MyApp({
    super.key,
    required this.notificationService,
    this.initialNotification,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registro de Transportista',
      theme: AppThemes.darkTheme,
      navigatorKey: navigatorKey,
      home: FutureBuilder(
        future: _autoLogin.tryAutoLogin(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Si no hay sesión activa, mostrar la pantalla de login
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/route': (context) => const RutaPedidosScreen(),
      },
    );
  }
}
