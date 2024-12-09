import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/DuplicarLista.dart'; 
import 'Pages/ListaPorDentro.dart';
import 'firebase_options.dart'; 

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
        primarySwatch: Colors.blue,
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
  List<String> idListas = []; 
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
        idsListas.add(doc.id); 
      });

      setState(() {
        listas = nombresListas;
        idListas = idsListas;
      });
    } catch (e) {
      print('Error desde Firestore: $e');
      
    }
  }

  void navigateToList(BuildContext context, String listName, String idLista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: listName, idLista: idLista), 
      ),
    );
  }

  // Formulario de duplicar lista
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
      listas.add(nuevoNombreLista); 
      idListas.add("nuevoID"); 
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PocketList',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                ),
              ),
              Text(
                'Mis listas de compras',
                style: TextStyle(
                  fontSize: 16, 
                  fontStyle: FontStyle.italic, 
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Línea divisoria debajo del AppBar
          Container(
            height: 1, // Altura de la línea
            decoration: BoxDecoration(
              color: Colors.grey[300], // Color gris claro
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Sombras ligeras
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          // Contenido principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
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
                            onTap: () => navigateToList(context, listas[index], idListas[index]), 
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10.0),
                              padding: const EdgeInsets.all(25.0),
                              decoration: BoxDecoration(
                                color: hoveredIndex == index ? Colors.blue[50] : Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 12,
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
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.blue[800],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: mostrarFormularioDuplicarLista, 
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                    label: Text('Crear o Duplicar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

    );
  }
}