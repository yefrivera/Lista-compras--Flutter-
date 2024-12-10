import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Pages/DuplicarLista.dart';
import 'Pages/ListaPorDentro.dart';
import 'firebase_options.dart';
import 'Pages/login.dart';
import 'Pages/registro.dart';

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
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => ListaScreen(),
      },
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

  // Cargar listas desde Firestore para el usuario autenticado
  void cargarListasDesdeFirestore() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
      CollectionReference userListas =
          FirebaseFirestore.instance.collection('Usuarios').doc(uid).collection('Listas');

      QuerySnapshot querySnapshot = await userListas.get();
      List<String> nombresListas = [];
      List<String> idsListas = [];

      querySnapshot.docs.forEach((doc) {
        nombresListas.add(doc['nombre']); // Nombres de las listas
        idsListas.add(doc.id); // IDs de las listas
      });

      setState(() {
        listas = nombresListas;
        idListas = idsListas;
      });
    } catch (e) {
      print('Error desde Firestore: $e');
    }
  }

  // Eliminar una lista específica
  Future<void> eliminarLista(int index) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid; // UID del usuario actual
      String idLista = idListas[index];
      CollectionReference userListas =
          FirebaseFirestore.instance.collection('Usuarios').doc(uid).collection('Listas');

      await userListas.doc(idLista).delete();

      setState(() {
        listas.removeAt(index);
        idListas.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lista eliminada correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la lista: ${e.toString()}')),
      );
    }
  }

  // Cerrar sesión
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Navegar a la pantalla de una lista específica
  void navigateToList(BuildContext context, String listName, String idLista) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(title: listName, idLista: idLista),
      ),
    );
  }

  // Mostrar el formulario para duplicar una lista
  Future<void> mostrarFormularioDuplicarLista() async {
    Map<String, String>? nuevaLista = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return DuplicarListaForm(
          listaActual: listas.isNotEmpty ? listas[0] : '',
          idListaSeleccionada: idListas.isNotEmpty ? idListas[0] : null,
        );
      },
    );

    if (nuevaLista != null) {
      setState(() {
        listas.add(nuevaLista['nombre']!);
        idListas.add(nuevaLista['id']!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PocketList',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[500],
                ),
              ),
              Text(
                'Mis listas de compras',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
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
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                Image.asset(
                  './assets/c2.png',
                  height: 120,
                ),
                SizedBox(height: 10),
                Text(
                  'Organiza tus compras de manera eficiente y rápida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mis listas:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.indigo[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 30.0),
              child: ListView.builder(
                itemCount: listas.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(idListas[index]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      eliminarLista(index);
                    },
                    child: GestureDetector(
                      onTap: () => navigateToList(context, listas[index], idListas[index]),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        padding: const EdgeInsets.all(25.0),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
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
                                color: Colors.indigo,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 30.0, bottom: 30.0),
                child: ElevatedButton.icon(
                  onPressed: mostrarFormularioDuplicarLista,
                  icon: Icon(
                    Icons.add,
                    color: Colors.indigo,
                  ),
                  label: Text('Añadir'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.indigo,
                    backgroundColor: Colors.indigo[50],
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
