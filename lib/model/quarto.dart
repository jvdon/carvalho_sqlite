import 'dart:convert';

import 'package:flutter/material.dart';

class Quarto {
  int number;
  int occupancy;
  Quarto_Status status;

  Quarto({
    required this.number,
    required this.occupancy,
    required this.status,
  });

  factory Quarto.fromMap(Map<String, dynamic> map) {
    return Quarto(
      number: map['number'] as int,
      occupancy: map['occupancy'] as int,
      status: Quarto_Status.values.byName(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "number": number,
      "occupancy": occupancy,
      "status": status.name,
    };
  }

  factory Quarto.fromJSON(String json) => Quarto.fromMap(jsonDecode(json));

  String toJson() => jsonEncode(toMap());

  @override
  bool operator ==(Object other) {
    // Ensure the object is of the same type
    if (identical(this, other)) return true;
    return other is Quarto &&
        other.number == number &&
        other.occupancy == occupancy;
  }

  @override
  int get hashCode => number.hashCode ^ occupancy.hashCode;
}

enum Quarto_Status { LIVRE, USADO, OCUPADO }

Map<Quarto_Status, Color> status_color = {
  Quarto_Status.LIVRE: Colors.green[900]!,
  Quarto_Status.OCUPADO: Colors.red,
  Quarto_Status.USADO: Colors.yellow[900]!,
};
