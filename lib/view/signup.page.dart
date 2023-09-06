import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/controller/UserController.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final userController = UserController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final database = FirebaseDatabase.instance.ref();
  final _firebaseAuth = FirebaseAuth.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [Colors.green, Colors.white],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: ListView(
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 160,
                child: Image.asset("assets/images/logo.png"),
              ),

              SizedBox(height: 35),
              buildTextFormField(_nameController, "Nome", TextInputType.text, Icons.person),
              SizedBox(height: 10),
              buildTextFormField(_emailController, "E-mail", TextInputType.emailAddress, Icons.email),
              SizedBox(height: 10),
              buildTextFormField(_passwordController, "Senha", TextInputType.text, Icons.lock, obscure: _obscurePassword, toggleObscure: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              }),
              SizedBox(height: 10),
              buildTextFormField(_confirmPasswordController, "Confirmar Senha", TextInputType.text, Icons.lock, obscure: _obscureConfirmPassword, toggleObscure: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              }),
              SizedBox(height: 45),
              Container(
                height: 50,
                width: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    userController.cadastrar(
                      _emailController.text, _passwordController.text,
                      _confirmPasswordController.text, _nameController.text,
                      context,
                    );
                    try {
                      print('Written successfully');
                    } catch (e) {
                      print('You got an error!');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green[700],
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 40,
                child: TextButton(
                  child: Text(
                    "Cancelar",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField buildTextFormField(TextEditingController controller, String label, TextInputType type, IconData icon, {bool obscure = false, Function? toggleObscure}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        suffixIcon: toggleObscure != null
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleObscure as void Function()?,  // Casting the function type here
        )
            : null,
      ),
      style: TextStyle(fontSize: 18),
    );
  }
}

