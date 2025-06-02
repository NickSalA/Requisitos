import 'reto.dart';

class Ejercicio extends Reto {
  int series;
  int repeticiones;
  int descanso;

  Ejercicio({
    required int id,
    required String nombre,
    required String descripcion,
    required String imagenPath,
    required DateTime fechaCreacion,
    required String tipo,
    required this.series,
    required this.repeticiones,
    required this.descanso,
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
    /// Convierte un objeto Ejercicio a un mapa JSON.
    /// @param [this]: Objeto Ejercicio a convertir.
    /// @returns: [Map<String, dynamic>]: Mapa JSON que representa el objeto Ejercicio.
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'imagenPath': imagenPath,
      'tipo': tipo,
      'series': series,
      'repeticiones': repeticiones,
      'descanso': descanso,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  @override
  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    /// Documentacion para el método `fromJson`.
    /// Convierte un mapa JSON a un objeto Ejercicio.
    /// @param [json]: Mapa JSON que representa un objeto Ejercicio.
    /// @returns: [Ejercicio]: Objeto Ejercicio creado a partir del mapa JSON.
    return Ejercicio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenPath: json['imagenPath'],
      tipo: json['tipo'],
      series: json['series'],
      repeticiones: json['repeticiones'],
      descanso: json['descanso'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
