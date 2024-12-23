import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewSitioForm extends StatefulWidget {
  final Function(String) onSiteAdded;

  NewSitioForm({required this.onSiteAdded});

  @override
  _NewSitioFormState createState() => _NewSitioFormState();
}

class _NewSitioFormState extends State<NewSitioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController siteNameController = TextEditingController();

  String? _validateSiteName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese el nombre del sitio';
    }
    return null;
  }

  Future<void> saveData(String siteName, String userId) async {
    DateTime now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('Sitios')
        .add({
      'nombre_sitio': siteName,
      'fecha': now,
    });

    print('Datos enviados a Firestore');
  }

  void _saveSite() {
    if (_formKey.currentState!.validate()) {
      String newSiteName = siteNameController.text;
      String userId = FirebaseAuth.instance.currentUser!.uid;

      print('Datos para guardar: $newSiteName, $userId'); // Debug
      saveData(newSiteName, userId); // Guardar el dato usando tu lógica
      widget.onSiteAdded(newSiteName); // Pasar el nombre del sitio al callback
      Navigator.pop(context); // Cerrar el diálogo
      siteNameController.clear(); // Limpiar el campo de texto
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
      ),
      title: Center(
        child: Text(
          'Nuevo Sitio',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: siteNameController,
                validator: _validateSiteName,
                decoration: InputDecoration(
                  labelText: 'Nombre del nuevo sitio',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _saveSite,
              child: Text('Guardar'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.indigo,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                siteNameController.clear();
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo, // Texto índigo para cancelar
              ),
            ),
          ],
        ),
      ],
    );
  }
}
