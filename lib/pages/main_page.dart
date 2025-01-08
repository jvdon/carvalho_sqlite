import 'package:carvalho/pages/entradas_page.dart';
import 'package:carvalho/pages/hospede_page.dart';
import 'package:carvalho/pages/pagamento_page.dart';
import 'package:carvalho/pages/quartos_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currId = 0;
  List<Widget> pages = [
    EntradasPage(),
    QuartosPage(),
    HospedePage(),
    PagamentoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currId],
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.purple[800],
        enableFeedback: true,
        currentIndex: currId,
        unselectedItemColor: Colors.white,
        onTap: (value) {
          setState(() {
            currId = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: "Entrada",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bed),
            label: "Quartos",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: "Hospedes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: "Pagamentos",
          ),
        ],
      ),
    );
  }
}
