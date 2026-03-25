import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/atak.pbenum.dart' as atak;
import 'package:beacon/features/settings/data/services/settings_service.dart';

class TakConfigScreen extends ConsumerStatefulWidget {
  const TakConfigScreen({super.key});

  @override
  ConsumerState<TakConfigScreen> createState() => _TakConfigScreenState();
}

class _TakConfigScreenState extends ConsumerState<TakConfigScreen> {
  atak.Team _team = atak.Team.Unspecifed_Color;
  atak.MemberRole _role = atak.MemberRole.Unspecifed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.TAK_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasTak()) {
        _loadFromConfig(config.tak);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_TAKConfig takCfg) {
    _team = takCfg.team;
    _role = takCfg.role;
  }

  void _save() {
    final takConfig = ModuleConfig_TAKConfig(
      team: _team,
      role: _role,
    );

    final config = ModuleConfig(tak: takConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved TAK Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasTak()) {
        _loadFromConfig(next.tak);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('TAK Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'ATAK Integration',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<atak.Team>(
            value: _team,
            decoration: const InputDecoration(labelText: 'Team Color'),
            items: atak.Team.values.map((t) {
              return DropdownMenuItem(value: t, child: Text(t.name));
            }).toList(),
            onChanged: (val) => setState(() => _team = val!),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<atak.MemberRole>(
            value: _role,
            decoration: const InputDecoration(labelText: 'Member Role'),
            items: atak.MemberRole.values.map((r) {
              return DropdownMenuItem(value: r, child: Text(r.name));
            }).toList(),
            onChanged: (val) => setState(() => _role = val!),
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
