import 'package:zenjourney/controllers/authenticate_controller.dart';
import 'package:flutter/material.dart';
import '/routes/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  AuthenticateState createState() => AuthenticateState();
}

class AuthenticateState extends State<Authenticate> {
  final AuthenticateController _authenticateController = AuthenticateController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _loginEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        String? isSuccess = await _authenticateController.loginUsers(
          email: _emailController.text,
          password: _senhaController.text,
        );
        if (isSuccess != null) {
          return _showErrorDialog('Erro ao fazer login. Verifique suas credenciais.');
        }
        if (mounted) {
          await _checkUserSelections();
        }
      } catch (error) {
        _showErrorDialog('Erro ao fazer login. Verifique suas credenciais.');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _checkUserSelections() async {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "anonimo";
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    DocumentSnapshot userDoc = await userDocRef.get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = (userDoc.data() as Map<String, dynamic>);
      if (userData.containsKey('habitsSelected') && userDoc['habitsSelected'] == true) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else if (userData.containsKey('trails') && userDoc['trails'] == true) {
        Navigator.pushReplacementNamed(context, AppRoutes.habitsSelection, arguments: List<String>.from(userDoc['trails']));
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.trailPreference);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.trailPreference);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Tente novamente',
            style: TextStyle(fontFamily: 'Raleway', color: Color(0xFF193339)),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: const TextStyle(fontFamily: 'Raleway', color: Color(0xFF193339)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Fechar',
                style: TextStyle(fontFamily: 'Raleway', color: Color(0xFF193339)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        // Impede que o usuário volte para a tela anterior
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F7F9),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: screenWidth * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 8.0,
                              spreadRadius: 1.0,
                              offset: Offset(0.0, 4.0),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Habitus',
                              style: TextStyle(
                                fontSize: 36,
                                fontFamily: 'Raleway',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF193339),
                              ),
                            ),
                            Column(
                              children: const [
                                Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Raleway',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF448D9C),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: Text(
                                    'Entre na sua conta para manter seu progresso',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Raleway',
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF193339),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'E-mail',
                                    labelStyle: const TextStyle(fontFamily: 'Raleway', color: Color(0xFF193339)),
                                    prefixIcon: const Icon(Icons.email, color: Color(0xFF193339)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira seu nome de usuário ou e-mail';
                                    }
                                    return null;
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _senhaController,
                                  decoration: InputDecoration(
                                    labelText: 'Senha',
                                    labelStyle: const TextStyle(fontFamily: 'Raleway', color: Color(0xFF193339)),
                                    prefixIcon: const Icon(Icons.lock, color: Color(0xFF193339)),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  obscureText: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor, insira sua senha';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: () {
                                      // Ação de esqueci minha senha
                                    },
                                    child: const Text(
                                      'Esqueci minha senha',
                                      style: TextStyle(
                                        color: Color(0xFF193339),
                                        fontFamily: 'Raleway',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isLoading)
                              const CircularProgressIndicator()
                            else
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: _loginEmailPassword,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.1,
                                        vertical: 12,
                                      ),
                                      backgroundColor: const Color(0xFF448D9C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text(
                                      'Entrar na conta',
                                      style: TextStyle(
                                        fontFamily: 'Raleway',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade400,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        child: Text(
                                          'OU',
                                          style: TextStyle(
                                            fontFamily: 'Raleway',
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey.shade400,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Ainda não criou sua conta?',
                                        style: TextStyle(
                                          fontFamily: 'Raleway',
                                          fontSize: 14,
                                          color: Color(0xFF193339),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, AppRoutes.register);
                                          },
                                          child: const Text(
                                            'Registrar',
                                            style: TextStyle(
                                              fontFamily: 'Raleway',
                                              fontSize: 14,
                                              color: Color(0xFF448D9C),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}