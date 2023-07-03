import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/pages/home.page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateGame extends StatefulWidget {

   CreateGame({Key? key}) : super(key: key);

  @override
  State<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {

  @override
  void initState(){
    super.initState();
    _activateListeners();
  }
  void _activateListeners(){
    database.child('FirulaData/users/${user!.uid}/possuiJogoCriado').onValue.listen((event) {
      final bool possuiJogoCriado = event.snapshot.value as bool;
      setState(() {
        jaPossuiJogo = possuiJogoCriado;
      });
    });

  }
  final database = FirebaseDatabase.instance.ref();
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController matchLocalController = TextEditingController();

  final TextEditingController matchDataController = TextEditingController();

  final TextEditingController matchTimeController = TextEditingController();

  final TextEditingController matchPlayersController = TextEditingController();

  int nMax = 0;
  bool jaPossuiJogo = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/society.jpg"),
              fit: BoxFit.cover,
              opacity: 200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.black,),
                    ),
                    _buildPublicarButton(),
                  ],
                ),

                const SizedBox(height: 30,),

                Container(
                  decoration: BoxDecoration(

                  ),
                  child: TextFormField(
                    controller: matchLocalController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Local",
                      labelStyle: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0),borderSide: BorderSide(color: Colors.black, width: 8)),
                      suffixIcon: Icon(Icons.place, size: 30, color: Colors.black,)
                    ),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onTap: () async{
                    DateTime? date = DateTime(1900);
                    FocusScope.of(context).requestFocus(FocusNode());
                    date = await showDatePicker(
                        context: context,
                        initialDate:DateTime.now(),
                        firstDate:DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 7)));

                    String formattedDate = DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, 'pt_Br').format(date!);
                    matchDataController.text = formattedDate.toString();
                  },
                  controller: matchDataController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    labelText: "Data",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0), borderSide: BorderSide(color: Colors.black,)),
                    suffixIcon: Icon(Icons.calendar_month_rounded, size: 30,color: Colors.black,)
                  ),
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextFormField(
                  onTap: () async {
                    TimeOfDay time = TimeOfDay.now();
                    FocusScope.of(context).requestFocus(new FocusNode());
                    TimeOfDay? pickedTime =
                    await showTimePicker(context: context, initialTime: time);

                    if(pickedTime != null ){
                      print(pickedTime.format(context));   //output 10:51 PM
                        matchTimeController.text = pickedTime.format(context).toString();
                      //DateFormat() is from intl package, you can format the time on any pattern you need.
                    }else{
                      print("Time is not selected");
                    }
                  },
                  controller: matchTimeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  decoration: InputDecoration(
                    labelText: "Horário",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0),borderSide: BorderSide(color: Colors.black)),
                    suffixIcon: Icon(Icons.watch_later, size: 30,color: Colors.black,)
                  ),
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(
                  height: 20,
                ),

                TextFormField(
                  onEditingComplete: (){
                    nMax = int.parse(matchPlayersController.text);
                  },
                  controller: matchPlayersController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantidade de jogadores",
                    labelStyle: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.0),borderSide: BorderSide(color: Colors.black)),
                    suffixIcon: Icon(Icons.people, size: 30,color: Colors.black,),
                  ),
                  style: const TextStyle(fontSize: 20),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
  void publicar() async {
      if (matchLocalController.text == null || matchLocalController.text == ''
          || matchDataController.text == null || matchLocalController.text == ''
          || matchPlayersController.text == null ||
          matchPlayersController.text == ''
          || matchTimeController.text == null ||
          matchTimeController.text == '') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha todos os campos'),),
        );
      }
      else {
        User? user = FirebaseAuth.instance.currentUser;
        String host = user?.displayName ?? 'Anonymous';
        final profileData = database.child('FirulaData/matches/').push();
        await profileData.set(
            {'local': matchLocalController.text,
              'data': matchDataController.text,
              'time': matchTimeController.text,
              'nPlayers': nMax,
              'host': host,
              'id': profileData.key,
              'hostId': user!.uid,
              'onList': 1,
            });
        final matchData = database.child(
            'FirulaData/matches/${profileData.key}/participants').push();
        await matchData.set(
            {'userId': user!.uid, 'username': user.displayName});
        database.child('FirulaData/users/${user.uid}').update({
          'possuiJogoCriado' : true,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Jogo criado com sucesso'),
          backgroundColor: Colors.lightGreen,
        ));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
  }

  Widget _buildPublicarButton(){
    if(!jaPossuiJogo){
      return ElevatedButton(
        onPressed: () async {
          publicar();
        },
        child: const Text('Publicar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    else{
      return
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Você já possui jogo criado'),
            backgroundColor: Colors.red,
          ),
          );
        },
        child: const Text('Publicar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey
          ),
        ),
      );
    }
  }
  }


