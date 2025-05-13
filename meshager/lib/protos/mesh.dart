import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:protobuf/protobuf.dart'
    show PbFieldType, GeneratedMessage, BuilderInfo;

enum PortNum implements ProtobufEnum {
  unknownApp(0),
  textMessageApp(1),
  telemetryApp(2),
  adminApp(3),
  positionApp(4);

  final int value;
  const PortNum(this.value);

  @override
  int get value_ => value;

  @override
  String get name => toString().split('.').last;

  static PortNum valueOf(int value) {
    switch (value) {
      case 0:
        return PortNum.unknownApp;
      case 1:
        return PortNum.textMessageApp;
      case 2:
        return PortNum.telemetryApp;
      case 3:
        return PortNum.adminApp;
      case 4:
        return PortNum.positionApp;
      default:
        return PortNum.unknownApp;
    }
  }
}

enum Priority implements ProtobufEnum {
  unset(0),
  min(1),
  background(10),
  default_(64),
  reliable(70),
  ack(120),
  max(127);

  final int value;
  const Priority(this.value);

  @override
  int get value_ => value;

  @override
  String get name => toString().split('.').last;

  static Priority valueOf(int value) {
    switch (value) {
      case 0:
        return Priority.unset;
      case 1:
        return Priority.min;
      case 10:
        return Priority.background;
      case 64:
        return Priority.default_;
      case 70:
        return Priority.reliable;
      case 120:
        return Priority.ack;
      case 127:
        return Priority.max;
      default:
        return Priority.unset;
    }
  }
}

class MeshPacket extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('MeshPacket')
    ..a<int>(1, 'from', PbFieldType.OU3)
    ..a<int>(2, 'to', PbFieldType.OU3)
    ..a<int>(3, 'id', PbFieldType.O3)
    ..a<bool>(4, 'want_ack', PbFieldType.OB)
    ..a<int>(5, 'hop_limit', PbFieldType.O3)
    ..a<Data>(6, 'decoded', PbFieldType.OM)
    ..a<int>(7, 'channel', PbFieldType.O3)
    ..e<Priority>(8, 'priority', PbFieldType.OE)
    ..a<bool>(9, 'pki_encrypted', PbFieldType.OB)
    ..a<Uint8List>(10, 'public_key', PbFieldType.OY)
    ..hasRequiredFields = false;

  MeshPacket._() : super();
  factory MeshPacket() => MeshPacket._();
  factory MeshPacket.create() => MeshPacket._();

  @override
  MeshPacket createEmptyInstance() => MeshPacket();

  @override
  BuilderInfo get info_ => _i;

  int get from => $_get(0, 0);
  set from(int v) {
    $_setUnsignedInt32(0, v);
  }

  bool hasFrom() => $_has(0);
  void clearFrom() => clearField(1);

  int get to => $_get(1, 0);
  set to(int v) {
    $_setUnsignedInt32(1, v);
  }

  bool hasTo() => $_has(1);
  void clearTo() => clearField(2);

  int get id => $_get(2, 0);
  set id(int v) {
    $_setSignedInt32(2, v);
  }

  bool hasId() => $_has(2);
  void clearId() => clearField(3);

  bool get wantAck => $_get(3, false);
  set wantAck(bool v) {
    $_setBool(3, v);
  }

  bool hasWantAck() => $_has(3);
  void clearWantAck() => clearField(4);

  int get hopLimit => $_get(4, 0);
  set hopLimit(int v) {
    $_setSignedInt32(4, v);
  }

  bool hasHopLimit() => $_has(4);
  void clearHopLimit() => clearField(5);

  Data get decoded => $_get(5, Data());
  set decoded(Data v) {
    setField(6, v);
  }

  bool hasDecoded() => $_has(5);
  void clearDecoded() => clearField(6);

  int get channel => $_get(6, 0);
  set channel(int v) {
    $_setSignedInt32(6, v);
  }

  bool hasChannel() => $_has(6);
  void clearChannel() => clearField(7);

  Priority get priority => $_get(7, Priority.unset);
  set priority(Priority v) {
    setField(8, v);
  }

  bool hasPriority() => $_has(7);
  void clearPriority() => clearField(8);

  bool get pkiEncrypted => $_get(8, false);
  set pkiEncrypted(bool v) {
    $_setBool(8, v);
  }

  bool hasPkiEncrypted() => $_has(8);
  void clearPkiEncrypted() => clearField(9);

  Uint8List get publicKey => $_get(9, Uint8List(0));
  set publicKey(Uint8List v) {
    $_setBytes(9, v);
  }

  bool hasPublicKey() => $_has(9);
  void clearPublicKey() => clearField(10);

  MeshPacket clone() => MeshPacket()..mergeFromMessage(this);
  MeshPacket copyWith(void Function(MeshPacket) updates) =>
      super.copyWith((message) => updates(message as MeshPacket)) as MeshPacket;
}

class TextMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('TextMessage')
    ..a<String>(1, 'text', PbFieldType.OS)
    ..hasRequiredFields = false;

  TextMessage._() : super();
  factory TextMessage() => TextMessage._();
  factory TextMessage.create() => TextMessage._();

  @override
  TextMessage createEmptyInstance() => TextMessage();

  @override
  BuilderInfo get info_ => _i;

  String get text => $_get(0, '');
  set text(String v) {
    $_setString(0, v);
  }

  bool hasText() => $_has(0);
  void clearText() => clearField(1);

  TextMessage clone() => TextMessage()..mergeFromMessage(this);
  TextMessage copyWith(void Function(TextMessage) updates) =>
      super.copyWith((message) => updates(message as TextMessage))
          as TextMessage;
}

class AdminMessage extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('AdminMessage')
    ..a<bool>(1, 'getNodeInfoRequest', PbFieldType.OB)
    ..a<NodeInfo>(2, 'nodeInfo', PbFieldType.OM)
    ..hasRequiredFields = false;

  AdminMessage._() : super();
  factory AdminMessage() => AdminMessage._();
  factory AdminMessage.create() => AdminMessage._();

  @override
  AdminMessage createEmptyInstance() => AdminMessage();

  @override
  BuilderInfo get info_ => _i;

  bool get getNodeInfoRequest => $_get(0, false);
  set getNodeInfoRequest(bool v) {
    $_setBool(0, v);
  }

  bool hasGetNodeInfoRequest() => $_has(0);
  void clearGetNodeInfoRequest() => clearField(1);

  NodeInfo get nodeInfo => $_get(1, NodeInfo());
  set nodeInfo(NodeInfo v) {
    setField(2, v);
  }

  bool hasNodeInfo() => $_has(1);
  void clearNodeInfo() => clearField(2);

  AdminMessage clone() => AdminMessage()..mergeFromMessage(this);
  AdminMessage copyWith(void Function(AdminMessage) updates) =>
      super.copyWith((message) => updates(message as AdminMessage))
          as AdminMessage;
}

