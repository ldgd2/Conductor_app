import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/screen/register_transportista_screen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'dart:convert';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/services/ConductorProvider.dart'; // Importar ConductorProvider
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;






  // Obtener el token FCM
  Future<String?> _getFCMToken() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      final token = await messaging.getToken();
      debugPrint("Token FCM obtenido: $token");
      return token;
    } catch (e) {
      debugPrint("Error al obtener el token FCM: $e");
      return null;
    }
  }

  // Método para iniciar sesión
  Future<void> _login() async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAllConductores();

      if (response.statusCode == 200) {
        final List conductores = List.from(jsonDecode(response.body));
        final conductor = conductores.firstWhere(
          (c) => c['email'] == _emailController.text.trim(),
          orElse: () => null,
        );

        if (conductor != null) {
          final conductorId = conductor['id'];
          final conductorNombre = conductor['nombre'];
          debugPrint("Conductor encontrado: $conductorId");

          final token = await _getFCMToken();
          if (token != null) {
            // Actualizar estado global en el Provider
            conductorProvider.setConductor(conductorId, conductorNombre, token);

            // Navegar al HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else {
            _showSnackBar("No se pudo obtener el token FCM.");
          }
        } else {
          _showSnackBar("Correo electrónico no encontrado.");
        }
      } else {
        _showSnackBar("Error en el inicio de sesión. Intente nuevamente.");
      }
    } catch (e) {
      _showSnackBar("Error de red. Verifique su conexión.");
      debugPrint("Excepción al iniciar sesión: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

Future<void> _sendSessionStatus(int conductorId, String token, bool isActive) async {
  const url = notificationUrl; // Asegúrate de que esta URL esté bien configurada.

  final body = jsonEncode({
    "conductorId": conductorId,
    "token": token,
    "isActive": isActive,
  });

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      debugPrint("Estado de sesión enviado correctamente para conductorId $conductorId.");
    } else {
      debugPrint("Error al enviar estado de sesión: ${response.body}");
    }
  } catch (e) {
    debugPrint("Excepción al enviar estado de sesión: $e");
  }
}


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppThemes.primaryColor),
    );
  }

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  // Iniciar sesión automáticamente si hay una sesión guardada
  Future<void> _autoLogin() async {
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
  final prefs = await SharedPreferences.getInstance();
  final conductorId = prefs.getInt('conductorId');
  final conductorNombre = prefs.getString('nombre');
  final token = prefs.getString('token');

  if (conductorId != null && token != null) {
    debugPrint("Sesión encontrada: $conductorId");

    // Actualizar estado en el Provider
    conductorProvider.setConductor(conductorId, conductorNombre ?? 'Conductor', token);

    // Enviar estado de sesión al backend
    await _sendSessionStatus(conductorId, token, true);

    // Redirigir a HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
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
