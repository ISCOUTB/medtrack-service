import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';
import '../models/medication.dart';

class AddMedicationScreen extends StatefulWidget {
  static const routeName = '/add-medication';

  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _notasController = TextEditingController();

  String _frequencyType = 'Diariamente';
  final List<String> _daysOfWeek = [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom',
  ];
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  final List<TimeOfDay> _selectedTimes = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _loadMedicationData();
    }
  }

  void _loadMedicationData() {
    final med = widget.medication!;
    _nombreController.text = med.nombre;
    _dosisController.text = med.dosis;
    _notasController.text = med.notas ?? '';

    if (med.detallesFrecuencia != null) {
      final details = med.detallesFrecuencia!;
      if (details['type'] == 'daily') {
        _frequencyType = 'Diariamente';
      } else if (details['type'] == 'specific_days') {
        _frequencyType = 'Días específicos';
        final days = List<int>.from(details['days'] ?? []);
        for (var day in days) {
          if (day >= 1 && day <= 7) {
            _selectedDays[day - 1] = true;
          }
        }
      }

      if (details['times'] != null) {
        final times = List<String>.from(details['times']);
        for (var timeStr in times) {
          final parts = timeStr.split(':');
          if (parts.length == 2) {
            _selectedTimes.add(
              TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
            );
          }
        }
      }
    }
  }

  Future<void> _addTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && !_selectedTimes.contains(picked)) {
      setState(() {
        _selectedTimes.add(picked);
        _selectedTimes.sort(
          (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
        );
      });
    }
  }

  void _removeTime(TimeOfDay time) {
    setState(() {
      _selectedTimes.remove(time);
    });
  }

  Future<void> _submit() async {
    if (_nombreController.text.isEmpty ||
        _dosisController.text.isEmpty ||
        _selectedTimes.isEmpty ||
        (_frequencyType == 'Días específicos' &&
            !_selectedDays.contains(true))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa nombre, dosis, horarios y días.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Construct details
    Map<String, dynamic> detallesFrecuencia = {
      'type': _frequencyType == 'Diariamente' ? 'daily' : 'specific_days',
      'times': _selectedTimes
          .map(
            (t) =>
                '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
          )
          .toList(),
    };

    if (_frequencyType == 'Días específicos') {
      List<int> days = [];
      for (int i = 0; i < 7; i++) {
        if (_selectedDays[i]) {
          days.add(i + 1);
        }
      }
      detallesFrecuencia['days'] = days;
    }

    String frecuenciaStr = _frequencyType;
    if (_frequencyType == 'Diariamente') {
      frecuenciaStr = 'Diariamente ${_selectedTimes.length} veces';
    } else {
      frecuenciaStr =
          'Días específicos (${detallesFrecuencia['days'].length} días)';
    }

    bool success = false;
    final medService = Provider.of<MedicationService>(context, listen: false);

    if (widget.medication != null) {
      success = await medService.updateMedication(
        widget.medication!.id,
        _nombreController.text,
        _dosisController.text,
        frecuenciaStr,
        _notasController.text,
        detallesFrecuencia: detallesFrecuencia,
      );
    } else {
      final newMed = await medService.addMedication(
        _nombreController.text,
        _dosisController.text,
        frecuenciaStr,
        _notasController.text,
        detallesFrecuencia: detallesFrecuencia,
      );
      success = newMed != null;
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;

      final medId = widget.medication?.id ?? 0;
      final medName = _nombreController.text;

      if (widget.medication != null) {
        await NotificationService().cancelNotification(widget.medication!.id);
      }

      final now = DateTime.now();
      for (var time in _selectedTimes) {
        var scheduledDate = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        if (_frequencyType == 'Diariamente') {
          await NotificationService().scheduleNotification(
            id: medId * 100 + time.hour * 60 + time.minute,
            title: 'Hora de tomar tu medicamento',
            body: 'Es hora de tomar $medName',
            scheduledTime: scheduledDate,
          );
        } else {
          for (int i = 0; i < 7; i++) {
            if (_selectedDays[i]) {
              final targetWeekday = i + 1;
              var nextDate = DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              );

              while (nextDate.weekday != targetWeekday) {
                nextDate = nextDate.add(const Duration(days: 1));
              }

              if (nextDate.isBefore(now)) {
                nextDate = nextDate.add(const Duration(days: 7));
              }

              await NotificationService().scheduleNotification(
                id:
                    medId * 1000 +
                    targetWeekday * 100 +
                    time.hour * 60 +
                    time.minute,
                title: 'Hora de tomar tu medicamento',
                body: 'Es hora de tomar $medName',
                scheduledTime: nextDate,
              );
            }
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text(
            widget.medication != null
                ? 'Error al actualizar medicamento.'
                : 'Error al agregar medicamento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Medicamento' : 'Agregar Medicamento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Medicamento',
                        prefixIcon: Icon(Icons.medication),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _dosisController,
                      decoration: const InputDecoration(
                        labelText: 'Dosis (ej. 500mg)',
                        prefixIcon: Icon(Icons.scale),
                      ),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _frequencyType,
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: ['Diariamente', 'Días específicos']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _frequencyType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    if (_frequencyType == 'Días específicos') ...[
                      const Text(
                        'Selecciona los días:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: List.generate(7, (index) {
                          return FilterChip(
                            label: Text(_daysOfWeek[index]),
                            selected: _selectedDays[index],
                            onSelected: (selected) {
                              setState(() {
                                _selectedDays[index] = selected;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Horarios:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.teal,
                          ),
                          onPressed: () => _addTime(context),
                        ),
                      ],
                    ),
                    if (_selectedTimes.isEmpty)
                      const Text(
                        'No hay horarios agregados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ..._selectedTimes.map(
                      (time) => ListTile(
                        title: Text(time.format(context)),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeTime(time),
                        ),
                        dense: true,
                      ),
                    ),

                    const SizedBox(height: 16),
                    TextField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Actualizar' : 'Guardar Medicamento'),
            ),
          ],
        ),
      ),
    );
  }
}
