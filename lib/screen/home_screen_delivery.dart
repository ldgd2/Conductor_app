
import 'package:conductor_app/screen/ListaRutaScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:conductor_app/services/ConductorProvider.dart';
import 'package:conductor_app/services/api_service.dart';
import 'package:conductor_app/config/config.dart';
import 'package:conductor_app/themes/theme.dart';
import 'package:conductor_app/screen/profilescreen.dart';
import 'package:conductor_app/screen/logingscreen.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import 'package:permission_handler/permission_handler.dart';

class HomeScreenDelivery extends StatefulWidget {
  const HomeScreenDelivery({Key? key}) : super(key: key);

  @override
  _HomeScreenDeliveryState createState() => _HomeScreenDeliveryState();
}

class _HomeScreenDeliveryState extends State<HomeScreenDelivery> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _routes = [];
  List<Map<String, dynamic>> _finalizedRoutes = [];
 

  Map<int, Set<int>> productosSeleccionadosPorRuta = {};  // {idRuta: {idProducto}}

  late AnimationController _animationController;

  double _iconRotation = 0.0; 




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

  void _toggleDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer(); 
    setState(() {
      _iconRotation = _iconRotation == 0.0 ? 0.5 : 0.0; 
    });
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

/*
Future<void> _loadRoutes() async { 
  setState(() {
  });

  try {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    final response = await http.get(Uri.parse("$urlapi/conductores/$conductorId/rutas-carga-ofertas"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['rutas_carga_ofertas'] != null) {
        final List<Map<String, dynamic>> allRoutes = List<Map<String, dynamic>>.from(data['rutas_carga_ofertas']);
        print("All Routes: $allRoutes");

        // Agrupar rutas por id_ruta_oferta
        Map<int, List<Map<String, dynamic>>> groupedRoutes = {};
        for (var route in allRoutes) {
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
          String? fechaRecoleccion;

          for (var route in group) {
            final idCargaOferta = int.parse(route['id_carga_oferta'].toString());
            fechaRecoleccion = route['ruta_oferta']?['fecha_recogida'] ?? 'No disponible'; // Asegurarse que no sea null

            final detailsResponse = await http.get(Uri.parse("$urlapi/carga_ofertas/$idCargaOferta/detalle"));
            if (detailsResponse.statusCode == 200) {
              final detailsData = jsonDecode(detailsResponse.body);

              if (detailsData['detalle_carga_oferta'] != null) {
                final detalleCargaOferta = detailsData['detalle_carga_oferta'];

                final Map<String, dynamic> detalle = {
                  'id_rutacargaoferta': int.parse(route['id'].toString()),
                  'id_rutaoferta': int.parse(route['id_ruta_oferta'].toString()),
                  'id_cargaoferta': int.parse(idCargaOferta.toString()),
                  'orden': int.parse(route['orden'].toString()),
                  'fecha_recogida': fechaRecoleccion,
                  'nombre': detalleCargaOferta['oferta_detalle']['produccion']['producto']['nombre'],
                  'cantidad': detalleCargaOferta['pesokg'],
                };

                detailsForGroup.add(detalle);
              }
            } else {
              debugPrint("Error al obtener detalles de carga oferta: ${detailsResponse.statusCode}");
            }
          }

          // Agregar el grupo completo de detalles
          if (detailsForGroup.isNotEmpty) {
            detailedRoutes.add({
              'id_rutaoferta': group.first['id_ruta_oferta'],
  'fecha_recogida': fechaRecoleccion,
  'detalles': detailsForGroup,  
            });
          }
        }

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
    setState(() {
    });
  }
}
*/

