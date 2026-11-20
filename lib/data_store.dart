import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DataStore {
  DataStore._();
  static final instance = DataStore._();
  Database? _db;

  Future<void> init() async {
    final dir = await getDatabasesPath();
    _db = await openDatabase(p.join(dir, 'visites_chantier.db'),
      version: 1, onCreate: (db, version) async {
        await db.execute('''CREATE TABLE visits(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          site TEXT NOT NULL, date TEXT, subject TEXT,
          people TEXT NOT NULL, zones TEXT NOT NULL,
          created_at TEXT NOT NULL)''');
      });
  }

  Future<String> keepPhoto(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(p.join(directory.path, 'visit_photos'));
    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }
    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final filename = 'photo_${DateTime.now().microsecondsSinceEpoch}$extension';
    final saved = await File(sourcePath).copy(p.join(photosDirectory.path, filename));
    return saved.path;
  }

  Future<void> saveVisit({required String site, required String date,
    required String subject, required List<Map<String, String>> people,
    required List<Map<String, Object>> zones}) async {
    await _db!.insert('visits', {
      'site': site, 'date': date, 'subject': subject,
      'people': jsonEncode(people), 'zones': jsonEncode(zones),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> visits() async =>
    _db!.query('visits', orderBy: 'id DESC');

  Future<Map<String, Object?>> visitDetails(int id) async {
    final rows = await _db!.query('visits', where: 'id = ?', whereArgs: [id]);
    final row = Map<String, Object?>.from(rows.first);
    row['people'] = (jsonDecode(row['people'] as String) as List)
      .map((e) => Map<String, Object?>.from(e)).toList();
    row['zones'] = (jsonDecode(row['zones'] as String) as List)
      .map((e) => Map<String, Object?>.from(e)).toList();
    return row;
  }
}
