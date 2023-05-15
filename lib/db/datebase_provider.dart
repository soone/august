import 'package:path/path.dart';
import 'package:simple_calendar/models/calendar/calendar_event.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/date_utils.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._();
  static Database? _database;
  static const String calendarEvent = 'calendar_event';

  DatabaseProvider._();

  factory DatabaseProvider() => _instance;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'calendar.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
            CREATE TABLE IF NOT EXISTS $calendarEvent (
              id TEXT,
              dateId TEXT,
              title TEXT,
              content TEXT,
              date INTEGER,
              lunarDate TEXT,
              isCycle INTEGER,
              cycleBy INTEGER,
              createTime INTEGER,
              modifyTime INTEGER,
              deleted INTEGER
            )
          ''');
      },
    );
  }

  Future<List<CalendarEvent>> getEvents() async {
    final db = await database;
    var events = await db.query(calendarEvent);
    return events.map((event) => CalendarEvent.fromJson(event)).toList();
  }

  Future<List<CalendarEvent>> getEventsByDateId(String dateId) async {
    final db = await database;
    var events = await db.query(calendarEvent,
        where: 'dateId = ?', whereArgs: [dateId], orderBy: 'createTime');
    return events.map((event) => CalendarEvent.fromJson(event)).toList();
  }

  Future<List<CalendarEvent>> getEventsByPeriod(int month) async {
    int prevMonth = month - 1 <= 0 ? 12 : month - 1;
    int nextMonth = month + 1 >= 12 ? 1 : month + 1;

    final db = await database;
    var events = await db.query(
      calendarEvent,
      where: 'dateId LIKE ? OR dateId LIKE ? OR dateId LIKE ?',
      whereArgs: [
        '%${formatNumber(prevMonth)}%',
        '%${formatNumber(month)}%',
        '%${formatNumber(nextMonth)}%'
      ],
      orderBy: 'createTime',
    );
    return events.map((event) => CalendarEvent.fromJson(event)).toList();
  }

  Future<bool> createEvent(CalendarEvent event) async {
    final db = await database;
    var index = await db.insert(calendarEvent, event.toJson());
    return index > 0;
  }

  Future<bool> deleteEventById(String id) async {
    final db = await database;
    var index = await db.delete(
      calendarEvent,
      where: 'id = ?',
      whereArgs: [id],
    );
    return index > 0;
  }

  Future<bool> updateEvent(CalendarEvent event) async {
    final db = await database;
    int change = await db.update(
      calendarEvent,
      event.toJson(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    return change > 0;
  }
}