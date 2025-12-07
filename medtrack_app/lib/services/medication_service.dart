import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/medication.dart';

class MedicationService with ChangeNotifier {
  final String baseUrl = 'http://10.0.2.2:3000/medicamentos';
  final String? token;
  final int? userId;

  List<Medication> _medications = [];

  MedicationService(this.token, this.userId);

  List<Medication> get medications => _medications;

  Future<void> fetchMedications() async {
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _medications = data
            .map((item) => Medication.fromJson(item))
            .where((med) => med.usuarioId == userId)
            .toList();
        notifyListeners();
      } else {
        debugPrint('Failed to load medications: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching medications: $e');
    }
  }

  Future<Medication?> addMedication(
    String nombre,
    String dosis,
    String frecuencia,
    String notas, {
    Map<String, dynamic>? detallesFrecuencia,
  }) async {
    if (token == null || userId == null) return null;

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'usuario_id': userId,
          'nombre': nombre,
          'dosis': dosis,
          'frecuencia': frecuencia,
          'notas': notas,
          'detalles_frecuencia': detallesFrecuencia,
        }),
      );

      if (response.statusCode == 201) {
        final newMedication = Medication.fromJson(jsonDecode(response.body));
        _medications.add(newMedication);
        notifyListeners();
        return newMedication;
      } else {
        debugPrint('Failed to add medication: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error adding medication: $e');
      return null;
    }
  }

  Future<bool> recordIntake(
    int medicationId, {
    String status = 'TOMADO',
    DateTime? scheduledTime,
  }) async {
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/tomas/registrar'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'medicamento_id': medicationId,
          'fecha_hora': DateTime.now().toIso8601String(),
          'estado': status,
          'fecha_programada': scheduledTime?.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Failed to record intake: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error recording intake: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchIntakesForDate(DateTime date) async {
    if (token == null || userId == null) return [];

    try {
      final dateStr =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/tomas/usuario/$userId?fecha=$dateStr'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to load intakes: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching intakes: $e');
      return [];
    }
  }
}
