import 'package:conductor_app/model/NewRoutesNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'package:conductor_app/services/AutoLog.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/PedidosOfertasScreen.dart';
import 'package:conductor_app/screen/profilescreen.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final AutoLogin _autoLogin = AutoLogin(); // Instancia de AutoLog
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

  void _logout() async {
    // Utilizar el método logout desde AutoLogin
    await _autoLogin.logout(context);
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
            onPressed: _logout, // Llamada a la lógica de logout
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
