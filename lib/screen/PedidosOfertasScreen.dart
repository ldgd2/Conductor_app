import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:conductor_app/model/rutapedido2.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'dart:convert';

class RutaPedidosScreen extends StatefulWidget {
 final latLngLib.LatLng? notificationCoordinates; // Coordenadas individuales
  final List<latLngLib.LatLng>? notificationRoute; // Ruta completa

   const RutaPedidosScreen({Key? key, this.notificationCoordinates, this.notificationRoute}) : super(key: key);

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

    if (widget.notificationRoute != null && widget.notificationRoute!.isNotEmpty) {
      // Mostrar el mapa directamente si viene una ruta completa de la notificación
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMapDialog(widget.notificationRoute!);
      });
      setState(() {
        _isLoading = false; // No carga rutas adicionales
      });
    } else {
      // Cargar rutas normalmente si no hay datos de notificaciones
      _loadRutasPedido();
    }
  }

  Future<void> _loadRutasPedido() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Obtener el ID del conductor desde el Provider
      final conductorId = Provider.of<StatusModel>(context, listen: false).conductorId;

      if (conductorId == null) {
        setState(() {
          _errorMessage = "ID del conductor no encontrado. Inicie sesión nuevamente.";
          _isLoading = false;
        });
        return;
      }

      // Llamar a la API con el ID del conductor
      final response = await _apiService.getAllRutasOfertaconductor(conductorId);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic> && body.containsKey('data')) {
          final List<dynamic> data = body['data'];
          setState(() {
            _rutasPedido = data.map((json) => RutaPedido.fromJson(json)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "La respuesta no contiene rutas válidas. Verifica la API.";
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

  void _showMapDialog(List<latLngLib.LatLng> points) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 400,
            width: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: points.first,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      color: Colors.blue,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: points
                      .map((point) => Marker(
                            point: point,
                            width: 40,
                            height: 40,
                           child: const Icon(
    Icons.location_pin,
    color: Colors.red,
    size: 40,
),

                          ))
                      .toList(),
                ),
              ],
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
