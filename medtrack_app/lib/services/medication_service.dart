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

  Future<bool> addMedication(
    String nombre,
    String dosis,
    String frecuencia,
    String notas,
  ) async {
    if (token == null || userId == null) return false;

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
        }),
      );

      if (response.statusCode == 201) {
        final newMedication = Medication.fromJson(jsonDecode(response.body));
        _medications.add(newMedication);
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to add medication: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error adding medication: $e');
      return false;
    }
  }
}
