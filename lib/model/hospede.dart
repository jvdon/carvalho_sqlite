import 'dart:convert';

class Hospede {
  String nome;
  String documento;
  String telefone;
  bool empresa;

  Hospede(
      {required this.nome,
      required this.telefone,
      required this.documento,
      required this.empresa});

  factory Hospede.fromMap(Map<String, dynamic> map) {
    return Hospede(
      nome: map['nome'],
      telefone: map['telefone'],
      documento: map['documento'],
      empresa: map['empresa'] is bool ? map['empresa'] : map['empresa'] == 1,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'documento': documento,
      'empresa': empresa,
    };
  }

  factory Hospede.fromJSON(String json) {
    return Hospede.fromMap(jsonDecode(json));
  }

  String toJson() => jsonEncode(toMap());

  @override
  bool operator ==(Object other) {
    // Ensure the object is of the same type
    if (identical(this, other)) return true;
    return other is Hospede &&
        other.nome == nome &&
        other.documento == documento;
  }

  @override
  int get hashCode => nome.hashCode ^ documento.hashCode;
}
