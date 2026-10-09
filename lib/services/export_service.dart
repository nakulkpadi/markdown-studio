import 'dart:io';
import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  /// Converts Markdown to PDF and triggers preview/save/print
  static Future<void> exportToPdf({
    required BuildContext context,
    required String markdownContent,
    required String docTitle,
  }) async {
    final pdf = pw.Document();

    // Parse plain paragraphs/headers from markdown content
    final lines = markdownContent.split('\n');
    List<pw.Widget> widgets = [];

    widgets.add(
      pw.Header(
        level: 0,
        child: pw.Text(
          docTitle.replaceAll('.md', ''),
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 12));

    for (var line in lines) {
      if (line.startsWith('# ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          child: pw.Text(line.substring(2), style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ));
      } else if (line.startsWith('## ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 6),
          child: pw.Text(line.substring(3), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Text(line.substring(4), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ));
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, bottom: 3),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Expanded(child: pw.Text(line.substring(2))),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(pw.SizedBox(height: 6));
      } else {
        widgets.add(pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(line),
        ));
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => widgets,
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${docTitle.replaceAll('.md', '')}.pdf',
    );
  }

  /// Exports to styled HTML
  static Future<String?> exportToHtml({
    required String markdownContent,
    required String docTitle,
  }) async {
    String htmlBody = md.markdownToHtml(
      markdownContent,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    String fullHtml = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>${docTitle.replaceAll('.md', '')}</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      line-height: 1.6;
      max-width: 800px;
      margin: 40px auto;
      padding: 0 20px;
      color: #333;
    }
    code { background: #f4f4f4; padding: 2px 5px; border-radius: 4px; font-family: monospace; }
    pre { background: #f4f4f4; padding: 15px; border-radius: 6px; overflow-x: auto; }
    blockquote { border-left: 4px solid #007bff; margin: 0; padding-left: 15px; color: #666; }
    table { border-collapse: collapse; width: 100%; margin: 15px 0; }
    th, td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
    th { background: #f8f9fa; }
  </style>
</head>
<body>
$htmlBody
</body>
</html>''';

    String defaultFileName = '${docTitle.replaceAll('.md', '')}.html';
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export to HTML',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['html', 'htm'],
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(fullHtml);
      return outputPath;
    }
    return null;
  }

  /// Exports to Word-compatible .doc format (MIME formatted HTML)
  static Future<String?> exportToDoc({
    required String markdownContent,
    required String docTitle,
  }) async {
    String htmlBody = md.markdownToHtml(
      markdownContent,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );

    // Microsoft Word seamlessly renders HTML document structure with .doc extension
    String docWordHtml = '''<html xmlns:o='urn:schemas-microsoft-com:office:office' xmlns:w='urn:schemas-microsoft-com:office:word' xmlns='http://www.w3.org/TR/REC-html40'>
<head><meta charset='utf-8'><title>${docTitle.replaceAll('.md', '')}</title>
<style>
  body { font-family: 'Calibri', 'Arial', sans-serif; font-size: 11pt; line-height: 1.5; color: #111; }
  h1 { font-size: 18pt; color: #2E74B5; }
  h2 { font-size: 14pt; color: #2E74B5; }
  h3 { font-size: 12pt; color: #1F4D78; }
  table { border-collapse: collapse; width: 100%; }
  th, td { border: 1px solid #999; padding: 6px; }
  th { background-color: #F2F2F2; font-weight: bold; }
  code { font-family: 'Consolas', monospace; background: #eee; }
</style>
</head>
<body>
$htmlBody
</body>
</html>''';

    String defaultFileName = '${docTitle.replaceAll('.md', '')}.doc';
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export to Word (.doc)',
      fileName: defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['doc'],
    );

    if (outputPath != null) {
      final file = File(outputPath);
      await file.writeAsString(docWordHtml);
      return outputPath;
    }
    return null;
  }
}
