import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class LoraConfigScreen extends ConsumerStatefulWidget {
  const LoraConfigScreen({super.key});

  @override
  ConsumerState<LoraConfigScreen> createState() => _LoraConfigScreenState();
}

class _LoraConfigScreenState extends ConsumerState<LoraConfigScreen> {
  final _hopLimitController = TextEditingController();
  Config_LoRaConfig_RegionCode _selectedRegion = Config_LoRaConfig_RegionCode.UNSET;

  @override
  void initState() {
    super.initState();
    // In a real app we would load the initial values when the screen loads,
    // or request them from the service.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasLora()) {
        _hopLimitController.text = config.lora.hopLimit.toString();
        _selectedRegion = config.lora.region;
        setState(() {});
      } else {
        // Request the config if not loaded
      }
    });
  }

  @override
  void dispose() {
    _hopLimitController.dispose();
    super.dispose();
  }

  void _save() {
    final hopLimit = int.tryParse(_hopLimitController.text) ?? 3;
    
    final loraConfig = Config_LoRaConfig(
      region: _selectedRegion,
      hopLimit: hopLimit,
    );
    
    final config = Config(lora: loraConfig);
    ref.read(settingsServiceProvider).setConfig(config);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved LoRa Config')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to updates
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasLora()) {
        if (_hopLimitController.text.isEmpty || previous == null) {
          _hopLimitController.text = next.lora.hopLimit.toString();
        }
        if (_selectedRegion == Config_LoRaConfig_RegionCode.UNSET) {
          _selectedRegion = next.lora.region;
        }
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('LoRa Config'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<Config_LoRaConfig_RegionCode>(
            value: _selectedRegion,
            decoration: const InputDecoration(labelText: 'Region'),
            items: Config_LoRaConfig_RegionCode.values.map((region) {
              return DropdownMenuItem(
                value: region,
                child: Text(region.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedRegion = val);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _hopLimitController,
            decoration: const InputDecoration(labelText: 'Hop Limit'),
            keyboardType: TextInputType.number,
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
