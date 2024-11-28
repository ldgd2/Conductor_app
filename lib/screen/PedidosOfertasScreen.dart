import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:conductor_app/model/RutaCargaPedido.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/model/statusModel.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class RutaPedidosScreen extends StatefulWidget {
 final latLngLib.LatLng? notificationCoordinates; // Coordenadas individuales
  final List<latLngLib.LatLng>? notificationRoute; // Ruta completa

   const RutaPedidosScreen({Key? key, this.notificationCoordinates, this.notificationRoute}) : super(key: key);

  @override
  _RutaPedidosScreenState createState() => _RutaPedidosScreenState();
}

class _RutaPedidosScreenState extends State<RutaPedidosScreen> {
  final ApiService _apiService = ApiService();
  Set<int> _newRouteIds = {}; // Ahora es un conjunto
 // Almacena los IDs de rutas nuevas
    Set<int> _viewedRoutes = {};
  List<RutaCargaPedido> _rutasPedido = [];
  bool _isLoading = true;
  String? _errorMessage;
  latLngLib.LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();

    _fetchCurrentLocation().then((_) {
      if (widget.notificationRoute != null && widget.notificationRoute!.isNotEmpty) {
        // Mostrar el mapa directamente si viene una ruta completa de la notificación
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final routeWithCurrentLocation = [_currentLocation!, ...widget.notificationRoute!];
          _showMapDialog(routeWithCurrentLocation);
        });
        setState(() {
          _isLoading = false; // No carga rutas adicionales
        });
      } else {
        // Cargar rutas normalmente si no hay datos de notificaciones
        _loadRutasPedido();
      }
    });
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('El servicio de ubicación está deshabilitado.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('El permiso de ubicación fue denegado.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'El permiso de ubicación está denegado permanentemente. No se puede acceder a la ubicación.');
      }

      // Obtener ubicación actual
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation =
            latLngLib.LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al obtener la ubicación actual: $e';
      });
    }
  }

Future<void> _loadRutasPedido() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final response = await _apiService.getAllRutaCargasPedido();
    print("Respuesta de la API: ${response.body}");

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body is List) {
        // Mapear rutas y eliminar duplicados
        List<RutaCargaPedido> allRutas = body
            .map((json) => RutaCargaPedido.fromJson(json))
            .toList();

        // Eliminar duplicados basados en el ID
        Map<int, RutaCargaPedido> rutasMap = {
          for (var ruta in allRutas) ruta.idCargaPedido: ruta
        };
        allRutas = rutasMap.values.toList();

        print("Rutas mapeadas sin duplicados: ${allRutas.map((ruta) => ruta.idCargaPedido).toList()}");

        // Cargar rutas vistas desde SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        List<String> viewedRoutes = prefs.getStringList('viewedRoutes') ?? [];
        Set<int> viewedRouteIds = viewedRoutes.map((id) => int.parse(id)).toSet();

        print("IDs de rutas vistas: $viewedRouteIds");

        // Detectar nuevas rutas
        List<RutaCargaPedido> nuevasRutas = allRutas
            .where((ruta) => !viewedRouteIds.contains(ruta.idCargaPedido))
            .toList();

        print("Nuevas rutas detectadas: ${nuevasRutas.map((ruta) => ruta.idCargaPedido).toList()}");

        // Agregar todas las rutas a la lista (nuevas primero)
        setState(() {
          _rutasPedido = [
            ...nuevasRutas,
            ...allRutas.where((ruta) => viewedRouteIds.contains(ruta.idCargaPedido)),
          ];
          print("Rutas finales: ${_rutasPedido.map((ruta) => ruta.idCargaPedido).toList()}");

          // Marcar nuevas rutas con "Nuevo"
          _newRouteIds.addAll(nuevasRutas.map((ruta) => ruta.idCargaPedido));
          _isLoading = false;
        });

        // Actualizar rutas vistas en SharedPreferences
        viewedRouteIds.addAll(nuevasRutas.map((ruta) => ruta.idCargaPedido));
        await prefs.setStringList(
          'viewedRoutes',
          viewedRouteIds.map((id) => id.toString()).toList(),
        );

        // Remover etiqueta "Nuevo" después de 20 segundos
        if (nuevasRutas.isNotEmpty) {
          Future.delayed(const Duration(seconds: 20), () {
            setState(() {
              _newRouteIds.removeAll(nuevasRutas.map((ruta) => ruta.idCargaPedido));
              print("Etiqueta 'Nuevo' eliminada para IDs: ${nuevasRutas.map((ruta) => ruta.idCargaPedido).toList()}");
            });
          });
        }
      } else {
        setState(() {
          _errorMessage = "La respuesta no contiene datos válidos.";
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = "Error al cargar las rutas. Código: ${response.statusCode}";
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = "Error al cargar las rutas: $e";
      _isLoading = false;
    });
  }
}




