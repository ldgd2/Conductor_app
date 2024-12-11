
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
import 'package:conductor_app/screen/RutaScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
    // Asegúrate de tener la URL correcta
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _routes = [];
 

  Map<int, Set<int>> productosSeleccionadosPorRuta = {};  // {idRuta: {idProducto}}

  late AnimationController _animationController;

  double _iconRotation = 0.0; // Ángulo de rotación para el ícono

  // Función para abrir/cerrar el panel



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
    Scaffold.of(context).openDrawer(); // Abre el Drawer
    setState(() {
      _iconRotation = _iconRotation == 0.0 ? 0.5 : 0.0; // Rota 90 grados al abrir
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


void _showRutaDetailsDialog(BuildContext context, Map<String, dynamic> rutaGroup) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Lista para almacenar los detalles de cada ruta
      List<Map<String, dynamic>> detalles = List<Map<String, dynamic>>.from(rutaGroup['detalles']);
      
      return AlertDialog(
        title: Text('Detalles de Ruta Oferta ${rutaGroup['id_rutaoferta']}'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: detalles.map<Widget>((detalle) {
                  // Obtener el estado del checkbox (si ya fue confirmado)
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
                            value: isChecked,
                            activeColor: Colors.green, // Cambia el color cuando esté marcado
                            onChanged: (bool? value) async {
                              if (value != null && value) {
                                int idRutaCargaOferta = detalle['id_rutacargaoferta']; // Asume que tienes el id
                                
                                // Llamar a la función para confirmar la recogida
                                bool success = await confirmarRecogida(idRutaCargaOferta);

                                if (success) {
                                  // Solo actualizar el estado si la confirmación fue exitosa
                                  setState(() {
                                    detalle['isRecogidaConfirmed'] = true; // Marcar como confirmada
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error al confirmar la recogida"))
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
      print("Recogida confirmada exitosamente");
      return true; // Indica que la confirmación fue exitosa
    } else {
      print("Error al confirmar la recogida: ${response.statusCode}");
      return false; // Indica que hubo un error
    }
  } catch (e) {
    print("Error en la solicitud PUT: $e");
    return false; // Si ocurre un error en la solicitud
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





Future<void> _navegarARutaScreen(BuildContext context, Map<String, dynamic> rutaGroup) async {
  try {
    final idRutaOferta = rutaGroup['id_rutaoferta'];

    // Llama a la API para obtener el estado
    final response = await http.get(Uri.parse("$urlapi/ruta_ofertas/$idRutaOferta"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final estado = data['estado'];

      // Verificar si la ruta es válida para navegación
      if (estado == 'activo' || estado == 'en_proceso' || estado == 'finalizado') {
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
              idRutaOferta: idRutaOferta,
              estadoRuta: estado, // Pasar el estado al widget RutaScreen
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Ruta no válida para navegación")),
        );
      }
    } else {
      throw Exception("Error al verificar el estado de la ruta: ${response.statusCode}");
    }
  } catch (e) {
    print("Error al navegar a RutaScreen: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error al cargar los detalles de la ruta")),
    );
  }
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
              duration: const Duration(milliseconds: 300), // Tiempo para la animación
              child: const Icon(Icons.menu),
            ),
            onPressed: () => _toggleDrawer(context), // Abre el drawer al hacer click
          );
        },
      ),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             const  Text(
                'Gestión de Rutas',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // Aquí va la sección de "Rutas Disponibles"
              InkWell(
                onTap: _navigateToPedidosOfertas,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppThemes.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Alinear todo a la izquierda
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinea el texto y el ícono en los extremos
                        children: [
                          // Texto de Rutas Disponibles
                          Text(
                            'Rutas Disponibles',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Icono de etiqueta
                          Icon(Icons.add_location_alt, color: Colors.red),
                        ],
                      ),
                      SizedBox(height: 8), // Espaciado entre las dos líneas
                      // Texto adicional debajo
                      Text(
                        'Ve y acepta una',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Aquí está la lista de rutas
        Expanded(
          child: _routes.isEmpty
              ? const Center(child: Text("No hay rutas disponibles"))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinea el texto a la izquierda
                  children: [
                    // Título "Rutas Aceptadas"
                   const  Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Rutas Aceptadas",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red, // Puedes personalizar el color si lo deseas
                        ),
                      ),
                    ),
                    // Listado de rutas
                    Expanded(
                      child: ListView.builder(
                        itemCount: _routes.length,
                        itemBuilder: (context, index) {
                          final ruta = _routes[index];
                          final idRutaOferta = ruta['id_rutaoferta'];
                          final fechaRecoleccion = ruta['fecha_recogida'];

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.map, color: Colors.red),
                              title: Text("Ruta Oferta ID: $idRutaOferta"),
                              subtitle: Text("Fecha de Recolección: $fechaRecoleccion"),
                              onTap: () {
                               _navegarARutaScreen(context, ruta);
                               // _showRutaDetailsDialog(context, ruta);
                              },
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
    // Drawer Panel
    drawer: Drawer(
      backgroundColor: Colors.black.withOpacity(0.7), // Fondo oscuro y transparente
      child: Column(
        children: [
          const SizedBox(height: 50), // Espaciado para el encabezado del panel
          ListTile(
            leading: const Icon(Icons.person, color: Colors.red),
            title: const Text(
              'Perfil',
              style: TextStyle(color: Colors.white),
            ),
            onTap: _navigateToProfile,
          ),
          const Divider(color: Colors.white), // Línea divisoria
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
            onTap: _logout,
          ),
        ],
      ),
    ),
  );
}

// Función para redirigir al perfil
void _navigateToProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ProfileScreen()),
  );
}

// Función para redirigir a la pantalla de pedidos/ofertas
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