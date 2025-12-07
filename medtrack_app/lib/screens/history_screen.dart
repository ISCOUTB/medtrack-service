import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/medication_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _intakesFuture;

  @override
  void initState() {
    super.initState();
    _intakesFuture = Provider.of<MedicationService>(context, listen: false).fetchAllIntakes();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'TOMADO':
        return Colors.green;
      case 'OMITIDO':
        return Colors.red;
      case 'PENDIENTE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tomas'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _intakesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay historial de tomas.'));
          }

          final intakes = snapshot.data!;

          return ListView.builder(
            itemCount: intakes.length,
            itemBuilder: (context, index) {
              final intake = intakes[index];
              final dateStr = intake['fecha_programada'];
              final date = DateTime.parse(dateStr).toLocal();
              
              final medicationName = intake['medicamento_nombre'] ?? 'Desconocido';
              final status = intake['estado'] ?? 'PENDIENTE';
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: Icon(
                      status == 'TOMADO' ? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    medicationName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Programado: $formattedDate\nEstado: $status',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
