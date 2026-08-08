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
  static const String columnPaidAmount = 'paidAmount';
  static const String columnCategory = 'category';
  static const String columnRecurringDays = 'recurringDays';

  static const String _settingsTable = 'settings';
  static const String _settingsColumnKey = 'key';
  static const String _settingsColumnValue = 'value';

  static const int _databaseVersion = 3;

  static const String _createTableSql = '''
CREATE TABLE $tableTrosa (
  $columnId INTEGER PRIMARY KEY,
  $columnAmount TEXT,
  $columnOwner TEXT,
  $columnDate TEXT,
  $columnDueDate TEXT,
  $columnIsInflow INTEGER,
  $columnNote TEXT,
  $columnPaidAmount TEXT NOT NULL DEFAULT '0',
  $columnCategory TEXT NOT NULL DEFAULT '',
  $columnRecurringDays INTEGER NOT NULL DEFAULT 0
)''';

  static const String _createSettingsTableSql = '''
CREATE TABLE $_settingsTable (
  $_settingsColumnKey TEXT PRIMARY KEY,
  $_settingsColumnValue TEXT
)''';

  static const String _addNoteColumnSql =
      'ALTER TABLE $tableTrosa ADD COLUMN $columnNote TEXT';
  static const String _addPaidAmountColumnSql =
      "ALTER TABLE $tableTrosa ADD COLUMN $columnPaidAmount TEXT NOT NULL DEFAULT '0'";
  static const String _addCategoryColumnSql =
      "ALTER TABLE $tableTrosa ADD COLUMN $columnCategory TEXT NOT NULL DEFAULT ''";
  static const String _addRecurringDaysColumnSql =
      'ALTER TABLE $tableTrosa ADD COLUMN $columnRecurringDays INTEGER NOT NULL DEFAULT 0';

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database? _database;

  /// Test hook: opens an in-memory database instead of the on-disk file.
  bool debugUseInMemory = false;

  /// Test hook: closes and forgets the current database.
  Future<void> debugClose() async {
    await _database?.close();
    _database = null;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final dbPath = await getDatabasesPath();
    final path = debugUseInMemory ? inMemoryDatabasePath : join(dbPath, 'trosa.db');

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute(_createTableSql);
        await db.execute(_createSettingsTableSql);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(_addNoteColumnSql);
        }
        if (oldVersion < 3) {
          await db.execute(_addPaidAmountColumnSql);
          await db.execute(_addCategoryColumnSql);
          await db.execute(_addRecurringDaysColumnSql);
          await db.execute(_createSettingsTableSql);
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

  /// Re-inserts a previously deleted record (used by the undo action).
  Future<void> restore(Trosa trosa) async {
    final db = await database;
    final map = trosa.toMap();
    if (trosa.id != null) {
      map[columnId] = trosa.id;
    }
    await db.insert(tableTrosa, map,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Trosa trosa) async {
    final db = await database;
    return db.update(tableTrosa, trosa.toMap(),
        where: '$columnId = ?', whereArgs: [trosa.id]);
  }

  /// Total amount still owed to the user across all inflow debts.
  Future<double> totalInflow() async {
    final db = await database;
    final result = await db.rawQuery(_totalQuery(1));
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }

  /// Total amount still owed by the user across all outflow debts.
  Future<double> totalOutflow() async {
    final db = await database;
    final result = await db.rawQuery(_totalQuery(0));
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }

  static String _totalQuery(int inflow) {
    return '''
SELECT SUM(CASE
  WHEN $columnIsInflow = $inflow
   AND CAST($columnAmount AS REAL) > CAST($columnPaidAmount AS REAL)
  THEN CAST($columnAmount AS REAL) - CAST($columnPaidAmount AS REAL)
  ELSE 0 END) as total
FROM $tableTrosa''';
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final rows = await db.query(_settingsTable,
        columns: [_settingsColumnValue],
        where: '$_settingsColumnKey = ?',
        whereArgs: [key]);
    if (rows.isEmpty) {
      return null;
    }
    return rows.first[_settingsColumnValue] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert(_settingsTable,
        {_settingsColumnKey: key, _settingsColumnValue: value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
