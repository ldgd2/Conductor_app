
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conductor_app/screen/RutaScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/logingscreen.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:permission_handler/permission_handler.dart';

class ListaRutaScreen extends StatefulWidget {
  const ListaRutaScreen({Key? key}) : super(key: key);

  @override
  _ListaRutaScreen createState() => _ListaRutaScreen();
}

class _ListaRutaScreen extends State<ListaRutaScreen> with SingleTickerProviderStateMixin {

  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _routes = [];
 

  Map<int, Set<int>> productosSeleccionadosPorRuta = {};  // {idRuta: {idProducto}}

  late AnimationController _animationController;


  @override
  void initState() {
    super.initState();
    _loadRoutes();
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

Future<void> _loadRoutes() async { 
  setState(() {});

  try {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    final response = await http.get(Uri.parse("$urlapi/conductores/$conductorId/rutas-carga-ofertas"));
    print("Respuesta completa de puntos-ruta: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['rutas_carga_ofertas'] != null) {
        final List<Map<String, dynamic>> allRoutes = List<Map<String, dynamic>>.from(data['rutas_carga_ofertas']);
        print("All Routes: $allRoutes");

        // Filtrar rutas con estado "activo"
        final List<Map<String, dynamic>> activeRoutes = allRoutes.where((route) {
          return route['estado'] == 'activo'; // Filtramos por estado "activo"
        }).toList();

        print("Filtered Active Routes: $activeRoutes");

        // Agrupar rutas por id_ruta_oferta
        Map<int, List<Map<String, dynamic>>> groupedRoutes = {};
        for (var route in activeRoutes) {
          final idRutaOferta = int.parse(route['id_ruta_oferta'].toString());

          // Verifica si la ruta ya está en el grupo
          if (groupedRoutes.containsKey(idRutaOferta)) {
            groupedRoutes[idRutaOferta]!.add(route);
          } else {
            groupedRoutes[idRutaOferta] = [route];
          }
        }

        // Aquí, agrupamos las rutas y los productos
        List<Map<String, dynamic>> detailedRoutes = []; 

        for (var group in groupedRoutes.values) {
          List<Map<String, dynamic>> detailsForGroup = [];
          String? fechaRecogida; // Inicializamos la variable

          for (var route in group) {
            final idCargaOferta = int.parse(route['id_carga_oferta'].toString());

            // Asegurándonos de que 'fecha_recogida' sea accesible correctamente
            fechaRecogida = route['ruta_oferta'] != null 
                ? route['ruta_oferta']['fecha_recogida']?.toString() ?? 'No disponible'
                : 'No disponible';

            final detailsResponse = await http.get(Uri.parse("$urlapi/carga_ofertas/$idCargaOferta/detalle"));
            if (detailsResponse.statusCode == 200) {
              final detailsData = jsonDecode(detailsResponse.body);

              if (detailsData['detalle_carga_oferta'] != null) {
                final detalleCargaOferta = detailsData['detalle_carga_oferta'];

                final Map<String, dynamic> detalle = {
 'id_rutacargaoferta': int.parse(route['id'].toString()),
  'id_cargaoferta': int.parse(route['id_carga_oferta'].toString()), // Mantener id_cargaoferta
  'id_rutaoferta': int.parse(route['id_ruta_oferta'].toString()),
  'orden': int.parse(route['orden'].toString()),
  'fecha_recogida': fechaRecogida,
  'nombre': detalleCargaOferta['oferta_detalle']['produccion']['producto']['nombre'],
  'cantidad': detalleCargaOferta['pesokg'],
};


                print("Detalles de rutas: $detalle");

                detailsForGroup.add(detalle);
              }
            } else {
              debugPrint("Error al obtener detalles de carga oferta: ${detailsResponse.statusCode}");
            }
          }

          // Agregar el grupo completo de detalles
    if (detailsForGroup.isNotEmpty) {
  final totalCantidad = detailsForGroup.fold<double>(
    0,
    (sum, item) => sum + (item['cantidad'] ?? 0),
  );

  detailedRoutes.add({
    'id_rutaoferta': group.first['id_ruta_oferta'],
    'fecha_recogida': fechaRecogida,
    'total_cantidad': totalCantidad, // Calcula la cantidad total aquí
    'detalles': detailsForGroup,
  });
}
        }
        print("Detalles de rutas: $detailedRoutes");

        setState(() {
          _routes = detailedRoutes; // No necesitamos hacer cast aquí.
        });
      } else {
        throw Exception("No se encontraron rutas de carga oferta");
      }
    } else {
      throw Exception("Error en la solicitud: ${response.statusCode}");
    }
  } catch (e) {
    debugPrint("Error al cargar rutas: $e");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al cargar rutas.")));
  } finally {
    setState(() {});
  }
}



void _showRutaDetailsDialog(BuildContext context, Map<String, dynamic> rutaGroup) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Lista para almacenar los detalles de cada ruta
      List<Map<String, dynamic>> detalles = List<Map<String, dynamic>>.from(rutaGroup['detalles']);
      
