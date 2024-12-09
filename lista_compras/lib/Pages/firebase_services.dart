import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> saveData(String siteName) async {
  DateTime now = DateTime.now();

  await _firestore.collection('Sitios').add({
    'nombre_sitio': siteName,
    'fecha': now,
  });

  print('Datos enviados a Firestore');
}

Future<void> saveProducto(String selectedSite, String selectedProduct) async {
  DateTime now = DateTime.now();

  await _firestore.collection('Productos').add({
    'nombre_producto': selectedProduct,
    'sitios': selectedSite,
    'fecha': now,
  });

  print('Datos enviados a Firestore 2');
}

Future<List<String>> readData() async {
  List<String> sitios = [];

  CollectionReference collectionReferenceSitios =
      FirebaseFirestore.instance.collection('Sitios');

  QuerySnapshot querySitios =
      await collectionReferenceSitios.orderBy('fecha', descending: true).get();

  sitios = querySitios.docs.map((doc) {
    return doc['nombre_sitio'] as String;
  }).toList();

  print(sitios);
  return sitios;
}
