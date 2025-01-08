import 'dart:io';

import 'package:carvalho/conf.dart';
import 'package:carvalho/model/pagamento.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class PagamentoDB {
  PagamentoDB();

  Future<Database> getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "carvalho.db");

    return openDatabase(path);
  }

  Future<List<Pagamento>> pagamentos() async {
    var col = await getDatabase();
    List<Map<String, dynamic>> maps = await col.query("pagamentos");

    return List.generate(
      maps.length,
      (index) => Pagamento.fromMap(maps[index]),
    );
  }

  Future<bool> addPagamento(Map<String, dynamic> pagamento) async {
    var col = await getDatabase();

    int res = await col.insert("pagamentos", pagamento);
    return res > 0;
  }
}