      return AlertDialog(
        title: Text('Detalles de la ruta ${rutaGroup['id_rutaoferta']}'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detalles.map<Widget>((detalle) {
                  // Obtener el estado del checkbox (si ya fue confirmado)
            

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detalle['nombre'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cantidad: ${detalle['cantidad']}kg'),
                        ],
                      ),
                      Text('Fecha de Recolección: ${detalle['fecha_recogida']}'),
                      SizedBox(height: 10),
                      
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Llamar a la función verMapa pasando la ruta actual
              verMapa(context, rutaGroup); // Pasa todo el grupo de rutas (con detalles) a la función
            },
            child: Text('Ver en el mapa'),
          ),
        ],
      );
    },
  );
}




Future<bool> AceptarRuta(List<int> idsRutaCargaOferta) async {
  final conductorId = obteneridconductor();

  if (conductorId == null) {
    print("Error: El ID del conductor es nulo");
    return false;
  }

  bool allSuccess = true; // Para rastrear si todas las rutas fueron aceptadas correctamente

  for (int idRutaCargaOferta in idsRutaCargaOferta) {
    final url = "$urlapi/ruta_carga_ofertas/$idRutaCargaOferta/aceptar";
    print("$urlapi/ruta_carga_ofertas/$idRutaCargaOferta/aceptar");
    final body = jsonEncode({
      "id_conductor": conductorId,
    });

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
print(body);
      if (response.statusCode == 200) {
        print("Se aceptó la ruta con ID $idRutaCargaOferta exitosamente");
      } else {
        print("Error al aceptar la ruta con ID $idRutaCargaOferta: ${response.statusCode}");
        allSuccess = false;
      }
    } catch (e) {
      print("Error en la solicitud para aceptar la ruta con ID $idRutaCargaOferta: $e");
      allSuccess = false;
    }
  }
  return allSuccess;
}


Future<bool> CancelarRuta(List<int> idsRutaCargaOferta) async {
  final conductorId = obteneridconductor();

  if (conductorId == null) {
    print("Error: El ID del conductor es nulo");
    return false;
  }

  bool allSuccess = true; // Para rastrear si todas las rutas fueron aceptadas correctamente

    final url = "$urlapi/ruta_carga_ofertas/$idsRutaCargaOferta/cancelar";
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
        print("Se aceptó la ruta con ID $idsRutaCargaOferta exitosamente");
      } else {
        print("Error al aceptar la ruta con ID $idsRutaCargaOferta: ${response.statusCode}");
        allSuccess = false;
      }
    } catch (e) {
      print("Error en la solicitud para aceptar la ruta con ID $idsRutaCargaOferta: $e");
      allSuccess = false;
    }
  
_loadRoutes();
  return allSuccess;
}


