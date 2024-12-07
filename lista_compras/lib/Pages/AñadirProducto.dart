import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_services.dart'; // Asegúrate de importar este archivo

class NewProductForm extends StatefulWidget {
  final String idLista;

  const NewProductForm({required this.idLista});

  @override
  _NewProductFormState createState() => _NewProductFormState();
}

class _NewProductFormState extends State<NewProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  String? _selectedSite;
  List<String> _sites = [];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  /// Carga los sitios desde Firebase
  void _loadSites() async {
    List<String> sitios = await fetchSites();
    setState(() {
      _sites = sitios;
    });
  }

  /// Guarda el producto en Firebase
  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      String productName = _productController.text;
      String siteName = _selectedSite!;
      String idLista = widget.idLista;

      await FirebaseFirestore.instance.collection('Listas').doc(idLista).collection('Productos').add({
        'producto': productName,
        'sitio': siteName,
      });

      _productController.clear();
      _selectedSite = null;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Producto guardado exitosamente'),
      ));

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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese el nombre del producto';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedSite,
              items: _sites.map((site) {
                return DropdownMenuItem(
                  value: site,
                  child: Text(site),
                );
              }).toList(),
              hint: const Text('Seleccionar sitio'),
              onChanged: (value) {
                setState(() {
                  _selectedSite = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione un sitio' : null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveProduct,
              child: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
