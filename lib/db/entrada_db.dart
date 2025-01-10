import 'dart:io';

import 'package:carvalho/model/entrada.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class EntradaDB {
  EntradaDB();

  Future<Database> getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "carvalho.db");

    return openDatabase(path);
  }

  Future<List<Entrada>> entradas() async {
    var db = await getDatabase();

    List<Map<String, dynamic>> maps = await db.query("entradas");

    return List.generate(
      maps.length,
      (index) => Entrada.fromMap(maps[index]),
    );
  }

  Future<bool> deleteEntrada(int id) async {
    var col = await getDatabase();

    int rows = await col.delete("entradas", where: "id = ?", whereArgs: [id]);

    return rows > 0;
  }

  Future<bool> addEntrada(Map<String, dynamic> map) async {
    var col = await getDatabase();

    try {
      await col.insert("entradas", map,
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateEntrada(int id, Map<String, dynamic> map) async {
    var col = await getDatabase();
    int rows =
        await col.update("entradas", map, where: "id = ?", whereArgs: [id]);

    return rows > 0;
  }

  Future<bool> setPago(int id) async {
    var col = await getDatabase();

    int rows = await col.update(
      "entradas",
      {
        "paga": 1,
      },
      where: "id = ?",
      whereArgs: [id],
    );

    return rows > 0;
  }

  Future<bool> changeTotal(int id, double total) async {
    var col = await getDatabase();

    int rows = await col.update(
      "entradas",
      {
        "total": total,
      },
      where: "id = ?",
      whereArgs: [id],
    );

    return rows > 0;
  }
}
