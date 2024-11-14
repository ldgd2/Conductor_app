// lib/model/agricultor.dart

class Agricultor {
  final int? id; // Es nullable porque no lo necesitamos al crear un nuevo agricultor
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String direccion;
  final String password;
  final String informacionBancaria;
  final String nit;
  final String carnet;
  final String licenciaFuncionamiento;
  final String estado;

  // Constructor
  Agricultor({
    this.id,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.direccion,
    required this.password,
    required this.informacionBancaria,
    required this.nit,
    required this.carnet,
    required this.licenciaFuncionamiento,
    required this.estado,
  });

  // Método para convertir JSON a un objeto Agricultor
  factory Agricultor.fromJson(Map<String, dynamic> json) {
    return Agricultor(
      id: json['id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      email: json['email'],
      direccion: json['direccion'],
      password: json['password'],
      informacionBancaria: json['informacion_bancaria'],
      nit: json['nit'],
      carnet: json['carnet'],
      licenciaFuncionamiento: json['licencia_funcionamiento'],
      estado: json['estado'],
    );
  }

  // Método para convertir un objeto Agricultor a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'password': password,
      'informacion_bancaria': informacionBancaria,
      'nit': nit,
      'carnet': carnet,
      'licencia_funcionamiento': licenciaFuncionamiento,
      'estado': estado,
    };
  }
}
