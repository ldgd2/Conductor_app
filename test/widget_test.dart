import 'package:conductor_app/screen/logingscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:conductor_app/notifications/notification.dart';
import 'package:conductor_app/main.dart';

void main() {
  testWidgets('Verificar que la aplicación carga correctamente', (WidgetTester tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    final notificationService = NotificationService();

    await tester.pumpWidget(
      MyApp(
        notificationService: notificationService,
        initialNotification: null,
      ),
    );
    await notificationService.init(navigatorKey, tester.element(find.byType(LoginScreen)));
    expect(find.text('Registro de Transportista'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
