import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firula_app/view/creategame.page.dart';
import 'package:firula_app/view/home.page.dart';
import 'package:firula_app/view/profile.page.dart';
import 'package:firula_app/view/user.profile.page.dart';
import 'package:flutter/material.dart';


class HomeMyGames extends StatefulWidget {
  const HomeMyGames({Key? key}) : super(key: key);

  @override
  State<HomeMyGames> createState() => _HomeMyGamesState();
}

class _HomeMyGamesState extends State<HomeMyGames> {
  final _database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;
  String displayLocal = '';
  String displayData = '';
  String search = '';
  bool searchBarInUse = false;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  late StreamSubscription _match;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Gradient Background
            Positioned(
              top: -MediaQuery
                  .of(context)
                  .size
                  .height / 4,
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height / 2,
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green, Colors.lightGreen.shade200],
                  ),
                ),
              ),
            ),
            // Logo at the top center
            Positioned(
              top: 10,
              right: 0,
              left: 20,
              child: Image.asset('assets/images/logo.png', height: 125),
            ),
            // Create Game and Profile buttons
            Positioned(
              top: 30,
              left: 15,
              child: _buildCircleButton(
                icon: Icons.add_circle_outline,
                label: 'Criar Jogo',
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGame()),
                  );
                },
              ),
            ),
            Positioned(
              top: 34,
              right: 15,
              child: _buildCircleButton(
                icon: Icons.person,
                label: 'Perfil',
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
              ),
            ),
            Column(
              children: [
                SizedBox(height: 150), // Ajuste o valor conforme necessário
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: searchBarInUse
                          ? IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          searchController.clear();
                          setState(() {
                            searchBarInUse = false;
                          });
                        },
                        icon: Icon(Icons.cancel),
                      )
                          : null,
                      hintText: "Pesquisar usuários...",
                      border: InputBorder.none,
                    ),
                    onTap: () {},
                    onChanged: (String text) {
                      setState(() {
                        search = text;
                        searchBarInUse = true;
                      });
                    },
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 0),
                _buildSearch(),
                SizedBox(height: 7),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 4,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff036C00),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 4,
                              color: Color(0xff699708),
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: (() {}),
                          child: const Text(
                            'Meus Jogos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xff036C00),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                StreamBuilder(

                    stream: _database
                        .child('FirulaData/users/${user!.uid}/solicitParticip')
                        .orderByKey()
                        .limitToLast(10)
                        .onValue,
                    builder: (context, snapshot) {
                      final tileList = <Widget>[];
                      if (snapshot.data?.snapshot.value != null) {
                        final mySolicit = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as dynamic);
                        mySolicit.forEach((key, value) {
                          final next = Map<String, dynamic>.from(value);
                          String local = next['matchLocal'] as String;
                          String data = next['matchData'] as String;
                          String situacao = next['situation'] as String;
                          final orderTile = ListTile(
                            leading: situacao == "Na lista!" ? const Icon(
                              Icons.check_circle, size: 30,
                              color: Colors.green,) : situacao ==
                                'Aguardando resposta...' ? const Icon(
                              Icons.watch_later, size: 30,) : const Icon(
                              Icons.cancel, size: 30, color: Colors.red,),
                            onTap: () {},
                            title: Text("$local ($data)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                          tileList.add(orderTile);
                          tileList.add(Divider(thickness: 1.5, color: Colors.black));
                        });
                      }
                      return Expanded(
                        child: ListView(
                          children: tileList,
                        ),
                      );
                    }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  void deactivate() {
    _match.cancel();
    super.deactivate();
  }

  Widget _buildCircleButton(
      {required IconData icon, required String label, required VoidCallback onPress}) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: IconButton(
            icon: Icon(icon, size: 24),
            onPressed: onPress,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),  // Estilo adicionado aqui
        ),
      ],
    );
  }



  Widget _buildSearch() {
    if (searchBarInUse == true) {
      return Expanded(
        child: FirebaseAnimatedList(
          query: _database.child('FirulaData/users'),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            var data = snapshot.value as Map?;
            String tempTitle = data!['nome'];
            String tempId = snapshot.key!;
            if (searchController.text.isEmpty) {
              return SizedBox(height: 1,);
            }
            else if (tempTitle.contains(searchController.text.toString())) {
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfilePage(userId: tempId,),
                        ),
                      );
                    },
                    icon: CircleAvatar(
                      backgroundColor: Colors.black,
                      // Defina a cor de fundo do círculo aqui
                      child: Icon(Icons.person, size: 18,
                        color: Colors.white,), // Defina a cor do ícone aqui
                    ),
                    label: Text(
                      tempTitle,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w200),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white70,
                      minimumSize: Size(150,
                          50), // Ajuste a largura e altura conforme necessário
                    ),
                  ),
                  Container(
                    height: 10, // Ajuste a altura conforme necessário
                    color: Colors
                        .white, // Defina a cor do bloco de separação aqui
                  ),
                  // Você pode copiar e colar um bloco semelhante de ElevatedButton.icon aqui para adicionar mais botões
                ],
              );
            }
            else {
              return SizedBox(height: 2,);
            }
          },),
      );
    }
    else {
      return const SizedBox(height: 10,);
    }
  }

}

