
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firula_app/pages/home.page.dart';
import 'package:firula_app/pages/signup.page.dart';
import 'package:firula_app/provider/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {


  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 40, left: 40, right: 40),
        color: Color(0xff646660),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 228,
              height: 228,
              child: Image.asset("assets/images/logo.png"),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              validator: emailVazio,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              controller: _passwordController,
              keyboardType: TextInputType.text,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Login",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  onPressed: () {
                    login();
                  },
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,

              ),
              onPressed: (){
                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();
              },
              icon:FaIcon(FontAwesomeIcons.google, color: Colors.red,) ,
              label: Text("Entre com Google", style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Container(
              height: 40,
              child: TextButton(
                child: Text(
                  "Ainda não tem conta? Registre-se",
                  textAlign: TextAlign.center,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignupPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

  }
  login() async{
    try{
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      if(userCredential != null){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    }on FirebaseAuthException catch(e){
      if(e.code == 'user-not-found'){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Usuário não encontrado')
        ),
        );
      }
      else if (e.code == 'wrong-password'){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha incorreta'),),
        );
      }
     if (_emailController.text == null || _emailController.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email vazio'),),
        );
      }
      if (_passwordController.text == null || _passwordController.text == ''){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Senha vazia'),),
        );
      }

    }
  }

  String? emailVazio(String? value){
    if (value == null || value.isEmpty)
      return 'Email não preenchido';
    else
      return null;
  }

  String? senhaVazia(String? value){
    if (value == null || value.isEmpty)
      return 'Senha não preenchida';
    else
      return null;
  }


}


