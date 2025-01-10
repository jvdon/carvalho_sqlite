import 'dart:convert';

import 'package:carvalho/conf.dart';
import 'package:carvalho/model/hospede.dart';
import 'package:carvalho/model/quarto.dart';

class Entrada {
  int id;
  DateTime checkin;
  DateTime checkout;
  List<Quarto> quartos;
  List<Hospede> hospedes;
  double diaria;
  double total;
  bool paga;

  Entrada({
    required this.id,
    required this.checkin,
    required this.checkout,
    required this.quartos,
    required this.hospedes,
    required this.diaria,
    required this.total,
    required this.paga,
  });

  factory Entrada.fromMap(Map<String, dynamic> map) {
    int checkin = (map['checkin'] is int)
        ? map['checkin'] // If it's already an int, just use it
        : int.parse(map['checkin'].toString());

    int checkout = (map['checkout'] is int)
        ? map['checkout'] // If it's already an int, just use it
        : int.parse(map['checkout'].toString());

    double diaria = (map['diaria'] is double)
        ? map['diaria']
        : double.parse(map['diaria'].toString());

    double total = (map['total'] is double)
        ? map['total']
        : double.parse(map['total'].toString());
    return Entrada(
      id: map['id'],
      checkin: DateTime.fromMillisecondsSinceEpoch(checkin),
      checkout: DateTime.fromMillisecondsSinceEpoch(checkout),
      quartos: (jsonDecode(map['quartos']) as List)
          .map((e) => Quarto.fromJSON(e))
          .toList(),
      hospedes: (jsonDecode(map['hospedes']) as List)
          .map((e) => Hospede.fromJSON(e))
          .toList(),
      diaria: diaria,
      total: total,
      paga: map['paga'] is bool ? map['paga'] : map['paga'] == 1,
    );
  }

  @override
  String toString() {
    return """
      Id: ${id.toString()}
      Checkin: ${formater.format(checkin)}
      Checkout: ${formater.format(checkout)}
      Pago: ${paga}
      Hospedes: ${hospedes.length}
      Quartos: ${quartos.length}
    """;
  }
}
