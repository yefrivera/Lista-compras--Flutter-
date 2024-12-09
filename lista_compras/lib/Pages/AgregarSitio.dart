import 'package:flutter/material.dart';
import 'firebase_services.dart'; // Cambiar el import según tu estructura de archivos

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

  void _saveSite() {
    if (_formKey.currentState!.validate()) {
      String newSiteName = siteNameController.text;
      saveData(newSiteName);
      widget.onSiteAdded(newSiteName);
      Navigator.pop(context);
      siteNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: siteNameController,
              validator: _validateSiteName,
              decoration: InputDecoration(
                labelText: 'Aquí el nombre del sitio',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveSite,
                  child: Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
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
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}