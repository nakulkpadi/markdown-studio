import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  void _insertAround(String prefix, [String suffix = '']) {
    final text = controller.text;
    final selection = controller.selection;

    if (selection.start < 0 || selection.end < 0) {
      // Default to end of text
      controller.text = '$text$prefix$suffix';
      controller.selection = TextSelection.collapsed(offset: controller.text.length - suffix.length);
      onChanged();
      return;
    }

    final selectedText = text.substring(selection.start, selection.end);
    final replacement = '$prefix$selectedText$suffix';

    controller.text = text.replaceRange(selection.start, selection.end, replacement);
    controller.selection = TextSelection(
      baseOffset: selection.start + prefix.length,
      extentOffset: selection.start + prefix.length + selectedText.length,
    );
    onChanged();
  }

  void _insertLinePrefix(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final pos = selection.start >= 0 ? selection.start : text.length;

    // Find start of current line
    int lineStart = text.lastIndexOf('\n', pos - 1) + 1;
    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.text = newText;
    controller.selection = TextSelection.collapsed(offset: pos + prefix.length);
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _toolBtn(context, Icons.format_bold, 'Bold', () => _insertAround('**', '**')),
          _toolBtn(context, Icons.format_italic, 'Italic', () => _insertAround('*', '*')),
          _toolBtn(context, Icons.strikethrough_s, 'Strikethrough', () => _insertAround('~~', '~~')),
          const VerticalDivider(width: 16, indent: 10, endIndent: 10),
          _toolBtn(context, Icons.title, 'Heading 1', () => _insertLinePrefix('# ')),
          _toolBtn(context, Icons.text_fields, 'Heading 2', () => _insertLinePrefix('## ')),
          _toolBtn(context, Icons.format_quote, 'Quote', () => _insertLinePrefix('> ')),
          const VerticalDivider(width: 16, indent: 10, endIndent: 10),
          _toolBtn(context, Icons.format_list_bulleted, 'Bullet List', () => _insertLinePrefix('- ')),
          _toolBtn(context, Icons.format_list_numbered, 'Numbered List', () => _insertLinePrefix('1. ')),
          _toolBtn(context, Icons.check_box_outlined, 'Task Checkbox', () => _insertLinePrefix('- [ ] ')),
          const VerticalDivider(width: 16, indent: 10, endIndent: 10),
          _toolBtn(context, Icons.code, 'Inline Code', () => _insertAround('`', '`')),
          _toolBtn(context, Icons.data_object, 'Code Block', () => _insertAround('```\n', '\n```')),
          _toolBtn(context, Icons.link, 'Link', () => _insertAround('[', '](https://)')),
          _toolBtn(context, Icons.table_chart_outlined, 'Table', () {
            _insertAround('\n| Header 1 | Header 2 |\n| -------- | -------- |\n| Cell 1   | Cell 2   |\n');
          }),
          _toolBtn(context, Icons.horizontal_rule, 'Divider', () => _insertAround('\n---\n')),
        ],
      ),
    );
  }

  Widget _toolBtn(BuildContext context, IconData icon, String tooltip, VoidCallback onPressed) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        splashRadius: 20,
      ),
    );
  }
}
