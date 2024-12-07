import 'package:flutter/material.dart';
import 'firebase_services.dart'; // Asegúrate de que esta ruta sea correcta

class NewSitioForm extends StatefulWidget {
  final Function(String) onSiteAdded;

  const NewSitioForm({required this.onSiteAdded});

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
      saveSiteData(newSiteName).then((_) {
        widget.onSiteAdded(newSiteName);
        Navigator.pop(context);
        siteNameController.clear();
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el sitio: $error')),
        );
      });
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
              decoration: const InputDecoration(
                labelText: 'Nombre del sitio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveSite,
                  child: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    siteNameController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
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
