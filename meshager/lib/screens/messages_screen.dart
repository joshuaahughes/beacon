import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meshtastic_provider.dart';
import '../models/channel.dart';
import 'conversation_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          Consumer<MeshtasticProvider>(
            builder: (context, provider, child) {
              if (provider.connectedDevice == null) {
                return IconButton(
                  icon: const Icon(Icons.bluetooth_searching),
                  onPressed: () {
                    // TODO: Navigate to device scan screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please connect to a device first'),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MeshtasticProvider>(
        builder: (context, provider, child) {
          if (provider.connectedDevice == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No device connected',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect to a Meshtastic device to start messaging',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to device scan screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please connect to a device first'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bluetooth_searching),
                    label: const Text('Connect Device'),
                  ),
                ],
              ),
            );
          }

          if (provider.channels.isEmpty) {
            return const Center(
              child: Text('No channels yet'),
            );
          }
          
          return ListView.builder(
            itemCount: provider.channels.length,
            itemBuilder: (context, index) {
              final channel = provider.channels[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    channel.nodeId == null ? Icons.broadcast_on_personal : Icons.person,
                  ),
                ),
                title: Text(channel.name),
                subtitle: Text(
                  channel.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(channel.lastMessageTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (channel.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          channel.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConversationScreen(
                        channel: channel,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
} 