void _showMapDialog(List<latLngLib.LatLng> points) {
  // Filtramos puntos duplicados (ubicación del conductor que ya existe en la lista)
  List<latLngLib.LatLng> filteredPoints = points.where((point) {
    return !_isSameLocation(point, _currentLocation!);
  }).toList();

  // Añadimos la ubicación del conductor como inicio
  List<latLngLib.LatLng> pointsWithCurrentLocation = [_currentLocation!, ...filteredPoints];

  // Calculamos el orden óptimo de puntos, manteniendo el último como destino final
  final optimizedPoints = _getOptimizedRoute(pointsWithCurrentLocation);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 400,
              width: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _getRouteCenter(optimizedPoints),
                  initialZoom: _getOptimalZoom(optimizedPoints),
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: optimizedPoints,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: _buildMarkers(optimizedPoints),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      print("Ruta aceptada.");
                    },
                    child: const Text("Aceptar"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      print("Ruta rechazada.");
                    },
                    child: const Text("Rechazar"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<Set<int>> _loadViewedRoutes() async {
  final prefs = await SharedPreferences.getInstance();
  final viewedRoutes = prefs.getStringList('viewedRoutes') ?? [];
  return viewedRoutes.map((id) => int.parse(id)).toSet();
}

Future<void> _saveViewedRoutes(Set<int> viewedRoutes) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setStringList('viewedRoutes', viewedRoutes.map((id) => id.toString()).toList());
}


/// Verifica si dos ubicaciones son las mismas.
bool _isSameLocation(latLngLib.LatLng a, latLngLib.LatLng b) {
  return a.latitude.toStringAsFixed(6) == b.latitude.toStringAsFixed(6) &&
      a.longitude.toStringAsFixed(6) == b.longitude.toStringAsFixed(6);
}

/// Verifica si la lista de puntos ya contiene un punto específico
bool _pointsContain(List<latLngLib.LatLng> points, latLngLib.LatLng point) {
  return points.any((p) =>
      p.latitude.toStringAsFixed(6) == point.latitude.toStringAsFixed(6) &&
      p.longitude.toStringAsFixed(6) == point.longitude.toStringAsFixed(6));
}

  /// Reordena los puntos de forma óptima, manteniendo el último como destino final.
List<latLngLib.LatLng> _getOptimizedRoute(List<latLngLib.LatLng> points) {
  if (_currentLocation == null || points.isEmpty) {
    return points;
  }

  final start = _currentLocation!;
  final end = points.last;
  final intermediates = points.sublist(0, points.length - 1);

  // Usar el algoritmo del vecino más cercano
  List<latLngLib.LatLng> optimized = [start];
  List<latLngLib.LatLng> remaining = List.from(intermediates);

  while (remaining.isNotEmpty) {
    final current = optimized.last;

    // Encontrar el punto más cercano al actual
    latLngLib.LatLng nearest = remaining[0];
    double minDistance = _calculateDistance(current, nearest);

    for (var point in remaining) {
      double distance = _calculateDistance(current, point);
      if (distance < minDistance) {
        nearest = point;
        minDistance = distance;
      }
    }

    // Añadir el más cercano a la ruta optimizada
    optimized.add(nearest);
    remaining.remove(nearest);
  }

  // Añadir el punto final
  optimized.add(end);

  return optimized;
}

