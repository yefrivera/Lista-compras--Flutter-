import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AgregarSitio.dart';

class NewProductForm extends StatefulWidget {
  final String idLista;

  NewProductForm({required this.idLista});

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

  // Cargar los sitios para el usuario autenticado
  void _loadSites() async {
    try {
      String uid =
          FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(uid)
          .collection('Sitios')
          .get();

      // Asegúrate de usar el nombre correcto del campo
      List<String> sitios = querySnapshot.docs.map((doc) {
        return doc['nombre_sitio']
            as String; // Cambia a 'nombre_sitio' si es el campo correcto
      }).toList();

      // Eliminar duplicados si existen
      setState(() {
        _sites = sitios.toSet().toList();
      });
    } catch (e) {
      print('Error al cargar los sitios: $e');
    }
  }

  // Añadir un nuevo sitio a la lista local y la base de datos
  void _addSiteToList(String newSiteName) {
    setState(() {
      if (!_sites.contains(newSiteName)) {
        _sites.add(newSiteName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El sitio "$newSiteName" ya existe.')),
        );
      }
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedSite == null || _selectedSite!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Debe seleccionar un sitio.'),
        ));
        return;
      }

      try {
        String uid =
            FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
        String productName = _productController.text;
        String siteName = _selectedSite!;

        await FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(uid)
            .collection('Listas')
            .doc(widget.idLista)
            .collection('Productos')
            .add({
          'producto': productName,
          'sitio': siteName,
          'fecha': FieldValue.serverTimestamp(),
        });

        _productController.clear();
        _selectedSite = null;

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Producto guardado exitosamente'),
        ));

        Navigator.pop(context);
      } catch (e) {
        print('Error al guardar el producto: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al guardar el producto.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width *
          0.8, // 80% del ancho de la pantalla
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Añadir producto',
              style: TextStyle(
                fontSize: 24, // Tamaño más grande
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Ingrese los detalles del producto.',
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
          SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _productController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese el nombre del producto';
                    } else if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
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
                  menuMaxHeight: 150,
                  value: _sites.contains(_selectedSite)
                      ? _selectedSite
                      : null, // Validar que el valor seleccionado sea válido
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Debe seleccionar un sitio';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => NewSitioForm(
                        onSiteAdded: _addSiteToList,
                      ),
                    );
                  },
                  icon: Icon(Icons.add),
                  label: Text('Nuevo sitio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[300],
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 32.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveProduct();
                        }
                      },
                      child: Text('Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
