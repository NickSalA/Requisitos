import 'package:flutter/material.dart';
import '../model/usuario.dart';
import '../repository/usuario_repositorio.dart';

class OnboardingViewModel extends ChangeNotifier {
  final UsuarioRepository _repo;
  String _nombre = '';
  bool _isLoading = false;
  String? _error;

  OnboardingViewModel(this._repo);

  // Getters para que la View observe
  String get nombre => _nombre;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cuando el usuario escribe en el TextField, llamas a este setter:
  set nombre(String value) {
    _nombre = value;
    _error = null; // limpiamos error si había
    notifyListeners();
  }

  /// Lógica que se invoca al pulsar “¡Empieza ahora!”
  Future<bool> submit() async {
    // Validación sencilla: no vacío
    if (_nombre.trim().isEmpty) {
      _error = 'El nombre no puede estar vacío';
      notifyListeners();
      return false;
    }

    if (_nombre.length > 20) {
      _error = 'El nombre no puede tener más de 20 caracteres';
      notifyListeners();
      return false;
    }
    _isLoading = true;
    notifyListeners();

    // Crea la entidad Usuario y la guarda
    final usuario = Usuario(nombre: _nombre.trim());
    await _repo.saveUsuario(usuario);

    _isLoading = false;
    notifyListeners();

    return true; // Indica a la Vista que puede navegar
  }
}
