import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, String>> listasFromDatabase = [];
  bool isButtonEnabled = false;
  String? selectedListId; // ID de la lista seleccionada

  @override
  void initState() {
    super.initState();
    cargarListasDesdeBaseDeDatos();
  }

  // Cargar listas del usuario actual desde Firestore
  void cargarListasDesdeBaseDeDatos() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('Listas')
          .get();

      List<Map<String, String>> listas = [];

      for (var doc in querySnapshot.docs) {
        listas.add({
          'id': doc.id,
          'nombre': doc['nombre'],
        });
      }

      setState(() {
        listasFromDatabase = listas;
      });
    } catch (e) {
      print('Error de Firestore: $e');
    }
  }

  // Crear una nueva lista para el usuario actual
  void crearLista(String nuevoNombreLista) async {
    if (nuevoNombreLista.isNotEmpty && nuevoNombreLista.length >= 5) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
        DocumentReference nuevaListaRef = await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('Listas')
            .add({
          'nombre': nuevoNombreLista,
          'fechaRegistro': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context, {
          'nombre': nuevoNombreLista,
          'id': nuevaListaRef.id
        });
      } catch (e) {
        print('Error al crear nueva lista: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ingrese el nombre de la nueva lista'),
      ));
    }
  }

  // Duplicar una lista existente
void duplicarLista(String idListaOriginal, String nuevoNombreLista) async {
  try {
    if (nuevoNombreLista.isNotEmpty && nuevoNombreLista.length >= 5) {
      // Obtener UID del usuario actual
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Consultar los productos de la lista original
      final querySnapshotProductos = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('Listas')
          .doc(idListaOriginal)
          .collection('Productos')
          .get();

      // Crear una nueva lista
      DocumentReference nuevaListaRef = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('Listas')
          .add({
        'nombre': nuevoNombreLista,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      // Copiar productos a la nueva lista
      for (var docSnapshot in querySnapshotProductos.docs) {
        // Convertir los datos del documento a Map<String, dynamic>
        Map<String, dynamic> productData =
            docSnapshot.data() as Map<String, dynamic>;

        await nuevaListaRef.collection('Productos').add(productData);
      }

      // Notificar que se ha completado
      Navigator.pop(context, {
        'nombre': nuevoNombreLista,
        'id': nuevaListaRef.id,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingrese el nombre de la nueva lista')),
      );
    }
  } catch (e) {
    print('Error al duplicar la lista: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al duplicar la lista')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Crear o duplicar lista',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          SizedBox(height: 16),
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
                    // Buscar el ID de la lista seleccionada
                    var listaMap = listasFromDatabase.firstWhere(
                      (element) => element['nombre'] == newValue,
                      orElse: () => {}
                    );
                    selectedListId = listaMap['id'];
                  });
                },
                items: listasFromDatabase.map((listaMap) {
                  return DropdownMenuItem<String>(
                    value: listaMap['nombre'],
                    child: Text(listaMap['nombre'] ?? ''),
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
                  errorText: (nuevoNombreLista.isNotEmpty && nuevoNombreLista.length < 5)
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
                  if (listaSeleccionada == null) {
                    crearLista(nuevoNombreLista);
                  } else {
                    if (selectedListId != null) {
                      duplicarLista(selectedListId!, nuevoNombreLista);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('No se pudo obtener el ID de la lista a duplicar'),
                      ));
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: Text('Añadir'),
        ),
      ],
    );
  }
}