Future<String> obtenerUbicacionConductor() async {
  try {
    PermissionStatus permission = await Permission.location.request();

    if (permission != PermissionStatus.granted) {
      throw 'Permiso de ubicación no concedido';
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return '${position.latitude},${position.longitude}';
  } catch (e) {
    throw 'Error al obtener la ubicación: $e';
  }
}

Future<void> verMapa(BuildContext context, Map<String, dynamic> rutaGroup) async {
  try {
    List<String> coordenadasRuta = []; // Lista de coordenadas
    String latConductor = '';
    String lonConductor = '';
    
    // Obtener la id_ruta_oferta de la ruta actual
    final idRutaOferta = rutaGroup['id_rutaoferta'];
    
    // Consumir la API para obtener los puntos de la ruta
    final response = await http.get(Uri.parse("$urlapi/ruta_ofertas/$idRutaOferta/puntos-ruta"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Si existen los puntos de ruta, procesarlos
      if (data['puntos_ruta'] != null) {
        // Recorrer todos los puntos y agruparlos
        for (var punto in data['puntos_ruta']) {
          if (punto['tipo'] == 'carga') {
            // Si es un punto de carga, lo añadimos como waypoint
            coordenadasRuta.add('${punto['lat']},${punto['lon']}');
          } else if (punto['tipo'] == 'punto_acopio') {
            // Si es un punto de acopio, lo almacenamos para usarlo como destino
            latConductor = punto['lat'].toString();
            lonConductor = punto['lon'].toString();
          }
        }
      }

      // Obtener la ubicación actual del conductor
      String ubicacionConductor = await obtenerUbicacionConductor();
      
      // Generar la URL de Google Maps con la secuencia de puntos
      String rutaUrl = 'https://www.google.com/maps/dir/?api=1';

      // Agregar el punto de origen (ubicación del conductor)
      rutaUrl += '&origin=$ubicacionConductor';
      
      // Agregar los puntos intermedios (coordenadas de carga)
      for (var punto in coordenadasRuta) {
        rutaUrl += '&waypoints=$punto';
      }

      // Agregar el punto de acopio como destino final
      if (latConductor.isNotEmpty && lonConductor.isNotEmpty) {
        rutaUrl += '&destination=$latConductor,$lonConductor';
      }

      // Mostrar la URL generada para depuración
      print('Ruta de Google Maps: $rutaUrl');

      // Intentar abrir la URL de Google Maps
      if (await canLaunch(rutaUrl)) {
        await launch(rutaUrl);
      } else {
        print('No se puede abrir Google Maps.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se puede abrir Google Maps"))
        );
      }
    } else {
      print("Error al obtener los puntos de la ruta: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al obtener los puntos de la ruta"))
      );
    }
  } catch (e) {
    print('Error al obtener la ruta: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al obtener la ruta"))
    );
  }
}



Future<Map<String, dynamic>> obtenerDetallesRuta(Map<String, dynamic> rutaGroup) async {
  try {
    List<Map<String, dynamic>> productos = [];
    Map<String, dynamic> acopioLocation = {};
    String conductorLocation = await obtenerUbicacionConductor();

    final idRutaOferta = rutaGroup['id_rutaoferta'];

    final response = await http.get(Uri.parse("$urlapi/ruta_ofertas/$idRutaOferta/puntos-ruta"));
    print("Respuesta de puntos-ruta: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['puntos_ruta'] != null) {
        for (var punto in data['puntos_ruta']) {
          if (punto['tipo'] == 'carga') {
            final producto = {
              'lat': punto['lat'].toString(),
              'lon': punto['lon'].toString(),
              'producto': punto['producto'] ?? 'Producto desconocido',
              'cantidad': punto['cantidad'] ?? 0,
              'unidad': punto['unidad'] ?? 'Kg',
              'id_rutaoferta': rutaGroup['id_rutaoferta'],
              'id_rutacargaoferta': punto['id'], // Extraemos correctamente el ID del punto
            };
            print("Producto procesado: $producto");
            productos.add(producto);
          } else if (punto['tipo'] == 'punto_acopio') {
            acopioLocation = {
              'lat': punto['lat'].toString(),
              'lon': punto['lon'].toString(),
            };
            print("Punto de acopio procesado: $acopioLocation");
          }
        }

        return {
          'conductorLocation': conductorLocation,
          'productos': productos,
          'acopioLocation': acopioLocation,
        };
      } else {
        throw Exception("No se encontraron puntos de ruta.");
      }
    } else {
      throw Exception("Error al obtener puntos de ruta: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al obtener detalles de la ruta: $e");
    throw Exception("Error al procesar la ruta.");
  }
}





_navegarARutaScreen(BuildContext context, Map<String, dynamic> rutaGroup) async {
  try {
    final rutaDetalles = await obtenerDetallesRuta(rutaGroup);

    final productosValidos = rutaDetalles['productos']
        .where((producto) => producto['id_rutaoferta'] != null)
        .toList();

    if (productosValidos.isEmpty) {
      print("No hay productos válidos con id_rutacargaoferta.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay productos válidos en esta ruta")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RutaScreen(
          conductorLocation: rutaDetalles['conductorLocation'],
          productos: productosValidos,
          acopioLocation: rutaDetalles['acopioLocation'],
          idRutaOferta: rutaGroup['id_rutaoferta'], // Pasar id_rutaoferta de la ruta
        ),
      ),
    );
  } catch (e) {
    print("Error al navegar a RutaScreen: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al cargar los detalles de la ruta")),
    );
  }
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

 void _logout() async {
  debugPrint("Iniciando logout...");
   setState(() {
  });

  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
  final conductorId = conductorProvider.conductorId;

  if (conductorId != null) {
    debugPrint("Conductor ID: $conductorId");

    try {
      // Obtener el tipo del conductor
      final tipo = await getConductorTipo(conductorId);

      if (tipo == null) {
        debugPrint("No se pudo obtener el tipo del conductor.");
        _showError("Error obteniendo información del conductor.");
        return;
      }

      debugPrint("Tipo del conductor: $tipo");

      // Actualizar el token del conductor a null
      final response = await _apiService.updateToken2(conductorId, null, tipo);

      if (response.statusCode == 200) {
        debugPrint("Token eliminado correctamente del servidor.");

        // Redirigir al usuario a la pantalla de inicio de sesión
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        debugPrint("Error al eliminar el token del servidor: ${response.body}");
        _showError("Error al cerrar sesión. Intenta de nuevo.");
      }
    } catch (e) {
      debugPrint("Excepción al realizar logout: $e");
      _showError("Ocurrió un error al cerrar sesión.");
    }
  } else {
    debugPrint("ID de conductor no encontrado.");
    _showError("No se pudo cerrar sesión. Intenta de nuevo.");
  }
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppThemes.primaryColor,
      ),
    );
  }
