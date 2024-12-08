import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latLngLib;

class SavePoints {
  static const String _storageKey = 'saved_routes';

  /// Guarda una ruta en el almacenamiento local
  static Future<void> saveRoute(int id, List<latLngLib.LatLng> points) async {
  final prefs = await SharedPreferences.getInstance();

  // Cargar las rutas existentes
  final storedData = prefs.getString(_storageKey) ?? "[]";
  final List<dynamic> rutas = jsonDecode(storedData);

  // Buscar ruta con el mismo ID
  final existingRouteIndex = rutas.indexWhere((ruta) => ruta['id'] == id);

  if (existingRouteIndex != -1) {
    // Actualizar ruta existente
    rutas[existingRouteIndex]['coordinates'] = points
        .map((point) => {'lat': point.latitude, 'lon': point.longitude})
        .toList();
  } else {
    // Agregar nueva ruta
    rutas.add({
      'id': id,
      'coordinates': points
          .map((point) => {'lat': point.latitude, 'lon': point.longitude})
          .toList(),
    });
  }

  // Guardar los datos actualizados
  await prefs.setString(_storageKey, jsonEncode(rutas));
  print("Ruta con ID $id guardada exitosamente.");
}


  /// Carga una ruta desde el almacenamiento local por su ID
  static Future<List<latLngLib.LatLng>> loadRoute(int id) async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar las rutas existentes
    final storedData = prefs.getString(_storageKey) ?? "[]";
    final List<dynamic> rutas = jsonDecode(storedData);

    // Buscar la ruta por ID
    final ruta = rutas.firstWhere(
      (ruta) => ruta['id'] == id,
      orElse: () => null,
    );

    if (ruta == null) {
      print("No se encontró una ruta para el ID $id en SavePoints.");
      return [];
    }

    // Convertir las coordenadas a objetos `latLngLib.LatLng`
    final List<dynamic> coordinates = ruta['coordinates'] ?? [];
    return coordinates
        .map((coord) => latLngLib.LatLng(coord['lat'], coord['lon']))
        .toList();
  }

  /// Carga todas las rutas almacenadas
  static Future<Map<int, List<latLngLib.LatLng>>> loadAllRoutes() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar las rutas existentes
    final storedData = prefs.getString(_storageKey) ?? "[]";
    final List<dynamic> rutas = jsonDecode(storedData);

    // Convertir las rutas a un mapa
    final Map<int, List<latLngLib.LatLng>> allRoutes = {};
    for (var ruta in rutas) {
      final int id = ruta['id'];
      final List<dynamic> coordinates = ruta['coordinates'] ?? [];
      allRoutes[id] = coordinates
          .map((coord) => latLngLib.LatLng(coord['lat'], coord['lon']))
          .toList();
    }

    return allRoutes;
  }

  /// Elimina una ruta por su ID
  static Future<void> deleteRoute(int id) async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar las rutas existentes
    final storedData = prefs.getString(_storageKey) ?? "[]";
    final List<dynamic> rutas = jsonDecode(storedData);

    // Remover la ruta con el ID especificado
    rutas.removeWhere((ruta) => ruta['id'] == id);

    // Guardar los datos actualizados
    await prefs.setString(_storageKey, jsonEncode(rutas));
    print("Ruta con ID $id eliminada de SavePoints.");
  }
}
