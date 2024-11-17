import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:flutter/material.dart';
/*import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/vehiculosscreen.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:conductor_app/config/config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadConductorData();
  }

  // Cargar datos del conductor al iniciar
  Future<void> _loadConductorData() async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    if (conductorId != null) {
      final response = await _apiService.getConductorById(conductorId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          conductorProvider.setConductor(
            conductorId,
            data['nombre'] ?? '',
            data['email'] ?? '',
          );
        }
      } else {
        _showError("Error al cargar los datos del conductor.");
      }
    } else {
      _showError("ID de conductor no encontrado en sesión.");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Enviar estado de sesión al servidor
 // Enviar estado de sesión al servidor
Future<void> _sendSessionStatus(bool isActive) async {
  final statusModel = Provider.of<StatusModel>(context, listen: false);
  final conductorId = statusModel.conductorId;
  final token = statusModel.token;

  // Verificar que haya datos válidos antes de enviar
  if (conductorId == null || token == null) {
    debugPrint("No se puede enviar el estado: falta información del conductor.");
    return;
  }

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
      debugPrint("Estado de sesión actualizado: $isActive para Conductor ID: $conductorId");
    } else {
      debugPrint("Error al actualizar estado de sesión: ${response.body}");
    }
  } catch (e) {
    debugPrint("Excepción al actualizar estado de sesión: $e");
  }
}

// Método para cerrar sesión
Future<void> _logout() async {
  final statusModel = Provider.of<StatusModel>(context, listen: false);
  final conductorId = statusModel.conductorId;

  // Enviar el estado de sesión como inactivo
  if (conductorId != null) {
    await _sendSessionStatus(false);
  } else {
    debugPrint("No se puede enviar estado de sesión inactiva: conductorId no disponible.");
  }

  // Eliminar los datos de la sesión almacenados localmente
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('conductorId');
  await prefs.remove('nombre');
  await prefs.remove('token');
  debugPrint("Datos de sesión eliminados de SharedPreferences.");

  // Limpiar los modelos
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
  conductorProvider.clearConductor();
  statusModel.clearStatus();
  debugPrint("Modelos ConductorProvider y StatusModel limpiados.");

  // Redirigir al inicio de sesión
  Navigator.pushReplacementNamed(context, '/login');
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryColor,
      ),
    );
  }

  void _navigateToVehiculos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehiculosScreen()),
    );
  }

  void _navigateToPedidosOfertas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RutaPedidosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conductorProvider = Provider.of<ConductorProvider>(context);
  final newRoutesNotifier = Provider.of<NewRoutesNotifier>(context);

    return Scaffold(
      backgroundColor: AppThemes.backgroundColor,
      appBar: AppBar(
        title: const Text("Inicio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                conductorProvider.nombre != null
                    ? "Bienvenido, ${conductorProvider.nombre}"
                    : "Cargando nombre del conductor...",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Mis Vehículos",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppThemes.primaryColor,
                  ),
            ),
            const SizedBox(height: 10),
            Card(
              color: AppThemes.cardColor,
              child: ListTile(
                title: const Text(
                  "Gestión de Vehículos",
                  style: TextStyle(color: AppThemes.textColor),
                ),
                subtitle: const Text(
                  "Visualiza o añade vehículos asociados a tu perfil.",
                  style: TextStyle(color: AppThemes.hintColor),
                ),
                trailing: const Icon(
                  Icons.directions_car,
                  color: AppThemes.primaryColor,
                ),
                onTap: _navigateToVehiculos,
              ),
            ),
            const SizedBox(height: 30),
            Text(
             "Pedidos en Oferta",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppThemes.primaryColor,
                ),
          ),
          const SizedBox(height: 10),
          Card(
            color: AppThemes.cardColor,
            child: ListTile(
              title: const Text(
                "Ofertas Disponibles",
                style: TextStyle(color: AppThemes.textColor),
              ),
              subtitle: const Text(
                "Consulta y selecciona pedidos en oferta.",
                style: TextStyle(color: AppThemes.hintColor),
              ),
              trailing: Stack(
                children: [
                  const Icon(
                    Icons.local_offer,
                    color: AppThemes.primaryColor,
                  ),
                  if (newRoutesNotifier.hasNewRoutes)
                    Positioned(
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 10,
                        child: Text(
                          '${newRoutesNotifier.newRoutesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              onTap: () {
                _navigateToPedidosOfertas();
                newRoutesNotifier.clearRoutes();
              },
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToVehiculos,
      backgroundColor: AppThemes.primaryColor,
      child: const Icon(Icons.add, color: AppThemes.secondaryColor),
    ),
  );
}
}*/

