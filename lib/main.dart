import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';

import 'data/isar_db.dart';
import 'data/note_repository.dart';
import 'ui/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarDb.instance.init();
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<NoteRepository>(
      create: (_) => NoteRepository(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'iPad Notes Offline',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF3B82F6),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        home: const HomeScreen(),
      ),
    );
  }
}