/*
Future<void> _loadRoutes() async { 
  setState(() {});

  try {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    final response = await http.get(Uri.parse("$urlapi/conductores/$conductorId/rutas-carga-ofertas"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['rutas_carga_ofertas'] != null) {
        // Obtener todas las rutas y filtrar solo las que tengan estado "en_proceso"
        final List<Map<String, dynamic>> allRoutes = List<Map<String, dynamic>>.from(
          data['rutas_carga_ofertas']
        ).where((route) => route['estado'] == "en_proceso").toList();

        print("Filtered Routes (en_proceso): $allRoutes");

        // Agrupar rutas por id_ruta_oferta
        Map<int, List<Map<String, dynamic>>> groupedRoutes = {};
        for (var route in allRoutes) {
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
          String? fechaRecoleccion;

          for (var route in group) {
            final idCargaOferta = int.parse(route['id_carga_oferta'].toString());
            fechaRecoleccion = route['ruta_oferta']?['fecha_recogida'] ?? 'No disponible'; // Asegurarse que no sea null

            final detailsResponse = await http.get(Uri.parse("$urlapi/carga_ofertas/$idCargaOferta/detalle"));
            if (detailsResponse.statusCode == 200) {
              final detailsData = jsonDecode(detailsResponse.body);

              if (detailsData['detalle_carga_oferta'] != null) {
                final detalleCargaOferta = detailsData['detalle_carga_oferta'];

                final Map<String, dynamic> detalle = {
                  'id_rutacargaoferta': int.parse(route['id'].toString()),
                  'id_rutaoferta': int.parse(route['id_ruta_oferta'].toString()),
                  'id_cargaoferta': int.parse(idCargaOferta.toString()),
                  'orden': int.parse(route['orden'].toString()),
                  'fecha_recogida': fechaRecoleccion,
                  'nombre': detalleCargaOferta['oferta_detalle']['produccion']['producto']['nombre'],
                  'cantidad': detalleCargaOferta['pesokg'],
                };

                detailsForGroup.add(detalle);
              }
            } else {
              debugPrint("Error al obtener detalles de carga oferta: ${detailsResponse.statusCode}");
            }
          }

          // Agregar el grupo completo de detalles
          if (detailsForGroup.isNotEmpty) {
            detailedRoutes.add({
              'id_rutaoferta': group.first['id_ruta_oferta'],
              'fecha_recogida': fechaRecoleccion,
              'detalles': detailsForGroup,  
            });
          }
        }

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
}*/


void _showRutaDetailsDialog(BuildContext context, Map<String, dynamic> rutaGroup) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      List<Map<String, dynamic>> detalles = List<Map<String, dynamic>>.from(rutaGroup['detalles']);
      
      return AlertDialog(
        title: Text('Detalles de Ruta Oferta ${rutaGroup['id_rutaoferta']}'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detalles.map<Widget>((detalle) {
                  bool isChecked = detalle['isRecogidaConfirmed'] ?? false;

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
                          Checkbox(
  value: detalle['isRecogidaConfirmed'],
  activeColor: Colors.green, 
  onChanged: detalle['isRecogidaConfirmed']
      ? null 
      : (bool? value) async {
          if (value != null && value) {
            int idRutaCargaOferta = detalle['id_rutacargaoferta']; 

            bool success = await finalizarRecogida(idRutaCargaOferta);
_loadRoutes();
            if (success) {
              setState(() {
                detalle['isRecogidaConfirmed'] = true; 
                _loadRoutes();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error al finalizar la recogida para el producto")),
              );
            }
          }
        },
),



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
              _loadRoutes();
              Navigator.of(context).pop();
            },
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              verMapa(context, rutaGroup); 
            },
            child: Text('Ver en el mapa'),
          ),
        ],
      );
    },
  );
}




