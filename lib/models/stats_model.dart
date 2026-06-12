import 'goal_model.dart';

class TagStat {
  final int tagId;
  final String tagName;
  final String tagColor;
  final int completedCount;

  TagStat({
    required this.tagId,
    required this.tagName,
    required this.tagColor,
    required this.completedCount,
  });

  factory TagStat.fromJson(Map<String, dynamic> json) {
    return TagStat(
      tagId: json['tagId'],
      tagName: json['tagName'],
      tagColor: json['tagColor'],
      completedCount: json['completedCount'],
    );
  }
}

class Stats {
  final int completedLast7Days;
  final int completedLast15Days;
  final int completedLast30Days;
  final Map<String, int> dailyCompletions7Days;
  final Map<String, int> dailyCompletions15Days;
  final Map<String, int> dailyCompletions30Days;
  final List<TagStat> completionsByTag;
  final List<Goal> goalsProgress;

  Stats({
    required this.completedLast7Days,
    required this.completedLast15Days,
    required this.completedLast30Days,
    required this.dailyCompletions7Days,
    required this.dailyCompletions15Days,
    required this.dailyCompletions30Days,
    required this.completionsByTag,
    required this.goalsProgress,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    Map<String, int> parseDaily(Map<String, dynamic>? raw) {
      if (raw == null) return {};
      return raw.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return Stats(
      completedLast7Days: json['completedLast7Days'] ?? 0,
      completedLast15Days: json['completedLast15Days'] ?? 0,
      completedLast30Days: json['completedLast30Days'] ?? 0,
      dailyCompletions7Days: parseDaily(json['dailyCompletions7Days']),
      dailyCompletions15Days: parseDaily(json['dailyCompletions15Days']),
      dailyCompletions30Days: parseDaily(json['dailyCompletions30Days']),
      completionsByTag: (json['completionsByTag'] as List? ?? [])
          .map((e) => TagStat.fromJson(e))
          .toList(),
      goalsProgress: (json['goalsProgress'] as List? ?? [])
          .map((e) => Goal.fromJson(e))
          .toList(),
    );
  }
}