import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';
import 'package:conductor_app/screen/profilescreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:conductor_app/config/config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadConductorData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadConductorData() async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    if (conductorId != null) {
      final response = await _apiService.getConductorById(conductorId);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          conductorProvider.setConductor(
            conductorId,
            data['nombre'] ?? '',
            data['email'] ?? '',
          );
        }
      } else {
        _showError("Error al cargar los datos del conductor.");
      }
    } else {
      _showError("ID de conductor no encontrado en sesión.");
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _sendSessionStatus(bool isActive) async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);
    final conductorId = statusModel.conductorId;
    final token = statusModel.token;

    if (conductorId == null || token == null) {
      debugPrint("No se puede enviar el estado: falta información del conductor.");
      return;
    }

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
        debugPrint("Estado de sesión actualizado: $isActive para Conductor ID: $conductorId");
      } else {
        debugPrint("Error al actualizar estado de sesión: ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al actualizar estado de sesión: $e");
    }
  }

  Future<void> _logout() async {
    final statusModel = Provider.of<StatusModel>(context, listen: false);
    final conductorId = statusModel.conductorId;

    if (conductorId != null) {
      await _sendSessionStatus(false);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('conductorId');
    await prefs.remove('nombre');
    await prefs.remove('token');
    debugPrint("Datos de sesión eliminados de SharedPreferences.");

    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    conductorProvider.clearConductor();
    statusModel.clearStatus();
    debugPrint("Modelos ConductorProvider y StatusModel limpiados.");

    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryColor,
      ),
    );
  }

  void _navigateToPedidosOfertas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RutaPedidosScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conductorProvider = Provider.of<ConductorProvider>(context);
    final newRoutesNotifier = Provider.of<NewRoutesNotifier>(context);

    return Scaffold(
      backgroundColor: AppThemes.backgroundColor,
      appBar: AppBar(
        title: const Text("Inicio"),
        leading: IconButton(
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow,
            progress: _animationController,
          ),
          onPressed: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    conductorProvider.nombre != null
                        ? "Bienvenido, ${conductorProvider.nombre}"
                        : "Cargando nombre del conductor...",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Pedidos en Oferta",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppThemes.primaryColor,
                      ),
                ),
                const SizedBox(height: 10),
                Card(
                  color: AppThemes.cardColor,
                  child: ListTile(
                    title: const Text(
                      "Ofertas Disponibles",
                      style: TextStyle(color: AppThemes.textColor),
                    ),
                    subtitle: const Text(
                      "Consulta y selecciona pedidos en oferta.",
                      style: TextStyle(color: AppThemes.hintColor),
                    ),
                    trailing: Stack(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: AppThemes.primaryColor,
                        ),
                        if (newRoutesNotifier.hasNewRoutes)
                          Positioned(
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 10,
                              child: Text(
                                '${newRoutesNotifier.newRoutesCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      _navigateToPedidosOfertas();
                      newRoutesNotifier.clearRoutes();
                    },
                  ),
                ),
              ],
            ),
          ),
          SlideTransition(
            position: _animationController.drive(
              Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero),
            ),
            child: Container(
              color: AppThemes.cardColor,
              width: 250,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: AppThemes.primaryColor),
                    title: const Text(
                      "Mi Perfil",
                      style: TextStyle(color: AppThemes.textColor),
                    ),
                    onTap: _navigateToProfile,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

