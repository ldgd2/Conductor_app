import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:conductor_app/config/config.dart';
class ApiService {
  final String _baseUrl = urlapi; // URL base definida en config.dart

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Métodos genéricos de solicitud
 Future<http.Response> _get(String endpoint) async {
    try {
      final url = Uri.parse("$_baseUrl/$endpoint");
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }


  Future<http.Response> _post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$_baseUrl/$endpoint");
    return await http.post(url, headers: _headers, body: jsonEncode(data));
  }

  Future<http.Response> _put(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$_baseUrl/$endpoint");
    return await http.put(url, headers: _headers, body: jsonEncode(data));
  }

  Future<http.Response> _delete(String endpoint) async {
    final url = Uri.parse("$_baseUrl/$endpoint");
    return await http.delete(url, headers: _headers);
  }

  // 1. ConductorController
Future<List<dynamic>> getAllConductores() async {
  final response = await _get("conductores");
  final decodedResponse = jsonDecode(response.body);
  
  if (decodedResponse is List<dynamic>) {
    return decodedResponse;
  } else if (decodedResponse is Map<String, dynamic>) {
    // Si la respuesta es un objeto, verifica si contiene una lista
    if (decodedResponse.containsKey('data') && decodedResponse['data'] is List) {
      return decodedResponse['data'] as List<dynamic>;
    } else {
      throw Exception("La respuesta no contiene una lista válida de conductores.");
    }
  } else {
    throw Exception("Formato inesperado en la respuesta del servidor.");
  }
}

  Future<http.Response> getAllRutasOfertaconductor(int id) => _get("conductores/$id/rutas-carga-ofertas");


  Future<http.Response> createConductor(Map<String, dynamic> data) => _post("conductores", data);
  Future<http.Response> getConductorById(int id) => _get("conductores/$id");
  Future<http.Response> updateConductor(int id, Map<String, dynamic> data) => _put("conductores/$id", data);
  Future<http.Response> deleteConductor(int id) => _delete("conductores/$id");
  Future<http.Response> getTransportesByConductor(int id) => _get("conductores/$id/transportes");
//actualizar token cinductor
Future<http.Response> updateToken(int conductorId, String token, String tipo) async {
  try {
    final url = Uri.parse("$urlapi/conductores/$conductorId");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tokendevice": token,
        "tipo": tipo, // Agregado al cuerpo de la solicitud
      }),
      
    );
    //debugPrint("Respuesta del servidor: ${response.statusCode}, ${response.body}");
    
    if (response.statusCode != 200) {
      throw Exception("Error en la actualización del token: ${response.body}");
    }

    return response;
  } catch (e) {
   // debugPrint("Error al actualizar token: $e");
    throw Exception("Error actualizando token: $e");
  }
}

Future<http.Response> updateToken2(int conductorId, String? token, String tipo) async {
  try {
    final url = Uri.parse("$urlapi/conductores/$conductorId");
    debugPrint("URL para actualizar token: $url");
    debugPrint("Payload: ${jsonEncode({"tokendevice": token, "tipo": tipo})}");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "tokendevice": token,
        "tipo": tipo,
      }),
    );

    return response;
  } catch (e) {
    debugPrint("Error al actualizar el token: $e");
    rethrow;
  }
}

