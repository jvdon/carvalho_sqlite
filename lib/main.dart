import 'package:carvalho/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }
  // Change the default factory. On iOS/Android, if not using `sqlite_flutter_lib` you can forget
  // this step, it will use the sqlite version available on the system.
  databaseFactory = databaseFactoryFfi;

  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String path = join(documentsDirectory.path, "carvalho.db");

  String sql = """
  CREATE TABLE IF NOT EXISTS entradas (
    id INTEGER PRIMARY KEY,
    checkin INTEGER,
    checkout INTEGER,
    quartos TEXT DEFAULT \"[]\",
    hospedes TEXT DEFAULT \"[]\",
    diaria REAL,
    total REAL,
    paga INTEGER DEFAULT 0,
    observacao TEXT DEFAULT \"\"
  );
  
  CREATE TABLE IF NOT EXISTS quartos (
    id INTEGER PRIMARY KEY,
    number INTEGER UNIQUE,
    occupancy INTEGER,
    status TEXT DEFAULT "LIVRE"
  );
  
  CREATE TABLE IF NOT EXISTS hospedes (
    id INTEGER PRIMARY KEY,
    nome TEXT UNIQUE,
    documento TEXT,
    telefone TEXT,
    empresa INTEGER DEFAULT 0
  );
  
  CREATE TABLE IF NOT EXISTS pagamentos (
    id INTEGER PRIMARY KEY,
    valor REAL,
    data INTEGER,
    metodo TEXT,
    pagante TEXT
  );
""";

  openDatabase(
    path,
    onCreate: (db, version) async {
      // Execute all the CREATE TABLE statements in one go
      await db.execute(sql);
    },
    version: 1,
    onConfigure: (db) => db.execute(sql),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
