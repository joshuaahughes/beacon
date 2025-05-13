import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            subtitle: Text('Version 1.0.0'),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help & Support'),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
          ),
        ],
      ),
    );
  }
} 