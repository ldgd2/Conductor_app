import 'package:conductor_app/screen/logingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conductor_app/notifications/notification.dart';
import 'package:conductor_app/main.dart';

void main() {
  testWidgets('Verificar que la aplicación carga correctamente', (WidgetTester tester) async {
    // Inicializar el servicio de notificaciones
    final notificationService = NotificationService();
    await notificationService.init();

    // Inicializar sin notificación inicial
    final initialNotification = null;

    // Construir la aplicación
    await tester.pumpWidget(
      MyApp(
        notificationService: notificationService,
        initialNotification: initialNotification,
      ),
    );

    // Verificar que la aplicación se carga correctamente
    expect(find.text('Registro de Transportista'), findsOneWidget);

    // Verificar que estamos en la pantalla de inicio de sesión
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
