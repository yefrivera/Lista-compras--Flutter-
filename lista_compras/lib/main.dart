import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/DuplicarLista.dart'; // Asegúrate de importar correctamente el archivo donde está definido DuplicarListaForm
import 'Pages/firebase_services.dart';
import 'firebase_options.dart'; // Asegúrate de importar correctamente tus opciones de Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListaScreen(),
    );
  }
}

class ListaScreen extends StatefulWidget {
  @override
  _ListaScreenState createState() => _ListaScreenState();
}

class _ListaScreenState extends State<ListaScreen> {
  List<String> listas = [];
  List<String> idListas = []; // Añadido para almacenar los IDs de las listas
  int? hoveredIndex;

  @override
  void initState() {
    super.initState();
    cargarListasDesdeFirestore();
  }

  void cargarListasDesdeFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Listas').get();
      List<String> nombresListas = [];
      List<String> idsListas = [];

      querySnapshot.docs.forEach((doc) {
        nombresListas.add(doc['nombre']);
        idsListas.add(doc.id); // Agregar el ID del documento a la lista de IDs
      });

      setState(() {
        listas = nombresListas;
        idListas = idsListas;
      });
    } catch (e) {
      print('Error al cargar las listas desde Firestore: $e');
      // Manejar el error según sea necesario
    }
  }

  void navigateToList(BuildContext context, String listName, String idLista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: listName, idLista: idLista), // Navega a MyHomePage con el título y idLista
      ),
    );
  }

  // Función para mostrar el formulario de duplicar lista
void mostrarFormularioDuplicarLista() async {
  String? nuevoNombreLista = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return DuplicarListaForm(
        listaActual: listas.isNotEmpty ? listas[0] : '',
        idListaSeleccionada: idListas.isNotEmpty ? idListas[0] : null,
      );
    },
  );

  if (nuevoNombreLista != null) {
    setState(() {
      listas.add(nuevoNombreLista); // Agregar la nueva lista
      idListas.add("nuevoID"); // Deberías ajustar cómo generas el nuevo ID
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas de compras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: listas.length,
                itemBuilder: (context, index) {
                  return MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        hoveredIndex = index;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        hoveredIndex = null;
                      });
                    },
                    child: GestureDetector(
                      onTap: () => navigateToList(context, listas[index], idListas[index]), // Pasar idLista al navegar
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: hoveredIndex == index ? Colors.purple[100] : Colors.purple[50],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              listas[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[800],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.purple[800],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: mostrarFormularioDuplicarLista, // Llama a la función que muestra el formulario
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.purple, // Text color
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Duplicar lista'),
            ),
          ],
        ),
      ),
    );
  }
}