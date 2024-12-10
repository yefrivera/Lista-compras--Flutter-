import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // Llave fija y vector de inicialización
  final key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // 32 caracteres
  final iv = encrypt.IV.fromUtf8('16lengthinitvect'); // 16 caracteres

  // Método para validar campos y registrar al usuario
  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    // Validaciones de los campos
    if (_nameController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validación de longitud del correo
    if (_emailController.text.trim().length > 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El correo no puede tener más de 40 caracteres.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Validación de longitud de la contraseña
    if (_passwordController.text.trim().length > 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La contraseña no puede tener más de 200 caracteres.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Crear usuario con Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtener el UID del usuario creado
      String uid = userCredential.user!.uid;

      // Guardar los datos adicionales en Firestore
      await FirebaseFirestore.instance.collection('Usuarios').doc(uid).set({
        'nombres': _nameController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'listas': [], // Inicializa con una lista vacía
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso. Redirigiendo a la pantalla principal...')),
      );

      // Redirigir a la pantalla principal después de un breve retraso
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrarse: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Crea una cuenta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombres',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _apellidosController,
              decoration: InputDecoration(
                labelText: 'Apellidos',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
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
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo[50],
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Regístrate',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Volver',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
