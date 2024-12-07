import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AñadirProducto.dart';
import 'EditarProducto.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.idLista});

  final String title;
  final String idLista; // Nuevo parámetro

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

  // Función para cargar los productos desde Firebase
  void _loadProducts() async {
    FirebaseFirestore.instance
        .collection('Listas')
        .doc(widget.idLista) // Filtrar por idLista
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

  // Función para marcar un producto como comprado
  void _togglePurchased(String id, bool currentValue) async {
    await FirebaseFirestore.instance
        .collection('Listas')
        .doc(widget.idLista)
        .collection('Productos')
        .doc(id)
        .update({
      'comprado': !currentValue,
    });
  }

  // Función para eliminar un producto
  void _deleteProduct(String id, bool comprado) async {
    if (!comprado) {
      await FirebaseFirestore.instance
          .collection('Listas')
          .doc(widget.idLista)
          .collection('Productos')
          .doc(id)
          .delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No puedes eliminar un producto marcado como comprado.'),
      ));
    }
  }

  // Función para abrir el formulario de edición de un producto
  void _editProduct(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Editar Producto')),
        body: EditProductForm(productToEdit: product, idLista: widget.idLista),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.purple, // Color del AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columnSpacing: 15.0, // Espaciado entre columnas
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.purple.shade100),
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Color del texto del encabezado
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sitio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Color del texto del encabezado
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Acciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple, // Color del texto del encabezado
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
                              color: Colors.purple, // Color del texto
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
                              color: Colors.purple, // Color del texto
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
                              onPressed: () =>
                                  _editProduct(product), // Abrir formulario de edición
                              icon: Icon(Icons.edit),
                              color: Colors.blue, // Color del icono
                            ),
                            if (!(product['comprado'] ?? false))
                              IconButton(
                                onPressed: () => _deleteProduct(
                                    product['id'], product['comprado'] ?? false),
                                icon: Icon(Icons.delete),
                                color: Colors.red, // Color del icono
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
              appBar: AppBar(title: Text('Nuevo Producto')),
              body: NewProductForm(idLista: widget.idLista), // Pasar idLista aquí
            ),
          );
        },
        tooltip: 'Añadir',
        child: const Icon(Icons.add),
        backgroundColor: Colors.purple, // Color del FAB
      ),
    );
  }
}