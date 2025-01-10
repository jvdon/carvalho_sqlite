import 'dart:io';

import 'package:carvalho/model/quarto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class QuartoDB {
  QuartoDB();

  Future<Database> getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "carvalho.db");

    return openDatabase(path);
  }

  Future<List<Quarto>> quartos() async {
    var col = await getDatabase();
    List<Map<String, dynamic>> maps = await col.query("quartos");

    return List.generate(
      maps.length,
      (index) => Quarto.fromMap(maps[index]),
    );
  }

  Future<List<Quarto>> avaliable() async {
    var col = await getDatabase();
    List<Map<String, dynamic>> maps = await col.query("quartos",
        where: "status = ?", whereArgs: [Quarto_Status.LIVRE.name]);

    return List.generate(maps.length, (index) => Quarto.fromMap(maps[index]));
  }

  Future<Quarto?> getQuartoByNumber(int number) async {
    var col = await getDatabase();
    var map =
        await col.query("quartos", where: "number = ?", whereArgs: [number]);
    return List.generate(
      map.length,
      (index) => Quarto.fromMap(map[index]),
    ).first;
  }

  Future<bool> addQuarto(Map<String, dynamic> map) async {
    var col = await getDatabase();
    int res = await col.insert("quartos", map);
    return res > 0;
  }

  Future<bool> deleteQuarto(int number) async {
    var col = await getDatabase();
    int res =
        await col.delete("quartos", where: "number = ?", whereArgs: [number]);
    return res > 0;
  }

  Future<bool> updateQuarto(int number, Map<String, dynamic> map) async {
    var col = await getDatabase();
    int res = await col
        .update("quartos", map, where: "number = ?", whereArgs: [number]);
    return res > 0;
  }

  Future<bool> ocuparQuarto(int number) async {
    var col = await getDatabase();
    int res = await col.update(
      "quartos",
      {
        "status": Quarto_Status.OCUPADO.name,
      },
      where: "number = ?",
      whereArgs: [number],
    );

    return res > 0;
  }

  Future<bool> limparQuarto(int number) async {
    var col = await getDatabase();
    int res = await col.update(
      "quartos",
      {"status": Quarto_Status.LIVRE.name},
      where: "number = ?",
      whereArgs: [number],
    );

    return res > 0;
  }

  Future<bool> vagarQuarto(int number) async {
    var col = await getDatabase();
    int res = await col.update(
        "quartos",
        {
          "status": Quarto_Status.USADO.name,
        },
        where: "number = ?",
        whereArgs: [number]);

    return res > 0;
  }
}
