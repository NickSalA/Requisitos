import 'reto.dart';

class ModoCronometro extends Reto {
  int duracion;
  List<String> posesPath;
  ModoCronometro({
    required int id,
    required String nombre,
    required String descripcion,
    required String tipo,
    required DateTime fechaCreacion,
    required String imagenPath,
    required this.duracion,
    required this.posesPath,
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
      'duracion': duracion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'posesPath': posesPath,
    };
  }

  @override
  factory ModoCronometro.fromJson(Map<String, dynamic> json) {
    /// Documentacion para el método `fromJson`.
    /// Convierte un mapa JSON a un objeto Ejercicio.
    /// @param [json]: Mapa JSON que representa un objeto Ejercicio.
    /// @returns: [Ejercicio]: Objeto Ejercicio creado a partir del mapa JSON.
    return ModoCronometro(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      imagenPath: json['imagenPath'],
      tipo: json['tipo'],
      duracion: json['duracion'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      posesPath: List<String>.from(json['posesPath'] ?? []),
    );
  }
}
