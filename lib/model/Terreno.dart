// lib/model/terreno.dart

class Terreno {
  final int? id; // El ID es opcional ya que solo es necesario para terrenos existentes
  final int idAgricultor;
  final String descripcion;
  final double area;
  final double superficieTotal;
  final double ubicacionLatitud;
  final double ubicacionLongitud;

  // Constructor
  Terreno({
    this.id,
    required this.idAgricultor,
    required this.descripcion,
    required this.area,
    required this.superficieTotal,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
  });

  // Método para crear un objeto Terreno a partir de JSON
  factory Terreno.fromJson(Map<String, dynamic> json) {
    return Terreno(
      id: json['id'],
      idAgricultor: json['id_agricultor'],
      descripcion: json['descripcion'],
      area: (json['area'] as num).toDouble(),
      superficieTotal: (json['superficie_total'] as num).toDouble(),
      ubicacionLatitud: (json['ubicacion_latitud'] as num).toDouble(),
      ubicacionLongitud: (json['ubicacion_longitud'] as num).toDouble(),
    );
  }

  // Método para convertir un objeto Terreno a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_agricultor': idAgricultor,
      'descripcion': descripcion,
      'area': area,
      'superficie_total': superficieTotal,
      'ubicacion_latitud': ubicacionLatitud,
      'ubicacion_longitud': ubicacionLongitud,
    };
  }
}
