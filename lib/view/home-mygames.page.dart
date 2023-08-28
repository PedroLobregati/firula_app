import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firula_app/view/creategame.page.dart';
import 'package:firula_app/view/home.page.dart';
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
  void initState(){
    super.initState();
  }
  late StreamSubscription _match;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Color(0xffE1FFA4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGame(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.add,
                        size: 55,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffE1FFA4),
                        shape: CircleBorder(),
                        side: const BorderSide(
                          width: 1.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 220,
                      height: 75,
                      child: Image.asset("assets/images/logo.png"),
                    ),
                    IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person,
                        size: 85,
                      ),
                      padding: EdgeInsets.only(bottom: 50),
                    ),
                  ],
                ),
                Row(
                  children: const [
                    SizedBox(width: 9,),
                    Text('Criar jogo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(width: 245,),
                    Text('Perfil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30,),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  child: TextField(controller: searchController,
                    decoration:  InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                      searchBarInUse? IconButton(onPressed: (){
                        FocusManager.instance.primaryFocus?.unfocus();
                        searchController.clear();
                        setState(() {
                          searchBarInUse = false;
                        });
                      }, icon: const Icon(Icons.cancel)): null,
                      hintText: "Pesquisar usuários...",
                      border: InputBorder.none,
                    ),
                    onTap: (){},
                    onChanged: (String text){
                      setState(() {
                        search = text;
                        searchBarInUse = true;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),

                _buildSearch(),
                const SizedBox(height: 10,),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 4,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: ((){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }),
                          child: const Text('Explorar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff036C00),
                            ),),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 4,
                              color: Color(0xff699708),
                            ),
                          ),
                        ),
                        child: TextButton(
                            onPressed: (){
                            },
                            child: const Text('Meus jogos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff036C00),
                              ),)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20,),

                StreamBuilder(stream:
                _database.child('FirulaData/users/${user!.uid}/solicitParticip').orderByKey().limitToLast(10).onValue,
                    builder: (context, snapshot){
                      final tileList = <ListTile>[];
                      if(snapshot.data?.snapshot.value != null) {
                        final mySolicit = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as dynamic);
                        mySolicit.forEach((key, value) {
                          final next = Map<String, dynamic>.from(value);
                          String local = next['matchLocal'] as String;
                          String data = next['matchData'] as String;
                          String situacao = next['situation'] as String;
                          final orderTile = ListTile(
                            leading: situacao == "Na lista!" ? const Icon(Icons.check_circle, size: 30, color: Colors.green,) : situacao == 'Aguardando resposta...' ? const Icon(Icons.watch_later, size: 30,) : const Icon(Icons.cancel, size: 30, color: Colors.red,),
                            onTap: () {
                            },
                            title: Text("$local ($data)",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,

                              ),),
                            );
                          tileList.add(orderTile);
                        });
                      }
                      return Expanded(
                        child: ListView(
                          children:
                          tileList,
                        ),
                      );
                    }
                ),

              ],


            ),
          ),
        ),
      ),

    );
  }
  @override
  void deactivate(){
    _match.cancel();
    super.deactivate();

  }

  Widget _buildSearch(){

    if(searchBarInUse == true){
      return Expanded(
        child: FirebaseAnimatedList(
          query: _database.child('FirulaData/users'),
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
            var data = snapshot.value as Map?;
            String tempTitle = data!['nome'];
            String tempId = data['id'];
            if(searchController.text.isEmpty){
              return SizedBox(height: 1,);
            }
            else if (tempTitle.contains(searchController.text.toString())){
              return ElevatedButton.icon(onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(userId: tempId,),
                  ),
                );
              },
                icon: Icon(Icons.person, size: 14,),
                label: Text(tempTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w200),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white70,
                ),);
            }
            else{
              return SizedBox(height: 1,);
            }
          },),
      );}
    else {
      return const SizedBox(height: 10,);
    }

  }

}


