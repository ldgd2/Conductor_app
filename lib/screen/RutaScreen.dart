import 'dart:async';
import 'dart:convert';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

class RutaScreen extends StatefulWidget {
  final String conductorLocation;
  final List<Map<String, dynamic>> productos;
  final Map<String, dynamic> acopioLocation;
final int idRutaOferta;
final String estadoRuta;

  const RutaScreen({
    required this.conductorLocation,
    required this.productos,
    required this.acopioLocation,
    required this.idRutaOferta,
     required this.estadoRuta,
  });

  @override
  _RutaScreenState createState() => _RutaScreenState();
}

class _RutaScreenState extends State<RutaScreen> {
  late GoogleMapController _mapController;
  final Map<MarkerId, Marker> _markers = {};
  final Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  List<bool> _recogidaStatus = [];
  bool rutaAceptada = false; 
late StreamSubscription<Position> _positionStream;

@override
void initState() {
  super.initState();
  _filtrarRutas();
  _initializeLocationUpdates();
   rutaAceptada = widget.estadoRuta == 'en_proceso' || widget.estadoRuta == 'finalizado';

  if (rutaAceptada) {
    _initializeLocationUpdates();
    _generateRoute();
  } else {
    _filtrarRutas();
  }
  _recogidaStatus = List<bool>.filled(widget.productos.length, false);
  _checkRutaAceptada();
  _generateRoute();
  _initializeRecogidaStatus();
}

 @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  // # # # Funcion para obtener id carga ruta oferta # # #
  Future<List<int>> filtrarIdRutaCargaOfertaPorRutaOferta(int idRutaOferta) async {
  int? conductorId = obteneridconductor(); 
  if (conductorId == null) {
    throw Exception("ID del conductor no encontrado");
  }
  final url = "$urlapi/conductores/$conductorId/rutas-carga-ofertas";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['rutas_carga_ofertas'] != null) {
        final List<Map<String, dynamic>> rutas = List<Map<String, dynamic>>.from(data['rutas_carga_ofertas']);
        final rutasFiltradas = rutas.where((ruta) => ruta['id_ruta_oferta'] == idRutaOferta).toList();
        final List<int> idsRutaCargaOferta = rutasFiltradas.map<int>((ruta) => ruta['id']).toList();
        print("IDs filtrados para id_ruta_oferta $idRutaOferta: $idsRutaCargaOferta");
        return idsRutaCargaOferta;
      } else {
        print("No se encontraron rutas_carga_ofertas");
      }
    } else {
      print("Error al obtener rutas_carga_ofertas: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al consumir la API: $e");
  }
  return [];
}

Future<void> _initializeRecogidaStatus() async {
  final url = "$urlapi/ruta_ofertas/${widget.idRutaOferta}";
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rutaCargaOferta = data['ruta_carga_oferta'];

      setState(() {
        _recogidaStatus = widget.productos.map((producto) {
          final matchingItem = rutaCargaOferta.firstWhere(
            (item) => item['id'] == producto['id_rutacargaoferta'],
            orElse: () => null,
          );
          // Activar el checkbox si el estado es "finalizado"
          return matchingItem?['carga_oferta']?['estado'] == 'finalizado';
        }).toList();
      });
    } else {
      print("Error al obtener el estado de los productos: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al inicializar el estado de los checkboxes: $e");
  }
}


// # # # funciones para Aceptar,Confirmar Ruta # # #
Future<bool> AceptarRuta(List<int> idsRutaOferta) async {
  final conductorId = obteneridconductor();
  if (conductorId == null) {
    print("Error: El ID del conductor es nulo");
    return false;
  }

  if (idsRutaOferta.isEmpty) {
    print("Error: La lista de IDs de ruta oferta está vacía");
    return false;
  }

  final idRutaOferta = idsRutaOferta.first;
  final url = "$urlapi/ruta_carga_ofertas/$idRutaOferta/aceptar";
  print(url);
  final body = jsonEncode({"id_conductor": conductorId});
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    print(body);
    if (response.statusCode == 200) {
      print("Se aceptó la ruta con ID $idRutaOferta exitosamente");
      return true;
    } else {
      print("Error al aceptar la ruta con ID $idRutaOferta: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Error en la solicitud para aceptar la ruta con ID $idRutaOferta: $e");
    return false;
  }
}

Future<void> _aceptarRuta() async {
  final conductorId = obteneridconductor();
  if (conductorId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID de conductor no encontrado")),
    );
    return;
  }

  final idRutaOferta = widget.productos.isNotEmpty
      ? widget.productos.first['id_rutaoferta']
      : null;

  if (idRutaOferta == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No se encontró un ID válido para la ruta oferta")),
    );
    return;
  }

  final success = await AceptarRuta([idRutaOferta]);
  if (success) {
    setState(() {
      rutaAceptada = true;
    });

    // Ajustar la vista del mapa al marcador del conductor
    final LatLng conductorLatLng = LatLng(
      double.parse(widget.conductorLocation.split(',')[0]),
      double.parse(widget.conductorLocation.split(',')[1]),
    );
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: conductorLatLng, zoom: 18), // Iniciar con zoom cercano
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ruta aceptada exitosamente")),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al aceptar la ruta")),
    );
  }
}

