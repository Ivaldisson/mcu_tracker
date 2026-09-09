class ContentItem {
  final int id;
  final DateTime updatedAt;
  final String title;
  final String mediaType;
  final String? era;
  final String importance;
  final int runtimeMinutes;
  final DateTime? storyDate;
  final int? chronologicalOrder;
  final DateTime? releaseDate;
  final bool timeyWimey;

  ContentItem({
    required this.id,
    required this.updatedAt,
    required this.title,
    required this.mediaType,
    this.era,
    required this.importance,
    required this.runtimeMinutes,
    this.storyDate,
    this.chronologicalOrder,
    this.releaseDate,
    required this.timeyWimey,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      id: json['id'],
      updatedAt: DateTime.parse(json['updated_at']),
      title: json['title'],
      mediaType: json['media_type'],
      era: json['era'],
      importance: json['importance'],
      runtimeMinutes: json['runtime_minutes'],
      storyDate: json['story_date'] != null ? DateTime.parse(json['story_date']) : null,
      chronologicalOrder: json['chronological_order'],
      releaseDate: json['release_date'] != null ? DateTime.parse(json['release_date']) : null,
      timeyWimey: json['timey_wimey'],
    );
  }

  factory ContentItem.fromDb(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'],
      updatedAt: DateTime.parse(map['updated_at']),
      title: map['title'],
      mediaType: map['media_type'],
      era: map['era'],
      importance: map['importance'],
      runtimeMinutes: map['runtime_minutes'],
      storyDate: map['story_date'] != null ? DateTime.parse(map['story_date']) : null,
      chronologicalOrder: map['chronological_order'],
      releaseDate: map['release_date'] != null ? DateTime.parse(map['release_date']) : null,
      timeyWimey: map['timey_wimey'] == 1,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'id': id,
      'updated_at': updatedAt.toIso8601String(),
      'title': title,
      'media_type': mediaType,
      'era': era,
      'importance': importance,
      'runtime_minutes': runtimeMinutes,
      'story_date': storyDate?.toIso8601String(),
      'chronological_order': chronologicalOrder,
      'release_date': releaseDate?.toIso8601String(),
      'timey_wimey': timeyWimey ? 1 : 0,
    };
  }
}
