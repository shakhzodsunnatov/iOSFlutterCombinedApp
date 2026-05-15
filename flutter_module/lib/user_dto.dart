import 'package:flutter/foundation.dart';

@immutable
class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.source,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String source; // "ios" | "flutter"
  final DateTime createdAt;

  bool get isFromFlutter => source == 'flutter';

  static UserDto? fromMap(Object? raw) {
    if (raw is! Map) return null;
    try {
      final m = Map<String, dynamic>.from(raw as Map);
      final createdAt = DateTime.tryParse(m['createdAt'] as String? ?? '') ?? DateTime.now();
      return UserDto(
        id: m['id'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
        source: m['source'] as String,
        createdAt: createdAt,
      );
    } catch (_) {
      return null;
    }
  }
}
