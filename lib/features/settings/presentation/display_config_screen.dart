import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/settings/data/services/settings_service.dart';

class DisplayConfigScreen extends ConsumerStatefulWidget {
  const DisplayConfigScreen({super.key});

  @override
  ConsumerState<DisplayConfigScreen> createState() =>
      _DisplayConfigScreenState();
}

class _DisplayConfigScreenState extends ConsumerState<DisplayConfigScreen> {
  final _screenOnSecsController = TextEditingController();
  final _autoScreenCarouselSecsController = TextEditingController();

  bool _flipScreen = false;
  bool _headingBold = false;
  bool _wakeOnTapOrMotion = false;
  bool _use12hClock = false;
  bool _useLongNodeName = false;
  bool _enableMessageBubbles = false;
  Config_DisplayConfig_DisplayUnits _units =
      Config_DisplayConfig_DisplayUnits.METRIC;
  Config_DisplayConfig_OledType _oled = Config_DisplayConfig_OledType.OLED_AUTO;
  Config_DisplayConfig_DisplayMode _displaymode =
      Config_DisplayConfig_DisplayMode.DEFAULT;
  Config_DisplayConfig_CompassOrientation _compassOrientation =
      Config_DisplayConfig_CompassOrientation.DEGREES_0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final config = ref.read(deviceConfigProvider);
      if (config != null && config.hasDisplay()) {
        _loadFromConfig(config.display);
        setState(() {});
      }
    });
  }

  void _loadFromConfig(Config_DisplayConfig display) {
    _screenOnSecsController.text = display.screenOnSecs.toString();
    _autoScreenCarouselSecsController.text = display.autoScreenCarouselSecs
        .toString();
    _flipScreen = display.flipScreen;
    _headingBold = display.headingBold;
    _wakeOnTapOrMotion = display.wakeOnTapOrMotion;
    _use12hClock = display.use12hClock;
    _useLongNodeName = display.useLongNodeName;
    _enableMessageBubbles = display.enableMessageBubbles;
    _units = display.hasUnits()
        ? display.units
        : Config_DisplayConfig_DisplayUnits.METRIC;
    _oled = display.hasOled()
        ? display.oled
        : Config_DisplayConfig_OledType.OLED_AUTO;
    _displaymode = display.hasDisplaymode()
        ? display.displaymode
        : Config_DisplayConfig_DisplayMode.DEFAULT;
    _compassOrientation = display.hasCompassOrientation()
        ? display.compassOrientation
        : Config_DisplayConfig_CompassOrientation.DEGREES_0;
  }

  @override
  void dispose() {
    _screenOnSecsController.dispose();
    _autoScreenCarouselSecsController.dispose();
    super.dispose();
  }

  void _save() {
    final displayConfig = Config_DisplayConfig(
      screenOnSecs: int.tryParse(_screenOnSecsController.text) ?? 60,
      autoScreenCarouselSecs:
          int.tryParse(_autoScreenCarouselSecsController.text) ?? 0,
      flipScreen: _flipScreen,
      units: _units,
      oled: _oled,
      displaymode: _displaymode,
      headingBold: _headingBold,
      wakeOnTapOrMotion: _wakeOnTapOrMotion,
      compassOrientation: _compassOrientation,
      use12hClock: _use12hClock,
      useLongNodeName: _useLongNodeName,
      enableMessageBubbles: _enableMessageBubbles,
    );

    final config = Config(display: displayConfig);
    ref.read(settingsServiceProvider).setConfig(config);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved Display Config')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Config?>(deviceConfigProvider, (previous, next) {
      if (next != null && next.hasDisplay()) {
        _loadFromConfig(next.display);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Display Config')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _screenOnSecsController,
            decoration: const InputDecoration(
              labelText: 'Screen On (seconds)',
              helperText: '0 for default (1 min), MAXUINT for always on',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _autoScreenCarouselSecsController,
            decoration: const InputDecoration(
              labelText: 'Auto Screen Carousel (seconds)',
              helperText: '0 to disable, for devices without buttons',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Flip Screen'),
            subtitle: const Text('Flip vertically for upside-down mounting'),
            value: _flipScreen,
            onChanged: (val) => setState(() => _flipScreen = val),
          ),
          SwitchListTile(
            title: const Text('Heading Bold'),
            subtitle: const Text('Bold first line'),
            value: _headingBold,
            onChanged: (val) => setState(() => _headingBold = val),
          ),
          SwitchListTile(
            title: const Text('Wake On Tap/Motion'),
            value: _wakeOnTapOrMotion,
            onChanged: (val) => setState(() => _wakeOnTapOrMotion = val),
          ),
          SwitchListTile(
            title: const Text('Use 12h Clock'),
            value: _use12hClock,
            onChanged: (val) => setState(() => _use12hClock = val),
          ),
          SwitchListTile(
            title: const Text('Use Long Node Name'),
            value: _useLongNodeName,
            onChanged: (val) => setState(() => _useLongNodeName = val),
          ),
          SwitchListTile(
            title: const Text('Enable Message Bubbles'),
            value: _enableMessageBubbles,
            onChanged: (val) => setState(() => _enableMessageBubbles = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_DisplayConfig_DisplayUnits>(
            value: _units,
            decoration: const InputDecoration(labelText: 'Display Units'),
            items: Config_DisplayConfig_DisplayUnits.values.map((u) {
              return DropdownMenuItem(value: u, child: Text(u.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _units = val);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_DisplayConfig_OledType>(
            value: _oled,
            decoration: const InputDecoration(labelText: 'OLED Type'),
            items: Config_DisplayConfig_OledType.values.map((o) {
              return DropdownMenuItem(value: o, child: Text(o.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _oled = val);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_DisplayConfig_DisplayMode>(
            value: _displaymode,
            decoration: const InputDecoration(labelText: 'Display Mode'),
            items: Config_DisplayConfig_DisplayMode.values.map((m) {
              return DropdownMenuItem(value: m, child: Text(m.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _displaymode = val);
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Config_DisplayConfig_CompassOrientation>(
            value: _compassOrientation,
            decoration: const InputDecoration(labelText: 'Compass Orientation'),
            items: Config_DisplayConfig_CompassOrientation.values.map((c) {
              return DropdownMenuItem(value: c, child: Text(c.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _compassOrientation = val);
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
    );
  }
}
