import 'dart:math';
import 'package:fittrack/repository/modo_cronometro_repositorio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fittrack/model/modo_cronometro.dart';

class HistorialEjercicioScreen extends StatefulWidget {
  final String exerciseName;

  const HistorialEjercicioScreen({super.key, required this.exerciseName});

  @override
  State<HistorialEjercicioScreen> createState() =>
      _HistorialEjercicioScreenState();
}

class _HistorialEjercicioScreenState extends State<HistorialEjercicioScreen> {
  late Future<List<ModoCronometro>> _ejercicioDataFuture;
  final List<String> _tiposEjercicios = const [
    'Sentadilla',
    'Planchas',
    'Curl de Bíceps',
    'Laterales hombros'
  ];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    setState(() {
      _ejercicioDataFuture = _fetchEjercicioData();
    });
    return _ejercicioDataFuture;
  }

  Future<List<ModoCronometro>> _fetchEjercicioData() async {
    final ejercicioRepo = EjercicioRepository();
    final listaEjercicios = await ejercicioRepo.fetchEjercicios();

    final filtered =
        listaEjercicios.where((e) => e.nombre == widget.exerciseName).toList();
    /*
    if (filtered.isEmpty && _tiposEjercicios.contains(widget.exerciseName)) {
      return _generateTestData();
    }
    */
    return filtered;
  }
/*
  List<Ejercicio> _generateTestData() {
    final random = Random();
    return List.generate(10, (index) {
      final daysAgo = index * 2;
      return Ejercicio(
        id: DateTime.now().millisecondsSinceEpoch + index,
        nombre: widget.exerciseName,
        descripcion: 'Sesión ${index + 1}',
        imagenPath: _getImagePath(widget.exerciseName),
        tipo: 'fuerza',
        series: 3 + random.nextInt(3),
        repeticiones: 8 + random.nextInt(12),
        descanso: 30 + random.nextInt(60),
        fechaCreacion: DateTime.now().subtract(Duration(days: daysAgo)),
      );
    });
  }*/

  String _getImagePath(String exerciseName) {
    switch (exerciseName) {
      case 'Sentadilla':
        return 'assets/icons/sentadillas.png';
      case 'Planchas':
        return 'assets/icons/planchas.png';
      case 'Curl de Bíceps':
        return 'assets/icons/curl de biceps.png';
      case 'Laterales hombros':
        return 'assets/icons/laterales hombros.png';
      default:
        return 'assets/icons/ejercicio.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Historial',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildPurpleHeader(),
          SafeArea(
            child: FutureBuilder<List<ModoCronometro>>(
              future: _ejercicioDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildContent(snapshot.data!);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurpleHeader() {
    return Container(
      height: 160,
      decoration: const BoxDecoration(
        color: Color(0xFFA9A8F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          Text("Error: $error", style: GoogleFonts.poppins(fontSize: 16)),
          ElevatedButton(
            onPressed: _refreshData,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 180),
        Center(
          child: Text(
            'No hay datos históricos para ${widget.exerciseName}',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
        const Spacer(),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildContent(List<ModoCronometro> ejercicios) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildExerciseTitle(),
        const SizedBox(height: 30),
        Expanded(
          child: SingleChildScrollView(
            child: _buildHistoryTable(ejercicios),
          ),
        ),
        _buildBackButton(),
      ],
    );
  }

  Widget _buildExerciseTitle() {
    return Text(
      widget.exerciseName,
      style: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHistoryTable(List<ModoCronometro> ejercicios) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            ...ejercicios.map((e) => _buildTableRow(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text('Series',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('Rep. efectivas',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('Descanso',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(ModoCronometro ejercicio) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(dateFormat.format(ejercicio.fechaCreacion)),
          ),
          Expanded(
            child: Text(
              'Duracion',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA9A8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        child: Text(
          'Volver al inicio',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