Future<String> getTipoConductorById(int conductorId) async {
  try {
    final url = Uri.parse("$_baseUrl/conductores/$conductorId");
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['tipo'] ?? "default_tipo"; // Retorna el tipo o un valor por defecto
    } else {
      throw Exception("Error al obtener el tipo de conductor: ${response.statusCode}, ${response.body}");
    }
  } catch (e) {
    throw Exception("Error al obtener el tipo de conductor: $e");
  }
}





  // 2. AgricultorController
  Future<http.Response> getAllAgricultores() => _get("agricultors");
  Future<http.Response> createAgricultor(Map<String, dynamic> data) => _post("agricultors", data);
  Future<http.Response> getAgricultorById(int id) => _get("agricultors/$id");
  Future<http.Response> updateAgricultor(int id, Map<String, dynamic> data) => _put("agricultors/$id", data);
  Future<http.Response> deleteAgricultor(int id) => _delete("agricultors/$id");
  Future<http.Response> getTerrenosByAgricultor(int id) => _get("agricultors/$id/terrenos");
  Future<http.Response> getProduccionesByAgricultor(int id) => _get("agricultors/$id/producciones");

  // 3. ClienteController
  Future<http.Response> getAllClientes() => _get("clientes");
  Future<http.Response> createCliente(Map<String, dynamic> data) => _post("clientes", data);
  Future<http.Response> getClienteById(int id) => _get("clientes/$id");
  Future<http.Response> updateCliente(int id, Map<String, dynamic> data) => _put("clientes/$id", data);
  Future<http.Response> deleteCliente(int id) => _delete("clientes/$id");
  Future<http.Response> getPedidosByCliente(int id) => _get("clientes/$id/pedidos");

  // 4. TemporadaController
  Future<http.Response> getAllTemporadas() => _get("temporadas");
  Future<http.Response> createTemporada(Map<String, dynamic> data) => _post("temporadas", data);
  Future<http.Response> getTemporadaById(int id) => _get("temporadas/$id");
  Future<http.Response> updateTemporada(int id, Map<String, dynamic> data) => _put("temporadas/$id", data);
  Future<http.Response> deleteTemporada(int id) => _delete("temporadas/$id");
  Future<http.Response> getProduccionesByTemporada(int id) => _get("temporadas/$id/producciones");

  // 5. CategoriaController
  Future<http.Response> getAllCategorias() => _get("categorias");
  Future<http.Response> createCategoria(Map<String, dynamic> data) => _post("categorias", data);
  Future<http.Response> getCategoriaById(int id) => _get("categorias/$id");
  Future<http.Response> updateCategoria(int id, Map<String, dynamic> data) => _put("categorias/$id", data);
  Future<http.Response> deleteCategoria(int id) => _delete("categorias/$id");
  Future<http.Response> getProductosByCategoria(int id) => _get("categorias/$id/productos");

  // 6. TransporteController
  Future<http.Response> getAllTransportes() => _get("transportes");
  Future<http.Response> createTransporte(Map<String, dynamic> data) => _post("transportes", data);
  Future<http.Response> getTransporteById(int id) => _get("transportes/$id");
  Future<http.Response> updateTransporte(int id, Map<String, dynamic> data) => _put("transportes/$id", data);
  Future<http.Response> deleteTransporte(int id) => _delete("transportes/$id");
  Future<http.Response> getTransportesByConductorTrans(int conductorId) => _get("conductores/$conductorId/transportes");
  Future<http.Response> searchTransportesByCapacity(double min, double max) => _get("transportes/buscar?min=$min&max=$max");

  // 7. ProductoController
  Future<http.Response> getAllProductos() => _get("productos");
  Future<http.Response> createProducto(Map<String, dynamic> data) => _post("productos", data);
  Future<http.Response> getProductoById(int id) => _get("productos/$id");
  Future<http.Response> updateProducto(int id, Map<String, dynamic> data) => _put("productos/$id", data);
  Future<http.Response> deleteProducto(int id) => _delete("productos/$id");
  Future<http.Response> getProduccionesByProducto(int id) => _get("productos/$id/producciones");

  // 8. TerrenoController
  Future<http.Response> getAllTerrenos() => _get("terrenos");
  Future<http.Response> createTerreno(Map<String, dynamic> data) => _post("terrenos", data);
  Future<http.Response> getTerrenoById(int id) => _get("terrenos/$id");
  Future<http.Response> updateTerreno(int id, Map<String, dynamic> data) => _put("terrenos/$id", data);
  Future<http.Response> deleteTerreno(int id) => _delete("terrenos/$id");
  Future<http.Response> getProduccionesByTerreno(int id) => _get("terrenos/$id/producciones");

  // 9. UnidadMedidaController
  Future<http.Response> getAllUnidadMedidas() => _get("unidad_medidas");
  Future<http.Response> createUnidadMedida(Map<String, dynamic> data) => _post("unidad_medidas", data);
  Future<http.Response> getUnidadMedidaById(int id) => _get("unidad_medidas/$id");
  Future<http.Response> updateUnidadMedida(int id, Map<String, dynamic> data) => _put("unidad_medidas/$id", data);
  Future<http.Response> deleteUnidadMedida(int id) => _delete("unidad_medidas/$id");

  // 10. MonedaController
  Future<http.Response> getAllMonedas() => _get("monedas");
  Future<http.Response> createMoneda(Map<String, dynamic> data) => _post("monedas", data);
  Future<http.Response> getMonedaById(int id) => _get("monedas/$id");
  Future<http.Response> updateMoneda(int id, Map<String, dynamic> data) => _put("monedas/$id", data);
  Future<http.Response> deleteMoneda(int id) => _delete("monedas/$id");

  // 11. PedidoController
  Future<http.Response> getAllPedidos() => _get("pedidos");
  Future<http.Response> createPedido(Map<String, dynamic> data) => _post("pedidos", data);
  Future<http.Response> getPedidoById(int id) => _get("pedidos/$id");
  Future<http.Response> updatePedido(int id, Map<String, dynamic> data) => _put("pedidos/$id", data);
  Future<http.Response> deletePedido(int id) => _delete("pedidos/$id");
  Future<http.Response> getDetallesByPedido(int id) => _get("pedidos/$id/detalles");
  Future<http.Response> getPedidosByEstado(String estado) => _get("pedidos/estado/$estado");
  Future<http.Response> updateEstadoBatch(Map<String, dynamic> data) => _put("pedidos/estado/batch", data);
  Future<http.Response> getPedidosByClientePedido(int clienteId) => _get("pedidos/cliente/$clienteId");
  Future<http.Response> getPedidosByFecha(String fecha) => _get("pedidos/fecha/$fecha");

  // 12. PedidoDetalleController
  Future<http.Response> getAllPedidoDetalles() => _get("pedido_detalles");
  Future<http.Response> createPedidoDetalle(Map<String, dynamic> data) => _post("pedido_detalles", data);
  Future<http.Response> getPedidoDetalleById(int id) => _get("pedido_detalles/$id");
  Future<http.Response> updatePedidoDetalle(int id, Map<String, dynamic> data) => _put("pedido_detalles/$id", data);
  Future<http.Response> deletePedidoDetalle(int id) => _delete("pedido_detalles/$id");
  Future<http.Response> getCargasByPedidoDetalle(int id) => _get("pedido_detalles/$id/cargas");
  Future<http.Response> getDetallesByProducto(int productoId) => _get("pedido_detalles/producto/$productoId");
  Future<http.Response> updateCantidadBatch(Map<String, dynamic> data) => _put("pedido_detalles/cantidad/batch", data);
  Future<http.Response> getResumenProductos() => _get("pedido_detalles/resumen");
  Future<http.Response> checkAvailability(int id) => _get("pedido_detalles/$id/check_availability");


