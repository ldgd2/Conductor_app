// lib/model/transporte.dart

class Transporte {
  final int? id; // El ID es opcional ya que solo es necesario cuando el transporte existe
  final int idConductor;
  final int capacidadMaxKg;
  final String marca;
  final String modelo;
  final String placa;

  // Constructor
  Transporte({
    this.id,
    required this.idConductor,
    required this.capacidadMaxKg,
    required this.marca,
    required this.modelo,
    required this.placa,
  });

  // Método para crear un objeto Transporte a partir de JSON
  factory Transporte.fromJson(Map<String, dynamic> json) {
    return Transporte(
      id: json['id'],
      idConductor: json['id_conductor'],
      capacidadMaxKg: json['capacidadmaxkg'],
      marca: json['marca'],
      modelo: json['modelo'],
      placa: json['placa'],
    );
  }

  // Método para convertir un objeto Transporte a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_conductor': idConductor,
      'capacidadmaxkg': capacidadMaxKg,
      'marca': marca,
      'modelo': modelo,
      'placa': placa,
    };
  }
}
