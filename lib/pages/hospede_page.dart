import 'package:carvalho/db/hospede_db.dart';
import 'package:carvalho/model/hospede.dart';
import 'package:carvalho/partials/custom_input.dart';
import 'package:carvalho/partials/icon_text.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class HospedePage extends StatefulWidget {
  const HospedePage({super.key});

  @override
  State<HospedePage> createState() => _HospedePageState();
}

class _HospedePageState extends State<HospedePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        future: HospedeDB().hospedes(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error),
                      Text("Unable to fetch guests!"),
                    ],
                  ),
                );
              } else {
                List<Hospede> hospedes = snapshot.requireData;
                if (hospedes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off),
                        Text("Nenhum hospede encontrado!"),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => _buildAddHospede(context),
                            ).then(
                              (value) {
                                setState(() {});
                              },
                            );
                          },
                          child: Text("Adicionar um hospede"),
                        ),
                      ],
                    ),
                  );
                }
                return Scaffold(
                  floatingActionButton: IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildAddHospede(context),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                    icon: Icon(Icons.add),
                  ),
                  body: ListView.builder(
                    itemCount: hospedes.length,
                    itemBuilder: (context, index) {
                      Hospede hospede = hospedes[index];
                      return ListTile(
                        leading: Icon(
                            (!hospede.empresa) ? Icons.people : Icons.business),
                        title: Text(hospede.nome),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                IconText(
                                  icon: Icons.wysiwyg,
                                  text: hospede.documento.isEmpty
                                      ? "No Data"
                                      : hospede.documento,
                                ),
                                IconText(
                                  icon: Icons.phone,
                                  text: hospede.telefone.isEmpty
                                      ? "No Data"
                                      : hospede.telefone,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          _buildEditHospede(context, hospede),
                                    ).then(
                                      (value) {
                                        setState(() {});
                                      },
                                    );
                                  },
                                  icon: Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    bool ok = await HospedeDB()
                                        .deletehospede(hospede.nome);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? "Guest delete successfully"
                                              : "Unable to delete guest",
                                        ),
                                      ),
                                    );

                                    setState(() {});
                                  },
                                  icon: Icon(Icons.delete),
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

  Widget _buildAddHospede(BuildContext context) {
    TextEditingController nome = TextEditingController();
    TextEditingController documento = TextEditingController();
    TextEditingController telefone = TextEditingController();
    bool empresa = false;

    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 400,
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
                controller: nome,
                label: "Nome",
                keyboardType: TextInputType.name,
              ),
              CustomInput(
                controller: documento,
                label: "Documento",
                keyboardType: TextInputType.number,
                formatters: [
                  (empresa == false)
                      ? MaskTextInputFormatter(
                          mask: "###.###.###-##",
                        )
                      : MaskTextInputFormatter(
                          mask: "##.###.###/####-##",
                        ),
                ],
              ),
              CustomInput(
                controller: telefone,
                label: "Telefone",
                keyboardType: TextInputType.number,
                formatters: [
                  MaskTextInputFormatter(mask: "(##) #####-####"),
                ],
              ),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Empresa"),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Switch(
                      value: empresa,
                      onChanged: (value) {
                        setState(() {
                          empresa = value;
                        });
                      },
                    ),
                    Text(
                      (empresa) ? "SIM" : "NÃO",
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  Map<String, dynamic> hospede = {
                    "nome": nome.text,
                    "documento": documento.text,
                    "telefone": telefone.text,
                    "empresa": empresa ? 1 : 0,
                  };

                  HospedeDB().addhospede(hospede);

                  Navigator.of(context).pop();
                },
                child: Text("Adicionar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditHospede(BuildContext context, Hospede hospede) {
    TextEditingController nome = TextEditingController(text: hospede.nome);
    TextEditingController documento =
        TextEditingController(text: hospede.documento);
    TextEditingController telefone =
        TextEditingController(text: hospede.telefone);
    bool empresa = hospede.empresa;

    return Dialog(
      child: StatefulBuilder(
        builder: (context, setState) => Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 400,
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
                controller: nome,
                label: "Nome",
                keyboardType: TextInputType.name,
              ),
              CustomInput(
                controller: documento,
                label: "Documento",
                keyboardType: TextInputType.number,
                formatters: [
                  (empresa == false)
                      ? MaskTextInputFormatter(
                          mask: "###.###.###-##",
                        )
                      : MaskTextInputFormatter(
                          mask: "##.###.###/####-##",
                        ),
                ],
              ),
              CustomInput(
                controller: telefone,
                label: "Telefone",
                keyboardType: TextInputType.number,
                formatters: [
                  MaskTextInputFormatter(mask: "(##) #####-####"),
                ],
              ),
              InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Empresa"),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Switch(
                      value: empresa,
                      onChanged: (value) {
                        setState(() {
                          empresa = value;
                        });
                      },
                    ),
                    Text(
                      (empresa) ? "SIM" : "NÃO",
                    )
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  Map<String, dynamic> hospedeN = {
                    "nome": nome.text,
                    "documento": documento.text,
                    "telefone": telefone.text,
                    "empresa": empresa ? 1 : 0,
                  };

                  HospedeDB().updatehospede(hospede.nome, hospedeN);

                  Navigator.of(context).pop();
                },
                child: Text("Atualizar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
