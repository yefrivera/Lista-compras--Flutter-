import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DuplicarListaForm extends StatefulWidget {
  final String listaActual;
  final String? idListaSeleccionada;

  DuplicarListaForm({required this.listaActual, this.idListaSeleccionada});

  @override
  _DuplicarListaFormState createState() => _DuplicarListaFormState();
}

class _DuplicarListaFormState extends State<DuplicarListaForm> {
  String nuevoNombreLista = '';
  String? listaSeleccionada;
  List<String> listasFromDatabase = [];
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    cargarListasDesdeBaseDeDatos();
  }

  void cargarListasDesdeBaseDeDatos() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Listas').get();
      List<String> nombresListas = [];
      querySnapshot.docs.forEach((doc) {
        nombresListas.add(doc['nombre']);
      });
      setState(() {
        listasFromDatabase = nombresListas;
      });
    } catch (e) {
      print('Error al cargar las listas desde la base de datos: $e');
    }
  }

  void duplicarLista(String? listaSeleccionada, String nuevoNombreLista) async {
    try {
      if (nuevoNombreLista.isNotEmpty && nuevoNombreLista.length >= 5) {
        String nuevaListaId = FirebaseFirestore.instance.collection('Listas').doc().id;
        Timestamp fechaRegistro = Timestamp.now();

        await FirebaseFirestore.instance.collection('Listas').doc(nuevaListaId).set({
          'id': nuevaListaId,
          'nombre': nuevoNombreLista,
          'fechaRegistro': fechaRegistro,
        });

        Navigator.pop(context, nuevoNombreLista); // Devolver el nombre de la lista creada
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Por favor, ingrese el nombre de la nueva lista'),
        ));
      }
    } catch (e) {
      print('Error al crear la nueva lista: $e');
    }
  }

  String? validarNombreLista(String value) {
    if (value.isEmpty) {
      return 'Por favor, ingrese el nombre de la lista';
    } else if (value.length < 5) {
      return 'El nombre debe tener al menos 5 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Duplicar Lista'),
      content: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: listaSeleccionada,
                onChanged: (String? newValue) {
                  setState(() {
                    listaSeleccionada = newValue;
                    isButtonEnabled = nuevoNombreLista.length >= 5;
                  });
                },
                items: listasFromDatabase.map((String lista) {
                  return DropdownMenuItem<String>(
                    value: lista,
                    child: Text(lista),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Selecciona la lista a duplicar o deja vacío para crear nueva',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  setState(() {
                    nuevoNombreLista = value;
                    isButtonEnabled = value.length >= 5;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Nombre de la nueva lista *',
                  border: OutlineInputBorder(),
                  errorText: nuevoNombreLista.isNotEmpty && nuevoNombreLista.length < 5
                      ? 'El nombre debe tener al menos 5 caracteres'
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: isButtonEnabled
              ? () {
                  duplicarLista(widget.idListaSeleccionada, nuevoNombreLista);
                }
              : null,
          child: Text('Duplicar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}