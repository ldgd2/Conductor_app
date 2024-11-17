import 'package:flutter/material.dart';
import 'package:conductor_app/screen/vehiculosscreen.dart';
import 'package:conductor_app/themes/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _navigateToVehiculos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehiculosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: AppThemes.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: AppThemes.primaryColor),
              title: const Text(
                "Información Personal",
                style: TextStyle(color: AppThemes.textColor),
              ),
              subtitle: const Text(
                "Ver y actualizar información personal.",
                style: TextStyle(color: AppThemes.hintColor),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppThemes.primaryColor),
              onTap: () {
                // Implementa lógica para navegar a la pantalla de información personal
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.directions_car, color: AppThemes.primaryColor),
              title: const Text(
                "Administrar Vehículos",
                style: TextStyle(color: AppThemes.textColor),
              ),
              subtitle: const Text(
                "Registrar o actualizar tus vehículos.",
                style: TextStyle(color: AppThemes.hintColor),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppThemes.primaryColor),
              onTap: () => _navigateToVehiculos(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock, color: AppThemes.primaryColor),
              title: const Text(
                "Cambiar Contraseña",
                style: TextStyle(color: AppThemes.textColor),
              ),
              subtitle: const Text(
                "Actualizar tu contraseña de acceso.",
                style: TextStyle(color: AppThemes.hintColor),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppThemes.primaryColor),
              onTap: () {
                // Implementa lógica para cambiar contraseña
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: AppThemes.primaryColor),
              title: const Text(
                "Configuración",
                style: TextStyle(color: AppThemes.textColor),
              ),
              subtitle: const Text(
                "Configura preferencias de tu cuenta.",
                style: TextStyle(color: AppThemes.hintColor),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppThemes.primaryColor),
              onTap: () {
                // Implementa lógica para configuración
              },
            ),
          ],
        ),
      ),
    );
  }
}
