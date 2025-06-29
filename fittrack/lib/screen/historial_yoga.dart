import 'package:fittrack/repository/yoga_repositorio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/yoga.dart';

class HistorialYogaScreen extends StatefulWidget {
  final String exerciseName;

  const HistorialYogaScreen({super.key, required this.exerciseName});

  @override
  State<HistorialYogaScreen> createState() => _HistorialYogaScreenState();
}

class _HistorialYogaScreenState extends State<HistorialYogaScreen> {
  late Future<List<Yoga>> _yogaDataFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    setState(() {
      _yogaDataFuture = _fetchYogaData();
    });
    return _yogaDataFuture;
  }

  Future<List<Yoga>> _fetchYogaData() async {
    final yogaRepo = YogaRepository();
    final listaYoga = await yogaRepo.fetchYoga();

    // Debug: Imprimir todos los datos disponibles
    debugPrint("Todos los datos de yoga:");
    for (var yoga in listaYoga) {
      debugPrint("${yoga.nombre} - ${yoga.fechaCreacion} - ${yoga.duracion}s");
    }

    // Debug: Imprimir lo que estamos buscando
    debugPrint("Buscando datos para: ${widget.exerciseName}");
    for (var yoga in listaYoga) {
      debugPrint("➡️ Guardado: ${yoga.nombre} (${yoga.fechaCreacion})");
    }
    final filtered = listaYoga
        .where((yoga) =>
            yoga.nombre.trim().toLowerCase() ==
            widget.exerciseName.trim().toLowerCase())
        .toList();
    // Debug: Imprimir resultados del filtro
    debugPrint("Encontrados ${filtered.length} registros");

    return filtered;
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
            child: FutureBuilder<List<Yoga>>(
              future: _yogaDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildContent(context, snapshot.data!);
              },
            ),
          ),
        ],
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () => _addTestData(context),
        child: const Icon(Icons.add),
      ),*/
    );
  }

/*  Future<void> _addTestData(BuildContext context) async {
    final yogaRepo = YogaRepository();
    await yogaRepo.saveYoga([
      Yoga(
        id: DateTime.now().millisecondsSinceEpoch,
        nombre: widget.exerciseName,
        descripcion: 'Nueva sesión ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
        imagenPath: 'assets/icons/guerrero.png',
        tipo: 'yoga',
        duracion: (60 + Random().nextInt(120)),
        duractionCorrecta: (50 + Random().nextInt(100)),
        duracionIncorrecta: Random().nextInt(20),
        fechaCreacion: DateTime.now(),
      )
    ]);
    
    await _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos agregados y actualizados'))
    );
  }*/

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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 180),
        Center(
          child: Text(
            'No hay datos históricos para $widget.exerciseName',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
        const Spacer(),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<Yoga> yogaData) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildTitle(),
        const SizedBox(height: 30),
        Expanded(
          // Añadido Expanded aquí
          child: SingleChildScrollView(
            // Envuelve la tabla en un ScrollView
            child: _buildHistoryTable(yogaData),
          ),
        ),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.exerciseName,
      style: GoogleFonts.montserrat(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildHistoryTable(List<Yoga> yogaData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: BoxConstraints(
          // Añade constraints para el scroll
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
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
          mainAxisSize: MainAxisSize.min, // Importante para el scroll
          children: [
            _buildTableHeader(),
            ...yogaData.map((yoga) => _buildTableRow(yoga)),
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
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Fecha',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Tiempo\nmáximo',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Tiempo\nerrado',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(Yoga yoga) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              dateFormat.format(yoga.fechaCreacion),
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${yoga.duracion}s',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${yoga.duracionIncorrecta}s',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
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
