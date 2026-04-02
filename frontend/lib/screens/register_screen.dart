import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme.dart';
import '../widgets/glass_container.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telephoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool loading = false;
  String role = 'agriculteur';

  void register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      var response = await ApiService.register(
        nomController.text,
        prenomController.text,
        emailController.text,
        passwordController.text,
        telephoneController.text,
        role,
      );

      setState(() => loading = false);

      if (response['token'] != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        Fluttertoast.showToast(
          msg: "❌ Erreur inscription",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassContainer(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(Icons.person_add,
                            color: Colors.white, size: 70),

                        SizedBox(height: 20),

                        Text("Inscription",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold)),

                        SizedBox(height: 20),

                        TextFormField(
                          controller: nomController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Nom",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon:
                                Icon(Icons.person, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          controller: prenomController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Prénom",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.person_outline,
                                color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          controller: emailController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon:
                                Icon(Icons.email, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: 15),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            labelStyle: TextStyle(color: Colors.white),
                            prefixIcon:
                                Icon(Icons.lock, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                        ),

                        SizedBox(height: 20),

                        DropdownButton<String>(
                          value: role,
                          dropdownColor: Colors.black,
                          style: TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: [
                            DropdownMenuItem(
                                value: 'agriculteur',
                                child: Text('Agriculteur')),
                            DropdownMenuItem(
                                value: 'technicien',
                                child: Text('Technicien')),
                            DropdownMenuItem(
                                value: 'admin',
                                child: Text('Admin')),
                          ],
                          onChanged: (v) {
                            setState(() => role = v!);
                          },
                        ),

                        SizedBox(height: 30),

                        loading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize:
                                      Size(double.infinity, 50),
                                ),
                                child: Text("S'INSCRIRE",
                                    style: TextStyle(color: Colors.white)),
                              ),

                        SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => LoginScreen()),
                            );
                          },
                          child: Text("Se connecter",
                              style:
                                  TextStyle(color: Colors.greenAccent)),
                        )
                      ],
                    ),
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
