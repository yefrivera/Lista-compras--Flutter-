import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProductForm extends StatefulWidget {
  final Map<String, dynamic> productToEdit;
  final String idLista;

  const EditProductForm({
    required this.productToEdit,
    required this.idLista,
    Key? key,
  }) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productController;
  late String _sitio;

  @override
  void initState() {
    super.initState();
    _productController = TextEditingController(text: widget.productToEdit['producto']);
    _sitio = widget.productToEdit['sitio'];
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('Listas')
          .doc(widget.idLista)
          .collection('Productos')
          .doc(widget.productToEdit['id'])
          .update({
        'producto': _productController.text,
        'sitio': _sitio,
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _productController,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Ingrese el nombre del producto' : null,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              initialValue: _sitio,
              onChanged: (value) => _sitio = value,
              decoration: const InputDecoration(
                labelText: 'Sitio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
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