Future<void> _loadRoutes() async {
  setState(() {});

  try {
    final conductorProvider = Provider.of<ConductorProvider>(context, listen: false);
    final conductorId = conductorProvider.conductorId;

    final response = await http.get(Uri.parse("$urlapi/conductores/$conductorId/rutas-carga-ofertas"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['rutas_carga_ofertas'] != null) {
        final List<Map<String, dynamic>> allRoutes = List<Map<String, dynamic>>.from(data['rutas_carga_ofertas']);

        final rutasActivas = allRoutes.where((route) => route['estado'] == "activo").toList();
        final rutasPendientes = allRoutes.where((route) => route['estado'] == "en_proceso").toList();
        final rutasFinalizadas = allRoutes.where((route) => route['estado'] == "finalizado").toList();


        if (rutasActivas.isNotEmpty) {
         List<int> idsRutaCargaOfertaActivas = rutasActivas.map((ruta) => int.parse(ruta['id'].toString())).toList();
          //await aceptarYConfirmarPorGrupo(rutasActivas);
;
        }

        List<Map<String, dynamic>> pendingRoutes = await _processRoutes(rutasPendientes, false);

        List<Map<String, dynamic>> finalizedRoutes = await _processRoutes(rutasFinalizadas, true);

        setState(() {
          _routes = pendingRoutes;
          _finalizedRoutes = finalizedRoutes; 
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

Future<List<Map<String, dynamic>>> _processRoutes(
    List<Map<String, dynamic>> routes, bool isFinalized) async {
  Map<int, List<Map<String, dynamic>>> groupedRoutes = {};

  for (var route in routes) {
    final idRutaOferta = int.parse(route['id_ruta_oferta'].toString());
    if (groupedRoutes.containsKey(idRutaOferta)) {
      groupedRoutes[idRutaOferta]!.add(route);
    } else {
      groupedRoutes[idRutaOferta] = [route];
    }
  }

  List<Map<String, dynamic>> detailedRoutes = [];
  for (var group in groupedRoutes.values) {
    List<Map<String, dynamic>> detailsForGroup = [];
    String? fechaRecoleccion;

    for (var route in group) {
      final idCargaOferta = int.parse(route['id_carga_oferta'].toString());
      fechaRecoleccion = route['ruta_oferta']?['fecha_recogida'] ?? 'No disponible';

      final detailsResponse = await http.get(Uri.parse("$urlapi/carga_ofertas/$idCargaOferta/detalle"));
      if (detailsResponse.statusCode == 200) {
        final detailsData = jsonDecode(detailsResponse.body);

        if (detailsData['detalle_carga_oferta'] != null) {
          final detalleCargaOferta = detailsData['detalle_carga_oferta'];

          final Map<String, dynamic> detalle = {
            'id_rutacargaoferta': int.parse(route['id'].toString()),
            'id_rutaoferta': int.parse(route['id_ruta_oferta'].toString()),
            'id_cargaoferta': int.parse(idCargaOferta.toString()),
            'orden': int.parse(route['orden'].toString()),
            'fecha_recogida': fechaRecoleccion,
            'nombre': detalleCargaOferta['oferta_detalle']['produccion']['producto']['nombre'],
            'cantidad': detalleCargaOferta['pesokg'],
            'isRecogidaConfirmed': isFinalized || route['estado'] == "finalizado",
          };

          detailsForGroup.add(detalle);
        }
      } else {
        debugPrint("Error al obtener detalles de carga oferta: ${detailsResponse.statusCode}");
      }
    }

    if (detailsForGroup.isNotEmpty) {
      detailedRoutes.add({
        'id_rutaoferta': group.first['id_ruta_oferta'], 
        'fecha_recogida': fechaRecoleccion,
        'detalles': detailsForGroup,
      });
    }
  }

  return detailedRoutes;
}



List<int> obtenerIdsRutaCargaOferta(List<Map<String, dynamic>> rutas) {
  List<int> idsRutaCargaOferta = [];

  for (var ruta in rutas) {
    if (ruta['detalles'] != null && ruta['detalles'] is List) {
      final detalles = List<Map<String, dynamic>>.from(ruta['detalles']);
      for (var detalle in detalles) {
        if (detalle['id_rutacargaoferta'] != null) {
          idsRutaCargaOferta.add(detalle['id_rutacargaoferta']);
        }
      }
    }
  }

  return idsRutaCargaOferta;
}

Future<void> aceptarYConfirmarPorGrupo(List<Map<String, dynamic>> rutasCargaOferta) async {
  Map<int, List<int>> rutasPorGrupo = {};
  
  for (var ruta in rutasCargaOferta) {
    int idRutaOferta = int.parse(ruta['id_ruta_oferta'].toString());
    int idRutaCargaOferta = int.parse(ruta['id'].toString());

    if (!rutasPorGrupo.containsKey(idRutaOferta)) {
      rutasPorGrupo[idRutaOferta] = [];
    }
    rutasPorGrupo[idRutaOferta]!.add(idRutaCargaOferta);
  }

  for (var entry in rutasPorGrupo.entries) {
    int idRutaOferta = entry.key;
    List<int> idsRutaCargaOferta = entry.value;

    print("Procesando rutas para Ruta Oferta ID: $idRutaOferta con IDs Carga Oferta: $idsRutaCargaOferta");

    bool aceptada = await aceptarRecogida(idRutaOferta);
    if (!aceptada) {
      debugPrint("Error al aceptar Ruta Oferta ID: $idRutaOferta");
      continue;
    }

    for (int idRutaCargaOferta in idsRutaCargaOferta) {
      bool confirmada = await confirmarRecogida(idRutaCargaOferta);
      if (!confirmada) {
        debugPrint("Error al confirmar recogida para ID: $idRutaCargaOferta en Ruta Oferta ID: $idRutaOferta");
      }
    }
  }
}


Future<void> aceptarTodasRutasCargaOferta(List<int> idsRutaCargaOferta) async {
  for (int id in idsRutaCargaOferta) {
    bool success = await confirmarRecogida(id);
    if (!success) {
      debugPrint("Error al confirmar recogida para ID: $id");
    } else {
      debugPrint("Recogida confirmada para ID: $id");
    }
  }
}


Future<bool> finalizarRecogida(int idRutaCargaOferta) async {
  final url = "$urlapi/ruta_carga_ofertas/$idRutaCargaOferta/terminar";

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
      print("Recogida finalizada exitosamente para la ruta carga oferta $idRutaCargaOferta");
      return true; 
    } else {
      print("Error al terminar la recogida: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");
      return false; 
    }
  } catch (e) {
    print("Error en la solicitud PUT: $e");
    return false; 
  }
}

List<int> obtenerIdsRutaCargaOfertaDeRutaGroup(Map<String, dynamic> rutaGroup) {
  if (rutaGroup['detalles'] != null && rutaGroup['detalles'] is List) {
    return List<Map<String, dynamic>>.from(rutaGroup['detalles'])
        .map((detalle) => detalle['id_rutacargaoferta'] as int)
        .toList();
  }
  return [];
}


Future<void> aceptarYConfirmarTodasRutasCargaOferta(List<int> idsRutaCargaOferta) async {
  for (int id in idsRutaCargaOferta) {
    bool aceptada = await aceptarRecogida(id);
    if (!aceptada) {
      debugPrint("Error al aceptar recogida para ID: $id");
      continue; 
    } else {
      debugPrint("Recogida aceptada para ID: $id");
    }

    bool confirmada = await confirmarRecogida(id);
    if (!confirmada) {
      debugPrint("Error al confirmar recogida para ID: $id");
    } else {
      debugPrint("Recogida confirmada para ID: $id");
    }
  }
}

Future<bool> aceptarRecogida(int idRutaOferta) async {
  final url = "$urlapi/ruta_ofertas/$idRutaOferta/aceptar"; 

  int? conductorId = obteneridconductor();
  if (conductorId == null) {
    print("Error: ID del conductor es nulo");
    return false;
  }

  final body = jsonEncode({
    "id_conductor": conductorId,
  });

  try {
    print("Procesando aceptación para ID Ruta Oferta: $idRutaOferta");
    print("Datos enviados para aceptar recogida: $body");
    print("URL solicitada: $url");

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print("Ruta aceptada exitosamente para ID Ruta Oferta: $idRutaOferta");
      return true;
    } else {
      print("Error al aceptar la ruta: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error en la solicitud PUT para aceptar: $e");
    return false;
  }
}




Future<bool> confirmarRecogida(int idRutaCargaOferta) async {
  final url = "$urlapi/ruta_carga_ofertas/$idRutaCargaOferta/confirmar-recogida";
print("servicio para confirmar: $url");
  int? conductorId = obteneridconductor();
  if (conductorId == null) {
    print("Error: ID del conductor es nulo");
    return false;
  }

  final body = jsonEncode({
    "id_conductor": conductorId,
  });

  try {
    print("Datos enviados para confirmar recogida: $body");

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      print("Recogida confirmada exitosamente");
      return true; 
    } else {
      print("Error al confirmar la recogida: ${response.statusCode}");
      print("Respuesta del servidor: ${response.body}");
      return false; 
    }
  } catch (e) {
    print("Error en la solicitud PUT para confirmar: $e");
    return false; 
  }
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
    List<String> coordenadasRuta = []; 
    String latConductor = '';
    String lonConductor = '';
    
    final idRutaOferta = rutaGroup['id_rutaoferta'];
    
    final response = await http.get(Uri.parse("$urlapi/ruta_ofertas/$idRutaOferta/puntos-ruta"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['puntos_ruta'] != null) {
        for (var punto in data['puntos_ruta']) {
          if (punto['tipo'] == 'carga') {
            coordenadasRuta.add('${punto['lat']},${punto['lon']}');
          } else if (punto['tipo'] == 'punto_acopio') {
            latConductor = punto['lat'].toString();
            lonConductor = punto['lon'].toString();
          }
        }
      }

      String ubicacionConductor = await obtenerUbicacionConductor();
      String rutaUrl = 'https://www.google.com/maps/dir/?api=1';
      rutaUrl += '&origin=$ubicacionConductor';
      for (var punto in coordenadasRuta) {
        rutaUrl += '&waypoints=$punto';
      }
      if (latConductor.isNotEmpty && lonConductor.isNotEmpty) {
        rutaUrl += '&destination=$latConductor,$lonConductor';
      }
      print('Ruta de Google Maps: $rutaUrl');
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

   Future<String?> getConductorTipo(int conductorId) async {
  final url = Uri.parse('$urlapi/conductores/$conductorId');
  debugPrint("URL para obtener detalles del conductor: $url");
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final tipo = data['tipo'];
      debugPrint("Tipo del conductor obtenido: $tipo");
      return tipo;
    } else {
      debugPrint("Error al obtener detalles del conductor:");
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");
      return null;
    }
  } catch (e) {
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
      final tipo = await getConductorTipo(conductorId);
      if (tipo == null) {
        debugPrint("No se pudo obtener el tipo del conductor.");
        _showError("Error obteniendo información del conductor.");
        return;
      }
      debugPrint("Tipo del conductor: $tipo");
      final response = await _apiService.updateToken2(conductorId, null, tipo);

      if (response.statusCode == 200) {
        debugPrint("Token eliminado correctamente del servidor.");
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
      title: const Text("Gestión de Rutas"),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: AnimatedRotation(
              turns: _iconRotation,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.menu),
            ),
            onPressed: () => _toggleDrawer(context),
          );
        },
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              // Sección de Rutas Pendientes
              if (_routes.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Rutas Pendientes",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true, 
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _routes.length,
                  itemBuilder: (context, index) {
                    final ruta = _routes[index];
                    final idRutaOferta = ruta['id_rutaoferta'];
                    final fechaRecoleccion = ruta['fecha_recogida'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.pending, color: Colors.orange),
                        title: Text("Ruta en proceso"),
                        subtitle: Text("Fecha de Recolección: $fechaRecoleccion"),
                        onTap: () {
                          _showRutaDetailsDialog(context, ruta);
                        },
                      ),
                    );
                  },
                ),
              ],
              // Sección de Rutas Finalizadas
              if (_finalizedRoutes.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Rutas Finalizadas",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _finalizedRoutes.length,
                  itemBuilder: (context, index) {
                    final ruta = _finalizedRoutes[index];
                    final idRutaOferta = ruta['id_rutaoferta'];
                    final fechaRecoleccion = ruta['fecha_recogida'];

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.green),
                        title: Text("Ruta Finalizada"),
                        subtitle: Text("Fecha de Recolección: $fechaRecoleccion"),
                        onTap: () {
                          _showRutaDetailsDialog(context, ruta);
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    ),
    drawer: Drawer(
      backgroundColor: Colors.black.withOpacity(0.7),
      child: Column(
        children: [
          const SizedBox(height: 50),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.red),
            title: const Text('Perfil', style: TextStyle(color: Colors.white)),
            onTap: _navigateToProfile,
          ),
          const Divider(color: Colors.white),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
            onTap: _logout,
          ),
        ],
      ),
    ),
  );
}


void _navigateToProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
  );
}

void _navigateToPedidosOfertas() {
  Navigator.push(
    context,
    MaterialPageRoute(
      // builder: (context) => RutasScreen(),
      builder: (context) => ListaRutaScreen(),
    ),
  );
}




}