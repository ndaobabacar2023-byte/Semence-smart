import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool loading = false;

  void register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); // Ferme le clavier
      setState(() { loading = true; });
      
      var response = await ApiService.register(
        nomController.text.trim(),
        prenomController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim()
      );
      
      setState(() { loading = false; });

      if (response['message'] != null) {
        Fluttertoast.showToast(msg: response['message']);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      } else {
        Fluttertoast.showToast(msg: response['message'] ?? 'Erreur inscription');
      }
    }
  }

  String? emailValidator(String? v) {
    if (v == null || v.isEmpty) return "Obligatoire";
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v)) return "Email invalide";
    return null;
  }

  String? passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Obligatoire";
    if (v.length < 6) return "Minimum 6 caractères";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(labelText: "Nom"),
                validator: (v)=>v!.isEmpty?"Obligatoire":null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(labelText: "Prénom"),
                validator: (v)=>v!.isEmpty?"Obligatoire":null,
              ),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: emailValidator,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
                validator: passwordValidator,
              ),
              SizedBox(height: 20),
              loading 
                ? CircularProgressIndicator() 
                : ElevatedButton(
                    onPressed: register, 
                    child: Text("S'inscrire")
                  )
            ],
          ),
        ),
      ),
    );
  }
}
