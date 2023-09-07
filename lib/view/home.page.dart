import 'dart:async';
//teste
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firula_app/view/creategame.page.dart';
import 'package:firula_app/view/home-mygames.page.dart';
import 'package:firula_app/view/match.page.dart';
import 'package:firula_app/view/notification.page.dart';
import 'package:firula_app/view/profile.page.dart';
import 'package:firula_app/view/user.profile.page.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final _database = FirebaseDatabase.instance.ref();
  String displaytext = '';
  final _firebaseAuth = FirebaseAuth.instance;
  int notificNumber = 0;
  final TextEditingController searchController = TextEditingController();
  String search = '';
  bool searchBarInUse = false;

  @override
  void initState(){
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
              top: -MediaQuery.of(context).size.height / 4,
              child: Container(
                height: MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width,
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
                              color: Color(0xff699708),
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: (() {}),
                          child: const Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeMyGames(),
                              ),
                            );
                          },
                          child: const Text(
                            'Meus jogos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff036C00),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                StreamBuilder(
                  stream: _database
                      .child('FirulaData/matches')
                      .orderByKey()
                      .limitToLast(10)
                      .onValue,
                  builder: (context, snapshot) {
                    final tileList = <Widget>[]; // Usaremos uma lista de Widgets para incluir Dividers
                    if (snapshot.data?.snapshot.value != null) {
                      final myMatches = Map<String, dynamic>.from(
                          snapshot.data!.snapshot.value as dynamic);
                      myMatches.forEach((key, value) {
                        final nextMatch = Map<String, dynamic>.from(value);
                        String local = nextMatch['local'] as String? ?? 'Local não definido';
                        String data = nextMatch['data'] as String? ?? 'Data não definida';
                        String horario = nextMatch['time'] as String? ?? 'Horário não definido';
                        String host = nextMatch['host'] as String? ?? 'Anfitrião não definido';
                        String matchId = key;
                        final orderTile = ListTile(
                          leading: const Icon(Icons.sports_soccer),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MatchPage(matchId: matchId),
                              ),
                            );
                          },
                          title: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                    text: local, style: TextStyle(fontSize: 20)),
                                TextSpan(
                                    text: ' - $data ($horario)',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          subtitle: Text("Criado por $host"),
                        );
                        tileList.add(orderTile);
                        tileList.add(Divider(thickness: 1.5, color: Colors.black)); // Adiciona um Divider após cada jogo
                      });

                    }
                    return Expanded(
                      child: RefreshIndicator(
                        onRefresh: refreshPage,
                        child: ListView(
                          children: tileList,
                        ),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _database.child('FirulaData/users/${user!.uid}/received').orderByKey().limitToLast(10).onValue,
                    builder: (context, snapshot) {
                      int notificacao = 0;
                      if (snapshot.data?.snapshot.value != null) {
                        print("SNAPSHOT: $snapshot");
                        print("SNAPSHOT.DATA: ${snapshot.data?.snapshot.value}");
                        final myNotifications = Map<String, dynamic>.from(
                            snapshot.data!.snapshot.value as dynamic);
                        myNotifications.forEach((key, value) {
                          notificacao++;
                        });
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 5.0), // Ajuste o valor de 'top' conforme necessário
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            badges.Badge(
                              badgeContent: Text('$notificacao',
                                  style: const TextStyle(color: Colors.white)),
                              child: Icon(Icons.notifications, size: 42,),
                              badgeStyle: BadgeStyle(badgeColor: Colors.green),
                              onTap: () {
                                Navigator.push(context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const NotificationPage()));
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  @override
  void deactivate(){
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


  Widget _buildSearch(){
    if(searchBarInUse == true){
      return Expanded(
        child: FirebaseAnimatedList(
          query: _database.child('FirulaData/users'),
          itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
            var data = snapshot.value as Map?;
            String tempTitle = data!['nome'];
            String tempId = snapshot.key!;
            if(searchController.text.isEmpty){
              return SizedBox(height: 1,);
            }
            else if (tempTitle.contains(searchController.text.toString())){
              return Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(userId: tempId,),
                        ),
                      );
                    },
                    icon: CircleAvatar(
                      backgroundColor: Colors.black, // Defina a cor de fundo do círculo aqui
                      child: Icon(Icons.person, size: 18, color: Colors.white,), // Defina a cor do ícone aqui
                    ),
                    label: Text(
                      tempTitle,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w200),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white70,
                      minimumSize: Size(150, 50), // Ajuste a largura e altura conforme necessário
                    ),
                  ),
                  Container(
                    height: 10, // Ajuste a altura conforme necessário
                    color: Colors.white, // Defina a cor do bloco de separação aqui
                  ),
                  // Você pode copiar e colar um bloco semelhante de ElevatedButton.icon aqui para adicionar mais botões
                ],
              );

            }
            else{
              return SizedBox(height: 2, );
            }
          },),
      );}
    else {
      return const SizedBox(height: 10,);
    }

  }
  Future<void> refreshPage() async {
    DateTime dataHoje = DateTime.now();
    TimeOfDay horarioAtual = TimeOfDay.now();

    final ref = FirebaseDatabase.instance.ref().child('FirulaData/matches/').orderByKey();
    ref.get().then((snapshot) {
      for (final data in snapshot.children) {
        String dataJogo = data.child("data").value as String;
        String horaJogo = data.child("time").value as String;
        String hostId = data.child("hostId").value as String;

        var horaJogoParsed = TimeOfDay(hour:int.parse(horaJogo.split(":")[0]),minute: int.parse(horaJogo.split(":")[1]));
        var dataJogoParsed = DateFormat('d/M/y').parse(dataJogo);
        double atualtoDouble(TimeOfDay myTime) => (myTime.hour - 3) + (myTime.minute/60.0);
        double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute/60.0;
        if(DateUtils.isSameDay(dataJogoParsed, dataHoje) && DateUtils.isSameMonth(dataJogoParsed, dataHoje) || dataJogoParsed.isBefore(dataHoje)){

          if(dataJogoParsed.isBefore(dataHoje)){
            _database.child('FirulaData/matches/${data.key}').remove();
            _database.child('FirulaData/users/$hostId').update(
                {'possuiJogoCriado': false});
          }
          else if (atualtoDouble(horarioAtual) >= toDouble(horaJogoParsed)){
            _database.child('FirulaData/matches/${data.key}').remove();
            _database.child('FirulaData/users/$hostId').update(
                {'possuiJogoCriado': false});

          }
        }
      }
    });
    return Future.delayed(Duration(seconds: 2));
  }




}