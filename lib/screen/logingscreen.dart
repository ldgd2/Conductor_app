import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/screen/register_transportista_screen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'dart:convert';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/model/statusModel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  /// Obtener el token FCM
  Future<String?> _getFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint("Token FCM obtenido: $token");
      return token;
    } catch (e) {
      debugPrint("Error al obtener el token FCM: $e");
      return null;
    }
  }

  /// Método para iniciar sesión
 Future<void> _login() async {
  final statusModel = Provider.of<StatusModel>(context, listen: false);
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);

  setState(() {
    _isLoading = true;
  });

  try {
    // Obtener todos los conductores
    final List<dynamic> conductores = await _apiService.getAllConductores();

    // Buscar el conductor con el correo proporcionado
    final conductor = conductores.firstWhere(
      (c) => c['email'] == _emailController.text.trim(),
      orElse: () => null,
    );

    if (conductor != null) {
      final conductorId = conductor['id'];
      final nombre = conductor['nombre'];
      final email = conductor['email'];

      // Obtener el token FCM
      final token = await _getFCMToken();
      if (token != null) {
        // Actualizar el token en el servidor
        final tokenResponse = await _apiService.updateToken(conductorId, token);

        if (tokenResponse.statusCode == 200) {
          debugPrint("Token actualizado correctamente en el servidor.");

          // Actualizar estado en StatusModel
          statusModel.setStatus(conductorId, token, true);

          // Actualizar información en ConductorProvider
          conductorProvider.setConductor(conductorId, nombre, email);

          // Navegar al HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showSnackBar("Error al actualizar el token.");
          debugPrint("Error al actualizar el token: ${tokenResponse.body}");
        }
      } else {
        _showSnackBar("No se pudo obtener el token FCM.");
      }
    } else {
      _showSnackBar("Correo electrónico no encontrado.");
    }
  } catch (e) {
    _showSnackBar("Error de red. Verifique su conexión.");
    debugPrint("Excepción al iniciar sesión: $e");
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  /// Mostrar mensajes al usuario
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppThemes.primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.backgroundColor,
      appBar: AppBar(
        title: const Text("Inicio de Sesión"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                hintText: "Ingrese su correo electrónico",
                prefixIcon: Icon(Icons.email, color: AppThemes.primaryColor),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: AppThemes.secondaryColor)
                  : const Text("Iniciar Sesión"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterTransportistaScreen()),
                );
              },
              child: const Text("Registrarse"),
            ),
          ],
        ),
      ),
    );
  }
}
