import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trosa/models/trosa.dart';

class DatabaseProvider {
  static const String tableTrosa = 'trosa';
  static const String columnId = 'id';
  static const String columnOwner = 'owner';
  static const String columnAmount = 'amount';
  static const String columnIsInflow = 'isInflow';
  static const String columnDate = 'date';
  static const String columnDueDate = 'dueDate';
  static const String columnNote = 'note';

  static const int _databaseVersion = 2;

  static const String _createTableSql = '''
CREATE TABLE $tableTrosa (
  $columnId INTEGER PRIMARY KEY,
  $columnAmount TEXT,
  $columnOwner TEXT,
  $columnDate TEXT,
  $columnDueDate TEXT,
  $columnIsInflow INTEGER
)''';

  static const String _addNoteColumnSql =
      'ALTER TABLE $tableTrosa ADD COLUMN $columnNote TEXT';

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trosa.db');

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute(_createTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(_addNoteColumnSql);
        }
      },
    );
    return _database!;
  }

  Future<List<Trosa>> getTrosa() async {
    final db = await database;
    final rows = await db.query(tableTrosa);
    return rows.map(Trosa.fromMap).toList();
  }

  Future<Trosa> insert(Trosa trosa) async {
    final db = await database;
    final id = await db.insert(tableTrosa, trosa.toMap());
    trosa.id = id;
    return trosa;
  }

  Future<int> delete(Trosa trosa) async {
    final db = await database;
    return db.delete(tableTrosa,
        where: '$columnId = ?', whereArgs: [trosa.id]);
  }

  Future<int> update(Trosa trosa) async {
    final db = await database;
    return db.update(tableTrosa, trosa.toMap(),
        where: '$columnId = ?', whereArgs: [trosa.id]);
  }

  Future<double> totalInflow() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableTrosa WHERE $columnIsInflow = 1');
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }

  Future<double> totalOutflow() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM($columnAmount) as total FROM $tableTrosa WHERE $columnIsInflow = 0');
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }
}
