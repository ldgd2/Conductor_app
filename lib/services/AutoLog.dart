import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:conductor_app/screen/home_screen.dart';

class AutoLogin {
  final ApiService _apiService = ApiService();

  // Método para intentar un autologin al iniciar la app
  Future<void> tryAutoLogin(BuildContext context) async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);

    // Verificar si hay un usuario autenticado en memoria
    if (statusModel.isAuthenticated) { // Aquí accedes al getter
      debugPrint("Usuario ya autenticado en memoria.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
      return;
    }

    debugPrint("No hay sesión activa en memoria. Redirigiendo a Login.");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // Método para iniciar sesión
  Future<void> login({
    required BuildContext context,
    required String email,
  }) async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);

    try {
      // Obtener la lista de conductores
      final List<dynamic> conductores = await _apiService.getAllConductores();

      // Buscar el conductor con el correo proporcionado
      final conductor = conductores.firstWhere(
        (c) => c['email'] == email.trim(),
        orElse: () => null,
      );

      if (conductor != null) {
        final conductorId = conductor['id'];
        final token = 'dummy-token'; // Simula obtener un token válido del servidor

        // Actualizar el estado en StatusModel
        statusModel.setStatus(conductorId, token, true);

        debugPrint("Inicio de sesión exitoso. Usuario autenticado.");
        // Navegar al HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        throw Exception("Correo electrónico no encontrado.");
      }
    } catch (e) {
      debugPrint("Error durante el inicio de sesión: $e");
      throw Exception("Error durante el inicio de sesión.");
    }
  }

  // Método para cerrar sesión
  Future<void> logout(BuildContext context) async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);

    // Limpiar el estado de sesión en memoria
    statusModel.clearStatus();

    debugPrint("Usuario ha cerrado sesión.");

    // Redirigir a la pantalla de inicio de sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
