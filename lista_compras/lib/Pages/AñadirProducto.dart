import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AgregarSitio.dart';
import 'firebase_services.dart';

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

  void _loadSites() async {
    List<String> sitios = await readData();
    setState(() {
      _sites = sitios;
    });
  }

  void _addSiteToList(String newSiteName) {
    setState(() {
      _sites.add(newSiteName);
    });
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      String productName = _productController.text;
      String siteName = _selectedSite ?? '';
      String idLista = widget.idLista;

      await FirebaseFirestore.instance
          .collection('Listas')
          .doc(idLista)
          .collection('Productos')
          .add({
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
    return SizedBox(
      // Aumentar el ancho del AlertDialog
      width: MediaQuery.of(context).size.width * 0.8, // 80% del ancho de la pantalla
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título principal centrado
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
          SizedBox(height: 16), // Espaciado después del título
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
                  value: _selectedSite,
                  validator: (value) {
                    if (value == null) {
                      return 'Seleccione un sitio';
                    }
                    return null;
                  },
                  hint: Text('Seleccionar sitio...'),
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
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.0),
                // Botón de "Nuevo sitio" debajo del selector
                ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Scaffold(
                        appBar: AppBar(title: Text('Nuevo Sitio')),
                        body: NewSitioForm(
                          onSiteAdded: _addSiteToList,
                        ),
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
                SizedBox(height: 32.0), // Mayor separación entre selector y botones
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
