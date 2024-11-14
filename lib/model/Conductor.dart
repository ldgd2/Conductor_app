// lib/model/conductor.dart

class Conductor {
  final int? id; // ID opcional, solo necesario cuando ya existe en la base de datos
  final String nombre;
  final String apellido;
  final String carnet;
  final String licenciaConducir;
  final DateTime fechaNacimiento;
  final String direccion;
  final String email;
  final String password;
  final double ubicacionLatitud;
  final double ubicacionLongitud;
  final String estado;

  // Constructor
  Conductor({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.carnet,
    required this.licenciaConducir,
    required this.fechaNacimiento,
    required this.direccion,
    required this.email,
    required this.password,
    required this.ubicacionLatitud,
    required this.ubicacionLongitud,
    required this.estado,
  });

  // Método para crear un objeto Conductor a partir de JSON
  factory Conductor.fromJson(Map<String, dynamic> json) {
    return Conductor(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      carnet: json['carnet'],
      licenciaConducir: json['licencia_conducir'],
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento']),
      direccion: json['direccion'],
      email: json['email'],
      password: json['password'],
      ubicacionLatitud: json['ubicacion_latitud'],
      ubicacionLongitud: json['ubicacion_longitud'],
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto Conductor a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'carnet': carnet,
      'licencia_conducir': licenciaConducir,
      'fecha_nacimiento': fechaNacimiento.toIso8601String(),
      'direccion': direccion,
      'email': email,
      'password': password,
      'ubicacion_latitud': ubicacionLatitud,
      'ubicacion_longitud': ubicacionLongitud,
      'estado': estado,
    };
  }
}
