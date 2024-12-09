import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'AñadirProducto.dart';
import 'EditarProducto.dart';

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

  void _loadProducts() async {
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
        content: Text('Ya has marcado el producto como comprado.'),
      ));
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('Editar Producto')),
        body: EditProductForm(productToEdit: product, idLista: widget.idLista),
      ),
    );
  }
  void _addNewProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Bordes redondeados
        content: SingleChildScrollView(
          child: NewProductForm(idLista: widget.idLista), // Llamar al formulario correctamente
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 95.0), // Desplazar título hacia la izquierda
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.indigo, // Texto índigo
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        backgroundColor: Colors.white, // Fondo blanco
        elevation: 0, // Sin sombra
      ),
      body: Column(
        children: [
          // Línea divisoria debajo del AppBar
          Container(
            height: 1,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Línea gris clara
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: DataTable(
                      columnSpacing: 15.0,
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.indigo), // Fondo índigo para encabezados
                      headingTextStyle: const TextStyle(
                        color: Colors.white, // Texto blanco en encabezado
                        fontWeight: FontWeight.bold,
                      ),
                      dividerThickness: 0.5, // Grosor de los bordes internos
                      dataRowColor: MaterialStateProperty.resolveWith(
                          (states) => Colors.white),
                      dataRowHeight: 60,
                      columns: const <DataColumn>[
                        // Orden de columnas: Editar - Producto - Sitio - Eliminar
                        DataColumn(
                          label: Text('Editar'),
                        ),
                        DataColumn(
                          label: Text('Producto'),
                        ),
                        DataColumn(
                          label: Text('Sitio'),
                        ),
                        DataColumn(
                          label: Text('Eliminar'),
                        ),
                      ],
                      rows: _products.map((product) {
                        return DataRow(
                          cells: <DataCell>[
                            // Columna Editar
                            DataCell(
                              IconButton(
                                onPressed: () => _editProduct(product),
                                icon: Icon(Icons.edit),
                                color: Colors.indigo, // Color del icono
                              ),
                            ),
                            // Columna Producto
                            DataCell(
                              GestureDetector(
                                onDoubleTap: () => _togglePurchased(
                                    product['id'], product['comprado'] ?? false),
                                child: Text(
                                  product['producto'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: (product['comprado'] ?? false)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            // Columna Sitio
                            DataCell(
                              GestureDetector(
                                onDoubleTap: () => _togglePurchased(
                                    product['id'], product['comprado'] ?? false),
                                child: Text(
                                  product['sitio'] ?? '',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: (product['comprado'] ?? false)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            // Columna Eliminar
                            DataCell(
                              IconButton(
                                onPressed: () => _deleteProduct(
                                    product['id'], product['comprado'] ?? false),
                                icon: Icon(Icons.delete),
                                color: Colors.red[300], // Color del icono
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProduct, // Cambiado para usar el AlertDialog
        tooltip: 'Añadir',
        icon: const Icon(Icons.add),
        label: const Text('Añadir'), // Texto "Añadir" en el botón
        backgroundColor: Colors.indigo[50], // Fondo blanco
        foregroundColor: Colors.indigo, // Texto e icono en índigo
      ),
    );
  }
}
