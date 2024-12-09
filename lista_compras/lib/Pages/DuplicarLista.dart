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
      print('Error de Firestore: $e');
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
          content: Text('Ingrese el nombre de la nueva lista'),
        ));
      }
    } catch (e) {
      print('Error al crear la nueva lista: $e');
    }
  }

  String? validarNombreLista(String value) {
    if (value.isEmpty) {
      return 'Ingrese el nombre de la lista';
    } else if (value.length < 5) {
      return 'El nombre debe tener al menos 5 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título centrado en dos líneas
          Text(
            'Crear o duplicar lista',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8), // Espaciado entre líneas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding horizontal
            child: Text(
              'Para una nueva lista, deje el campo de duplicar vacío.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16), // Espaciado antes de la línea divisoria
          // Línea divisoria
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  labelText: 'Lista que desea duplicar',
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
                  labelText: 'Nombre de la nueva lista',
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
          child: Text('Añadir'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

}