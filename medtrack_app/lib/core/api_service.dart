import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:3000",
    headers: {"Content-Type": "application/json"},
  ));

  final storage = const FlutterSecureStorage();

  Future<String?> login(String email, String password) async {
    final res = await dio.post("/auth/login", data: {
      "email": email,
      "password": password,
    });
    final token = res.data["token"];
    if (token != null) {
      await storage.write(key: "jwt", value: token);
    }
    return token;
  }

  Future<void> register(String nombre, String email, String password) async {
    await dio.post("/auth/register", data: {
      "nombre": nombre,
      "email": email,
      "password": password,
    });
  }

  Future<List<dynamic>> getMedicamentos() async {
    final token = await storage.read(key: "jwt");
    final res = await dio.get("/medicamentos",
        options: Options(headers: {"Authorization": "Bearer $token"}));
    return res.data;
  }

  Future<void> createMedicamento(Map<String, dynamic> payload) async {
    final token = await storage.read(key: "jwt");
    await dio.post("/medicamentos",
        data: payload,
        options: Options(headers: {"Authorization": "Bearer $token"}));
  }

  Future<String?> getToken() => storage.read(key: "jwt");
  Future<void> clearToken() => storage.delete(key: "jwt");
}
