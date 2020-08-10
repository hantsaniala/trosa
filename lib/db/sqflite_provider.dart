import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:Trosa/models/trosa.dart';
import 'package:sqflite_migration/sqflite_migration.dart';
import 'dart:async';

class DatabaseProvider {
  static const String TABLE_TROSA = "trosa";
  static const String COLUMN_ID = 'id';
  static const String COLUMN_OWNER = 'owner';
  static const String COLUMN_AMOUNT = 'amount';
  static const String COLUMN_ISINFLOW = 'isInflow';
  static const String COLUMN_DATE = 'date';
  static const String COLUMN_DUEDATE = 'dueDate';
  static const String COLUMN_NOTE = 'note';

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;
  String path;

  static final initScript = [
    '''CREATE TABLE $TABLE_TROSA (
          $COLUMN_ID INTEGER PRIMARY KEY,
          $COLUMN_AMOUNT TEXT,
          $COLUMN_OWNER TEXT,
          $COLUMN_DATE TEXT,
          $COLUMN_DUEDATE TEXT,
          $COLUMN_ISINFLOW INTEGER
          )''',
  ];

  static final migrations = [
    '''ALTER TABLE $TABLE_TROSA ADD $COLUMN_NOTE TEXT''',
  ];

  final config = MigrationConfig(
      initializationScript: initScript, migrationScripts: migrations);

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await openDatabase();
    return _database;
  }

  Future<Database> openDatabase() async {
    String dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trosa.db');

    return await openDatabaseWithMigration(path, config);
  }

  Future<List<Trosa>> getTrosa() async {
    print('Get Trosa list from DB');
    final db = await database;

    var trosa = await db.query(TABLE_TROSA, columns: [
      COLUMN_ID,
      COLUMN_AMOUNT,
      COLUMN_OWNER,
      COLUMN_DATE,
      COLUMN_DUEDATE,
      COLUMN_ISINFLOW,
      COLUMN_NOTE
    ]);

    List<Trosa> trosaList = List<Trosa>();

    trosa.forEach((currentTrosa) {
      Trosa trosa = Trosa.fromMap(currentTrosa);

      trosaList.add(trosa);
    });

    return trosaList;
  }

  Future<Trosa> insert(Trosa trosa) async {
    print('Inserting a new Trosa to the DB');
    final db = await database;
    await db.insert(TABLE_TROSA, trosa.toMap());
    return trosa;
  }

  Future<int> delete(Trosa trosa) async {
    print('Deleting a Trosa from the DB');
    final db = await database;

    return await db.delete(
      TABLE_TROSA,
      where: 'id = ?',
      whereArgs: [trosa.id],
    );
  }

  Future<int> update(Trosa trosa) async {
    print('Updating an existing Trosa from the DB');
    final db = await database;

    return await db.update(TABLE_TROSA, trosa.toMap(),
        where: 'id = ?', whereArgs: [trosa.id]);
  }

  Future totalInflow() async {
    print('Getting the inflow total');
    final db = await database;
    var res = await db.rawQuery(
        'SELECT SUM(amount) as totalInflow from Trosa WHERE isInflow="1"');
    return res[0]['totalInflow'] != null ? res[0]['totalInflow'] : 0.0;
  }

  Future totalOutflow() async {
    print('Getting the outflow total');
    final db = await database;
    var res = await db.rawQuery(
        'SELECT SUM(amount) as totalOutflow from Trosa WHERE isInflow="0"');
    return res[0]['totalOutflow'] != null ? res[0]['totalOutflow'] : 0.0;
  }
}
