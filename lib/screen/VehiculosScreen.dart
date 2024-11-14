import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/model/transporte.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'RegistrarVeiculosScreen.dart';
import 'dart:convert';

class VehiculosScreen extends StatefulWidget {
  const VehiculosScreen({Key? key}) : super(key: key);

  @override
  _VehiculosScreenState createState() => _VehiculosScreenState();
}

class _VehiculosScreenState extends State<VehiculosScreen> {
  final ApiService _apiService = ApiService();
  List<Transporte> _vehiculos = [];
  List<Transporte> _filteredVehiculos = [];
  bool _isLoading = true;

  // Filtros
  int? _capacidadFilter;
  String? _marcaFilter;
  String? _modeloFilter;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  Future<void> _loadVehiculos() async {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    if (conductorId != null) {
      try {
        final response = await _apiService.getTransportesByConductorTrans(conductorId);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data is List) {
            setState(() {
              _vehiculos = data.map((json) => Transporte.fromJson(json)).toList();
              _filteredVehiculos = List.from(_vehiculos); // Inicializamos la lista filtrada
              _isLoading = false;
            });
          } else {
            _showError("Formato de respuesta inesperado. Verifica la API.");
            setState(() {
              _isLoading = false;
            });
          }
        } else {
          _showError("Error al cargar los vehículos. Por favor, intenta más tarde.");
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        _showError("Error al procesar la respuesta de la API.");
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showError("ID de conductor no encontrado en la sesión.");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredVehiculos = _vehiculos.where((vehiculo) {
        final matchMarca = _marcaFilter == null || vehiculo.marca == _marcaFilter;
        final matchModelo = _modeloFilter == null || vehiculo.modelo == _modeloFilter;
        final matchCapacidad = _capacidadFilter == null || vehiculo.capacidadMaxKg == _capacidadFilter;
        return matchMarca && matchModelo && matchCapacidad;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _capacidadFilter = null;
      _marcaFilter = null;
      _modeloFilter = null;
      _filteredVehiculos = List.from(_vehiculos);
    });
  }

  Future<void> _deleteVehiculo(Transporte vehiculo) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text("ADVERTENCIA"),
            ],
          ),
          content: Text(
            "¿Está seguro de eliminar el vehículo: ${vehiculo.marca} ${vehiculo.modelo} ${vehiculo.placa}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await _apiService.deleteTransporte(vehiculo.id!);
        if (response.statusCode == 200) {
          setState(() {
            _vehiculos.remove(vehiculo);
            _applyFilters();
          });
        } else {
          _showError("Error al eliminar el vehículo.");
        }
      } catch (e) {
        _showError("Error al eliminar el vehículo. Por favor, intenta más tarde.");
      }
    }
  }

  Future<void> _editVehiculo(Transporte vehiculo) async {
    final TextEditingController marcaController =
        TextEditingController(text: vehiculo.marca);
    final TextEditingController modeloController =
        TextEditingController(text: vehiculo.modelo);
    final TextEditingController capacidadController =
        TextEditingController(text: vehiculo.capacidadMaxKg.toString());
    final TextEditingController placaController =
        TextEditingController(text: vehiculo.placa);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Vehículo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
              ),
              TextField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
              ),
              TextField(
                controller: capacidadController,
                decoration: const InputDecoration(labelText: 'Capacidad (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedVehiculo = Transporte(
                  id: vehiculo.id,
                  idConductor: vehiculo.idConductor,
                  capacidadMaxKg: int.parse(capacidadController.text),
                  marca: marcaController.text,
                  modelo: modeloController.text,
                  placa: placaController.text,
                );

                final response = await _apiService.updateTransporte(
                    updatedVehiculo.id!, updatedVehiculo.toJson());

                if (response.statusCode == 200) {
                  Navigator.of(context).pop();
                  _loadVehiculos();
                } else {
                  _showError("Error al actualizar el vehículo.");
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      hint: Text(hint),
      onChanged: onChanged,
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text(hint),
        ),
        ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Vehículos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDropdown<String>(
                          hint: "Marca",
                          value: _marcaFilter,
                          items: _vehiculos.map((v) => v.marca).toSet().toList(),
                          onChanged: (value) {
                            setState(() {
                              _marcaFilter = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdown<String>(
                          hint: "Modelo",
                          value: _modeloFilter,
                          items: _vehiculos.map((v) => v.modelo).toSet().toList(),
                          onChanged: (value) {
                            setState(() {
                              _modeloFilter = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDropdown<int>(
                          hint: "Capacidad Max",
                          value: _capacidadFilter,
                          items: _vehiculos.map((v) => v.capacidadMaxKg).toSet().toList(),
                          onChanged: (value) {
                            setState(() {
                              _capacidadFilter = value;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredVehiculos.length,
                    itemBuilder: (context, index) {
                      final vehiculo = _filteredVehiculos[index];
                      return Card(
                        child: ListTile(
                          title: Text("${vehiculo.marca} ${vehiculo.modelo}"),
                          subtitle: Text("Placa: ${vehiculo.placa}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editVehiculo(vehiculo),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteVehiculo(vehiculo),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegistrarVehiculoScreen()),
          ).then((_) => _loadVehiculos());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
