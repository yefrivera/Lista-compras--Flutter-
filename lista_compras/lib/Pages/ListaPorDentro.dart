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

  void _togglePurchased(String id, bool currentValue) async {
    await FirebaseFirestore.instance
        .collection('Listas')
        .doc(widget.idLista)
        .collection('Productos')
        .doc(id)
        .update({'comprado': !currentValue});
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
        content: Text('No puedes eliminar un producto ya comprado.'),
      ));
    }
  }

  void _editProduct(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => EditProductForm(
        productToEdit: product,
        idLista: widget.idLista,
      ),
    );
  }

  void _addNewProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: SingleChildScrollView(
          child: NewProductForm(idLista: widget.idLista),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Dismissible(
                  key: Key(product['id']),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    if (product['comprado'] ?? false) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No puedes eliminar un producto ya comprado.'),
                        ),
                      );
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    _deleteProduct(product['id'], product['comprado'] ?? false);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: GestureDetector(
                      onDoubleTap: () => _togglePurchased(
                          product['id'], product['comprado'] ?? false),
                      child: Text(
                        'Producto: ${product['producto']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: (product['comprado'] ?? false)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    subtitle: GestureDetector(
                      onDoubleTap: () => _togglePurchased(
                          product['id'], product['comprado'] ?? false),
                      child: Text("Tienda: ${product['sitio']}"),
                    ),
                    trailing: IconButton(
                      onPressed: () => _editProduct(product),
                      icon: const Icon(Icons.edit, color: Colors.indigo),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewProduct,
        tooltip: 'Añadir',
        icon: const Icon(Icons.add),
        label: const Text('Añadir'),
        backgroundColor: Colors.indigo[50],
        foregroundColor: Colors.indigo,
      ),
    );
  }
}
