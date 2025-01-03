import 'package:flutter/foundation.dart';

@immutable
class DraftItem {
  final String id;
  final Map<String, dynamic> formData;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DraftItem({
    required this.id,
    required this.formData,
    required this.createdAt,
    required this.updatedAt,
  });

  DraftItem copyWith({
    String? id,
    Map<String, dynamic>? formData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DraftItem(
      id: id ?? this.id,
      formData: formData ?? this.formData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formData': formData,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DraftItem.fromJson(Map<String, dynamic> json) {
    return DraftItem(
      id: json['id'] as String,
      formData: json['formData'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
