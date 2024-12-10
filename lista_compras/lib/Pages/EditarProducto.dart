import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProductForm extends StatefulWidget {
  final Map<String, dynamic> productToEdit;
  final String idLista;

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

  @override
  void initState() {
    super.initState();
    _productController.text = widget.productToEdit['producto'];
    _selectedSite = widget.productToEdit['sitio'];
    _loadSites();
  }

  // Cargar los sitios del usuario autenticado desde Firestore
  void _loadSites() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('Sitios')
          .get();

      List<String> sitios = querySnapshot.docs.map((doc) => doc['nombre_sitio'] as String).toList();

      setState(() {
        _sites = sitios;
        // Validar que _selectedSite sea parte de _sites
        if (!_sites.contains(_selectedSite)) {
          _selectedSite = null; // Si no está, establece un valor nulo
        }
        _loading = false;
      });
    } catch (e) {
      print('Error al cargar sitios: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  // Validador del nombre del producto
  String? _productNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese el nombre del producto';
    } else if (value.length < 3) {
      return 'El nombre del producto debe tener al menos 3 caracteres';
    }
    return null;
  }

  // Guardar el producto editado
  void _saveProduct() async {
    if (_formKey.currentState!.validate() && _selectedSite != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual

        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('Listas')
            .doc(widget.idLista)
            .collection('Productos')
            .doc(widget.productToEdit['id'])
            .update({
          'producto': _productController.text,
          'sitio': _selectedSite,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto actualizado exitosamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el producto: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete los campos correctamente')),
      );
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
          'Editar producto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
      ),
      content: _loading
          ? Center(child: CircularProgressIndicator()) // Mostrar un indicador mientras se cargan los sitios
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _productController,
                      validator: _productNameValidator,
                      decoration: InputDecoration(
                        labelText: 'Nombre del producto',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 150,
                      value: _selectedSite,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSite = newValue;
                        });
                      },
                      items: _sites.map((String site) {
                        return DropdownMenuItem<String>(
                          value: site,
                          child: Text(site),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Seleccionar sitio',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo, // Color del texto para cancelar
              ),
            ),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
