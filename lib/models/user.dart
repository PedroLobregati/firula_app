class UserProfile{
  final String name, email, id;
  final String? localiz, pos;
  UserProfile({required this.name, required this.email, required this.localiz, required this.pos, required this.id});

  factory UserProfile.fromRTDB(Map<String,dynamic> data){
    return UserProfile(
        name: data['nome'], email: data['email'],
        localiz: data['localiz'] ?? '', pos: data['pos'] ?? '', id: data['id']);
  }
}