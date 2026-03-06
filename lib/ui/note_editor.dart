import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import '../data/note_repository.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.noteId});
  final int noteId;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _titleCtrl = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<NoteRepository>();
    final note = await repo.getNote(widget.noteId);
    if (!mounted) return;

    _titleCtrl.text = note?.title ?? 'Untitled';

    final doc = note == null
        ? Document()
        : Document.fromJson(jsonDecode(note.deltaJson));

    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _controller!.addListener(_onChanged);
    setState(() {});
  }

  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      final repo = context.read<NoteRepository>();
      final c = _controller;
      if (c == null) return;

      final deltaJson = jsonEncode(c.document.toDelta().toJson());
      final plain = c.document.toPlainText();

      final title = _titleCtrl.text.trim().isEmpty
          ? 'Untitled'
          : _titleCtrl.text.trim();

      await repo.updateNote(
        widget.noteId,
        title: title,
        deltaJson: deltaJson,
        plainText: plain,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller?.removeListener(_onChanged);
    _controller?.dispose();
    _titleCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            controller: _titleCtrl,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => _onChanged(),
          ),
        ),
        QuillSimpleToolbar(
          controller: c,
          config: const QuillSimpleToolbarConfig(
            multiRowsDisplay: false,
            showFontFamily: false,
            showFontSize: false,
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: QuillEditor.basic(
              controller: c,
              focusNode: _focusNode,
              config: const QuillEditorConfig(
                autoFocus: true,
                expands: true,
                padding: EdgeInsets.all(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
