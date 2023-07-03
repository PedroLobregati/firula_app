import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/pages/login.page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/auth_check.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _password = '';
  var _confirmPassword = '';
  var _name = null;
  final database = FirebaseDatabase.instance.ref();

  final _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(top: 10, left: 40, right: 40),
          color: Color(0xff646660),
          child: ListView(
            children: <Widget>[
              Container(
                width: 200,
                height: 160,
                alignment: Alignment(0.0, 1.15),
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: AssetImage("assets/images/logo.png"),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
              SizedBox(
                height: 13,
              ),
              TextFormField(
                onChanged: (value){
                  _name = value;
                },
                controller: _nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "E-mail",
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),

                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                onChanged: (value){
                  _password = value;
                },
                controller: _passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Senha",
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(fontSize: 20),
              ),

              /* SizedBox(
                height: 10,
              ),*/

              TextFormField(
                onChanged: (value){
                  _confirmPassword = value;
                },
                controller: _confirmPasswordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmar Senha",
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(fontSize: 20),
              ),

              SizedBox(
                height: 40,
              ),
              Container(
                height: 60,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Color(0xffC3EC37),
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: SizedBox.expand(
                  child: TextButton(
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () async {
                      cadastrar();
                      try{
                        print('Written successfully');
                      }catch(e) {
                        print('You got an error!');
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                alignment: Alignment.center,
                child: TextButton(
                  child: Text(
                    "Cancelar",
                    textAlign: TextAlign.center,
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

  cadastrar() async {
    bool checkSign = true;

    if (_emailController.text == null || _emailController.text == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 1),content: Text('Email obrigatório'),),
      );
    }
    if (_passwordController.text == null || _passwordController.text == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(duration: Duration(seconds: 1),content: Text('Senha obrigatória'),),
      );
    }
    if (_password.toString() != _confirmPassword.toString()) {
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Senhas diferentes'),
        backgroundColor: Colors.redAccent,
      ),
      );
    }
    if (_name == null || _name == ''){
      checkSign = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Campo nome obrigatório'),
        backgroundColor: Colors.redAccent,
      ),
      );
    }
      if (checkSign == true ){
        try {
          UserCredential userCredential = await _firebaseAuth
              .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text,);
          if (userCredential != null) {
            String email = _emailController.text;
            print(email);
            userCredential.user!.updateDisplayName(_nameController.text);
            final profileData = database.child('FirulaData/users/${userCredential.user!.uid}');

            await profileData.set({'nome': _name, 'email': _emailController.text, 'localiz': '', 'pos': '', 'possuiJogoCriado': false});
            userCredential.user!.updatePhotoURL(profileData.key);
          }

        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            checkSign = false;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Senha fraca.'),
              backgroundColor: Colors.redAccent,
            ),
            );
          }
          else if (e.code == 'email-already-in-use') {
            checkSign = false;
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Email já cadastrado.'),
              backgroundColor: Colors.redAccent,
            ),
            );
          }
        }

        if (checkSign == true){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
          );
        }
      }


  }
}