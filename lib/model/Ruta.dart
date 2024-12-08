class RutaCargaOferta {
  final int idRutaOferta;
  final String fechaRecogida;
  final List<Map<String, dynamic>> detalles;
  final double totalCantidad;

  RutaCargaOferta({
    required this.idRutaOferta,
    required this.fechaRecogida,
    required this.detalles,
    required this.totalCantidad,
  });

  factory RutaCargaOferta.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> detalles = [];
    double totalCantidad = 0;

    if (json['detalles'] != null) {
      detalles = List<Map<String, dynamic>>.from(json['detalles']);
      for (var detalle in detalles) {
        totalCantidad += detalle['cantidad'] ?? 0;
      }
    }

    return RutaCargaOferta(
      idRutaOferta: json['id_rutaoferta'],
      fechaRecogida: json['fecha_recogida'] ?? 'No disponible',
      detalles: detalles,
      totalCantidad: totalCantidad,
    );
  }
}
