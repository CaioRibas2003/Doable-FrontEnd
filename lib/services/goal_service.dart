import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal_model.dart';

class GoalService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Goal>> findAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/goals'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((e) => Goal.fromJson(e))
          .toList();
    }
    throw Exception('Erro ao buscar metas');
  }

  Future<Goal> create(Goal goal) async {
    final response = await http.post(
      Uri.parse('$baseUrl/goals'),
      headers: await _headers(),
      body: jsonEncode(goal.toJson()),
    );
    if (response.statusCode == 201) {
      return Goal.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao criar meta');
  }

  Future<Goal> update(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/goals/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return Goal.fromJson(jsonDecode(response.body));
    }
    throw Exception('Erro ao atualizar meta');
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/goals/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar meta');
    }
  }
}