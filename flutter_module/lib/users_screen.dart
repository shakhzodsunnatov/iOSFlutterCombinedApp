import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_dto.dart';
import 'users_channel.dart';
import 'create_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<UserDto> _users = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<UserDto>>? _sub;

  @override
  void initState() {
    super.initState();
    _subscribeToStream();
    _loadInitial();
  }

  void _subscribeToStream() {
    _sub = UsersChannel.userStream.listen(
      (users) {
        if (!mounted) return;
        setState(() {
          _users = users;
          _loading = false;
          _error = null;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = e is PlatformException ? (e.message ?? 'Stream error') : e.toString();
        });
      },
    );
  }

  Future<void> _loadInitial() async {
    try {
      final users = await UsersChannel.getUsers();
      if (!mounted) return;
      // Fallback: only apply if the EventChannel hasn't delivered yet.
      if (_loading) {
        setState(() {
          _users = users;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (_loading) {
        setState(() {
          _loading = false;
          _error = e is PlatformException ? (e.message ?? 'Load failed') : e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _closeFlutter() async {
    try {
      await UsersChannel.closeFlutter();
    } catch (_) {}
  }

  Future<void> _confirmDelete(UserDto user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user?'),
        content: Text('Remove "${user.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await UsersChannel.deleteUser(user.id);
    } catch (e) {
      if (!mounted) return;
      final msg = e is PlatformException ? (e.message ?? 'Delete failed') : 'Delete failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _openCreateScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CreateUserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Back to iOS',
            icon: const Icon(Icons.close),
            onPressed: _closeFlutter,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateScreen,
        tooltip: 'Add user',
        child: const Icon(Icons.add),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: cs.error),
              const SizedBox(height: 16),
              Text(
                'Could not load users',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: cs.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 72, color: cs.outlineVariant),
            const SizedBox(height: 20),
            Text(
              'No users yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.outline,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap + to add the first one.',
              style: TextStyle(color: cs.outlineVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _users.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (ctx, i) => _UserTile(
        user: _users[i],
        onDelete: _confirmDelete,
      ),
    );
  }
}

// ── User list tile ──────────────────────────────────────────────────────────

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onDelete});

  final UserDto user;
  final Future<void> Function(UserDto) onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFlutter = user.isFromFlutter;

    final sourceColor = isFlutter ? const Color(0xFF0468D7) : const Color(0xFF34C759);
    final sourceLabel = isFlutter ? 'Flutter' : 'iOS';
    final sourceIcon = isFlutter ? Icons.flutter_dash : Icons.phone_iphone;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: sourceColor.withAlpha(30),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: TextStyle(color: sourceColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user.email,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(sourceIcon, size: 13, color: sourceColor),
              const SizedBox(width: 3),
              Text(
                sourceLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: sourceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(user.createdAt),
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
            ],
          ),
        ],
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: cs.error),
        tooltip: 'Delete',
        onPressed: () => onDelete(user),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final t = dt.toLocal();
    final mo = t.month.toString().padLeft(2, '0');
    final d = t.day.toString().padLeft(2, '0');
    final h = t.hour.toString().padLeft(2, '0');
    final mi = t.minute.toString().padLeft(2, '0');
    return '${t.year}-$mo-$d  $h:$mi';
  }
}
