class Device {
  final String id;
  final String name;
  final String address;
  final bool isConnected;
  final int signalStrength;

  Device({
    required this.id,
    required this.name,
    required this.address,
    this.isConnected = false,
    this.signalStrength = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'isConnected': isConnected,
      'signalStrength': signalStrength,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      isConnected: json['isConnected'],
      signalStrength: json['signalStrength'],
    );
  }

  Device copyWith({
    String? id,
    String? name,
    String? address,
    bool? isConnected,
    int? signalStrength,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      isConnected: isConnected ?? this.isConnected,
      signalStrength: signalStrength ?? this.signalStrength,
    );
  }
} 