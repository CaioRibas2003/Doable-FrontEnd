import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/stats_model.dart';

class StatsService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Stats> getStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/stats'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return Stats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar estatísticas');
    }
  }
}