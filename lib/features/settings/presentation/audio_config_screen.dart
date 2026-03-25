import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/module_config.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class AudioConfigScreen extends ConsumerStatefulWidget {
  const AudioConfigScreen({super.key});

  @override
  ConsumerState<AudioConfigScreen> createState() => _AudioConfigScreenState();
}

class _AudioConfigScreenState extends ConsumerState<AudioConfigScreen> {
  final _pttPinController = TextEditingController();
  final _i2sWsController = TextEditingController();
  final _i2sSdController = TextEditingController();
  final _i2sDinController = TextEditingController();
  final _i2sSckController = TextEditingController();

  bool _codec2Enabled = false;
  ModuleConfig_AudioConfig_Audio_Baud _bitrate =
      ModuleConfig_AudioConfig_Audio_Baud.CODEC2_DEFAULT;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsServiceProvider).requestModuleConfig(
        AdminMessage_ModuleConfigType.AUDIO_CONFIG,
      );
      final config = ref.read(moduleConfigProvider);
      if (config != null && config.hasAudio()) {
        _loadFromConfig(config.audio);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(ModuleConfig_AudioConfig audio) {
    _codec2Enabled = audio.codec2Enabled;
    _pttPinController.text = audio.pttPin.toString();
    _bitrate = audio.bitrate;
    _i2sWsController.text = audio.i2sWs.toString();
    _i2sSdController.text = audio.i2sSd.toString();
    _i2sDinController.text = audio.i2sDin.toString();
    _i2sSckController.text = audio.i2sSck.toString();
  }

  @override
  void dispose() {
    _pttPinController.dispose();
    _i2sWsController.dispose();
    _i2sSdController.dispose();
    _i2sDinController.dispose();
    _i2sSckController.dispose();
    super.dispose();
  }

  void _save() {
    final audioConfig = ModuleConfig_AudioConfig(
      codec2Enabled: _codec2Enabled,
      pttPin: int.tryParse(_pttPinController.text) ?? 0,
      bitrate: _bitrate,
      i2sWs: int.tryParse(_i2sWsController.text) ?? 0,
      i2sSd: int.tryParse(_i2sSdController.text) ?? 0,
      i2sDin: int.tryParse(_i2sDinController.text) ?? 0,
      i2sSck: int.tryParse(_i2sSckController.text) ?? 0,
    );

    final config = ModuleConfig(audio: audioConfig);
    ref.read(settingsServiceProvider).setModuleConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Audio Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ModuleConfig?>(moduleConfigProvider, (previous, next) {
      if (next != null && next.hasAudio()) {
        _loadFromConfig(next.audio);
        setState(() {});
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Audio Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Codec2 Enabled'),
            subtitle: const Text('Enable voice encoding'),
            value: _codec2Enabled,
            onChanged: (val) => setState(() => _codec2Enabled = val),
          ),
          const Divider(),
          TextField(
            controller: _pttPinController,
            decoration: const InputDecoration(
              labelText: 'PTT Pin',
              helperText: 'GPIO for Push-to-Talk',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ModuleConfig_AudioConfig_Audio_Baud>(
            value: _bitrate,
            decoration: const InputDecoration(labelText: 'Bitrate'),
            items: ModuleConfig_AudioConfig_Audio_Baud.values.map((b) {
              return DropdownMenuItem(value: b, child: Text(b.name));
            }).toList(),
            onChanged: (val) => setState(() => _bitrate = val!),
          ),
          const Divider(),
          const Text('I2S Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(
            controller: _i2sWsController,
            decoration: const InputDecoration(labelText: 'I2S Word Select (WS)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _i2sSdController,
            decoration: const InputDecoration(labelText: 'I2S Data OUT (SD)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _i2sDinController,
            decoration: const InputDecoration(labelText: 'I2S Data IN (DIN)'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _i2sSckController,
            decoration: const InputDecoration(labelText: 'I2S Clock (SCK)'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
