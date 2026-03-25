import 'package:flutter/material.dart';
import 'package:beacon/features/settings/presentation/mqtt_config_screen.dart';
import 'package:beacon/features/settings/presentation/serial_config_screen.dart';
import 'package:beacon/features/settings/presentation/store_forward_config_screen.dart';
import 'package:beacon/features/settings/presentation/range_test_config_screen.dart';
import 'package:beacon/features/settings/presentation/external_notification_config_screen.dart';
import 'package:beacon/features/settings/presentation/telemetry_config_screen.dart';
import 'package:beacon/features/settings/presentation/canned_message_config_screen.dart';
import 'package:beacon/features/settings/presentation/audio_config_screen.dart';
import 'package:beacon/features/settings/presentation/remote_hardware_config_screen.dart';
import 'package:beacon/features/settings/presentation/neighbor_info_config_screen.dart';
import 'package:beacon/features/settings/presentation/ambient_lighting_config_screen.dart';
import 'package:beacon/features/settings/presentation/detection_sensor_config_screen.dart';
import 'package:beacon/features/settings/presentation/paxcounter_config_screen.dart';
import 'package:beacon/features/settings/presentation/status_message_config_screen.dart';
import 'package:beacon/features/settings/presentation/traffic_management_config_screen.dart';
import 'package:beacon/features/settings/presentation/tak_config_screen.dart';

class ModuleConfigHubScreen extends StatelessWidget {
  const ModuleConfigHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module Configuration')),
      body: ListView(
        children: [
          _buildItem(
            context,
            Icons.cloud_outlined,
            'MQTT',
            'MQTT Client, Server, JSON',
            const MqttConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.usb_outlined,
            'Serial',
            'Baud rate, Mode, Serial console',
            const SerialConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.storage_outlined,
            'Store & Forward',
            'Mesh history, Periodic broadcast',
            const StoreForwardConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.speed_outlined,
            'Range Test',
            'Automated signal testing',
            const RangeTestConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.notifications_active_outlined,
            'External Notification',
            'Buzzer, LED, Screen alert',
            const ExternalNotificationConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.analytics_outlined,
            'Telemetry',
            'Environment, Power, Air Quality',
            const TelemetryConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.message_outlined,
            'Canned Message',
            'Predetermined text responses',
            const CannedMessageConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.audiotrack_outlined,
            'Audio',
            'Codec2, Voice, I2S',
            const AudioConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.settings_remote_outlined,
            'Remote Hardware',
            'GPIO read/write access',
            const RemoteHardwareConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.people_outline,
            'Neighbor Info',
            'Mesh node discovery',
            const NeighborInfoConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.light_mode_outlined,
            'Ambient Lighting',
            'LED current, RGB color',
            const AmbientLightingConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.sensors_outlined,
            'Detection Sensor',
            'GPIO trigger, State broadcast',
            const DetectionSensorConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.group_outlined,
            'Paxcounter',
            'BLE/WiFi device counting',
            const PaxcounterConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.short_text_outlined,
            'Status Message',
            'Custom node status text',
            const StatusMessageConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.traffic_outlined,
            'Traffic Management',
            'Rate limiting, Dedup, Throttling',
            const TrafficManagementConfigScreen(),
          ),
          _buildItem(
            context,
            Icons.map_outlined,
            'TAK',
            'ATAK, Team color, Role',
            const TakConfigScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
