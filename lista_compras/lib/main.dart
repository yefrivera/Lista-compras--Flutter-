import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/DuplicarLista.dart'; 
import 'Pages/ListaPorDentro.dart';
import 'firebase_options.dart'; 

// Punto de entrada de la aplicación
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

// Clase principal de la aplicación
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Tema principal de la app
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ListaScreen(), // Pantalla inicial
    );       
  }
}

// Pantalla principal de la app
class ListaScreen extends StatefulWidget {
  @override
  _ListaScreenState createState() => _ListaScreenState();
}

// Estado de la pantalla principal
class _ListaScreenState extends State<ListaScreen> {
  List<String> listas = []; // Lista de nombres de listas
  List<String> idListas = []; // Lista de IDs de las listas
  int? hoveredIndex; // Índice de elemento seleccionado al pasar el mouse (en web/desktop)

  @override
  void initState() {
    super.initState();
    cargarListasDesdeFirestore(); // Cargar las listas desde Firestore al iniciar
  }

  // Método para obtener las listas desde Firestore
  void cargarListasDesdeFirestore() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Listas').get();
      List<String> nombresListas = [];
      List<String> idsListas = [];

      querySnapshot.docs.forEach((doc) {
        nombresListas.add(doc['nombre']); // Obtiene los nombres de las listas
        idsListas.add(doc.id); // Obtiene los IDs de las listas
      });

      setState(() {
        listas = nombresListas;
        idListas = idsListas;
      });
    } catch (e) {
      print('Error desde Firestore: $e'); // Manejo básico de errores
    }
  }

  // Método para navegar a la pantalla de una lista específica
  void navigateToList(BuildContext context, String listName, String idLista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: listName, idLista: idLista), 
      ),
    );
  }

  // Método para mostrar el formulario para duplicar una lista
  void mostrarFormularioDuplicarLista() async {
    String? nuevoNombreLista = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return DuplicarListaForm(
          listaActual: listas.isNotEmpty ? listas[0] : '', // Lista seleccionada
          idListaSeleccionada: idListas.isNotEmpty ? idListas[0] : null,
        );
      },
    );

    // Si se obtiene un nombre nuevo, se añade a la lista
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
        // Título de la AppBar con diseño en dos líneas
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PocketList', // Línea principal en negrita
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.indigo[500],
                ),
              ),
              Text(
                'Mis listas de compras', // Subtítulo en cursiva
                style: TextStyle(
                  fontSize: 16, 
                  fontStyle: FontStyle.italic, 
                  color: Colors.black
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
            height: 1,
            decoration: BoxDecoration(
              color: Colors.grey[300], // Línea gris clara
              boxShadow: [
                BoxShadow(
                  color: Colors.grey, // Sombra ligera
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          // Contenido principal de la pantalla
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  Expanded(
                    // Lista de elementos obtenidos de Firestore
                    child: ListView.builder(
                      itemCount: listas.length,
                      itemBuilder: (context, index) {
                        return MouseRegion(
                          // Cambia el estado al pasar el mouse sobre un elemento
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
                            onTap: () => navigateToList(context, listas[index], idListas[index]), // Navegar al detalle
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10.0),
                              padding: const EdgeInsets.all(25.0),
                              decoration: BoxDecoration(
                                color: hoveredIndex == index ? Colors.indigo[100] : Colors.indigo[50],
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
                                    listas[index], // Nombre de la lista
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios, // Flecha para indicar navegación
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Botón de añadir/duplicar lista, alineado a la derecha
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: mostrarFormularioDuplicarLista, 
                        icon: Icon(
                          Icons.add, // Icono de suma
                          color: Colors.indigo,
                        ),
                        label: Text('Añadir'), // Texto del botón
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.indigo,
                          backgroundColor: Colors.indigo[50],
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
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
