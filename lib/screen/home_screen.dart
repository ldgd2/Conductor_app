import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
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
  Future<void> _sendSessionStatus(bool isActive) async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);

    const url = notificationUrl;
    final body = jsonEncode({
      "conductorId": conductorProvider.conductorId,
      "token": null, // Suponiendo que el token está en otro lugar o es opcional
      "isActive": isActive,
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint("Estado de sesión actualizado: $isActive");
      } else {
        debugPrint("Error al actualizar estado de sesión: ${response.body}");
      }
    } catch (e) {
      debugPrint("Excepción al actualizar estado de sesión: $e");
    }
  }

  // Cerrar sesión
  Future<void> _logout() async {
    await _sendSessionStatus(false);
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    conductorProvider.clearConductor();
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
                trailing: const Icon(
                  Icons.local_offer,
                  color: AppThemes.primaryColor,
                ),
                onTap: _navigateToPedidosOfertas,
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
}
