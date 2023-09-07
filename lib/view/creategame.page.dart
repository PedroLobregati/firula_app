import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firula_app/controller/UserController.dart';
import 'package:firula_app/view/home.page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firula_app/view/map_view.dart';
import 'package:latlong2/latlong.dart';

class CreateGame extends StatefulWidget {
  CreateGame({Key? key}) : super(key: key);

  @override
  State<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  final userController = UserController();

  @override
  void initState() {
    super.initState();
    userController.verificarJogoCriado().then((bool resultado) {
      setState(() {
        jaPossuiJogo = resultado;
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
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
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
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 70), // Centralizado verticalmente com margens
                padding: EdgeInsets.all(5.0),
                height: MediaQuery.of(context).size.height * 1, // Ajustado o tamanho conforme solicitado
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      const SizedBox(height: 30),
                      _buildTextFormField(
                        matchLocalController,
                        "Local",
                        TextInputType.text,
                        Icons.place,
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        matchDataController,
                        "Data",
                        TextInputType.datetime,
                        Icons.calendar_month_rounded,
                        onTap: () async {
                          DateTime? date = DateTime(1900);
                          FocusScope.of(context).requestFocus(new FocusNode());
                          date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            String formattedDate = DateFormat(DateFormat.YEAR_NUM_MONTH_DAY, 'pt_Br').format(date);
                            matchDataController.text = formattedDate;
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        matchTimeController,
                        "Horário",
                        TextInputType.text,
                        Icons.watch_later,
                        onTap: () async {
                          TimeOfDay time = TimeOfDay.now();
                          FocusScope.of(context).requestFocus(new FocusNode());
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: time,
                          );
                          if (pickedTime != null) {
                            matchTimeController.text = pickedTime.format(context).toString();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTextFormField(
                        matchPlayersController,
                        "Quantidade de jogadores",
                        TextInputType.number,
                        Icons.people,
                        onEditingComplete: () {
                          nMax = int.parse(matchPlayersController.text);
                        },
                      ),
                      const SizedBox(height: 30),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: MapView(
                            onLocationSelected: (LatLng latLng) async {
                              String address = await userController.convertCoordinatesToAddress(latLng);
                              matchLocalController.text = address;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Center(
                  child: _buildPublicarButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _buildTextFormField(TextEditingController controller,
      String label, TextInputType type, IconData icon,
      {Function? onTap, Function? onEditingComplete}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: Colors.black), // Cor do texto alterada para branco
      cursorColor: Colors.green, // Cor do cursor alterada para branco
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        prefixIcon: Icon(icon, color: Colors.black), // Cor do ícone alterada para branco
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.black, // Cor do rótulo alterada para branco
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.green), // Cor da borda focada alterada para branco
        ),
      ),
      onTap: onTap as void Function()?,
      onEditingComplete: onEditingComplete as void Function()?,
    );
  }

  Widget _buildPublicarButton() {
    if (!jaPossuiJogo) {
      return ElevatedButton(
        onPressed: () async {
          userController.publicar(
              matchLocalController.text,
              matchDataController.text,
              nMax,
              matchTimeController.text,
              context);
        },
        child: const Text(
          'Publicar',
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.green[700],
          padding: EdgeInsets.symmetric(horizontal: 70, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Você já possui um jogo criado!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
