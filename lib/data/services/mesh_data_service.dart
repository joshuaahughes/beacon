import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:beacon/core/proto/gen/meshtastic/mesh.pb.dart';
import 'package:beacon/core/proto/gen/meshtastic/portnums.pbenum.dart';
import 'package:beacon/domain/models/node_model.dart';
import 'package:beacon/data/providers/ble_providers.dart';
import 'package:beacon/data/providers/database_providers.dart';

class MeshDataService {
  final Ref ref;
  StreamSubscription<FromRadio>? _subscription;

  MeshDataService(this.ref) {
    _init();
  }

  void _init() {
    final repo = ref.read(bleRepositoryProvider);
    _subscription = repo.incomingMessages.listen(_onFromRadio);
  }

  void _onFromRadio(FromRadio fromRadio) async {
    if (!fromRadio.hasPacket()) return;
    final packet = fromRadio.packet;
    
    // Check if packet has decoded payload
    if (packet.hasDecoded()) {
      final decoded = packet.decoded;
      final senderNum = packet.from; 
      
      final nodeRepo = await ref.read(nodeRepositoryProvider.future);
      var node = await nodeRepo.getNodeByNumId(senderNum);
      
      bool updated = false;
      
      if (node == null) {
        // Create an empty node if we don't know it yet
        node = MeshNode(numId: senderNum, longName: 'Unknown-$senderNum', shortName: 'UNK');
        updated = true;
      }

      node.lastHeard = DateTime.now();
      updated = true;

      if (decoded.portnum == PortNum.POSITION_APP) {
        try {
          final pos = Position.fromBuffer(decoded.payload);
          
          if (pos.hasLatitudeI() && pos.hasLongitudeI()) {
             node.latitude = pos.latitudeI * 1e-7;
             node.longitude = pos.longitudeI * 1e-7;
             
             if (pos.hasAltitude()) {
               node.altitude = pos.altitude.toDouble();
             }
             
             debugPrint('Decoded Position for $senderNum: ${node.latitude}, ${node.longitude}');
          }
        } catch (e) {
          debugPrint('Error parsing POSITION_APP payload: $e');
        }
      } else if (decoded.portnum == PortNum.NODEINFO_APP) {
        try {
          final user = User.fromBuffer(decoded.payload);
          if (user.hasLongName()) node.longName = user.longName;
          if (user.hasShortName()) node.shortName = user.shortName;
          if (user.hasHwModel()) node.hardwareModel = user.hwModel.name;
          
          debugPrint('Decoded NodeInfo for $senderNum: ${node.longName}');
        } catch (e) {
          debugPrint('Error parsing NODEINFO_APP payload: $e');
        }
      }
      
      if (updated) {
        await nodeRepo.saveNode(node);
        // Alert the UI that the nodes have changed
        ref.invalidate(nodesProvider);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}

final meshDataServiceProvider = Provider<MeshDataService>((ref) {
  final service = MeshDataService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
