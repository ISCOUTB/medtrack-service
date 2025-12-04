import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/api_service.dart';
import 'features/auth/state/auth_provider.dart';

class MedListScreen extends StatefulWidget {
  const MedListScreen({super.key});

  @override
  State<MedListScreen> createState() => _MedListScreenState();
}

class _MedListScreenState extends State<MedListScreen> {
  final api = ApiService();
  late Future<List<dynamic>> _futureMeds;

  @override
  void initState() {
    super.initState();
    _futureMeds = api.getMedicamentos();
  }

  void _refresh() {
    setState(() {
      _futureMeds = api.getMedicamentos();
    });
  }

  void _showAddMedicamentoDialog() {
    final nombreCtrl = TextEditingController();
    final dosisCtrl = TextEditingController();
    final frecuenciaCtrl = TextEditingController();
    final notasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo Medicamento"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: dosisCtrl, decoration: const InputDecoration(labelText: "Dosis")),
              TextField(controller: frecuenciaCtrl, decoration: const InputDecoration(labelText: "Frecuencia")),
              TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: "Notas")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              try {
                await api.createMedicamento({
                  "nombre": nombreCtrl.text.trim(),
                  "dosis": dosisCtrl.text.trim(),
                  "frecuencia": frecuenciaCtrl.text.trim(),
                  "notas": notasCtrl.text.trim(),
                });
                Navigator.pop(context);
                _refresh();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Medicamentos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (mounted) Navigator.pushReplacementNamed(context, "/login");
            },
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureMeds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final meds = snapshot.data ?? [];
          if (meds.isEmpty) return const Center(child: Text("No hay medicamentos"));
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              itemCount: meds.length,
              itemBuilder: (_, i) {
                final m = meds[i];
                return ListTile(
                  title: Text(m["nombre"] ?? "Medicamento"),
                  subtitle: Text("Dosis: ${m["dosis"] ?? "-"}"),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicamentoDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
