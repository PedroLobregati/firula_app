import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firula_app/controller/UserController.dart';
import 'package:firula_app/model/UserModel.dart';
import 'package:firula_app/provider/google_sign_in.dart';
import 'package:firula_app/view/home.page.dart';
import 'package:firula_app/view/login.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _firebaseAuth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final userController = UserController();
  final _localizController = TextEditingController();
  final _posController = TextEditingController();
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    userController.carregarInfoPerfil(_onDataReceived);
  }

  late StreamSubscription _user;

  void _onDataReceived(UserModel userData) {
    setState(() {
      userModel = userData;
      _localizController.text = userModel?.localiz ?? '';
      _posController.text = userModel?.pos ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                height: 250.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.green, Colors.lightGreen.shade200],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 100.0,
              left: queryData.size.width / 2 - 90.0,
              child: CircleAvatar(
                radius: 90.0,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 82.0,
                  backgroundImage: AssetImage(
                      'assets/path/to/your/image.jpg'), // add your image asset here
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 28.0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.green,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios),
                        color: Colors.black,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white, // Botão colorido
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50), // Botão arredondado
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding
                        ),
                        onPressed: () async {
                          showAlertDialog(context);
                        },
                        child: Text(
                          'Sair',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 225),
                  Text(
                    "${user?.displayName ?? ''}",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFieldContainer(
                    child: TextField(
                      controller: TextEditingController(text: user?.email),
                      enabled: false,
                      decoration: InputDecoration(
                        icon: Icon(Icons.email, color: Colors.green),
                        hintText: "Email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      controller: _localizController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.location_on, color: Colors.green),
                        hintText: userModel?.localiz == ''
                            ? "Localização"
                            : userModel?.localiz,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      controller: _posController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.sports_soccer, color: Colors.green),
                        hintText: userModel?.pos == ''
                            ? "Posição"
                            : userModel?.pos,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 90),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Botão colorido
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50), // Botão arredondado
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 70, vertical: 15), // Padding
                    ),
                    onPressed: () async {
                      userController.salvarAlteracoes(
                          _localizController.text, _posController.text);
                    },
                    child: Text(
                      'Salvar Alterações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Sair"),
          content: new Text("Você tem certeza que deseja sair?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new TextButton(
              child: new Text("Sim"),
              onPressed: () async {
                final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogout();
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()));
                await _firebaseAuth.signOut().then(
                      (user) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();
    path.lineTo(0, size.height - 50);
    var controlPoint = Offset(50, size.height);
    var endPoint = Offset(size.width / 2, size.height);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    controlPoint = Offset(size.width - 50, size.height);
    endPoint = Offset(size.width, size.height - 50);
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.green[100],
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
