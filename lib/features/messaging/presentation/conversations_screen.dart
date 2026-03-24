import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/data/providers/database_providers.dart';
import 'package:intl/intl.dart';
import 'package:beacon/features/messaging/presentation/message_thread_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For the prototype, we show a fixed list of common channels
    final channels = [0, 1, 2]; // Map to Meshtastic channel indices

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: ListView.builder(
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channelIdx = channels[index];
          final messagesAsync = ref.watch(channelMessagesProvider(channelIdx));

          return messagesAsync.when(
            data: (messages) {
              final lastMessage = messages.isNotEmpty ? messages.last.textPayload : 'No messages yet';
              final time = messages.isNotEmpty ? DateFormat('HH:mm').format(messages.last.timestamp) : '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(channelIdx == 0 ? 'P' : '$channelIdx'),
                ),
                title: Text(channelIdx == 0 ? 'Primary Channel' : 'Channel $channelIdx'),
                subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(time),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MessageThreadScreen(channelIndex: channelIdx),
                    ),
                  );
                },
              );
            },
            loading: () => const ListTile(title: LinearProgressIndicator()),
            error: (err, stack) => ListTile(title: Text('Error: $err')),
          );
        },
      ),
    );
  }
}

// Removed MessageBubble from here as it's now in message_thread_screen.dart

