import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class UserConfigScreen extends ConsumerStatefulWidget {
  const UserConfigScreen({super.key});

  @override
  ConsumerState<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends ConsumerState<UserConfigScreen> {
  final _longNameController = TextEditingController();
  final _shortNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(nodeUserProvider);
      if (user != null) {
        _longNameController.text = user.longName;
        _shortNameController.text = user.shortName;
        setState(() {});
      } else {
        ref.read(settingsServiceProvider).requestOwner();
      }
    });
  }

  @override
  void dispose() {
    _longNameController.dispose();
    _shortNameController.dispose();
    super.dispose();
  }

  void _save() {
    final longName = _longNameController.text;
    final shortName = _shortNameController.text;
    
    final user = (ref.read(nodeUserProvider) ?? User())
      ..longName = longName
      ..shortName = shortName;
    
    ref.read(settingsServiceProvider).setOwner(user);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved User Config')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<User?>(nodeUserProvider, (previous, next) {
      if (next != null) {
        if (_longNameController.text.isEmpty || previous == null) {
          _longNameController.text = next.longName;
          _shortNameController.text = next.shortName;
          setState(() {});
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _longNameController,
            decoration: const InputDecoration(
              labelText: 'Node Name (Long Name)',
              helperText: 'Max 30 characters',
            ),
            maxLength: 30,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _shortNameController,
            decoration: const InputDecoration(
              labelText: 'Initials (Short Name)',
              helperText: 'Max 4 characters',
            ),
            maxLength: 4,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
