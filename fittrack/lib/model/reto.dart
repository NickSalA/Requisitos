import 'dart:convert';

abstract class Reto {
  late int id;
  late String nombre;
  late String descripcion;
  late String tipo;
  late DateTime fechaCreacion;
  late String imagenPath;

  Reto(this.id, this.nombre, this.descripcion, this.tipo, this.fechaCreacion,
      this.imagenPath);
  Map<String, dynamic> toJson();
  factory Reto.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError();
  }

  static String encode(List<Reto> retos) =>

      /// Documentacion para el método `encode`.
      /// Convierte una lista de objetos Reto a una cadena JSON.
      /// @param [retos]: Lista de objetos Reto a convertir.
      /// @returns: [String]: Cadena JSON que representa la lista de objetos Reto.
      json.encode(retos.map((e) => e.toJson()).toList());

  static List<Reto> decode(String retos) =>

      /// Documentacion para el método `decode`.
      /// Convierte una cadena JSON a una lista de objetos Reto.
      /// @param [retos]: Cadena JSON que representa una lista de objetos Reto.
      /// @returns: [List<Reto>]: Lista de objetos Reto creada a partir de la cadena JSON.
      (json.decode(retos) as List<dynamic>)
          .map((item) => Reto.fromJson(item))
          .toList();
}
