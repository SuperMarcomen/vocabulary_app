// needed for Directory()
import 'dart:io';
// needed for join()
import 'package:path/path.dart';
// needed for SQL database operations
import 'package:sqflite/sqflite.dart';
// needed for getApplicationDocumentsDirectory()
import 'package:path_provider/path_provider.dart';

final String databaseName = 'words_database.db';
final String tableName = 'words';
final String wordColumn = 'word';
final String articleColumn = 'article';
final String rightColumn = 'right';
final String wrongColumn = 'wrong';

class Word {
  String word;
  String article;
  int right;
  int wrong;

  Word();

  void increaseRight() {
    right++;
  }

  void increaseWrong() {
    wrong++;
  }

  double getRightPercentage() {
    return wrong/right;
  }

  // convenience constructor to create a Word object
  Word.fromMap(Map<String, dynamic> map) {    // andrea
    word = map[wordColumn];
    article = map[articleColumn];
    right = map[rightColumn];
    wrong = map[wrongColumn];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      wordColumn: word,
      articleColumn: article.toString().substring(article.toString().indexOf('.')+1),
      rightColumn: right,
      wrongColumn: wrong
    };
    return map;
  }
}

class DatabaseManager {
  // Make this a singleton class.
  DatabaseManager._privateConstructor();
  static final DatabaseManager instance = DatabaseManager._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    print(0);
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, databaseName);
    // Open the database, can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: 1,
        onCreate: _onCreate);
  }

  // SQL string to create the database
  _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableName (
            $wordColumn TEXT NOT NULL,
            $articleColumn TEXT NOT NULL,
            $rightColumn INTEGER,
            $wrongColumn INTEGER
          )
          ''');
  }

  // Database helper methods:
  void insertWord(Word word) async {
    Database db = await database;
    await db.insert(tableName, word.toMap());
  }

  Future<List<Word>> queryAllWords() async {
    Database db = await database;
    List<Map> maps = await db.query(tableName);
    if (maps.length > 0) {
      List<Word> words = [];
      maps.forEach((map) => words.add(Word.fromMap(map)));
      return words;
    }
    return null;
  }

  void deleteWord(String word) async {
    Database db = await database;
    await db.delete(tableName, where: '$wordColumn = ?', whereArgs: [word]);
  }

  void updateWord(Word word) async {
    Database db = await database;

    await db.update(tableName, word.toMap(),
        where: '$wordColumn = ?', whereArgs: [word.word]);
  }

  void updateWordAlternative(String originalWord, String newWord, String article) async {
    Database db = await database;
    Word word = await _queryWord(originalWord);
    word.word = newWord;
    word.article = article;

    await db.update(tableName, word.toMap(),
        where: '$wordColumn = ?', whereArgs: [originalWord]);
  }

  Future<Word> _queryWord(String word) async {
    Database db = await database;
    List<Map> maps = await db.query(tableName,
        columns: [wordColumn, articleColumn, rightColumn, wrongColumn],
        where: '$wordColumn = ?',
        whereArgs: [word]);
    if (maps.length > 0) {
      return Word.fromMap(maps.first);
    }
    return null;
  }
}