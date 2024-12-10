import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Guardar un nuevo sitio en la colección del usuario autenticado
Future<void> saveSite(String siteName) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid; // Obtener UID del usuario actual
    DateTime now = DateTime.now();

    // Verificar si el sitio ya existe
    QuerySnapshot existingSite = await _firestore
        .collection('Usuarios')
        .doc(uid)
        .collection('Sitios')
        .where('nombre', isEqualTo: siteName)
        .get();

    if (existingSite.docs.isEmpty) {
      // Solo agrega el sitio si no existe
      await _firestore
          .collection('Usuarios')
          .doc(uid)
          .collection('Sitios')
          .add({
        'nombre': siteName,
        'fecha': now,
      });

      print('Sitio guardado exitosamente: $siteName');
    } else {
      print('El sitio "$siteName" ya existe en Firestore.');
    }
  } catch (e) {
    print('Error al guardar el sitio: $e');
  }
}


// Guardar un producto en la lista del usuario autenticado
Future<void> saveProducto(String idLista, String selectedSite, String selectedProduct) async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid; // Obtener UID del usuario actual
    DateTime now = DateTime.now();

    await _firestore
        .collection('Usuarios')
        .doc(uid)
        .collection('Listas')
        .doc(idLista)
        .collection('Productos')
        .add({
      'producto': selectedProduct,
      'sitio': selectedSite,
      'fecha': now,
    });

    print('Producto guardado exitosamente en la lista $idLista');
  } catch (e) {
    print('Error al guardar el producto: $e');
  }
}

// Leer todos los sitios del usuario autenticado
Future<List<String>> readUserSites() async {
  try {
    String uid = FirebaseAuth.instance.currentUser!.uid; // Obtener UID del usuario actual

    QuerySnapshot querySnapshot = await _firestore
        .collection('Usuarios')
        .doc(uid)
        .collection('Sitios')
        .orderBy('fecha', descending: true)
        .get();

    List<String> sitios = querySnapshot.docs.map((doc) {
      return doc['nombre'] as String;
    }).toList();

    print('Sitios cargados para el usuario $uid: $sitios');
    return sitios;
  } catch (e) {
    print('Error al leer los sitios: $e');
    return [];
  }
}
