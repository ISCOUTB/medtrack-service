class Medication {
  final int id;
  final int usuarioId;
  final String nombre;
  final String dosis;
  final String frecuencia;
  final String? notas;

  Medication({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    this.notas,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      dosis: json['dosis'],
      frecuencia: json['frecuencia'],
      notas: json['notas'],
    );
  }
}