// 13. ProduccionController
Future<http.Response> getAllProducciones() => _get("producciones");
Future<http.Response> createProduccion(Map<String, dynamic> data) => _post("producciones", data);
Future<http.Response> getProduccionById(int id) => _get("producciones/$id");
Future<http.Response> updateProduccion(int id, Map<String, dynamic> data) => _put("producciones/$id", data);
Future<http.Response> deleteProduccion(int id) => _delete("producciones/$id");
Future<http.Response> getDetallesByProduccion(int id) => _get("producciones/$id/detalles");
Future<http.Response> getProduccionesActivas() => _get("producciones/activas");
Future<http.Response> getProduccionesByTerrenoProdiccion(int terrenoId) => _get("producciones/terreno/$terrenoId");
Future<http.Response> getProduccionesByTemporadaProdiccion(int temporadaId) => _get("producciones/temporada/$temporadaId");
Future<http.Response> getProduccionesByProductoProdiccion(int productoId) => _get("producciones/producto/$productoId");

// 14. OfertaController
Future<http.Response> getAllOfertas() => _get("ofertas");
Future<http.Response> createOferta(Map<String, dynamic> data) => _post("ofertas", data);
Future<http.Response> getOfertaById(int id) => _get("ofertas/$id");
Future<http.Response> updateOferta(int id, Map<String, dynamic> data) => _put("ofertas/$id", data);
Future<http.Response> deleteOferta(int id) => _delete("ofertas/$id");
Future<http.Response> getDetallesByOferta(int id) => _get("ofertas/$id/detalles");
Future<http.Response> getOfertasActivas() => _get("ofertas/activas");
Future<http.Response> getOfertasByProduccion(int produccionId) => _get("ofertas/produccion/$produccionId");
Future<http.Response> extendExpiracion(int id, Map<String, dynamic> data) => _put("ofertas/$id/extend_expiracion", data);

// 15. OfertaDetalleController
Future<http.Response> getAllOfertaDetalles() => _get("oferta_detalles");
Future<http.Response> createOfertaDetalle(Map<String, dynamic> data) => _post("oferta_detalles", data);
Future<http.Response> getOfertaDetalleById(int id) => _get("oferta_detalles/$id");
Future<http.Response> updateOfertaDetalle(int id, Map<String, dynamic> data) => _put("oferta_detalles/$id", data);
Future<http.Response> deleteOfertaDetalle(int id) => _delete("oferta_detalles/$id");
Future<http.Response> getCargasByOfertaDetalle(int id) => _get("oferta_detalles/$id/cargas");
Future<http.Response> checkDisponibilidad(int id) => _get("oferta_detalles/$id/check_disponibilidad");
Future<http.Response> getDetallesByMoneda(int monedaId) => _get("oferta_detalles/moneda/$monedaId");
Future<http.Response> getDetallesByUnidadMedida(int unidadMedidaId) => _get("oferta_detalles/unidad_medida/$unidadMedidaId");

// 16. CargaOfertaController
Future<http.Response> getAllCargasOferta() => _get("carga_ofertas");
Future<http.Response> createCargaOferta(Map<String, dynamic> data) => _post("carga_ofertas", data);
Future<http.Response> getCargaOfertaById(int id) => _get("carga_ofertas/$id");
Future<http.Response> updateCargaOferta(int id, Map<String, dynamic> data) => _put("carga_ofertas/$id", data);
Future<http.Response> deleteCargaOferta(int id) => _delete("carga_ofertas/$id");

