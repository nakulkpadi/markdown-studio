import 'package:markdown/markdown.dart' as md;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'theme/app_theme.dart';
import 'services/file_service.dart';
import 'services/export_service.dart';
import 'widgets/markdown_toolbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MarkdownStudioApp());
}

class MarkdownStudioApp extends StatefulWidget {
  const MarkdownStudioApp({super.key});

  @override
  State<MarkdownStudioApp> createState() => _MarkdownStudioAppState();
}

class _MarkdownStudioAppState extends State<MarkdownStudioApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _editorController = TextEditingController();
  String _currentContent = '';
  String _currentFileName = 'Untitled.md';
  String? _currentFilePath;
  bool _isEdited = false;

  // Mobile toggle mode: 0 = Edit, 1 = Preview
  int _mobileViewIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentContent = '''# Welcome to Markdown Studio 📝

A clean, responsive Markdown editor and reader for **PC** and **Android**.

---

### Features:
- ⚡ **Side-by-side Live Preview** on PC / Desktop.
- 📱 **Quick Switch Toggle** on Mobile.
- 🛠️ **Formatting Toolbar** for headings, bold, italic, code, tables & checklists.
- 💾 **File Management**: Open, Save, and Save As.
- 📤 **Multi-format Export**: PDF, Word (.doc), and HTML.

---

### Sample Checklist:
- [x] Create project structure
- [x] Configure Windows & Android build
- [ ] Export your first document

### Sample Code Block:
```dart
void main() {
  print("Hello Markdown!");
}
```

| Syntax | Description | Status |
| :--- | :--- | :--- |
| `**Bold**` | Emphasized text | Supported |
| `*Italic*` | Slanted text | Supported |
''';
    _editorController.text = _currentContent;
  }

  void _onContentChanged(String value) {
    setState(() {
      _currentContent = value;
      _isEdited = true;
    });
  }

  Future<void> _newFile() async {
    if (_isEdited) {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('You have unsaved changes. Discard and create a new file?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Discard')),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() {
      _editorController.text = '';
      _currentContent = '';
      _currentFileName = 'Untitled.md';
      _currentFilePath = null;
      _isEdited = false;
    });
  }

  Future<void> _openFile() async {
    final info = await FileService.openFile();
    if (info != null) {
      setState(() {
        _editorController.text = info.content;
        _currentContent = info.content;
        _currentFileName = info.name;
        _currentFilePath = info.path;
        _isEdited = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opened \${info.name}')),
        );
      }
    }
  }

  Future<void> _saveFile() async {
    final info = await FileService.saveFile(
      content: _editorController.text,
      existingPath: _currentFilePath,
      defaultName: _currentFileName,
    );
    if (info != null) {
      setState(() {
        _currentFileName = info.name;
        _currentFilePath = info.path;
        _isEdited = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved \${info.name}')),
        );
      }
    }
  }

  Future<void> _saveAsFile() async {
    final info = await FileService.saveAsFile(
      content: _editorController.text,
      defaultName: _currentFileName,
    );
    if (info != null) {
      setState(() {
        _currentFileName = info.name;
        _currentFilePath = info.path;
        _isEdited = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved as \${info.name}')),
        );
      }
    }
  }

  void _showExportMenu() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Export as PDF Document (.pdf)'),
              subtitle: const Text('Printable formatted document with headers and styling'),
              onTap: () {
                Navigator.pop(ctx);
                ExportService.exportToPdf(
                  context: context,
                  markdownContent: _currentContent,
                  docTitle: _currentFileName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.blue),
              title: const Text('Export as Microsoft Word Document (.doc)'),
              subtitle: const Text('Word-compatible document file'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ExportService.exportToDoc(
                  markdownContent: _currentContent,
                  docTitle: _currentFileName,
                );
                if (path != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to \$path')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.html, color: Colors.orange),
              title: const Text('Export as Standalone Web Page (.html)'),
              subtitle: const Text('GitHub Flavored formatted HTML file'),
              onTap: () async {
                Navigator.pop(ctx);
                final path = await ExportService.exportToHtml(
                  markdownContent: _currentContent,
                  docTitle: _currentFileName,
                );
                if (path != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to \$path')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData themeIcon;
    if (widget.currentThemeMode == ThemeMode.dark) {
      themeIcon = Icons.dark_mode;
    } else if (widget.currentThemeMode == ThemeMode.light) {
      themeIcon = Icons.light_mode;
    } else {
      themeIcon = Icons.brightness_auto;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.article_outlined, size: 22),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '$_currentFileName\${_isEdited ? " *" : ""}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'New File',
            icon: const Icon(Icons.note_add_outlined),
            onPressed: _newFile,
          ),
          IconButton(
            tooltip: 'Open File',
            icon: const Icon(Icons.folder_open_outlined),
            onPressed: _openFile,
          ),
          IconButton(
            tooltip: 'Save',
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveFile,
          ),
          PopupMenuButton<String>(
            tooltip: 'File Options',
            onSelected: (val) {
              if (val == 'save_as') _saveAsFile();
              if (val == 'export') _showExportMenu();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'save_as',
                child: Row(children: [Icon(Icons.save_as_outlined), SizedBox(width: 8), Text('Save As...')]),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(children: [Icon(Icons.file_download_outlined), SizedBox(width: 8), Text('Export (PDF, DOC, HTML)...')]),
              ),
            ],
          ),
          const VerticalDivider(width: 12, indent: 12, endIndent: 12),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(themeIcon),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              MarkdownToolbar(
                controller: _editorController,
                onChanged: () => _onContentChanged(_editorController.text),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // On mobile, show the segmented switcher
          if (!isDesktop)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              child: Center(
                child: SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('Editor'), icon: Icon(Icons.edit_note)),
                    ButtonSegment(value: 1, label: Text('Preview'), icon: Icon(Icons.visibility_outlined)),
                  ],
                  selected: {_mobileViewIndex},
                  onSelectionChanged: (set) {
                    setState(() => _mobileViewIndex = set.first);
                  },
                ),
              ),
            ),

          Expanded(
            child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
          ),

          // Status Bar
          _buildStatusBar(isDark),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Editor Side
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildEditorTextField(),
          ),
        ),
        const VerticalDivider(width: 1),
        // Preview Side
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildMarkdownPreview(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    if (_mobileViewIndex == 0) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: _buildEditorTextField(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        child: _buildMarkdownPreview(),
      );
    }
  }

  Widget _buildEditorTextField() {
    return TextField(
      controller: _editorController,
      maxLines: null,
      expands: true,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 14, height: 1.5),
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: 'Type your Markdown here...',
      ),
      onChanged: _onContentChanged,
    );
  }

  Widget _buildMarkdownPreview() {
    return Markdown(
      data: _currentContent.isEmpty ? '*Nothing to preview*' : _currentContent,
      selectable: true,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
  }

  Widget _buildStatusBar(bool isDark) {
    int wordCount = _currentContent.trim().isEmpty ? 0 : _currentContent.trim().split(RegExp(r'\s+')).length;
    int charCount = _currentContent.length;

    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      child: Row(
        children: [
          Text(
            'Words: \$wordCount | Characters: \$charCount',
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700]),
          ),
          const Spacer(),
          Text(
            _isEdited ? 'Modified' : 'Saved',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _isEdited ? Colors.amber[700] : Colors.green[600],
            ),
          ),
        ],
      ),
    );
  }
}
