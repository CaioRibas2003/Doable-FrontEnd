import 'package:flutter/material.dart';
import '../models/stats_model.dart';
import '../services/stats_service.dart';

class StatsController extends ChangeNotifier {
  final StatsService _service = StatsService();

  Stats? stats;
  bool isLoading = false;
  String? errorMessage;

  // Período selecionado para o gráfico de linha: 7, 15 ou 30
  int selectedPeriod = 7;

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      stats = await _service.getStats();
    } catch (e) {
      errorMessage = 'Erro ao carregar estatísticas';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(int days) {
    selectedPeriod = days;
    notifyListeners();
  }

  Map<String, int> get currentDailyMap {
    if (stats == null) return {};
    switch (selectedPeriod) {
      case 7:
        return stats!.dailyCompletions7Days;
      case 15:
        return stats!.dailyCompletions15Days;
      case 30:
      default:
        return stats!.dailyCompletions30Days;
    }
  }

  int get currentTotal {
    if (stats == null) return 0;
    switch (selectedPeriod) {
      case 7:
        return stats!.completedLast7Days;
      case 15:
        return stats!.completedLast15Days;
      case 30:
      default:
        return stats!.completedLast30Days;
    }
  }
}