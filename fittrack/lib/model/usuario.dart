class Usuario {
  String nombre;
  Usuario({
    required this.nombre,
  });

  Map<String, dynamic> toJson() {
    /// Documentacion para el método `toJson`.
    /// Convierte un objeto Usuario a un mapa JSON.
    /// @param [this]: Objeto Usuario a convertir.
    /// @returns: [Map<String, dynamic>]: Mapa JSON que representa el objeto Usuario.
    return {
      'nombre': nombre,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    /// Documentacion para el método `fromJson`.
    /// Convierte un mapa JSON a un objeto Usuario.
    /// @param [json]: Mapa JSON que representa un objeto Usuario.
    /// @returns: [Usuario]: Objeto Usuario creado a partir del mapa JSON.
    return Usuario(
      nombre: json['nombre'],
    );
  }
}
