import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../models/tag_model.dart';

enum TaskFilter { all, pending, done }

class TaskController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Task> tasks = [];
  List<Task> _allTasks = [];
  List<Tag> _selectedTagFilter = [];
  bool isLoading = false;
  String? errorMessage;
  TaskFilter currentFilter = TaskFilter.all;

  List<Tag> get selectedTagFilter => _selectedTagFilter;

  Future<void> findAll() async {
    isLoading = true;
    notifyListeners();
    try {
      _allTasks = await _apiService.findAll();
      _applyFilter();
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Erro ao carregar tarefas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void setTagFilter(Tag tag) {
    if (_selectedTagFilter.any((t) => t.id == tag.id)) {
      _selectedTagFilter.removeWhere((t) => t.id == tag.id);
    } else {
      _selectedTagFilter.add(tag);
    }
    _applyFilter();
    notifyListeners();
  }

  void clearTagFilter() {
    _selectedTagFilter = [];
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    List<Task> filtered = List.from(_allTasks);

    switch (currentFilter) {
      case TaskFilter.all:
        break;
      case TaskFilter.pending:
        filtered = filtered.where((t) => !t.isDone).toList();
        break;
      case TaskFilter.done:
        filtered = filtered.where((t) => t.isDone).toList();
        break;
    }

    if (_selectedTagFilter.isNotEmpty) {
      filtered = filtered.where((task) =>
          task.tags.any((tag) =>
              _selectedTagFilter.any((f) => f.id == tag.id))).toList();
    }

    tasks = filtered;
  }

  Future<void> create(String title, String? description, String? deadline, List<Tag> tags) async {
    try {
      final task = Task(
        title: title,
        description: description,
        deadline: deadline,
        tags: tags,
      );
      await _apiService.create(task);
      await findAll();
    } catch (e) {
      errorMessage = 'Erro ao criar tarefa';
      notifyListeners();
    }
  }

  Future<void> toggleDone(Task task) async {
    try {
      final updated = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        isDone: !task.isDone,
      );
      await _apiService.update(task.id!, updated);
      await findAll();
    } catch (e) {
      errorMessage = 'Erro ao atualizar tarefa';
      notifyListeners();
    }
  }

  Future<void> update(int id, String title, String? description, String? deadline, List<Tag> tags) async {
    try {
      final task = Task(
        id: id,
        title: title,
        description: description,
        deadline: deadline,
        isDone: _allTasks.firstWhere((t) => t.id == id).isDone,
        tags: tags,
      );
      await _apiService.update(id, task);
      await findAll();
    } catch (e) {
      errorMessage = 'Erro ao atualizar tarefa';
      notifyListeners();
    }
  }

  Future<void> delete(int id) async {
    try {
      await _apiService.delete(id);
      await findAll();
    } catch (e) {
      errorMessage = 'Erro ao deletar tarefa';
      notifyListeners();
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      _applyFilter();
    } else {
      tasks = _allTasks
          .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}