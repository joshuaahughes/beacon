/// A shim for dart:io that allows code referencing File and Directory to compile on web.
/// These classes throw UnimplementedError if used on web.

class File {
  final String path;
  File(this.path);
  
  Future<bool> exists() async => false;
  Future<File> copy(String path) async => throw UnimplementedError('File.copy is not supported on web.');
  void writeAsStringSync(String contents) => throw UnimplementedError('File.writeAsStringSync is not supported on web.');
  Future<File> writeAsString(String contents) async => throw UnimplementedError('File.writeAsString is not supported on web.');
}

class Directory {
  final String path;
  Directory(this.path);
  
  bool existsSync() => false;
  List<FileSystemEntity> listSync() => [];
  void createSync({bool recursive = false}) => throw UnimplementedError('Directory.createSync is not supported on web.');
}

abstract class FileSystemEntity {
  String get path;
  Uri get uri => Uri.parse(path);
}
