class Milestone {
  final int? id;
  final String title;
  final String? description;
  final String? trimester;
  final String? weekRange;
  final bool completed;
  final String? category;
  final DateTime? timestamp;
  final bool hasNotes;
  final String? notes;

  Milestone({
    this.id,
    required this.title,
    this.description,
    this.trimester,
    this.weekRange,
    this.completed = false,
    this.category,
    this.timestamp,
    this.hasNotes = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'trimester': trimester,
      'week_range': weekRange,
      'completed': completed ? 1 : 0,
      'category': category,
      'timestamp': timestamp?.toString(),
      'has_notes': hasNotes ? 1 : 0,
      'notes': notes,
    };
  }

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      trimester: map['trimester'],
      weekRange: map['week_range'],
      completed: map['completed'] == 1,
      category: map['category'],
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : null,
      hasNotes: map['has_notes'] == 1,
      notes: map['notes'],
    );
  }

  Milestone copyWith({
    int? id,
    String? title,
    String? description,
    String? trimester,
    String? weekRange,
    bool? completed,
    String? category,
    DateTime? timestamp,
    bool? hasNotes,
    String? notes,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      trimester: trimester ?? this.trimester,
      weekRange: weekRange ?? this.weekRange,
      completed: completed ?? this.completed,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      hasNotes: hasNotes ?? this.hasNotes,
      notes: notes ?? this.notes,
    );
  }
}