/// Calcula la distancia entre dos puntos.
double _calculateDistance(latLngLib.LatLng a, latLngLib.LatLng b) {
  final distance = latLngLib.Distance();
  return distance.as(
    latLngLib.LengthUnit.Meter,
    latLngLib.LatLng(a.latitude, a.longitude),
    latLngLib.LatLng(b.latitude, b.longitude),
  );
}

/// Genera marcadores con colores dinámicos.
/// Genera marcadores con colores dinámicos y etiquetas "Inicio" y "Fin".
List<Marker> _buildMarkers(List<latLngLib.LatLng> points) {
  final colors = [
    Colors.cyan, // Punto inicial: ubicación del conductor
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.yellow,
    Colors.blue,
    Colors.red, // Último punto: destino final
  ];

  return points.asMap().entries.map((entry) {
    final index = entry.key;
    final point = entry.value;

    // El último punto siempre es rojo
    final color = (index == points.length - 1) ? Colors.red : colors[index % colors.length];

    // Etiquetas para "Inicio" y "Fin"
    final label = (index == 0)
        ? "Inicio"
        : (index == points.length - 1)
            ? "Fin"
            : null;

     return Marker(
      point: point,
      width: 80,
      height: 60,
      child: Column(
        children: [
          if (label != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          Icon(
            Icons.location_pin,
            color: color,
            size: 40,
          ),
        ],
      ),
    );
  }).toList();
}


  latLngLib.LatLng _getRouteCenter(List<latLngLib.LatLng> points) {
    double latSum = 0;
    double lngSum = 0;

    for (var point in points) {
      latSum += point.latitude;
      lngSum += point.longitude;
    }

    return latLngLib.LatLng(latSum / points.length, lngSum / points.length);
  }

  double _getOptimalZoom(List<latLngLib.LatLng> points) {
    double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;

    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    if (maxDiff < 0.01) {
      return 16; // Zoom cercano
    } else if (maxDiff < 0.05) {
      return 14; // Zoom medio
    } else if (maxDiff < 0.1) {
      return 12; // Zoom más amplio
    } else {
      return 10; // Zoom lejano
    }
  }


  Future<void> _acceptRoute(int idCargaPedido) async {
  try {
    final data = {"estado": "finalizado"}; // Cambiar estado a finalizado
    final response = await _apiService.updateRutaCargaPedido(idCargaPedido, data);

    if (response.statusCode == 200) {
      print("Ruta aceptada: $idCargaPedido");
      _loadRutasPedido(); // Refrescar la lista
    } else {
      print("Error al aceptar la ruta: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al aceptar la ruta: $e");
  }
}

Future<void> _cancelRoute(int idCargaPedido) async {
  try {
    final response = await _apiService.deleteRutaCargaPedido(idCargaPedido);

    if (response.statusCode == 200) {
      print("Ruta cancelada: $idCargaPedido");
      _loadRutasPedido(); // Refrescar la lista
    } else {
      print("Error al cancelar la ruta: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al cancelar la ruta: $e");
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Rutas de Pedido"),
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : _rutasPedido.isEmpty
                ? const Center(
                    child: Text(
                      "No hay rutas disponibles.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _rutasPedido.length,
                    itemBuilder: (context, index) {
                      final rutaPedido = _rutasPedido[index];
                      bool isNew = _newRouteIds.contains(rutaPedido.idCargaPedido);

                      return Card(
                        child: ListTile(
                          leading: isNew
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "Nuevo",
                                    style: TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                )
                              : null,
                          title: Text("Orden: ${rutaPedido.orden}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("ID Transporte: ${rutaPedido.idTransporte}"),
                              Text("Distancia: ${rutaPedido.distancia} km"),
                              Text("Estado: ${rutaPedido.estado}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.map),
                                onPressed: () {
                                  _showMapDialog(rutaPedido.points);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () {
                                  _acceptRoute(rutaPedido.idCargaPedido);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _cancelRoute(rutaPedido.idCargaPedido);
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