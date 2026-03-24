import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/portnums.pbenum.dart';
import 'package:beacon/core/proto/gen/meshtastic/admin.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/config.pb.dart';
import 'package:beacon/features/ble/data/repositories/ble_repository.dart';
import 'package:beacon/data/providers/ble_providers.dart';

class DeviceConfigNotifier extends Notifier<Config?> {
  @override
  Config? build() => null;
  
  void setConfig(Config? config) {
    state = config;
  }
}

final deviceConfigProvider = NotifierProvider<DeviceConfigNotifier, Config?>(DeviceConfigNotifier.new);

class NodeUserNotifier extends Notifier<User?> {
  @override
  User? build() => null;
  
  void setUser(User? user) {
    state = user;
  }
}

final nodeUserProvider = NotifierProvider<NodeUserNotifier, User?>(NodeUserNotifier.new);

class SettingsService {
  final Ref ref;
  StreamSubscription<FromRadio>? _subscription;

  SettingsService(this.ref) {
    _init();
  }

  void _init() {
    final repo = ref.read(bleRepositoryProvider);
    _subscription = repo.incomingMessages.listen(_onFromRadio);
  }

  void _onFromRadio(FromRadio fromRadio) {
    if (!fromRadio.hasPacket()) return;
    final packet = fromRadio.packet;
    
    if (packet.hasDecoded() && packet.decoded.portnum == PortNum.ADMIN_APP) {
      try {
        final adminMsg = AdminMessage.fromBuffer(packet.decoded.payload);
        
        if (adminMsg.hasGetConfigResponse()) {
          ref.read(deviceConfigProvider.notifier).setConfig(adminMsg.getConfigResponse);
        } else if (adminMsg.hasGetOwnerResponse()) {
          ref.read(nodeUserProvider.notifier).setUser(adminMsg.getOwnerResponse);
        }
      } catch (e) {
        debugPrint('Error parsing ADMIN_APP payload: $e');
      }
    }
  }

  Future<void> requestOwner() async {
    final adminMsg = AdminMessage(getOwnerRequest: true);
    await _sendAdminMessage(adminMsg);
  }

  Future<void> setOwner(User user) async {
    final adminMsg = AdminMessage(setOwner: user);
    await _sendAdminMessage(adminMsg);
    // Optimistic update
    ref.read(nodeUserProvider.notifier).setUser(user);
  }

  Future<void> requestConfig(AdminMessage_ConfigType type) async {
    final adminMsg = AdminMessage(
      getConfigRequest: type,
    );
    await _sendAdminMessage(adminMsg);
  }

  Future<void> setConfig(Config config) async {
    final adminMsg = AdminMessage(
      setConfig: config,
    );
    await _sendAdminMessage(adminMsg);
    // Optimistic update
    ref.read(deviceConfigProvider.notifier).setConfig(config);
  }

  Future<void> _sendAdminMessage(AdminMessage adminMsg) async {
    final repo = ref.read(bleRepositoryProvider);
    
    final data = Data(
      portnum: PortNum.ADMIN_APP,
      payload: adminMsg.writeToBuffer(),
    );
    
    final meshPacket = MeshPacket(
      decoded: data,
    );
    
    final toRadio = ToRadio(
      packet: meshPacket,
    );
    
    await repo.sendToRadio(toRadio);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final service = SettingsService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
