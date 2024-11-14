import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/model/transporte.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';

class RegistrarVehiculoScreen extends StatefulWidget {
  const RegistrarVehiculoScreen({Key? key}) : super(key: key);

  @override
  _RegistrarVehiculoScreenState createState() => _RegistrarVehiculoScreenState();
}

class _RegistrarVehiculoScreenState extends State<RegistrarVehiculoScreen> {
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();

  final ApiService _apiService = ApiService();

  void _registrarVehiculo() async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    if (conductorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No se encontró el ID del conductor en la sesión.")),
      );
      return;
    }

    final capacidadMaxKg = int.tryParse(_capacidadController.text.trim());
    final marca = _marcaController.text.trim();
    final modelo = _modeloController.text.trim();
    final placa = _placaController.text.trim();

    if (capacidadMaxKg != null && marca.isNotEmpty && modelo.isNotEmpty && placa.isNotEmpty) {
      final transporte = Transporte(
        idConductor: conductorId,
        capacidadMaxKg: capacidadMaxKg,
        marca: marca,
        modelo: modelo,
        placa: placa,
      );

      try {
        final response = await _apiService.createTransporte(transporte.toJson());

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vehículo registrado exitosamente.")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error al registrar el vehículo: ${response.reasonPhrase}")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de red. Por favor, intenta más tarde.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa todos los campos correctamente.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Registrar Vehículo"),
        backgroundColor: AppThemes.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _capacidadController,
              label: 'Capacidad Máxima (kg)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _marcaController,
              label: 'Marca',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _modeloController,
              label: 'Modelo',
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _placaController,
              label: 'Placa',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarVehiculo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Registrar Vehículo"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppThemes.surfaceColor,
        labelStyle: const TextStyle(color: AppThemes.textColor),
        hintStyle: const TextStyle(color: AppThemes.hintColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppThemes.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppThemes.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppThemes.primaryColor),
        ),
      ),
      style: const TextStyle(color: AppThemes.textColor),
    );
  }
}
