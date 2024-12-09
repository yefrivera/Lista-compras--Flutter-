import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_services.dart';

class EditProductForm extends StatefulWidget {
  final Map<String, dynamic> productToEdit;
  final String idLista; // Añadido el parámetro idLista

  const EditProductForm({Key? key, required this.productToEdit, required this.idLista}) : super(key: key);

  @override
  _EditProductFormState createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  String? _selectedSite;
  List<String> _sites = [];
  bool _loading = true;
  bool _changesMade = false; // Bandera para controlar cambios realizados

  @override
  void initState() {
    super.initState();
    _productController.text = widget.productToEdit['producto'];
    _selectedSite = widget.productToEdit['sitio'];
    _loadSites();
  }

  // Función para cargar los sitios desde Firebase
  void _loadSites() async {
    List<String> sitios = await readData();
    setState(() {
      _sites = sitios;
      _loading = false; // Indicar que se han cargado los datos
    });
  }

  // Función para validar cambios antes de guardar
  bool _validateChanges() {
    if (_productController.text != widget.productToEdit['producto'] ||
        _selectedSite != widget.productToEdit['sitio']) {
      return true;
    }
    return false;
  }

  // Validador personalizado para el nombre del producto
  String? _productNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese el nombre del producto';
    } else if (value.length < 3) {
      return 'El nombre del producto debe tener al menos 3 caracteres';
    }
    return null;
  }

  void _saveProduct() async {
    if (!_validateChanges()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se han realizado cambios'),
      ));
      return;
    }

    // Verifica si el nombre del producto y el sitio están seleccionados
    if (_formKey.currentState!.validate() && _selectedSite != null) {
      // Actualiza los datos en Firestore
      await FirebaseFirestore.instance
          .collection('Listas')
          .doc(widget.idLista) // Usa idLista para especificar la lista
          .collection('Productos')
          .doc(widget.productToEdit['id'])
          .update({
        'producto': _productController.text,
        'sitio': _selectedSite,
      });

      // Muestra un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Producto actualizado exitosamente'),
      ));

      // Cierra el modal de edición
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _loading
          ? CircularProgressIndicator() // Mostrar indicador de carga mientras se cargan los sitios
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _productController,
                    validator: _productNameValidator,
                    onChanged: (value) {
                      setState(() {
                        _changesMade = true; 
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Ingrese el nombre del producto',
                      border: OutlineInputBorder(),
                      errorStyle: TextStyle(color: Colors.red[400]), 
                    ),
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    menuMaxHeight: 150,
                    value: _selectedSite,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSite = newValue;
                        _changesMade = true; // Marcar cambios al modificar el sitio seleccionado
                      });
                    },
                    items: _sites.map((String site) {
                      return DropdownMenuItem<String>(
                        value: site,
                        child: Text(site),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _saveProduct,
                        child: Text('Guardar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
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