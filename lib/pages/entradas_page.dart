import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:carvalho/conf.dart';
import 'package:carvalho/db/entrada_db.dart';
import 'package:carvalho/db/hospede_db.dart';
import 'package:carvalho/db/pagamento_db.dart';
import 'package:carvalho/db/quarto_db.dart';
import 'package:carvalho/model/entrada.dart';
import 'package:carvalho/model/hospede.dart';
import 'package:carvalho/model/pagamento.dart';
import 'package:carvalho/model/quarto.dart';
import 'package:carvalho/partials/custom_input.dart';
import 'package:carvalho/partials/icon_text.dart';
import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pix_flutter/pix_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pdf/widgets.dart' as pw;

class EntradasPage extends StatefulWidget {
  const EntradasPage({super.key});

  @override
  State<EntradasPage> createState() => _EntradasPageState();
}

class _EntradasPageState extends State<EntradasPage> {
  int month = 0;
  ordenador orde = ordenador.VALOR;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: EntradaDB().entradas(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                // print(snapshot.error);
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      Text("Unable to fetch bookings!"),
                    ],
                  ),
                );
              } else {
                List<Entrada> entradas = snapshot.requireData;
                if (entradas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off),
                        Text("Nenhuma reserva encontrada!"),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildAddEntrada(context),
                            ).then((value) {
                              setState(() {});
                            });
                          },
                          child: Text("Adicionar reserva"),
                        ),
                      ],
                    ),
                  );
                }

                switch (orde) {
                  case ordenador.CHECKIN:
                    entradas.sort(
                      (a, b) => b.checkin.compareTo(a.checkin),
                    );
                    break;
                  case ordenador.CHECKOUT:
                    entradas.sort(
                      (a, b) => b.checkout.compareTo(a.checkout),
                    );
                    break;
                  case ordenador.VALOR:
                    entradas.sort(
                      (a, b) => b.total.compareTo(a.total),
                    );
                    break;
                  case ordenador.KPA:
                    entradas.sort(
                      (a, b) => b.hospedes.length.compareTo(a.hospedes.length),
                    );
                    break;
                  case ordenador.NOME:
                    entradas.sort(
                      (a, b) => b.hospedes.first.nome.compareTo(a.hospedes.first.nome),
                    );
                    break;
                  case ordenador.PAGO:
                    entradas.sort(
                      (a, b) => b.paga ? 1 : -1,
                    );
                }

                if (month != 0) {
                  entradas = entradas.where((entrada) => entrada.checkin.month == month).toList();
                }

                return Scaffold(
                  floatingActionButton: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildAddEntrada(context),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                  appBar: AppBar(
                    title: Column(
                      children: [
                        Text(
                          "Total: R\$ ${entradas.isNotEmpty ? entradas.map((e) => e.total).reduce((a, b) => a + b) : 0}",
                        ),
                        Text(
                          "Total pago: R\$ ${entradas.where((element) => element.paga).isNotEmpty ? entradas.where(
                                (element) => element.paga,
                              ).map((e) => e.total).reduce((a, b) => a + b) : 0}",
                        )
                      ],
                    ),
                    actions: [
                      DropdownMenu(
                        initialSelection: month,
                        onSelected: (value) {
                          if (value != null) {
                            // print(value);
                            setState(() {
                              month = value;
                            });
                          }
                        },
                        dropdownMenuEntries: months.values
                            .map(
                              (e) => DropdownMenuEntry(value: e.index, label: e.name),
                            )
                            .toList(),
                      ),
                      DropdownMenu(
                        initialSelection: orde,
                        onSelected: (value) {
                          if (value != null) {
                            // print(value);
                            setState(() {
                              orde = (value);
                            });
                          }
                        },
                        dropdownMenuEntries: ordenador.values
                            .map(
                              (e) => DropdownMenuEntry(value: e, label: e.name),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                  body: ListView.builder(
                    itemCount: entradas.length,
                    itemBuilder: (context, index) {
                      Entrada entrada = entradas[index];

                      final dataSet = HashSet<Hospede>(
                        equals: (a, b) => a.nome == b.nome,
                        hashCode: (a) => a.nome.hashCode,
                      )..addAll(entrada.hospedes);

                      return ListTile(
                        leading: Icon(Icons.local_hotel),
                        title: Row(
                          children: [
                            IconText(
                              icon: Icons.people,
                              width: 200,
                              text: "${entrada.hospedes.length} x ${dataSet.first.nome}",
                            ),
                            IconText(
                              icon: Icons.meeting_room,
                              text: entrada.quartos.map((e) => e.number).join(" | "),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(entrada.observacao),
                            Row(
                              spacing: 5,
                              children: [
                                IconText(
                                  icon: Icons.currency_bitcoin,
                                  text: "R\$ ${entrada.total}",
                                  width: 90,
                                  spacing: 5,
                                ),
                                IconText(
                                  icon: Icons.calendar_month,
                                  text: formater.format(entrada.checkin),
                                  width: 93,
                                  spacing: 2,
                                ),
                                IconText(
                                  icon: Icons.calendar_month,
                                  text: formater.format(entrada.checkout),
                                  width: 93,
                                  spacing: 2,
                                ),
                                IconText(
                                  icon: Icons.currency_exchange,
                                  text: entrada.paga ? "SIM" : "NÃO",
                                  width: 55,
                                  spacing: 2,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _buildEditEntrada(context, entrada),
                                    ).then(
                                      (value) {
                                        setState(() {});
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    EntradaDB().deleteEntrada(entrada.id);
                                    entrada.quartos.forEach((quarto) {
                                      QuartoDB().limparQuarto(quarto.number);
                                    });
                                    setState(() {});
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                                if (entrada.paga == false)
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => _buildPagar(context, entrada),
                                      ).then(
                                        (value) {
                                          setState(() {});
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.currency_exchange),
                                  ),
                                IconButton(
                                  onPressed: () async {
                                    Directory directory = await getDownloadsDirectory() ??
                                        await getApplicationDocumentsDirectory();
                                    String fileName =
                                        "hospedagem_${entrada.hospedes.first.nome}_${DateFormat("d_M_y").format(entrada.checkin)}.pdf";
                                    String path = join(directory.path, fileName);
                                    // print(path);

                                    final pdf = pw.Document();
                                    pdf.addPage(
                                      pw.Page(
                                        pageFormat: PdfPageFormat.a4,
                                        build: (context) => pw.Column(
                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Center(
                                              child: pw.Column(
                                                children: [
                                                  pw.Text("Carvalho de Oliveira e Cia Ltda"),
                                                  pw.Text("Hotel Carvalho"),
                                                ],
                                              ),
                                            ),
                                            pw.Text(entrada.hospedes.first.nome),
                                            pw.Row(
                                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                              children: [
                                                pw.Text(
                                                    "Entrada: ${formater.format(entrada.checkin)}"),
                                                pw.Text(
                                                    "Saída: ${formater.format(entrada.checkout)}"),
                                              ],
                                            ),
                                            pw.Text("Hospedes: ${entrada.hospedes.length}"),
                                            pw.Text("Unidades: ${entrada.quartos.map(
                                                  (e) => e.number,
                                                ).join(", ")}"),
                                            pw.Text("Diaria: R\$${entrada.diaria}"),
                                            pw.Text("Total: R\$${entrada.total}"),
                                          ],
                                        ),
                                      ),
                                    );
                                    var file = File(path);
                                    await file.writeAsBytes(await pdf.save());
                                    await OpenFilex.open(path);
                                  },
                                  icon: Icon(Icons.print),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            default:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.question_mark),
                    Text("Oops something went wrong!"),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildAddEntrada(BuildContext context) {
    DateTime checkIn = DateTime.now().toLocal();
    DateTime checkOut = DateTime.now().toLocal();
    List<Quarto> quartos = [];
    List<Hospede> hospedes = [];
    CurrencyTextFieldController diaria = CurrencyTextFieldController(
      currencySymbol: "R\$",
      decimalSymbol: ",",
      thousandSymbol: ".",
      minValue: 0,
    );
    TextEditingController observacao = TextEditingController();

    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              // Quartos
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Quartos"),
                ),
                child: Container(
                  height: 150,
                  child: FutureBuilder(
                    future: QuartoDB().avaliable(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error),
                                    Text("Unable to fetch rooms"),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            List<Quarto> quartoLocal = snapshot.requireData;
                            quartoLocal.sort((a, b) => a.number.compareTo(b.number));
                            return StatefulBuilder(
                              builder: (context, setState) => GridView.builder(
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 100,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: quartoLocal.length,
                                itemBuilder: (context, index) {
                                  Quarto quarto = quartoLocal[index];
                                  return GestureDetector(
                                    onTap: () {
                                      if (quartos.contains(quarto)) {
                                        quartos.remove(quarto);
                                      } else {
                                        quartos.add(quarto);
                                      }
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: (quartos.contains(quarto))
                                            ? Colors.red[900]
                                            : Colors.black54,
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text("# ${quarto.number}"),
                                          IconText(
                                            icon: Icons.people,
                                            text: "${quarto.occupancy} x ",
                                            spacing: 0,
                                            reversed: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        default:
                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.question_mark),
                                  Text("Unknown state"),
                                ],
                              ),
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
              // Hospedes
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Hospedes"),
                ),
                child: Container(
                  height: 150,
                  child: FutureBuilder(
                    future: HospedeDB().hospedes(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(),
                            ),
                          );
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Center(
                              child: Container(
                                width: 100,
                                height: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error),
                                    Text("Unable to fetch rooms"),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            List<Hospede> hospedeLocal = snapshot.requireData;
                            return StatefulBuilder(
                              builder: (context, setState) => GridView.builder(
                                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 150,
                                  childAspectRatio: 1.2,
                                ),
                                itemCount: hospedeLocal.length,
                                itemBuilder: (context, index) {
                                  Hospede hospede = hospedeLocal[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon((hospede.empresa) ? Icons.business : Icons.people),
                                        IconText(
                                          icon: Icons.abc,
                                          text: hospede.nome,
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                hospedes.remove(hospede);
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.remove),
                                            ),
                                            Text(
                                              hospedes
                                                  .where((element) => element == hospede)
                                                  .length
                                                  .toString(),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                hospedes.add(hospede);
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                        default:
                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.question_mark),
                                  Text("Unknown state"),
                                ],
                              ),
                            ),
                          );
                      }
                    },
                  ),
                ),
              ),
              StatefulBuilder(
                builder: (context, setState) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () async {
                        DateTime? nCheckIn = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(Duration(days: 120)),
                          currentDate: checkIn.toLocal(),
                          lastDate: DateTime.now().add(Duration(days: 120)),
                          helpText: "Check-in",
                        );
                        if (nCheckIn != null) {
                          checkIn = nCheckIn;
                        }
                        setState(() {});
                      },
                      icon: Container(
                        width: 150,
                        height: 50,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            ),
                            label: Text("Check-in"),
                          ),
                          child: IconText(
                            icon: Icons.calendar_month,
                            text: formater.format(checkIn),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        DateTime? nCheckout = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now().subtract(Duration(days: 120)),
                          currentDate: checkOut,
                          lastDate: DateTime.now().add(Duration(days: 120)),
                          helpText: "Check-Out",
                        );
                        if (nCheckout != null) {
                          checkOut = nCheckout.toLocal();
                        }
                        setState(() {});
                      },
                      icon: Container(
                        width: 150,
                        height: 50,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                            ),
                            label: Text("Checkout"),
                          ),
                          child: IconText(
                            icon: Icons.calendar_month,
                            text: formater.format(checkOut),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              CustomInput(
                controller: diaria,
                label: "Valor Diaria",
                keyboardType: TextInputType.number,
              ),
              CustomInput(
                controller: observacao,
                label: "Observação",
                // outline: true,
              ),
              IconButton(
                onPressed: () async {
                  if (quartos.isNotEmpty && hospedes.isNotEmpty && diaria.value.text.isNotEmpty) {
                    Map<String, dynamic> entrada = {
                      "checkin": checkIn.millisecondsSinceEpoch,
                      "checkout": checkOut.millisecondsSinceEpoch,
                      "quartos": jsonEncode(quartos.map((e) => e.toJson()).toList()),
                      "hospedes": jsonEncode(hospedes.map((e) => e.toJson()).toList()),
                      "diaria": diaria.doubleValue,
                      "total": (checkOut.difference(checkIn).inDays +
                              (checkIn.isBefore(checkOut) ? 0 : 1)) *
                          hospedes.length *
                          diaria.doubleValue,
                      "paga": 0,
                      "observacao": observacao.text
                    };

                    bool ok = await EntradaDB().addEntrada(entrada);
                    quartos.forEach(
                      (element) {
                        QuartoDB().ocuparQuarto(element.number);
                      },
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? "Entrada adicionada" : "Erro ao adicionar entrada",
                        ),
                      ),
                    );

                    Navigator.of(context).pop();
                  }
                },
                color: Colors.white,
                icon: Text("Adicionar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditEntrada(BuildContext context, Entrada entrada) {
    DateTime checkIn = entrada.checkin;
    DateTime checkOut = entrada.checkout;
    List<Quarto> quartos = entrada.quartos;
    List<Hospede> hospedes = entrada.hospedes;
    CurrencyTextFieldController diaria = CurrencyTextFieldController(
        currencySymbol: "R\$",
        decimalSymbol: ",",
        thousandSymbol: ".",
        minValue: 0,
        initDoubleValue: entrada.diaria);
    TextEditingController observacao = TextEditingController(text: entrada.observacao);
    // print(hospedes);

    return Dialog(
      insetPadding: EdgeInsets.all(15),
      child: Container(
        padding: EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        color: Colors.black87,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 10,
          children: [
            // Quartos
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Quartos"),
              ),
              child: Container(
                height: 150,
                child: FutureBuilder(
                  future: QuartoDB().quartos(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error),
                                  Text("Unable to fetch rooms"),
                                ],
                              ),
                            ),
                          );
                        } else {
                          List<Quarto> quartoLocal = snapshot.requireData;
                          quartoLocal.sort((a, b) => a.number.compareTo(b.number));
                          return StatefulBuilder(
                            builder: (context, setState) => GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 100,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: quartoLocal.length,
                              itemBuilder: (context, index) {
                                Quarto quarto = quartoLocal[index];
                                return GestureDetector(
                                  onTap: () {
                                    if (quartos.contains(quarto)) {
                                      quartos.remove(quarto);
                                    } else {
                                      quartos.add(quarto);
                                    }
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: (quartos.contains(quarto))
                                          ? Colors.red[900]
                                          : Colors.black54,
                                      borderRadius: BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text("# ${quarto.number}"),
                                        IconText(
                                          icon: Icons.people,
                                          text: "${quarto.occupancy} x ",
                                          spacing: 0,
                                          reversed: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      default:
                        return Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.question_mark),
                                Text("Unknown state"),
                              ],
                            ),
                          ),
                        );
                    }
                  },
                ),
              ),
            ),
            // Hospedes
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Hospedes"),
              ),
              child: Container(
                height: 150,
                child: FutureBuilder(
                  future: HospedeDB().hospedes(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      case ConnectionState.done:
                        if (snapshot.hasError) {
                          return Center(
                            child: Container(
                              width: 100,
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error),
                                  Text("Unable to fetch rooms"),
                                ],
                              ),
                            ),
                          );
                        } else {
                          List<Hospede> hospedeLocal = snapshot.requireData;
                          return StatefulBuilder(
                            builder: (context, setState) => GridView.builder(
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 150,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: hospedeLocal.length,
                              itemBuilder: (context, index) {
                                Hospede hospede = hospedeLocal[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon((hospede.empresa) ? Icons.business : Icons.people),
                                      IconText(
                                        icon: Icons.abc,
                                        text: hospede.nome,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              hospedes.remove(hospede);
                                              setState(() {});
                                            },
                                            icon: Icon(Icons.remove),
                                          ),
                                          Text(
                                            hospedes
                                                .where((element) => element == hospede)
                                                .length
                                                .toString(),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              hospedes.add(hospede);
                                              // print(hospedes);
                                              setState(() {});
                                            },
                                            icon: Icon(Icons.add),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      default:
                        return Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.question_mark),
                                Text("Unknown state"),
                              ],
                            ),
                          ),
                        );
                    }
                  },
                ),
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      DateTime? nCheckIn = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(days: 120)),
                        currentDate: checkIn,
                        lastDate: DateTime.now().add(Duration(days: 120)),
                        helpText: "Check-in",
                      );
                      if (nCheckIn != null) {
                        checkIn = nCheckIn.toLocal();
                      }
                      setState(() {});
                    },
                    icon: Container(
                      width: 150,
                      height: 50,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          label: Text("Check-in"),
                        ),
                        child: IconText(
                          icon: Icons.calendar_month,
                          text: formater.format(checkIn),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      DateTime? nCheckout = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(days: 120)),
                        currentDate: checkOut,
                        lastDate: DateTime.now().add(Duration(days: 120)),
                        helpText: "Check-Out",
                      );
                      if (nCheckout != null) {
                        checkOut = nCheckout.toLocal();
                      }
                      setState(() {});
                    },
                    icon: Container(
                      width: 150,
                      height: 50,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                          label: Text("Checkout"),
                        ),
                        child: IconText(
                          icon: Icons.calendar_month,
                          text: formater.format(checkOut),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CustomInput(
              controller: diaria,
              label: "Valor Diaria",
              keyboardType: TextInputType.number,
            ),
            CustomInput(controller: observacao, label: "Observação"),
            TextButton(
              onPressed: () async {
                Map<String, dynamic> new_entrada = {
                  "checkin": checkIn.millisecondsSinceEpoch,
                  "checkout": checkOut.millisecondsSinceEpoch,
                  "quartos": jsonEncode(quartos.map((e) => e.toJson()).toList()),
                  "hospedes": jsonEncode(hospedes.map((e) => e.toJson()).toList()),
                  "diaria": diaria.doubleValue,
                  "total":
                      (checkOut.difference(checkIn).inDays + (checkIn.isBefore(checkOut) ? 0 : 1)) *
                          hospedes.length *
                          diaria.doubleValue,
                  "paga": 0,
                  "observacao": observacao.text,
                };

                bool ok = await EntradaDB().updateEntrada(entrada.id, new_entrada);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok ? "Entrada atualizada" : "Erro ao atualizar entrada",
                    ),
                  ),
                );

                Navigator.of(context).pop();
              },
              child: Text("Atualizar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagar(BuildContext context, Entrada entrada) {
    CurrencyTextFieldController total = CurrencyTextFieldController(
      initDoubleValue: entrada.total,
      currencySymbol: "R\$",
      thousandSymbol: ".",
      decimalSymbol: ",",
    );

    TextEditingController pagante = TextEditingController();
    DateTime data = entrada.checkout;
    TextEditingController metodo = TextEditingController();

    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(20),
          height: 450,
          decoration: BoxDecoration(
            color: Colors.black87,
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(25)),
          ),
          child: Column(
            spacing: 20,
            children: [
              CustomInput(controller: total, label: "Total"),
              DropdownMenu(
                width: MediaQuery.of(context).size.width,
                label: Text("Pagante"),
                initialSelection: entrada.hospedes.first.nome,
                onSelected: (value) {
                  if (value != null) {
                    pagante.text = value;
                  }
                  setState(() {});
                },
                dropdownMenuEntries: entrada.hospedes
                    .map(
                      (e) => DropdownMenuEntry(value: e.toJson(), label: e.nome),
                    )
                    .toList(),
              ),
              IconButton(
                onPressed: () async {
                  DateTime? nData = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(Duration(days: 120)),
                    currentDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 120)),
                    helpText: "Data de Pagamento",
                  );
                  if (nData != null) {
                    data = nData;
                  }
                  setState(() {});
                },
                icon: Container(
                  width: 120,
                  height: 50,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      label: Text("Data de Pagamento"),
                    ),
                    child: IconText(
                      icon: Icons.calendar_month,
                      text: formater.format(data),
                    ),
                  ),
                ),
              ),
              DropdownMenu(
                width: MediaQuery.of(context).size.width,
                label: Text("Metodo de Pagamento"),
                controller: metodo,
                initialSelection: METODO_PAGAMENTO.DINHEIRO.name,
                onSelected: (value) {
                  if (value == METODO_PAGAMENTO.PIX.name) {
                    PixFlutter pixFlutter = PixFlutter(
                      payload: Payload(
                        pixKey: '53612825615',
                        merchantName: 'Hotel Carvalho',
                        merchantCity: 'Guaruanesia, MG',
                        txid: entrada.id.toRadixString(2),
                        amount: total.doubleValue.toString(),
                      ),
                    );

                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: Container(
                          child: QrImageView(
                            data: pixFlutter.getQRCode(),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                },
                dropdownMenuEntries: METODO_PAGAMENTO.values
                    .map(
                      (e) => DropdownMenuEntry(value: e.name, label: e.name),
                    )
                    .toList(),
              ),
              TextButton(
                child: Text("Pagar"),
                onPressed: () async {
                  if (pagante.text.isNotEmpty && metodo.text.isNotEmpty) {
                    Map<String, dynamic> pagamento = {
                      "pagante": pagante.text,
                      "valor": total.doubleValue,
                      "data": data.millisecondsSinceEpoch,
                      "metodo": metodo.text,
                    };
                    await PagamentoDB().addPagamento(pagamento);
                    if (entrada.total == total.doubleValue) {
                      await EntradaDB().setPago(entrada.id);
                    } else {
                      await EntradaDB().changeTotal(
                        entrada.id,
                        total.doubleValue,
                      );
                    }

                    entrada.quartos.forEach(
                      (quarto) {
                        QuartoDB().vagarQuarto(quarto.number);
                      },
                    );

                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Preencha todos os campos"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
