import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class PowerConfigScreen extends ConsumerStatefulWidget {
  const PowerConfigScreen({super.key});

  @override
  ConsumerState<PowerConfigScreen> createState() => _PowerConfigScreenState();
}

class _PowerConfigScreenState extends ConsumerState<PowerConfigScreen> {
  final _onBatteryShutdownSecsController = TextEditingController();
  final _adcMultiplierController = TextEditingController();
  final _waitBluetoothSecsController = TextEditingController();
  final _sdsSecsController = TextEditingController();
  final _lsSecsController = TextEditingController();
  final _minWakeSecsController = TextEditingController();
  final _deviceBatteryInaAddressController = TextEditingController();

  bool _isPowerSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasPower()) {
        _loadFromConfig(config.power);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(Config_PowerConfig power) {
    _isPowerSaving = power.isPowerSaving;
    _onBatteryShutdownSecsController.text = power.onBatteryShutdownAfterSecs
        .toString();
    _adcMultiplierController.text = power.adcMultiplierOverride.toString();
    _waitBluetoothSecsController.text = power.waitBluetoothSecs.toString();
    _sdsSecsController.text = power.sdsSecs.toString();
    _lsSecsController.text = power.lsSecs.toString();
    _minWakeSecsController.text = power.minWakeSecs.toString();
    _deviceBatteryInaAddressController.text = power.deviceBatteryInaAddress
        .toString();
  }

  @override
  void dispose() {
    _onBatteryShutdownSecsController.dispose();
    _adcMultiplierController.dispose();
    _waitBluetoothSecsController.dispose();
    _sdsSecsController.dispose();
    _lsSecsController.dispose();
    _minWakeSecsController.dispose();
    _deviceBatteryInaAddressController.dispose();
    super.dispose();
  }

  void _save() {
    final powerConfig = Config_PowerConfig(
      isPowerSaving: _isPowerSaving,
      onBatteryShutdownAfterSecs:
          int.tryParse(_onBatteryShutdownSecsController.text) ?? 0,
      adcMultiplierOverride:
          double.tryParse(_adcMultiplierController.text) ?? 0,
      waitBluetoothSecs: int.tryParse(_waitBluetoothSecsController.text) ?? 0,
      sdsSecs: int.tryParse(_sdsSecsController.text) ?? 0,
      lsSecs: int.tryParse(_lsSecsController.text) ?? 0,
      minWakeSecs: int.tryParse(_minWakeSecsController.text) ?? 0,
      deviceBatteryInaAddress:
          int.tryParse(_deviceBatteryInaAddressController.text) ?? 0,
    );

    final config = Config(power: powerConfig);
    ref.read(settingsServiceProvider).setConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Power Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasPower()) {
        _loadFromConfig(next.power);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Power Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Power Saving'),
            subtitle: const Text('Sleep everything as much as possible'),
            value: _isPowerSaving,
            onChanged: (val) => setState(() => _isPowerSaving = val),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _onBatteryShutdownSecsController,
            decoration: const InputDecoration(
              labelText: 'On Battery Shutdown After (seconds)',
              helperText: '0 for default (1 year)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _adcMultiplierController,
            decoration: const InputDecoration(
              labelText: 'ADC Multiplier Override',
              helperText: 'Ratio of voltage divider (2-6)',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _waitBluetoothSecsController,
            decoration: const InputDecoration(
              labelText: 'Wait Bluetooth (seconds)',
              helperText: '0 for default (1 minute)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _sdsSecsController,
            decoration: const InputDecoration(
              labelText: 'Super Deep Sleep (seconds)',
              helperText: '0 for default (1 year)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _lsSecsController,
            decoration: const InputDecoration(
              labelText: 'Light Sleep (seconds)',
              helperText: '0 for default (300)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _minWakeSecsController,
            decoration: const InputDecoration(
              labelText: 'Min Wake (seconds)',
              helperText: '0 for default (10)',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _deviceBatteryInaAddressController,
            decoration: const InputDecoration(
              labelText: 'Battery INA Address (I2C)',
              helperText: 'I2C address for battery voltage',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
