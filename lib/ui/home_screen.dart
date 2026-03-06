import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/note_repository.dart';
import 'note_editor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? selectedNotebookId;
  int? selectedNoteId;
  String search = '';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<NoteRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          if (selectedNotebookId != null)
            IconButton(
              tooltip: 'New note',
              icon: const Icon(Icons.note_add_outlined),
              onPressed: () async {
                final id = await repo.createNote(selectedNotebookId!);
                setState(() => selectedNoteId = id);
              },
            ),
        ],
      ),
      body: Row(
        children: [
          // Left pane: notebooks + list
          SizedBox(
            width: 360,
            child: Column(
              children: [
                _NotebookBar(
                  selectedNotebookId: selectedNotebookId,
                  onSelect: (id) => setState(() {
                    selectedNotebookId = id;
                    selectedNoteId = null;
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search notes...',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: selectedNotebookId == null
                      ? const Center(child: Text('Create/select a notebook'))
                      : StreamBuilder<List<Note>>(
                          stream: repo.watchNotes(
                            selectedNotebookId!,
                            query: search,
                          ),
                          builder: (context, snapshot) {
                            final notes = snapshot.data ?? const <Note>[];
                            if (notes.isEmpty) {
                              return Center(
                                child: Text(
                                  search.trim().isEmpty
                                      ? 'No notes yet'
                                      : 'No results',
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: notes.length,
                              itemBuilder: (_, i) {
                                final n = notes[i];
                                final selected = n.id == selectedNoteId;
                                return ListTile(
                                  selected: selected,
                                  leading: Icon(
                                    n.pinned ? Icons.push_pin : Icons.note,
                                    size: 20,
                                  ),
                                  title: Text(
                                    n.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    n.plainText.replaceAll('
', ' '),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => setState(() {
                                    selectedNoteId = n.id;
                                  }),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (v) async {
                                      if (v == 'pin') {
                                        await repo.togglePin(n.id);
                                      } else if (v == 'delete') {
                                        if (selectedNoteId == n.id) {
                                          setState(() => selectedNoteId = null);
                                        }
                                        await repo.deleteNote(n.id);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'pin',
                                        child: Text(n.pinned ? 'Unpin' : 'Pin'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          // Right pane: editor
          Expanded(
            child: selectedNoteId == null
                ? const Center(child: Text('Select a note to start editing'))
                : NoteEditor(noteId: selectedNoteId!),
          ),
        ],
      ),
    );
  }
}

class _NotebookBar extends StatelessWidget {
  const _NotebookBar({
    required this.selectedNotebookId,
    required this.onSelect,
  });

  final int? selectedNotebookId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final repo = context.read<NoteRepository>();

    return StreamBuilder<List<Notebook>>(
      stream: repo.watchNotebooks(),
      builder: (context, snapshot) {
        final books = snapshot.data ?? const <Notebook>[];

        if (books.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('Create your first notebook'),
              onPressed: () async {
                final id = await repo.addNotebook('My Notebook');
                onSelect(id);
              },
            ),
          );
        }

        final currentId = selectedNotebookId ?? books.first.id;
        if (selectedNotebookId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelect(currentId);
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: currentId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                    labelText: 'Notebook',
                  ),
                  items: books
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.id,
                          child: Text(b.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onSelect(v);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Add notebook',
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final id = await repo.addNotebook('Notebook ${books.length + 1}');
                  onSelect(id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
