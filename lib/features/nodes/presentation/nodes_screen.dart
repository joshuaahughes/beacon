import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/data/providers/database_providers.dart';
import 'package:intl/intl.dart';

class NodesScreen extends ConsumerWidget {
  const NodesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(nodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nodes'),
      ),
      body: nodesAsync.when(
        data: (nodes) {
          if (nodes.isEmpty) {
            return const Center(child: Text('No nodes discovered yet.'));
          }

          return ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (context, index) {
              final node = nodes[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(node.shortName),
                ),
                title: Text(node.longName),
                subtitle: Text('ID: ${node.numId} • ${node.hardwareModel}'),
                trailing: node.lastHeard != null 
                  ? Text(DateFormat('HH:mm').format(node.lastHeard!)) 
                  : null,
                onTap: () {
                  // TODO: Node Details
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
