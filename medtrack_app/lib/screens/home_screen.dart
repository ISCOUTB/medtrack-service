import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/medication_service.dart';
import '../models/medication.dart';
import 'add_medication_screen.dart';
import 'history_screen.dart';

class ScheduleItem {
  final Medication medication;
  final DateTime scheduledTime;
  final String status; // 'PENDIENTE', 'TOMADO', 'OMITIDO'
  final dynamic recordedIntake;

  ScheduleItem({
    required this.medication,
    required this.scheduledTime,
    required this.status,
    this.recordedIntake,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  var _isLoading = false;
  DateTime _selectedDate = DateTime.now();
  Map<int, List<dynamic>> _recordedIntakes = {};

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final medService = Provider.of<MedicationService>(context, listen: false);
    await medService.fetchMedications();

    // Fetch intakes for the selected date
    final intakes = await medService.fetchIntakesForDate(_selectedDate);

    // Organize intakes by medication ID for easier lookup
    Map<int, List<dynamic>> intakesMap = {};
    for (var intake in intakes) {
      final medId = intake['medicamento_id'];
      if (!intakesMap.containsKey(medId)) {
        intakesMap[medId] = [];
      }
      intakesMap[medId]!.add(intake);
    }

    if (mounted) {
      setState(() {
        _recordedIntakes = intakesMap;
        _isLoading = false;
      });
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  Future<void> _recordIntake(
    Medication med,
    DateTime scheduledTime,
    String status,
  ) async {
    final success = await Provider.of<MedicationService>(
      context,
      listen: false,
    ).recordIntake(med.id, status: status, scheduledTime: scheduledTime);

    if (success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Toma registrada como $status'),
          backgroundColor: status == 'TOMADO' ? Colors.green : Colors.orange,
        ),
      );
      _loadData(); // Reload to update UI
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar la toma'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editMedication(Medication med) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => AddMedicationScreen(medication: med)),
    );
    if (result == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicamento actualizado correctamente'),
            backgroundColor: Colors.teal,
          ),
        );
        _loadData();
      }
    }
  }

  List<ScheduleItem> _generateSchedule(List<Medication> meds) {
    List<ScheduleItem> schedule = [];

    for (var med in meds) {
      // Parse frequency details
      List<TimeOfDay> times = [];
      bool shouldInclude = false;

      if (med.detallesFrecuencia != null) {
        final type = med.detallesFrecuencia!['type'];
        if (type == 'daily') {
          shouldInclude = true;
        } else if (type == 'specific_days') {
          final days = List<int>.from(med.detallesFrecuencia!['days'] ?? []);
          // weekday: 1=Mon, 7=Sun
          if (days.contains(_selectedDate.weekday)) {
            shouldInclude = true;
          }
        }

        if (shouldInclude) {
          final timeStrings = List<String>.from(
            med.detallesFrecuencia!['times'] ?? [],
          );
          for (var t in timeStrings) {
            final parts = t.split(':');
            if (parts.length == 2) {
              times.add(
                TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                ),
              );
            }
          }
        }
      } else {
        // Legacy fallback or default
        if (med.frecuencia.contains('Diariamente')) {
          // If no details but text says daily, assume 8am?
          // Better to not assume to avoid confusion.
        }
      }

      // Generate items for each time
      for (var time in times) {
        final scheduledDateTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          time.hour,
          time.minute,
        );

        // Find if there's a recorded intake for this time
        dynamic matchingIntake;
        final intakes = _recordedIntakes[med.id] ?? [];

        for (var intake in intakes) {
          if (intake['fecha_programada'] != null) {
            final intakeTime = DateTime.parse(
              intake['fecha_programada'],
            ).toLocal();
            // Compare with minute precision
            if (intakeTime.year == scheduledDateTime.year &&
                intakeTime.month == scheduledDateTime.month &&
                intakeTime.day == scheduledDateTime.day &&
                intakeTime.hour == scheduledDateTime.hour &&
                intakeTime.minute == scheduledDateTime.minute) {
              matchingIntake = intake;
              break;
            }
          }
        }

        String status = 'PENDIENTE';
        if (matchingIntake != null) {
          status = matchingIntake['estado'] ?? 'PENDIENTE';
        }

        schedule.add(
          ScheduleItem(
            medication: med,
            scheduledTime: scheduledDateTime,
            status: status,
            recordedIntake: matchingIntake,
          ),
        );
      }
    }

    // Sort by time
    schedule.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    return schedule;
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeDate(-1),
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, d MMM yyyy', 'es').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList(List<Medication> medications) {
    final schedule = _generateSchedule(medications);

    if (schedule.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay tomas programadas para hoy.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: schedule.length,
      itemBuilder: (ctx, i) {
        final item = schedule[i];
        final med = item.medication;
        final isTaken = item.status == 'TOMADO';
        final isSkipped = item.status == 'OMITIDO';

        Color statusColor = Colors.grey;
        IconData statusIcon = Icons.circle_outlined;
        String statusText = 'Pendiente';

        if (isTaken) {
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
          statusText = 'Tomado';
        } else if (isSkipped) {
          statusColor = Colors.orange;
          statusIcon = Icons.remove_circle;
          statusText = 'Omitido';
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Icon(Icons.medication, color: statusColor),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        med.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editMedication(med);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.teal,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                          ],
                      child: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(item.scheduledTime),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.scale, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            med.dosis,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (med.notas != null && med.notas!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        med.notas!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isTaken && !isSkipped)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.block, size: 18),
                          label: const Text('Omitir'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                          ),
                          onPressed: () =>
                              _recordIntake(med, item.scheduledTime, 'OMITIDO'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Tomar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () =>
                              _recordIntake(med, item.scheduledTime, 'TOMADO'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTrack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const AddMedicationScreen(),
                ),
              );
              if (result == true) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medicamento creado correctamente'),
                      backgroundColor: Colors.teal,
                    ),
                  );
                  _loadData();
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Provider.of<AuthService>(context, listen: false).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildDateHeader(),
                Expanded(
                  child: Consumer<MedicationService>(
                    builder: (ctx, medService, child) =>
                        _buildScheduleList(medService.medications),
                  ),
                ),
              ],
            ),
    );
  }
}
