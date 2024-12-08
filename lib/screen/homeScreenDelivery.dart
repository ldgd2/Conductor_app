import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/logingscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:url_launcher/url_launcher.dart';
import 'package:conductor_app/config/config.dart';


import 'package:conductor_app/services/SavePoints.dart';
class HomeScreenDelivery extends StatefulWidget {
  const HomeScreenDelivery({Key? key}) : super(key: key);

  @override
  _HomeScreenDeliveryState createState() => _HomeScreenDeliveryState();
}

class _HomeScreenDeliveryState extends State<HomeScreenDelivery>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = false; // Indicador de carga
  List<Map<String, dynamic>> _routes = []; // Lista de rutas de carga
  late AnimationController _animationController;
      List<Map<String, dynamic>> _enProcesoRoutes = [];
List<Map<String, dynamic>> _recogidoRoutes = [];
List<Map<String, dynamic>> _finalizadoRoutes = [];

  @override
  void initState() {

    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _loadRoutes(); // Cargar rutas al iniciar
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

Future<List<Map<String, dynamic>>> obtenerIdsRutasCargaOferta() async {
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
  final conductorId = conductorProvider.conductorId;
  final url = Uri.parse("$urlapi/$conductorId/conductores");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['rutas_carga_ofertas'] != null && data['rutas_carga_ofertas'].isNotEmpty) {
        // Devuelvo la lista completa de rutas con toda su información
        return List<Map<String, dynamic>>.from(data['rutas_carga_ofertas']);
      } else {
        throw Exception('No se encontraron rutas de carga oferta');
      }
    } else {
      throw Exception("Error en la solicitud: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al obtener las rutas de carga oferta: $e");
    return []; // Devuelve una lista vacía en caso de error
  }
}
/*
Future<void> _loadRoutes() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Obtener las rutas de carga de oferta
    final rutasCargaOferta = await obtenerIdsRutasCargaOferta();

    // Filtrar las rutas por su estado
    final filteredRoutes = rutasCargaOferta.where((ruta) {
      final estado = ruta['estado']; // Asegúrate de que el campo 'estado' existe en los datos

      // Filtrar los estados que deseas
      return estado == 'en_proceso' || estado == 'recogido' || estado == 'finalizado';
    }).toList();

    // Actualizar el estado con las rutas filtradas
    setState(() {
      _routes = filteredRoutes; // Ahora _routes contiene solo las rutas con el estado filtrado
    });
  } catch (e) {
    print("Error al cargar las rutas: $e");
    _showError("Ocurrió un error al cargar las rutas de carga.");
  }

  setState(() {
    _isLoading = false;
  });
}
*/
Future<void> _loadRoutes() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Obtener las rutas de carga de oferta
    final rutasCargaOferta = await obtenerIdsRutasCargaOferta();

    // Organizar las rutas por estado
    final enProcesoRoutes = rutasCargaOferta.where((ruta) {
      final estado = ruta['estado'];
      return estado == 'en_proceso';
    }).toList();

    final recogidoRoutes = rutasCargaOferta.where((ruta) {
      final estado = ruta['estado'];
      return estado == 'recogido';
    }).toList();

    final finalizadoRoutes = rutasCargaOferta.where((ruta) {
      final estado = ruta['estado'];
      return estado == 'finalizado';
    }).toList();

    // Ordenar las rutas por fecha (recientes primero)
    enProcesoRoutes.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
    recogidoRoutes.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
    finalizadoRoutes.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

    // Actualizar el estado con las rutas organizadas
    setState(() {
      _enProcesoRoutes = enProcesoRoutes;
      _recogidoRoutes = recogidoRoutes;
      _finalizadoRoutes = finalizadoRoutes;
    });
  } catch (e) {
    print("Error al cargar las rutas: $e");
    _showError("Ocurrió un error al cargar las rutas de carga.");
  }

  setState(() {
    _isLoading = false;
  });
}



  /// Método para abrir Google Maps con puntos de la ruta
  Future<void> _openGoogleMapsWithStops(List<latLngLib.LatLng> stops) async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latLngLib.LatLng currentLocation =
          latLngLib.LatLng(position.latitude, position.longitude);

      if (stops.isEmpty) {
        throw Exception("No hay puntos disponibles para mostrar en Google Maps.");
      }

      final origin = "${currentLocation.latitude},${currentLocation.longitude}";
      final waypoints = stops
          .take(stops.length - 1)
          .map((point) => "${point.latitude},${point.longitude}")
          .join('|');
      final destination = "${stops.last.latitude},${stops.last.longitude}";

      final url = Uri.parse(
          "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&waypoints=$waypoints&travelmode=driving");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("No se pudo abrir Google Maps.");
      }
    } catch (e) {
      debugPrint("Error al abrir Google Maps: $e");
      _showError("Error al abrir Google Maps.");
    }
  }

  /// Método para mostrar un error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryColor,
      ),
    );
  }

Future<String?> getConductorTipo(int conductorId) async {
  // Construir la URL
  final url = Uri.parse('$urlapi/conductores/$conductorId');
  debugPrint("URL para obtener detalles del conductor: $url");

  try {
    // Realizar la solicitud GET
    final response = await http.get(url);

    // Verificar el código de estado
    if (response.statusCode == 200) {
      // Parsear el cuerpo de la respuesta
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Retornar el valor del campo 'tipo'
      final tipo = data['tipo'];
      debugPrint("Tipo del conductor obtenido: $tipo");
      return tipo;
    } else {
      // Manejo de error cuando la respuesta no es 200
      debugPrint("Error al obtener detalles del conductor:");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      return null;
    }
  } catch (e) {
    // Manejo de excepciones
    debugPrint("Excepción al obtener detalles del conductor: $e");
    return null;
  }
}
  /// Método de logout
  void _logout() async {
    setState(() {
      _isLoading = true;
    });

    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    if (conductorId != null) {
      try {
        final tipo = await getConductorTipo(conductorId);
        if (tipo == null) {
          debugPrint("No se pudo obtener el tipo del conductor.");
          _showError("Error obteniendo información del conductor.");
          return;
        }

        final response = await _apiService.updateToken2(conductorId, null, tipo);
        if (response.statusCode == 200) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else {
          debugPrint("Error al eliminar el token: ${response.body}");
          _showError("Error al cerrar sesión. Intenta de nuevo.");
        }
      } catch (e) {
        debugPrint("Excepción al realizar logout: $e");
        _showError("Ocurrió un error al cerrar sesión.");
      }
    } else {
      _showError("ID de conductor no encontrado.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final conductorProvider = Provider.of<ConductorProvider>(context);

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
            icon: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.logout),
            onPressed: _isLoading ? null : _logout,
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
                        ? "Bienvenido DELIVERY, ${conductorProvider.nombre}"
                        : "Cargando nombre del conductor...",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Rutas de Carga",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppThemes.primaryColor,
                      ),
                ),
                const SizedBox(height: 10),
                Expanded(
  child: _routes.isEmpty
      ? const Center(
          child: Text(
            "No hay rutas de carga disponibles.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
      : ListView.builder(
          itemCount: _routes.length,
          itemBuilder: (context, index) {
            final route = _routes[index];

            return Card(
              color: AppThemes.cardColor,
              child: ListTile(
                title: Text("Ruta: ${route['ruta_oferta']['id']}"),
                subtitle: Text(
                  "Estado: ${route['estado']}",
                  style: const TextStyle(color: AppThemes.hintColor),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.map, color: Colors.blue),
                  onPressed: () async {
                    final points = await SavePoints.loadRoute(route['id']);
                    await _openGoogleMapsWithStops(points);
                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
