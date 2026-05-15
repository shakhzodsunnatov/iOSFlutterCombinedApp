import 'dart:async';
import 'package:flutter/services.dart';
import 'user_dto.dart';

class UsersChannel {
  UsersChannel._();

  static const _method = MethodChannel('com.huh.nativeflutter/users');
  static const _event = EventChannel('com.huh.nativeflutter/users/stream');

  static Future<List<UserDto>> getUsers() async {
    final raw = await _method.invokeMethod<List<dynamic>>('getUsers');
    return _parseList(raw);
  }

  static Future<UserDto> createUser({
    required String name,
    required String email,
  }) async {
    final raw = await _method.invokeMethod<Object>(
      'createUser',
      {'name': name, 'email': email},
    );
    final user = UserDto.fromMap(raw);
    if (user == null) {
      throw PlatformException(code: 'parse_error', message: 'Invalid user payload from native');
    }
    return user;
  }

  static Future<void> deleteUser(String id) async {
    await _method.invokeMethod<bool>('deleteUser', {'id': id});
  }

  static Future<void> closeFlutter() async {
    await _method.invokeMethod<void>('closeFlutter');
  }

  static Stream<List<UserDto>> get userStream {
    return _event
        .receiveBroadcastStream()
        .map((event) => _parseList(event));
  }

  static List<UserDto> _parseList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map(UserDto.fromMap).whereType<UserDto>().toList();
  }
}
