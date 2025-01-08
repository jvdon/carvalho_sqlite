import 'dart:convert';

import 'package:carvalho/conf.dart';
import 'package:carvalho/model/hospede.dart';

class Pagamento {
  Hospede pagante;
  double valor;
  DateTime data;
  METODO_PAGAMENTO metodo_pagamento;

  Pagamento({
    required this.pagante,
    required this.valor,
    required this.data,
    required this.metodo_pagamento,
  });

  factory Pagamento.fromMap(Map<String, dynamic> map) {
    int data = (map['data'] is int)
        ? map['data'] // If it's already an int, just use it
        : int.parse(map['data'].toString());

    return Pagamento(
      pagante: Hospede.fromMap(jsonDecode(map['pagante'])),
      valor: map['valor'],
      data: DateTime.fromMillisecondsSinceEpoch(data),
      metodo_pagamento: METODO_PAGAMENTO.values.byName(map['metodo']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "pagante": pagante.toMap(),
      "valor": valor,
      "data": formater.format(data),
      "metodo": metodo_pagamento.name,
    };
  }
}

enum METODO_PAGAMENTO {
  PIX,
  DINHEIRO,
  DEBITO,
  CREDITO,
}
