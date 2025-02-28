import 'package:intl/intl.dart';

DateFormat formater = DateFormat("d/M/y");

enum months {
  TODOS,
  JANEIRO,
  FEVEREIRO,
  MARCO,
  ABRIL,
  MAIO,
  JUNHO,
  JULHO,
  AGOSTO,
  SETEMBRO,
  OUTUBRO,
  NOVEMBRO,
  DEZEMBRO
}

enum ordenador {
  NOME,
  VALOR,
  CHECKIN,
  CHECKOUT,
  KPA,
  PAGO,
  DEVENDO,
}

int daysBetween(DateTime a, DateTime b) {
  return ((b.millisecondsSinceEpoch - a.millisecondsSinceEpoch) / (24 * 60 * 60 * 1000)).toInt() + 1;
}
