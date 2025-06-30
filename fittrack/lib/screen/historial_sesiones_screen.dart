import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/modo_cronometro.dart';
import '../repository/modo_cronometro_repositorio.dart';

class HistorialSesionesScreen extends StatefulWidget {
  final String sessionName;
  const HistorialSesionesScreen({super.key, required this.sessionName});

  @override
  State<HistorialSesionesScreen> createState() => _HistorialSesionesScreenState();
}

class _HistorialSesionesScreenState extends State<HistorialSesionesScreen> {
  late Future<List<ModoCronometro>> _sessionDataFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() {
    setState(() {
      _sessionDataFuture = _fetchSessionData();
    });
    return _sessionDataFuture;
  }

  Future<List<ModoCronometro>> _fetchSessionData() async {
    final repo = CronometroRepository();
    final allData = await repo.fetchCronometro();

    final filtered = allData.where((item) =>
      item.nombre.trim().toLowerCase() == widget.sessionName.trim().toLowerCase()
    ).toList();

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
            child: FutureBuilder<List<ModoCronometro>>(
              future: _sessionDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(context);
                }

                return _buildContent(context, snapshot.data!);
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

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 180),
        Center(
          child: Text(
            'No hay datos históricos para "${widget.sessionName}"',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
        const Spacer(),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildContent(BuildContext context, List<ModoCronometro> data) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          widget.sessionName,
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: SingleChildScrollView(
            child: _buildHistoryTable(data),
          ),
        ),
        _buildBackButton(context),
      ],
    );
  }

  Widget _buildHistoryTable(List<ModoCronometro> data) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
            ...data.map((item) => _buildTableRow(item, dateFormat)),
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
        children: const [
          Expanded(flex: 2, child: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Pose 1', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Pose 2', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Pose 3', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Pose 4', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Total', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(ModoCronometro item, DateFormat dateFormat) {
    final duracionPromedio = (item.duracion ~/ (item.posesPath.length));
    final date = dateFormat.format(item.fechaCreacion);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(date, style: GoogleFonts.poppins(fontSize: 13))),
          ...List.generate(4, (i) =>
            Expanded(child: Text('${duracionPromedio}s', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13)))
          ),
          Expanded(child: Text('${item.duracion}s', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 13)))
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
