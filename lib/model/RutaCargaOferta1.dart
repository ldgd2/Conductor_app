import 'package:latlong2/latlong.dart' as latLngLib;
import 'package:conductor_app/model/RutaOferta.dart';
class RutaCargaOferta {
  final int? id;
  final int? idCargaOferta;
  final int? idRutaOferta;
  final int? idTransporte;
  final String estadoConductor;
  final int orden;
  final int cantidad;
  final String estado;
  final double distancia;
  final RutaOferta rutaOferta;

  RutaCargaOferta({
    this.id,
    this.idCargaOferta,
    this.idRutaOferta,
    this.idTransporte,
    required this.estadoConductor,
    required this.orden,
    required this.cantidad,
    required this.estado,
    required this.distancia,
    required this.rutaOferta,
  });

  factory RutaCargaOferta.fromJson(Map<String, dynamic> json) {
  return RutaCargaOferta(
    id: json['id'],
    idCargaOferta: json['id_carga_oferta'],
    idRutaOferta: json['id_ruta_oferta'], 
    idTransporte: json['id_transporte'],
    estadoConductor: json['estado_conductor'] ?? "pendiente", // Valor por defecto
    orden: json['orden'] ?? 0, // Valor por defecto
    cantidad: int.tryParse(json['cantidad'].toString()) ?? 0, // Convertir cantidad a entero
    estado: json['estado'] ?? "pendiente", // Valor por defecto
    distancia: _parseDistancia(json['distancia']),
    rutaOferta: RutaOferta.fromJson(json['ruta_oferta']),
  );
}



  // Método auxiliar para manejar el parsing de 'distancia'
  static double _parseDistancia(dynamic distancia) {
    if (distancia is String) {
      return double.tryParse(distancia) ?? 0.0;
    }
    return distancia is num ? distancia.toDouble() : 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_carga_oferta': idCargaOferta,
      'id_ruta_oferta': idRutaOferta,
      'id_transporte': idTransporte,
      'estado_conductor': estadoConductor,
      'orden': orden,
      'cantidad': cantidad,
      'estado': estado,
      'distancia': distancia,
      'ruta_oferta': rutaOferta.toJson(),
    };
  }
}
