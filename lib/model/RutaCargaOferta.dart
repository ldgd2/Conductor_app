// lib/model/ruta_carga_oferta.dart

class RutaCargaOferta {
  final int? id; // El ID es opcional, solo necesario para rutas de carga de oferta existentes
  final int idCargaOferta;
  final int idRutaOferta;
  final int idTransporte;
  final int orden;
  final String estado;
  final double distancia;

  // Constructor
  RutaCargaOferta({
    this.id,
    required this.idCargaOferta,
    required this.idRutaOferta,
    required this.idTransporte,
    required this.orden,
    required this.estado,
    required this.distancia,
  });

  // Método para crear un objeto RutaCargaOferta a partir de JSON
  factory RutaCargaOferta.fromJson(Map<String, dynamic> json) {
    return RutaCargaOferta(
      id: json['id'],
      idCargaOferta: json['id_carga_oferta'],
      idRutaOferta: json['id_ruta_oferta'],
      idTransporte: json['id_transporte'],
      orden: json['orden'],
      estado: json['estado'],
      distancia: (json['distancia'] as num).toDouble(),
    );
  }

  // Método para convertir un objeto RutaCargaOferta a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_carga_oferta': idCargaOferta,
      'id_ruta_oferta': idRutaOferta,
      'id_transporte': idTransporte,
      'orden': orden,
      'estado': estado,
      'distancia': distancia,
    };
  }
}
