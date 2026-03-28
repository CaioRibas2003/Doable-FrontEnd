import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tag_model.dart';

class TagService {
  static const String baseUrl = 'http://10.0.2.2:8080';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Tag>> findAll() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tags'),
      headers: await _headers(),
    );
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Tag.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao buscar tags');
    }
  }

  Future<Tag> create(String name, String color) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tags'),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'color': color}),
    );
    if (response.statusCode == 201) {
      return Tag.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao criar tag');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tags/$id'),
      headers: await _headers(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erro ao deletar tag');
    }
  }
}