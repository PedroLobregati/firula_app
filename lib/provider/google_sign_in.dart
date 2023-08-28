
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';


class GoogleSignInProvider extends ChangeNotifier{
  final googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _user;
  final DatabaseReference _userRef =
  FirebaseDatabase.instance.ref().child('FirulaData/users');

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async{
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    saveUserData(userCredential.user!);
    notifyListeners();


  }

  Future googleLogout() async{
    await googleSignIn.disconnect();
    FirebaseAuth.instance.signOut();
  }

  void saveUserData(User user) {
    DatabaseReference userRef = _userRef.child(user.uid);

    userRef.once().then((DatabaseEvent event) {
      if (event.snapshot.value != null ) {
        print('Usuário já existe');
      } else {
        userRef.set({
          'nome': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'pos': '',
          'localiz' : '',
          'possuiJogoCriado': false,
        });
        print('Usuário salvo com sucesso');
      }
    }).catchError((error) {
      print('Erro ao verificar o usuário: $error');
    });
  }

}