import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore para la base de datos
import 'package:encrypt/encrypt.dart' as encrypt; // Encriptación

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Llave fija y vector de inicialización
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 caracteres
  final iv = encrypt.IV.fromUtf8('16lengthinitvect'); // 16 caracteres

  // Método para iniciar sesión con Firebase y Firestore
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    // Validar que los campos no estén vacíos
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Cifrar la contraseña ingresada
      String encryptedPassword = _encryptPassword(_passwordController.text.trim());

      // Consultar Firestore para obtener el usuario
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Si no se encuentra el correo en la base de datos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo no registrado.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtener el documento del usuario
      var userDoc = querySnapshot.docs.first;

      // Comparar la contraseña cifrada ingresada con la almacenada
      if (userDoc['password'] == encryptedPassword) {
        // Inicio de sesión exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inicio de sesión exitoso.')),
        );

        // Redirigir a la pantalla principal
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Contraseña incorrecta
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contraseña incorrecta.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Método para cifrar la contraseña usando AES
  String _encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64; // Devuelve la contraseña cifrada en base64
  }

  // Método para navegar a la pantalla de registro
  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'PocketList',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 30),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[50],
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    '¿No tienes una cuenta?',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _navigateToRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[50],
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
