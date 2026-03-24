class MeshNode {
  int? id; // SQLite internal ID

  int numId; // Meshtastic core Node Number Identifier
  String longName;
  String shortName;
  String hardwareModel;
  
  // GPS/Map Data
  double? latitude;
  double? longitude;
  double? altitude;

  int? batteryLevel;
  DateTime? lastHeard;

  MeshNode({
    this.id,
    required this.numId,
    required this.longName,
    required this.shortName,
    this.hardwareModel = '',
    this.latitude,
    this.longitude,
    this.altitude,
    this.batteryLevel,
    this.lastHeard,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numId': numId,
      'longName': longName,
      'shortName': shortName,
      'hardwareModel': hardwareModel,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'batteryLevel': batteryLevel,
      'lastHeard': lastHeard?.millisecondsSinceEpoch,
    };
  }

  factory MeshNode.fromMap(Map<String, dynamic> map) {
    return MeshNode(
      id: map['id'],
      numId: map['numId'],
      longName: map['longName'],
      shortName: map['shortName'],
      hardwareModel: map['hardwareModel'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      altitude: map['altitude'],
      batteryLevel: map['batteryLevel'],
      lastHeard: map['lastHeard'] != null ? DateTime.fromMillisecondsSinceEpoch(map['lastHeard']) : null,
    );
  }
}