Future<void> _checkRutaAceptada() async {
  final idRutaOferta = widget.productos.isNotEmpty 
      ? widget.productos.first['id_rutaoferta'] 
      : null;

  if (idRutaOferta == null) return;

  try {
    final url = "$urlapi/ruta_ofertas/$idRutaOferta/estado";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        rutaAceptada = data['aceptada'] ?? false; // Ajusta según la estructura de tu respuesta
      });
    }
  } catch (e) {
    print("Error al verificar el estado de la ruta: $e");
  }
}

  Future<bool> confirmarRecogida(int idRutaCargaOferta) async {
    final url = "$urlapi/ruta_carga_ofertas/$idRutaCargaOferta/confirmar-recogida";
    int? conductorId = obteneridconductor();
    final body = jsonEncode({
      "id_conductor": conductorId,
    });
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


// # # # Funciones para el conductor (provider, ubicacion) # # #
int? obteneridconductor(){
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;
  return conductorId;
}

// Mover cámara y animar marcador de manera fluida
void _animateConductorPosition(Position position) {
  final LatLng newLatLng = LatLng(position.latitude, position.longitude);

  // Calcular nivel de zoom basado en velocidad
  double zoomLevel;
  if (position.speed < 5) {
    zoomLevel = 18; // Lento: zoom cercano
  } else if (position.speed < 15) {
    zoomLevel = 16; // Velocidad media
  } else {
    zoomLevel = 14; // Rápido: zoom amplio
  }

  // Mover la cámara y animar el marcador
  _mapController.animateCamera(
    CameraUpdate.newCameraPosition(
      CameraPosition(target: newLatLng, zoom: zoomLevel),
    ),
  );

  setState(() {
    _markers[MarkerId('conductor')] = Marker(
      markerId: const MarkerId('conductor'),
      position: newLatLng,
      infoWindow: const InfoWindow(title: 'Conductor'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  });
}

  void _updateConductorPosition(Position position) {
    final LatLng newLatLng = LatLng(position.latitude, position.longitude);

    // Actualizar el marcador del conductor
    setState(() {
      _addMarker(
        'conductor',
        newLatLng,
        'Conductor',
        BitmapDescriptor.hueBlue,
      );
    });

    // Mover la cámara del mapa
    _mapController.animateCamera(
      CameraUpdate.newLatLng(newLatLng),
    );
  }

void _initializeLocationUpdates() async {
  final permission = await Geolocator.requestPermission();
  if (permission != LocationPermission.always &&
      permission != LocationPermission.whileInUse) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Permiso de ubicación no concedido")),
    );
    return;
  }
  _positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Alta frecuencia para actualizaciones suaves
    ),
  ).listen((Position position) {
    if (rutaAceptada) {
      _animateConductorPosition(position);
    }
  });
}

// ### Funciones para el mapa ###
Future<void> _fitMapToBounds() async {
  final List<LatLng> allCoordinates = [
    ...widget.productos.map((p) => LatLng(double.parse(p['lat']), double.parse(p['lon']))),
    LatLng(double.parse(widget.acopioLocation['lat']), double.parse(widget.acopioLocation['lon'])),
    LatLng(
      double.parse(widget.conductorLocation.split(',')[0]),
      double.parse(widget.conductorLocation.split(',')[1]),
    ),
  ];

  // Calcular los límites geográficos
  double minLat = allCoordinates.map((coord) => coord.latitude).reduce((a, b) => a < b ? a : b);
  double maxLat = allCoordinates.map((coord) => coord.latitude).reduce((a, b) => a > b ? a : b);
  double minLng = allCoordinates.map((coord) => coord.longitude).reduce((a, b) => a < b ? a : b);
  double maxLng = allCoordinates.map((coord) => coord.longitude).reduce((a, b) => a > b ? a : b);

  // Construir los límites de la cámara
  LatLngBounds bounds = LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );

  // Mover la cámara para ajustar a los límites
  _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50)); // Padding de 50px
}




