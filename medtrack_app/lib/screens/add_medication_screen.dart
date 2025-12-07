import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  static const routeName = '/add-medication';

  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nombreController = TextEditingController();
  final _dosisController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _notasController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_nombreController.text.isEmpty ||
        _dosisController.text.isEmpty ||
        _frecuenciaController.text.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await Provider.of<MedicationService>(context, listen: false)
        .addMedication(
          _nombreController.text,
          _dosisController.text,
          _frecuenciaController.text,
          _notasController.text,
        );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Error al agregar medicamento.'),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Medicamento')),
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
                    TextField(
                      controller: _frecuenciaController,
                      decoration: const InputDecoration(
                        labelText: 'Frecuencia (ej. 8 horas)',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notasController,
                      decoration: const InputDecoration(
                        labelText: 'Notas (Opcional)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.add),
                label: const Text('Agregar Medicamento'),
              ),
          ],
        ),
      ),
    );
  }
}
