import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AñadirProducto.dart';
import 'ListaPorDentro.dart';

/// Página principal de la lista
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.idLista});

  final String title;
  final String idLista;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Carga los productos asociados a la lista desde Firebase
  void _loadProducts() {
    FirebaseFirestore.instance
        .collection('Listas')
        .doc(widget.idLista)
        .collection('Productos')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _products = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    });
  }

  /// Marca o desmarca un producto como comprado
  Future<void> _togglePurchased(String id, bool currentValue) async {
    await FirebaseFirestore.instance
        .collection('Listas')
        .doc(widget.idLista)
        .collection('Productos')
        .doc(id)
        .update({'comprado': !currentValue});
  }

  /// Elimina un producto de la lista
  Future<void> _deleteProduct(String id, bool comprado) async {
    if (!comprado) {
      await FirebaseFirestore.instance
          .collection('Listas')
          .doc(widget.idLista)
          .collection('Productos')
          .doc(id)
          .delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes eliminar un producto marcado como comprado.'),
        ),
      );
    }
  }

  /// Abre el formulario para editar un producto
  void _editProduct(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Editar Producto')),
        body: EditProductForm(
          productToEdit: product,
          idLista: widget.idLista,
        ),
      ),
    );
  }

  /// Guarda un nuevo sitio en Firebase
  Future<void> saveSiteData(String siteName) async {
    await FirebaseFirestore.instance.collection('Sitios').add({
      'nombre': siteName,
    });
  }

  /// Obtiene una lista de sitios desde Firebase
  Future<List<String>> fetchSites() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Sitios').get();
      return snapshot.docs.map((doc) => doc['nombre'].toString()).toList();
    } catch (error) {
      print('Error al obtener los sitios: $error');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columnSpacing: 15.0,
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.purple.shade100,
                ),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sitio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Acciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
                rows: _products.map((product) {
                  return DataRow(
                    cells: <DataCell>[
                      DataCell(
                        GestureDetector(
                          onDoubleTap: () => _togglePurchased(
                              product['id'], product['comprado'] ?? false),
                          child: Text(
                            product['producto'] ?? '',
                            style: TextStyle(
                              color: Colors.purple,
                              decoration: (product['comprado'] ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        GestureDetector(
                          onDoubleTap: () => _togglePurchased(
                              product['id'], product['comprado'] ?? false),
                          child: Text(
                            product['sitio'] ?? '',
                            style: TextStyle(
                              color: Colors.purple,
                              decoration: (product['comprado'] ?? false)
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _editProduct(product),
                              icon: const Icon(Icons.edit),
                              color: Colors.blue,
                            ),
                            if (!(product['comprado'] ?? false))
                              IconButton(
                                onPressed: () => _deleteProduct(
                                  product['id'],
                                  product['comprado'] ?? false,
                                ),
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Nuevo Producto')),
              body: NewProductForm(idLista: widget.idLista),
            ),
          );
        },
        tooltip: 'Añadir',
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
