import 'dart:io';

import 'package:carvalho/conf.dart';
import 'package:carvalho/model/hospede.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class HospedeDB {
  HospedeDB();

  Future<Database> getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "carvalho.db");

    return openDatabase(path);
  }

  Future<List<Hospede>> hospedes() async {
    var col = await getDatabase();
    List<Map<String, dynamic>> maps = await col.query("hospedes");

    return List.generate(maps.length, (index) => Hospede.fromMap(maps[index]));
  }

  Future<Hospede?> gethospedeByNome(String nome) async {
    var col = await getDatabase();
    var map = await col.query("hospedes",
        where: "nome = ?", whereArgs: [nome], limit: 1);
    return List.generate(map.length, (index) => Hospede.fromMap(map[index]))
        .firstOrNull;
  }

  Future<bool> addhospede(Map<String, dynamic> map) async {
    var col = await getDatabase();
    int res = await col.insert("hospedes", map);
    return res > 0;
  }

  Future<bool> deletehospede(String nome) async {
    var col = await getDatabase();
    int res =
        await col.delete("hospedes", where: "nome = ?", whereArgs: [nome]);
    return res > 0;
  }

  Future<bool> updatehospede(String nome, Map<String, dynamic> map) async {
    var col = await getDatabase();
    int res =
        await col.update("hospedes", map, where: "nome = ?", whereArgs: [nome]);
    return res > 0;
  }
}
