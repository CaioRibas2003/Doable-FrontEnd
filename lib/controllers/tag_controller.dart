import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../services/tag_service.dart';

class TagController extends ChangeNotifier {
  final TagService _tagService = TagService();

  List<Tag> tags = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> findAll() async {
    isLoading = true;
    notifyListeners();
    try {
      tags = await _tagService.findAll();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Erro ao carregar tags';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String name, String color) async {
    try {
      final tag = await _tagService.create(name, color);
      tags.add(tag);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erro ao criar tag';
      notifyListeners();
      return false;
    }
  }

  Future<void> delete(int id) async {
    try {
      await _tagService.delete(id);
      tags.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao deletar tag';
      notifyListeners();
    }
  }
}