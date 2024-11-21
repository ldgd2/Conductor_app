import 'package:flutter/material.dart';
import 'package:conductor_app/model/rutapedido2.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      setState(() {
        _errorMessage = "Error al cargar las rutas de pedido: $e";
        _isLoading = false;
      });
    }
  }

  void _showMapDialog(List<LatLng> points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 400,
            width: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: points.first,
                zoom: 14,
              ),
              markers: points
                  .map((point) => Marker(
                        markerId: MarkerId(point.toString()),
                        position: point,
                      ))
                  .toSet(),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('route'),
                  points: points,
                  color: Colors.blue,
                  width: 5,
                ),
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _acceptRoute(int id) async {
    print("Ruta aceptada: $id");
  }

  Future<void> _cancelRoute(int id) async {
    print("Ruta cancelada: $id");
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
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.map, color: AppThemes.primaryColor),
                                  onPressed: () {
                                    _showMapDialog(rutaPedido.points);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    _acceptRoute(rutaPedido.id);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    _cancelRoute(rutaPedido.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
