import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:trosa/models/trosa.dart';

class DatabaseProvider {
  static const String TABLE_TROSA = 'trosa';
  static const String COLUMN_ID = 'id';
  static const String COLUMN_OWNER = 'owner';
  static const String COLUMN_AMOUNT = 'amount';
  static const String COLUMN_ISINFLOW = 'isInflow';
  static const String COLUMN_DATE = 'date';
  static const String COLUMN_DUEDATE = 'dueDate';
  static const String COLUMN_NOTE = 'note';

  static const int _databaseVersion = 2;

  static const String _createTableSql = '''
CREATE TABLE $TABLE_TROSA (
  $COLUMN_ID INTEGER PRIMARY KEY,
  $COLUMN_AMOUNT TEXT,
  $COLUMN_OWNER TEXT,
  $COLUMN_DATE TEXT,
  $COLUMN_DUEDATE TEXT,
  $COLUMN_ISINFLOW INTEGER
)''';

  static const String _addNoteColumnSql =
      'ALTER TABLE $TABLE_TROSA ADD COLUMN $COLUMN_NOTE TEXT';

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
    final rows = await db.query(TABLE_TROSA);
    return rows.map(Trosa.fromMap).toList();
  }

  Future<Trosa> insert(Trosa trosa) async {
    final db = await database;
    final id = await db.insert(TABLE_TROSA, trosa.toMap());
    trosa.id = id;
    return trosa;
  }

  Future<int> delete(Trosa trosa) async {
    final db = await database;
    return db.delete(TABLE_TROSA,
        where: '$COLUMN_ID = ?', whereArgs: [trosa.id]);
  }

  Future<int> update(Trosa trosa) async {
    final db = await database;
    return db.update(TABLE_TROSA, trosa.toMap(),
        where: '$COLUMN_ID = ?', whereArgs: [trosa.id]);
  }

  Future<double> totalInflow() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM($COLUMN_AMOUNT) as total FROM $TABLE_TROSA WHERE $COLUMN_ISINFLOW = 1');
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }

  Future<double> totalOutflow() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT SUM($COLUMN_AMOUNT) as total FROM $TABLE_TROSA WHERE $COLUMN_ISINFLOW = 0');
    final value = result.first['total'];
    return value is num ? value.toDouble() : 0.0;
  }
}