int? obteneridconductor(){
  final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;
  return conductorId;
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppThemes.backgroundColor,
    appBar: AppBar(
      title: const Text("Rutas Asignadas"),
    ),
    body: Column(
      children: [
        Expanded(
          child :   _routes.isEmpty
              ? const Center(child: Text("No hay rutas asignadas disponibles"))
              : ListView.builder(
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final ruta = _routes[index];
                   
                     List<Map<String, dynamic>> detalle = List<Map<String, dynamic>>.from(ruta['detalles']);
                    final idRutaOferta = ruta['id_rutaoferta'];
                    final fechaRecoleccion = ruta['fecha_recogida'];
                    final idRutaCargaOferta = ruta['id_rutacargaoferta'];
                     print("Id necesaro: $idRutaCargaOferta");
                     int? id_RutaCargaOferta;

// Iterar para encontrar el ID
for (var detalleItem in detalle) {
  if (detalleItem.containsKey('id_rutacargaoferta')) {
    id_RutaCargaOferta = detalleItem['id_rutacargaoferta'] as int;
    break; // Detén el loop una vez encontrado
  }
}

// Asegúrate de que no sea nulo antes de usarlo
if (id_RutaCargaOferta != null) {
  print("ID Ruta Carga Oferta: $id_RutaCargaOferta");
} else {
  print("No se encontró 'id_rutacargaoferta' en los detalles.");
}  print("Fecha de Recolección: $fechaRecoleccion\nCantidad Total: ${ruta['total_cantidad']} kg");
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.map, color: Colors.red),
                        title: Text("Ruta Asignada ID: $idRutaOferta"),
                        
                        subtitle: Text("Fecha de Recolección: $fechaRecoleccion\nCantidad Total: ${ruta['total_cantidad']} kg"),
                       
                        onTap: () async {
  _navegarARutaScreen(context, ruta);
 
},

                       trailing: Row(
  mainAxisSize: MainAxisSize.min, // Ajustar tamaño para no ocupar todo el espacio
  children: [
    IconButton(
      icon: const Icon(Icons.map, color: Colors.blue),
      onPressed: () {
        verMapa(context, ruta); // Método para mostrar el mapa
      },
    ),
   IconButton(
  icon: const Icon(Icons.check_circle, color: Colors.green),
  onPressed: () async {
    final detalles = List<Map<String, dynamic>>.from(ruta['detalles']);
    final idsRutaCargaOferta = detalles.map<int>((detalle) => detalle['id_rutacargaoferta']).toList();
final idsRutaOferta = detalles.map<int>((detalle) => detalle['id_rutaoferta']).toList();
    final success = await AceptarRuta(idsRutaOferta);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todas las rutas asociadas fueron aceptadas exitosamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hubo un error al aceptar una o más rutas")),
      );
    }
  },
),
    IconButton(
  icon: const Icon(Icons.cancel, color: Colors.red),
  onPressed: () async {
    final detalles = List<Map<String, dynamic>>.from(ruta['detalles']);
    final idsRutaCargaOferta = detalles.map<int>((detalle) => detalle['id_rutacargaoferta']).toList();
final idsRutaOferta = detalles.map<int>((detalle) => detalle['id_rutaoferta']).toList();
    final success = await CancelarRuta(idsRutaOferta);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todas las rutas asociadas fueron aceptadas exitosamente")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hubo un error al aceptar una o más rutas")),
      );
    }
  },
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
  );
}



}