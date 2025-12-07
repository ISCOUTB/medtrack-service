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
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Éxito'),
          content: Text(
            widget.medication != null
                ? 'Medicamento actualizado correctamente.'
                : 'Medicamento agregado correctamente.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Medicamento' : 'Agregar Medicamento'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Medicamento',
                        prefixIcon: Icon(Icons.medication_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _dosisController,
                      decoration: const InputDecoration(
                        labelText: 'Dosis (ej. 500mg, 1 tableta)',
                        prefixIcon: Icon(Icons.scale_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas adicionales (opcional)',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Frecuencia',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _frequencyType,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['Diariamente', 'Días específicos'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == 'Diariamente'
                                  ? Icons.calendar_today
                                  : Icons.calendar_month,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(value),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _frequencyType = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ),
            if (_frequencyType == 'Días específicos') ...[
              const SizedBox(height: 20),
              Text(
                'Selecciona los días',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final isSelected = _selectedDays[index];
                  return FilterChip(
                    label: Text(_daysOfWeek[index]),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedDays[index] = selected;
                      });
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                  );
                }),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Horarios de toma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _addTime(context),
                  icon: const Icon(Icons.add_alarm),
                  label: const Text('Agregar Hora'),
                ),
              ],
            ),
            if (_selectedTimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay horarios configurados',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _selectedTimes.map((time) {
                  return Chip(
                    label: Text(
                      time.format(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.secondary,
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white,
                    ),
                    onDeleted: () => _removeTime(time),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 40),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 4,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Crear Medicamento',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