class NodeInfo extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('NodeInfo')
    ..a<int>(1, 'num', PbFieldType.OU3)
    ..a<String>(2, 'user', PbFieldType.OS)
    ..a<String>(3, 'longName', PbFieldType.OS)
    ..a<String>(4, 'shortName', PbFieldType.OS)
    ..a<String>(5, 'macaddr', PbFieldType.OS)
    ..a<int>(6, 'hwModel', PbFieldType.OU3)
    ..hasRequiredFields = false;

  NodeInfo._() : super();
  factory NodeInfo() => NodeInfo._();
  factory NodeInfo.create() => NodeInfo._();

  @override
  NodeInfo createEmptyInstance() => NodeInfo();

  @override
  BuilderInfo get info_ => _i;

  int get num => $_get(0, 0);
  set num(int v) {
    $_setUnsignedInt32(0, v);
  }

  bool hasNum() => $_has(0);
  void clearNum() => clearField(1);

  String get user => $_get(1, '');
  set user(String v) {
    $_setString(1, v);
  }

  bool hasUser() => $_has(1);
  void clearUser() => clearField(2);

  String get longName => $_get(2, '');
  set longName(String v) {
    $_setString(2, v);
  }

  bool hasLongName() => $_has(2);
  void clearLongName() => clearField(3);

  String get shortName => $_get(3, '');
  set shortName(String v) {
    $_setString(3, v);
  }

  bool hasShortName() => $_has(3);
  void clearShortName() => clearField(4);

  String get macaddr => $_get(4, '');
  set macaddr(String v) {
    $_setString(4, v);
  }

  bool hasMacaddr() => $_has(4);
  void clearMacaddr() => clearField(5);

  int get hwModel => $_get(5, 0);
  set hwModel(int v) {
    $_setUnsignedInt32(5, v);
  }

  bool hasHwModel() => $_has(5);
  void clearHwModel() => clearField(6);

  NodeInfo clone() => NodeInfo()..mergeFromMessage(this);
  NodeInfo copyWith(void Function(NodeInfo) updates) =>
      super.copyWith((message) => updates(message as NodeInfo)) as NodeInfo;
}

class Position extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Position')
    ..a<int>(1, 'latitude', PbFieldType.O3)
    ..a<int>(2, 'longitude', PbFieldType.O3)
    ..a<int>(3, 'altitude', PbFieldType.O3)
    ..a<int>(4, 'time', PbFieldType.O3)
    ..a<int>(5, 'batteryLevel', PbFieldType.O3)
    ..a<int>(6, 'speed', PbFieldType.O3)
    ..a<int>(7, 'heading', PbFieldType.O3)
    ..a<int>(8, 'satsInView', PbFieldType.O3)
    ..a<int>(9, 'satsInUse', PbFieldType.O3)
    ..a<int>(10, 'hdop', PbFieldType.O3)
    ..a<int>(11, 'fixQuality', PbFieldType.O3)
    ..a<int>(12, 'fixType', PbFieldType.O3)
    ..hasRequiredFields = false;

  Position._() : super();
  factory Position() => Position._();
  factory Position.create() => Position._();

  @override
  Position createEmptyInstance() => Position();

  @override
  BuilderInfo get info_ => _i;

  int get latitude => $_get(0, 0);
  set latitude(int v) {
    $_setSignedInt32(0, v);
  }

  bool hasLatitude() => $_has(0);
  void clearLatitude() => clearField(1);

  int get longitude => $_get(1, 0);
  set longitude(int v) {
    $_setSignedInt32(1, v);
  }

  bool hasLongitude() => $_has(1);
  void clearLongitude() => clearField(2);

  int get altitude => $_get(2, 0);
  set altitude(int v) {
    $_setSignedInt32(2, v);
  }

  bool hasAltitude() => $_has(2);
  void clearAltitude() => clearField(3);

  int get time => $_get(3, 0);
  set time(int v) {
    $_setSignedInt32(3, v);
  }

  bool hasTime() => $_has(3);
  void clearTime() => clearField(4);

  int get batteryLevel => $_get(4, 0);
  set batteryLevel(int v) {
    $_setSignedInt32(4, v);
  }

  bool hasBatteryLevel() => $_has(4);
  void clearBatteryLevel() => clearField(5);

  int get speed => $_get(5, 0);
  set speed(int v) {
    $_setSignedInt32(5, v);
  }

  bool hasSpeed() => $_has(5);
  void clearSpeed() => clearField(6);

  int get heading => $_get(6, 0);
  set heading(int v) {
    $_setSignedInt32(6, v);
  }

  bool hasHeading() => $_has(6);
  void clearHeading() => clearField(7);

  int get satsInView => $_get(7, 0);
  set satsInView(int v) {
    $_setSignedInt32(7, v);
  }

  bool hasSatsInView() => $_has(7);
  void clearSatsInView() => clearField(8);

  int get satsInUse => $_get(8, 0);
  set satsInUse(int v) {
    $_setSignedInt32(8, v);
  }

  bool hasSatsInUse() => $_has(8);
  void clearSatsInUse() => clearField(9);

  int get hdop => $_get(9, 0);
  set hdop(int v) {
    $_setSignedInt32(9, v);
  }

  bool hasHdop() => $_has(9);
  void clearHdop() => clearField(10);

  int get fixQuality => $_get(10, 0);
  set fixQuality(int v) {
    $_setSignedInt32(10, v);
  }

  bool hasFixQuality() => $_has(10);
  void clearFixQuality() => clearField(11);

  int get fixType => $_get(11, 0);
  set fixType(int v) {
    $_setSignedInt32(11, v);
  }

  bool hasFixType() => $_has(11);
  void clearFixType() => clearField(12);

  Position clone() => Position()..mergeFromMessage(this);
}

