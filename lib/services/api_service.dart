import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Task>> findAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Task.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar tarefas');
    }
  }

  Future<Task> create(Task task) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: await _headers(),
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao criar tarefa');
    }
  }

  Future<Task> update(int id, Task task) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _headers(),
      body: jsonEncode(task.toJson()),
    );
    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao atualizar tarefa');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar tarefa');
    }
  }
}