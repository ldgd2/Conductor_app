import 'package:flutter/material.dart';
import 'package:conductor_app/model/rutapedido.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'dart:convert';

class RutaPedidosScreen extends StatefulWidget {
  const RutaPedidosScreen({Key? key}) : super(key: key);

  @override
  _RutaPedidosScreenState createState() => _RutaPedidosScreenState();
}

class _RutaPedidosScreenState extends State<RutaPedidosScreen> {
  final ApiService _apiService = ApiService();
  List<RutaPedido> _rutasPedido = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRutasPedido();
  }

  Future<void> _loadRutasPedido() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final response = await _apiService.getAllRutasPedido();
    if (response.statusCode == 200) {
      final body = response.body;
      print("Response Body: $body"); // Esto te ayudará a ver la respuesta en la consola

      final List<dynamic> data = jsonDecode(body);
      if (data is List) {
        setState(() {
          _rutasPedido = data.map((json) => RutaPedido.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "La respuesta no es una lista de rutas. Verifica la API.";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Error al cargar las rutas de pedido. Código: ${response.statusCode}";
        _isLoading = false;
      });
    }
  } catch (e) {
    print("Error: $e"); // Esto ayuda a depurar errores inesperados
    setState(() {
      _errorMessage = "Error al cargar las rutas de pedido: $e";
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rutas de Pedido"),
        backgroundColor: AppThemes.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: AppThemes.hintColor),
                  ),
                )
              : _rutasPedido.isEmpty
                  ? Center(
                      child: Text(
                        "No hay rutas de pedido disponibles en este momento.",
                        style: TextStyle(color: AppThemes.hintColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _rutasPedido.length,
                      itemBuilder: (context, index) {
                        final rutaPedido = _rutasPedido[index];
                        return Card(
                          color: AppThemes.cardColor,
                          child: ListTile(
                           title: Text(
  "Fecha de Entrega: ${rutaPedido.fechaEntrega.toLocal().toString().split(' ')[0]}",
  style: const TextStyle(color: AppThemes.textColor),
),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Capacidad Utilizada: ${rutaPedido.capacidadUtilizada} kg",
                                  style: const TextStyle(color: AppThemes.hintColor),
                                ),
                                Text(
                                  "Distancia Total: ${rutaPedido.distanciaTotal} km",
                                  style: const TextStyle(color: AppThemes.hintColor),
                                ),
                                Text(
                                  "Estado: ${rutaPedido.estado}",
                                  style: const TextStyle(color: AppThemes.hintColor),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.route,
                              color: AppThemes.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