class Data extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Data')
    ..a<Uint8List>(1, 'payload', PbFieldType.OY)
    ..e<PortNum>(2, 'portnum', PbFieldType.OE)
    ..a<bool>(3, 'want_response', PbFieldType.OB)
    ..a<int>(4, 'request_id', PbFieldType.O3)
    ..a<bool>(5, 'delayed', PbFieldType.OB)
    ..a<bool>(6, 'roundstart', PbFieldType.OB)
    ..a<bool>(7, 'roundend', PbFieldType.OB)
    ..hasRequiredFields = false;

  Data._() : super();
  factory Data() => Data._();
  factory Data.create() => Data._();

  @override
  Data createEmptyInstance() => Data();

  @override
  BuilderInfo get info_ => _i;

  Uint8List get payload => $_get(0, Uint8List(0));
  set payload(Uint8List v) {
    $_setBytes(0, v);
  }

  bool hasPayload() => $_has(0);
  void clearPayload() => clearField(1);

  PortNum get portnum => $_get(1, PortNum.unknownApp);
  set portnum(PortNum v) {
    setField(2, v);
  }

  bool hasPortnum() => $_has(1);
  void clearPortnum() => clearField(2);

  bool get wantResponse => $_get(2, false);
  set wantResponse(bool v) {
    $_setBool(2, v);
  }

  bool hasWantResponse() => $_has(2);
  void clearWantResponse() => clearField(3);

  int get requestId => $_get(3, 0);
  set requestId(int v) {
    $_setSignedInt32(3, v);
  }

  bool hasRequestId() => $_has(3);
  void clearRequestId() => clearField(4);

  bool get delayed => $_get(4, false);
  set delayed(bool v) {
    $_setBool(4, v);
  }

  bool hasDelayed() => $_has(4);
  void clearDelayed() => clearField(5);

  bool get roundstart => $_get(5, false);
  set roundstart(bool v) {
    $_setBool(5, v);
  }

  bool hasRoundstart() => $_has(5);
  void clearRoundstart() => clearField(6);

  bool get roundend => $_get(6, false);
  set roundend(bool v) {
    $_setBool(6, v);
  }

  bool hasRoundend() => $_has(6);
  void clearRoundend() => clearField(7);

  Data clone() => Data()..mergeFromMessage(this);
  Data copyWith(void Function(Data) updates) =>
      super.copyWith((message) => updates(message as Data)) as Data;
}

enum ErrorCode implements ProtobufEnum {
  unknown(0),
  invalidPacket(1),
  authenticationFailed(2),
  routingError(3);

  final int value;
  const ErrorCode(this.value);

  @override
  int get value_ => value;

  @override
  String get name => toString().split('.').last;

  static ErrorCode valueOf(int value) {
    switch (value) {
      case 0:
        return ErrorCode.unknown;
      case 1:
        return ErrorCode.invalidPacket;
      case 2:
        return ErrorCode.authenticationFailed;
      case 3:
        return ErrorCode.routingError;
      default:
        return ErrorCode.unknown;
    }
  }
}

