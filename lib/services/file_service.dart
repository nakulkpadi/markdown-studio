import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileInfo {
  final String? path;
  final String name;
  final String content;

  FileInfo({this.path, required this.name, required this.content});
}

class FileService {
  /// Opens a Markdown or Text file using the system picker
  static Future<FileInfo?> openFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile pickedFile = result.files.first;
      String content = '';
      if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        content = await file.readAsString();
        return FileInfo(path: pickedFile.path, name: pickedFile.name, content: content);
      } else if (pickedFile.bytes != null) {
        content = String.fromCharCodes(pickedFile.bytes!);
        return FileInfo(path: null, name: pickedFile.name, content: content);
      }
    }
    return null;
  }

  /// Saves content to an existing file path or prompts Save As
  static Future<FileInfo?> saveFile({required String content, String? existingPath, required String defaultName}) async {
    if (existingPath != null && !kIsWeb) {
      final file = File(existingPath);
      await file.writeAsString(content);
      return FileInfo(path: existingPath, name: existingPath.split(Platform.pathSeparator).last, content: content);
    } else {
      return saveAsFile(content: content, defaultName: defaultName);
    }
  }

  /// Prompts the user where to save the file
  static Future<FileInfo?> saveAsFile({required String content, required String defaultName}) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Markdown File',
      fileName: defaultName.endsWith('.md') ? defaultName : '$defaultName.md',
      type: FileType.custom,
      allowedExtensions: ['md', 'txt'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(content);
      return FileInfo(path: outputFile, name: outputFile.split(Platform.pathSeparator).last, content: content);
    }
    return null;
  }
}
