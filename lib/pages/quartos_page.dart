import 'package:carvalho/db/quarto_db.dart';
import 'package:carvalho/model/quarto.dart';
import 'package:carvalho/partials/custom_input.dart';
import 'package:carvalho/partials/icon_text.dart';
import 'package:flutter/material.dart';

class QuartosPage extends StatefulWidget {
  const QuartosPage({super.key});

  @override
  State<QuartosPage> createState() => _QuartosPageState();
}

class _QuartosPageState extends State<QuartosPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: FutureBuilder(
        future: QuartoDB().quartos(),
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
                      Text("Unable to fetch rooms!"),
                    ],
                  ),
                );
              } else {
                List<Quarto> quartos = snapshot.requireData;
                // print(quartos.length);
                if (quartos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off),
                        Text("Nenhum quarto encontrado!"),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildAddQuarto(context),
                            ).then(
                              (value) {
                                setState(() {});
                              },
                            );
                          },
                          child: Text("Adicionar um quarto"),
                        ),
                      ],
                    ),
                  );
                }
                quartos
                    .sort((a, b) => (a.status == Quarto_Status.LIVRE) ? -1 : 1);
                return Scaffold(
                  floatingActionButton: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildAddQuarto(context),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                  body: GridView.builder(
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 160,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: quartos.length,
                    itemBuilder: (context, index) {
                      Quarto quarto = quartos[index];
                      return Container(
                        color: status_color[quarto.status],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.bed),
                            Text("# ${quarto.number}"),
                            IconText(
                              icon: Icons.people,
                              text: "${quarto.occupancy} x ",
                              spacing: 0,
                              reversed: true,
                            ),
                            Container(
                              width: 150,
                              child: Row(
                                spacing: 0,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    iconSize: 16,
                                    enableFeedback: true,
                                    tooltip: "Editar",
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _buildEditQuarto(context, quarto),
                                      ).then(
                                        (value) {
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    iconSize: 16,
                                    tooltip: "Deletar",
                                    enableFeedback: true,
                                    onPressed: () async {
                                      bool ok = await QuartoDB()
                                          .deleteQuarto(quarto.number);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ok
                                                ? "Room delete successfully"
                                                : "Unable to delete room",
                                          ),
                                        ),
                                      );

                                      setState(() {});
                                    },
                                  ),
                                  if (quarto.status == Quarto_Status.USADO)
                                    IconButton(
                                      icon: Icon(Icons.cleaning_services),
                                      iconSize: 16,
                                      tooltip: "Limpar",
                                      enableFeedback: true,
                                      onPressed: () async {
                                        Map<String, dynamic> room = {
                                          "number": quarto.number,
                                          "occupancy": quarto.occupancy,
                                          "status": Quarto_Status.LIVRE.name
                                        };

                                        bool ok = await QuartoDB()
                                            .updateQuarto(quarto.number, room);
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
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

  Widget _buildAddQuarto(BuildContext context) {
    TextEditingController number = TextEditingController();
    TextEditingController occupancy = TextEditingController();
    TextEditingController status = TextEditingController();

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 300,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              controller: number,
              label: "Room Number",
              keyboardType: TextInputType.number,
            ),
            CustomInput(
              controller: occupancy,
              label: "Room Capacity",
              keyboardType: TextInputType.number,
            ),
            DropdownMenu(
              controller: status,
              width: double.infinity,
              enableSearch: true,
              label: Text("Room Status"),
              dropdownMenuEntries: Quarto_Status.values
                  .map((e) => DropdownMenuEntry(value: e.name, label: e.name))
                  .toList(),
            ),
            TextButton(
              onPressed: () async {
                if (number.text.isNotEmpty && occupancy.text.isNotEmpty) {
                  Map<String, dynamic> room = {
                    "number": int.parse(number.text),
                    "occupancy": int.parse(occupancy.text),
                    "status": status.text,
                  };

                  await QuartoDB().addQuarto(room);

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Preencha todos os campos")));
                }
              },
              child: Text("Adicionar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditQuarto(BuildContext context, Quarto quarto) {
    TextEditingController number =
        TextEditingController(text: quarto.number.toString());
    TextEditingController occupancy =
        TextEditingController(text: quarto.occupancy.toString());
    TextEditingController status =
        TextEditingController(text: quarto.status.name);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: 300,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: Column(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomInput(
              controller: number,
              label: "Room Number",
              keyboardType: TextInputType.number,
            ),
            CustomInput(
              controller: occupancy,
              label: "Room Capacity",
              keyboardType: TextInputType.number,
            ),
            DropdownMenu(
              controller: status,
              width: double.infinity,
              enableSearch: true,
              label: Text("Room Status"),
              initialSelection: quarto.status.name,
              dropdownMenuEntries: Quarto_Status.values
                  .map((e) => DropdownMenuEntry(value: e.name, label: e.name))
                  .toList(),
            ),
            TextButton(
              onPressed: () async {
                if (number.text.isNotEmpty && occupancy.text.isNotEmpty) {
                  Map<String, dynamic> room = {
                    "number": int.parse(number.text),
                    "occupancy": int.parse(occupancy.text),
                    "status": status.text,
                  };

                  await QuartoDB().updateQuarto(quarto.number, room);

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Preencha todos os campos"),
                    ),
                  );
                }
              },
              child: Text("Atualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
