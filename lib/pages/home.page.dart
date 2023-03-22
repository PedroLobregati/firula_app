import 'dart:async';
import 'package:badges/badges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firula_app/pages/creategame.page.dart';
import 'package:firula_app/pages/home-mygames.page.dart';
import 'package:firula_app/pages/match.page.dart';
import 'package:firula_app/pages/notification.page.dart';
import 'package:firula_app/pages/profile.page.dart';
import 'package:firula_app/models/match.dart';
import 'package:firula_app/pages/user.profile.page.dart';
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
    _activateListeners();
  }
  late StreamSubscription _match;

   _activateListeners(){
    final User? user = _firebaseAuth.currentUser;
    final userId = user!.photoURL;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                              builder: (context) => const ProfilePage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.person,
                          size: 80,
                        ),
                      padding: EdgeInsets.only(bottom: 50),
                        ),
                  ],
                ),
                Row(
                  children: const [
                    SizedBox(width: 7,),
                    Text('Criar jogo',
                    style: TextStyle(
                      fontFamily: 'Thonburi',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                    ),
                    SizedBox(width: 238,),
                    Text('Perfil',
                    style: TextStyle(
                      fontFamily: 'Thonburi',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.2,
                    ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),

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



                const SizedBox(height: 7,),

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
                                color: Color(0xff699708),
                              ),
                            ),
                          ),
                        child: TextButton(
                            onPressed: ((){
                            }),
                            child: const Text('Explorar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
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
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        child: TextButton(
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeMyGames(),
                                ),
                              );
                            },
                            child: const Text('Meus jogos',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xff036C00),
                            ),)),
                      ),
                    ),
                  ],
                ),

                Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 30),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 2,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('Últimos 7 dias',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          fontFamily: 'Arial'
                        ),),
                      ),
                      IconButton(onPressed: (){
                        refreshPage();
                      }, icon: Icon(Icons.refresh_rounded, color: Colors.black54,))
                    ],
                  ),
                ),
                const SizedBox(height: 20,),

                StreamBuilder(stream:
                _database.child('FirulaData/matches').orderByKey().limitToLast(10).onValue,
                    builder: (context, snapshot){
                  final tileList = <ListTile>[];
                  if(snapshot.data?.snapshot.value != null) {
                    final myMatches = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as dynamic);
                    myMatches.forEach((key, value) {
                      final nextMatch = Map<String, dynamic>.from(value);
                      String local = nextMatch['local'] as String;
                      String data = nextMatch['data'] as String;
                      String horario = nextMatch['time'] as String;
                      String host = nextMatch['host'] as String;
                      String matchId = nextMatch['id'] as String;
                      final orderTile = ListTile(
                        leading: const Icon(Icons.sports_soccer),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchPage(matchId: matchId,),
                            ),
                          );
                        },
                        title: RichText(
                          text: TextSpan(
                            // Note: Styles for TextSpans must be explicitly defined.
                            // Child text spans will inherit styles from parent
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: local, style: TextStyle(fontSize: 20)),
                              TextSpan(text: ' - $data ($horario)', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        subtitle: Text("Criado por $host"),);
                      tileList.add(orderTile);
                    });
                  }
                  return Expanded(
                    child: RefreshIndicator(
                      onRefresh:  refreshPage,
                      child: ListView(
                        children:
                        tileList,
                      ),
                    ),
                  );
                    }
                ),

                StreamBuilder(
                  stream: _database.child('FirulaData/users/${user!.photoURL}/received').orderByKey().limitToLast(10).onValue,
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
                        padding: const EdgeInsets.all(8.0),
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

  void showOverlay(BuildContext context){
     OverlayState? overlayState = Overlay.of(context);
     OverlayEntry overlayEntry = OverlayEntry(builder: (context) => Expanded(
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
             return ElevatedButton.icon(onPressed: (){},
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
     ),
     );
     overlayState!.insert(overlayEntry);
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


