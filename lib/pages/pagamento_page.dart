import 'package:carvalho/conf.dart';
import 'package:carvalho/db/pagamento_db.dart';
import 'package:carvalho/model/pagamento.dart';
import 'package:carvalho/partials/icon_text.dart';
import 'package:flutter/material.dart';

class PagamentoPage extends StatefulWidget {
  const PagamentoPage({super.key});

  @override
  State<PagamentoPage> createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: PagamentoDB().pagamentos(),
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
                      Text("Unable to fetch payments!"),
                    ],
                  ),
                );
              } else {
                List<Pagamento> pagamentos = snapshot.requireData;
                // print(pagamentos.length);
                if (pagamentos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off),
                        Text("Nenhum pagamento encontrado!"),
                      ],
                    ),
                  );
                }
                return Scaffold(
                  body: ListView.builder(
                    itemCount: pagamentos.length,
                    itemBuilder: (context, index) {
                      Pagamento pagamento = pagamentos[index];

                      return ListTile(
                        leading: Icon(Icons.monetization_on),
                        title: Row(
                          children: [
                            IconText(
                              icon: Icons.people,
                              text: pagamento.pagante.nome,
                              spacing: 1,
                              width: 150,
                            ),
                            IconText(
                              icon: Icons.currency_bitcoin,
                              text: "R\$ ${pagamento.valor}",
                              width: 85,
                              spacing: 5,
                            ),
                            IconText(
                              icon: Icons.calendar_month,
                              text: formater.format(pagamento.data),
                              width: 85,
                              spacing: 2,
                            ),
                            IconText(
                              icon: Icons.payment,
                              text: pagamento.metodo_pagamento.name,
                              width: 100,
                              spacing: 2,
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
}
