import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/ui/shell/blank_screen.dart';
import 'package:beacon/data/services/mesh_data_service.dart';
import 'package:beacon/features/map/presentation/map_screen.dart';
import 'package:beacon/features/messaging/presentation/conversations_screen.dart';
import 'package:beacon/features/nodes/presentation/nodes_screen.dart';
import 'package:beacon/features/settings/presentation/settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 2; // Default to Map tab for this prototype

  final List<Widget> _tabs = [
    const ConversationsScreen(),
    const NodesScreen(),
    const MapScreen(), 
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Keep the parsing service alive globally
    ref.watch(meshDataServiceProvider);

    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined),
            selectedIcon: Icon(Icons.people_alt),
            label: 'Nodes',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