class Error extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Error')
    ..a<String>(1, 'message', PbFieldType.OS)
    ..e<ErrorCode>(2, 'code', PbFieldType.OE)
    ..hasRequiredFields = false;

  Error._() : super();
  factory Error() => Error._();
  factory Error.create() => Error._();

  @override
  Error createEmptyInstance() => Error();

  @override
  BuilderInfo get info_ => _i;

  String get message => $_get(0, '');
  set message(String v) {
    $_setString(0, v);
  }

  bool hasMessage() => $_has(0);
  void clearMessage() => clearField(1);

  ErrorCode get code => $_get(1, ErrorCode.unknown);
  set code(ErrorCode v) {
    setField(2, v);
  }

  bool hasCode() => $_has(1);
  void clearCode() => clearField(2);

  Error clone() => Error()..mergeFromMessage(this);
  Error copyWith(void Function(Error) updates) =>
      super.copyWith((message) => updates(message as Error)) as Error;
}

class Ack extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Ack')
    ..a<int>(1, 'packet_id', PbFieldType.OU3)
    ..a<bool>(2, 'success', PbFieldType.OB)
    ..a<String>(3, 'error_message', PbFieldType.OS)
    ..hasRequiredFields = false;

  Ack._() : super();
  factory Ack() => Ack._();
  factory Ack.create() => Ack._();

  @override
  Ack createEmptyInstance() => Ack();

  @override
  BuilderInfo get info_ => _i;

  int get packetId => $_get(0, 0);
  set packetId(int v) {
    $_setUnsignedInt32(0, v);
  }

  bool hasPacketId() => $_has(0);
  void clearPacketId() => clearField(1);

  bool get success => $_get(1, false);
  set success(bool v) {
    $_setBool(1, v);
  }

  bool hasSuccess() => $_has(1);
  void clearSuccess() => clearField(2);

  String get errorMessage => $_get(2, '');
  set errorMessage(String v) {
    $_setString(2, v);
  }

  bool hasErrorMessage() => $_has(2);
  void clearErrorMessage() => clearField(3);

  Ack clone() => Ack()..mergeFromMessage(this);
  Ack copyWith(void Function(Ack) updates) =>
      super.copyWith((message) => updates(message as Ack)) as Ack;
}

class Config extends GeneratedMessage {
  static final BuilderInfo _i = BuilderInfo('Config')
    ..a<int>(1, 'channel', PbFieldType.OU3)
    ..a<int>(2, 'power', PbFieldType.OU3)
    ..a<bool>(3, 'encryption_enabled', PbFieldType.OB)
    ..p<String>(4, 'allowed_nodes', PbFieldType.PS)
    ..hasRequiredFields = false;

  Config._() : super();
  factory Config() => Config._();
  factory Config.create() => Config._();

  @override
  Config createEmptyInstance() => Config();

  @override
  BuilderInfo get info_ => _i;

  int get channel => $_get(0, 0);
  set channel(int v) {
    $_setUnsignedInt32(0, v);
  }

  bool hasChannel() => $_has(0);
  void clearChannel() => clearField(1);

  int get power => $_get(1, 0);
  set power(int v) {
    $_setUnsignedInt32(1, v);
  }

  bool hasPower() => $_has(1);
  void clearPower() => clearField(2);

  bool get encryptionEnabled => $_get(2, false);
  set encryptionEnabled(bool v) {
    $_setBool(2, v);
  }

  bool hasEncryptionEnabled() => $_has(2);
  void clearEncryptionEnabled() => clearField(3);

  List<String> get allowedNodes => $_getList(3);
  bool hasAllowedNodes() => $_has(3);
  void clearAllowedNodes() => clearField(4);

  Config clone() => Config()..mergeFromMessage(this);
  Config copyWith(void Function(Config) updates) =>
      super.copyWith((message) => updates(message as Config)) as Config;
}