Future<void> _filtrarRutas() async {
  final idRutaOferta = widget.idRutaOferta;
  try {
    final idsFiltrados = await filtrarIdRutaCargaOfertaPorRutaOferta(idRutaOferta);
    print("IDs de ruta carga oferta filtrados: $idsFiltrados");

    // Vincula los productos con las IDs de ruta carga oferta
    setState(() {
      for (int i = 0; i < widget.productos.length; i++) {
        widget.productos[i]['id_rutacargaoferta'] = idsFiltrados[i];
      }
    });

    print("Productos actualizados: ${widget.productos}");
  } catch (e) {
    print("Error al filtrar rutas: $e");
  }
}

  Future<void> _generateRoute() async {
    final List<String> waypoints = widget.productos.map((producto) {
      return '${producto['lat']},${producto['lon']}';
    }).toList();

    final String origin = widget.conductorLocation;
    final String destination =
        '${widget.acopioLocation['lat']},${widget.acopioLocation['lon']}';
    final String apiKey = 'AIzaSyD0LCJrziElcmi_f1Z4vokk1yHH-Pkyp68'; // Reemplazar con tu clave API

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&waypoints=optimize:true|${waypoints.join('|')}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK') {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylineCoordinates = _decodePolyline(points);

          setState(() {
            _routePoints = polylineCoordinates;
          });
          _addPolyline(polylineCoordinates);
          _addMarkers();
          await _fitMapToBounds();
        } else {
          debugPrint("Error en Directions API: ${data['status']}");
        }
      } else {
        debugPrint("Error HTTP: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error al obtener la ruta: $e");
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> coordinates = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      coordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return coordinates;
  }

  void _addPolyline(List<LatLng> coordinates) {
    final polylineId = PolylineId('route');
    final polyline = Polyline(
      polylineId: polylineId,
      points: coordinates,
      color: Colors.blue,
      width: 5,
    );

    setState(() {
      _polylines[polylineId] = polyline;
    });
  }

  void _addMarkers() {
    // Agregar marcador del conductor
    final LatLng conductorLatLng = LatLng(
      double.parse(widget.conductorLocation.split(',')[0]),
      double.parse(widget.conductorLocation.split(',')[1]),
    );
    _addMarker('conductor', conductorLatLng, 'Conductor', BitmapDescriptor.hueBlue);

    // Agregar marcadores de productos
    for (int i = 0; i < widget.productos.length; i++) {
      final producto = widget.productos[i];
      final LatLng productoLatLng = LatLng(
        double.parse(producto['lat']),
        double.parse(producto['lon']),
      );
      _addMarker(
        'producto_$i',
        productoLatLng,
        "${producto['producto']} - ${producto['cantidad']} ${producto['unidad']}",
        BitmapDescriptor.hueGreen,
      );
    }

    // Agregar marcador del punto de acopio
    final LatLng acopioLatLng = LatLng(
      double.parse(widget.acopioLocation['lat']),
      double.parse(widget.acopioLocation['lon']),
    );
    _addMarker('acopio', acopioLatLng, 'Punto de Acopio', BitmapDescriptor.hueRed);
  }

  void _addMarker(String id, LatLng position, String title, double hue) {
    final markerId = MarkerId(id);
    final marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
    );

    setState(() {
      _markers[markerId] = marker;
    });
  }

// # # # Interfaz # # #

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: rutaAceptada
        ? _buildRutaAceptada() // Interfaz para rutas aceptadas o finalizadas
        : _buildRutaNoAceptada(), // Interfaz para rutas no aceptadas
  );
}

  Widget _buildRutaNoAceptada() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _routePoints.isNotEmpty ? _routePoints.first : LatLng(0, 0),
            zoom: 12,
          ),
          markers: Set<Marker>.of(_markers.values),
          polylines: Set<Polyline>.of(_polylines.values),
          onMapCreated: (controller) => _mapController = controller,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.black.withOpacity(0.8),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.productos.length,
                  itemBuilder: (context, index) {
                    final producto = widget.productos[index];
                    return Text(
                      "${producto['producto']} (${producto['cantidad']} ${producto['unidad']})",
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 16),
ElevatedButton(
  onPressed: _aceptarRuta,
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: const Text("Aceptar Ruta", style: TextStyle(color: Colors.white)),
),


              ],
            ),
          ),
        ),
      ],
    );
  }

Widget _buildRutaAceptada() {
  return Stack(
    children: [
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _routePoints.isNotEmpty ? _routePoints.first : LatLng(0, 0),
          zoom: 12,
        ),
        markers: Set<Marker>.of(_markers.values),
        polylines: Set<Polyline>.of(_polylines.values),
        onMapCreated: (controller) => _mapController = controller,
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          color: Colors.black.withOpacity(0.8),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Usamos un ListView limitado en altura
              SizedBox(
                height: 150, // Altura limitada similar a _buildRutaNoAceptada
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.productos.length,
                  itemBuilder: (context, index) {
                    final producto = widget.productos[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Validar que el nombre del producto no sea nulo
                        Text(
                          "${producto['nombre'] ?? 'Producto desconocido'} (${producto['cantidad']} ${producto['unidad'] ?? ''})",
                          style: const TextStyle(color: Colors.white),
                        ),
                        Checkbox(
                          value: _recogidaStatus[index],
                          activeColor: Colors.green,
                          onChanged: (bool? value) async {
                            if (!_recogidaStatus[index] && value == true) {
                              final success = await confirmarRecogida(
                                producto['id_rutacargaoferta'], // Pasamos la ID correcta
                              );
                              if (success) {
                                setState(() {
                                  _recogidaStatus[index] = true; // Actualiza el estado
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Error al confirmar la recogida")),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Ruta finalizada")),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Finalizar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

}