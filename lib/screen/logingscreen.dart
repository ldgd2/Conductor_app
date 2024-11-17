import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/screen/register_transportista_screen.dart';
import 'package:conductor_app/screen/home_screen.dart';
import 'package:conductor_app/themes/theme.dart';
import 'dart:convert';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/model/statusModel.dart'; // Importar StatusModel
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

  // Guardar sesión localmente
  Future<void> _saveSession(int conductorId, String nombre, String email, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('conductorId', conductorId);
    await prefs.setString('nombre', nombre);
    await prefs.setString('email', email);
    await prefs.setString('token', token);
    debugPrint("Sesión guardada localmente: Conductor ID $conductorId, Nombre $nombre");
  }

 // Enviar estado de sesión al servidor
Future<void> _sendSessionStatus(int conductorId, String token, bool isActive) async {
  const url = notificationUrl;

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
      debugPrint("Estado de sesión enviado correctamente: $isActive para Conductor ID: $conductorId");
    } else {
      debugPrint("Error al enviar estado de sesión: ${response.body}");
    }
  } catch (e) {
    debugPrint("Excepción al enviar estado de sesión: $e");
  }
}

// Método para iniciar sesión
Future<void> _login() async {
  final statusModel = Provider.of<StatusModel>(context, listen: false);
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
        final nombre = conductor['nombre'];
        final email = conductor['email'];
        debugPrint("Conductor encontrado: $conductorId");

        final token = await _getFCMToken();
        if (token != null) {
          // Guardar sesión localmente
          await _saveSession(conductorId, nombre, email, token);

          // Actualizar estado en StatusModel
          statusModel.setStatus(conductorId, token, true);

          // Actualizar información en ConductorProvider
          conductorProvider.setConductor(conductorId, nombre, email);

          // Enviar estado de sesión activa al servidor
          await _sendSessionStatus(conductorId, token, true);

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


  // Validar sesión activa al iniciar la aplicación
  Future<void> _autoLogin() async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();
    final conductorId = prefs.getInt('conductorId');
    final nombre = prefs.getString('nombre');
    final email = prefs.getString('email');
    final token = prefs.getString('token');

    if (conductorId != null && token != null) {
      debugPrint("Sesión encontrada: $conductorId, Nombre: $nombre");

      // Actualizar estado en StatusModel
      statusModel.setStatus(conductorId, token, true);

      // Actualizar información en ConductorProvider
      conductorProvider.setConductor(conductorId, nombre ?? '', email ?? '');

      // Navegar al HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
