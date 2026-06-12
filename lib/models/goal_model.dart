class Goal {
  final int? id;
  final String title;
  final int targetCount;
  final int periodDays;
  final int? tagId;
  final String? tagName;
  final String? tagColor;
  final bool active;
  final int? currentCount;
  final double? progressPercent;
  final bool? achieved;

  Goal({
    this.id,
    required this.title,
    required this.targetCount,
    required this.periodDays,
    this.tagId,
    this.tagName,
    this.tagColor,
    this.active = true,
    this.currentCount,
    this.progressPercent,
    this.achieved,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      targetCount: json['targetCount'],
      periodDays: json['periodDays'],
      tagId: json['tagId'],
      tagName: json['tagName'],
      tagColor: json['tagColor'],
      active: json['active'] ?? true,
      currentCount: json['currentCount'],
      progressPercent: json['progressPercent']?.toDouble(),
      achieved: json['achieved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'targetCount': targetCount,
      'periodDays': periodDays,
      if (tagId != null) 'tagId': tagId,
      'active': active,
    };
  }
}