// 17. RutaOfertaController

/// Obtener todas las rutas de oferta
Future<http.Response> getAllRutasOferta() => _get("ruta_ofertas");

/// Crear una nueva ruta de oferta
/// [data] es un Map que contiene los datos necesarios para la creación
Future<http.Response> createRutaOferta(Map<String, dynamic> data) => _post("ruta_ofertas", data);

/// Obtener detalles de una ruta de oferta específica
/// [id] es el identificador único de la ruta
Future<Map<String, dynamic>> getRutaOfertaById(int id) async {
  final response = await http.get(Uri.parse('$urlapi/'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Error al obtener detalles de la ruta con ID $id: ${response.statusCode}");
  }
}

/// Actualizar los datos de una ruta de oferta específica
/// [id] es el identificador único de la ruta
/// [data] contiene los nuevos datos para actualizar
Future<http.Response> updateRutaOferta(int id, Map<String, dynamic> data) => _put("ruta_ofertas/$id", data);

/// Eliminar una ruta de oferta
/// [id] es el identificador único de la ruta
Future<http.Response> deleteRutaOferta(int id) => _delete("ruta_ofertas/$id");

/// Obtener puntos de ruta, detalles de recojo y punto de acopio
/// [id] es el identificador único de la ruta
Future<http.Response> getPuntosRutaOferta(int id) => _get("ruta_ofertas/$id/puntos-ruta");

/// Obtener detalles de las cargas asociadas a la ruta de oferta
/// [id] es el identificador único de la ruta
Future<http.Response> getCargasRutaOferta(int id) => _get("ruta_ofertas/$id/cargas");


// 18. RutaCargaOfertaController
Future<http.Response> getAllRutaCargasOferta() => _get("ruta_carga_ofertas");

Future<http.Response> createRutaCargaOferta(Map<String, dynamic> data) => _post("ruta_carga_ofertas", data);

Future<http.Response> getRutaCargaOfertaById(int id) => _get("ruta_carga_ofertas/$id");

Future<http.Response> updateRutaCargaOferta(int id, Map<String, dynamic> data) => _put("ruta_carga_ofertas/$id", data);

Future<http.Response> deleteRutaCargaOferta(int id) => _delete("ruta_carga_ofertas/$id");

// Métodos específicos de la API para actualizar estados
Future<http.Response> aceptarRutaCargaOferta(int id, Map<String, dynamic> data) =>
    _put("ruta_carga_ofertas/$id/aceptar", data);

Future<http.Response> confirmarRecogidaRutaCargaOferta(int id) =>
    _put("ruta_carga_ofertas/$id/confirmar-recogida", {});

Future<http.Response> terminarRutaCargaOferta(int id) =>
    _put("ruta_carga_ofertas/$id/terminar", {});

// Obtener puntos de la ruta
Future<http.Response> getPuntosRutaCargaOferta(int id) => _get("ruta_carga_ofertas/$id/getPuntosRuta");



// 19. CargaPedidoController
Future<http.Response> getAllCargasPedido() => _get("carga_pedidos");
Future<http.Response> createCargaPedido(Map<String, dynamic> data) => _post("carga_pedidos", data);
Future<http.Response> getCargaPedidoById(int id) => _get("carga_pedidos/$id");
Future<http.Response> updateCargaPedido(int id, Map<String, dynamic> data) => _put("carga_pedidos/$id", data);
Future<http.Response> deleteCargaPedido(int id) => _delete("carga_pedidos/$id");

// 20. RutaPedidoController
Future<http.Response> getAllRutasPedido() => _get("ruta_pedidos");
Future<http.Response> createRutaPedido(Map<String, dynamic> data) => _post("ruta_pedidos", data);
Future<http.Response> getRutaPedidoById(int id) => _get("ruta_pedidos/$id");
Future<http.Response> updateRutaPedido(int id, Map<String, dynamic> data) => _put("ruta_pedidos/$id", data);
Future<http.Response> deleteRutaPedido(int id) => _delete("ruta_pedidos/$id");

// 21. RutaCargaPedidoController
Future<http.Response> getAllRutaCargasPedido() => _get("ruta_carga_pedidos");
Future<http.Response> createRutaCargaPedido(Map<String, dynamic> data) => _post("ruta_carga_pedidos", data);
Future<http.Response> getRutaCargaPedidoById(int id) => _get("ruta_carga_pedidos/$id");
Future<http.Response> updateRutaCargaPedido(int id, Map<String, dynamic> data) => _put("ruta_carga_pedidos/$id", data);
Future<http.Response> deleteRutaCargaPedido(int id) => _delete("ruta_carga_pedidos/$id");
}