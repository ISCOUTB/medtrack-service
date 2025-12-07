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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tomas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _intakesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay historial de tomas.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final intakes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: intakes.length,
            itemBuilder: (context, index) {
              final intake = intakes[index];
              final dateStr = intake['fecha_programada'];
              final date = DateTime.parse(dateStr).toLocal();
              
              final medicationName = intake['medicamento_nombre'] ?? 'Desconocido';
              final status = intake['estado'] ?? 'PENDIENTE';
              final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);
              final statusColor = _getStatusColor(status);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          status == 'TOMADO' ? Icons.check : Icons.close,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today, 
                                  size: 14, 
                                  color: Colors.grey[600]
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, 
                          vertical: 6
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor.withOpacity(0.5)
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
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
