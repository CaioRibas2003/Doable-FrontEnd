import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalController extends ChangeNotifier {
  final GoalService _service = GoalService();

  List<Goal> goals = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> findAll() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      goals = await _service.findAll();
    } catch (e) {
      errorMessage = 'Erro ao carregar metas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(String title, int targetCount, int periodDays, int? tagId) async {
    try {
      final goal = Goal(
        title: title,
        targetCount: targetCount,
        periodDays: periodDays,
        tagId: tagId,
      );
      final created = await _service.create(goal);
      goals.add(created);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Erro ao criar meta';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleActive(Goal goal) async {
    try {
      final updated = await _service.update(goal.id!, {'active': !goal.active});
      final idx = goals.indexWhere((g) => g.id == goal.id);
      if (idx != -1) goals[idx] = updated;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao atualizar meta';
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    try {
      await _service.delete(id);
      goals.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      errorMessage = 'Erro ao deletar meta';
      notifyListeners();
    }
  }
}