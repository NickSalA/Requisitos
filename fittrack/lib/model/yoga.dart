import 'reto.dart';

class Yoga extends Reto {
  int duracion;
  Yoga({
    required int id,
    required String nombre,
    required String descripcion,
    required String imagenPath,
    required String tipo,
    required this.duracion,
    required DateTime fechaCreacion,
  }) : super(
          id,
          nombre,
          descripcion,
          tipo,
          fechaCreacion,
          imagenPath,
        );

  @override
  Map<String, dynamic> toJson() {
    /// Documentacion para el método `toJson`.
    /// Convierte un objeto Yoga a un mapa JSON.
    /// @param [this]: Objeto Yoga a convertir.
    /// @returns: [Map<String, dynamic>]: Mapa JSON que representa el objeto Yoga.
    return {
      'id': id,
      'name': nombre,
      'description': descripcion,
      'imageUrl': imagenPath,
      'type': tipo,
      'duration': duracion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  @override
  factory Yoga.fromJson(Map<String, dynamic> json) {
    /// Documentacion para el método `fromJson`.
    /// Convierte un mapa JSON a un objeto Yoga.
    /// @param [json]: Mapa JSON que representa un objeto Yoga.
    /// @returns: [Yoga]: Objeto Yoga creado a partir del mapa JSON.
    return Yoga(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenPath: json['imagenPath'],
      tipo: json['tipo'],
      duracion: json['duracion'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
