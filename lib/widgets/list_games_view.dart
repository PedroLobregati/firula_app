import 'package:flutter/cupertino.dart';
import 'package:firula_app/models/match.dart';

class ListGameItem extends StatelessWidget {
  ListGameItem({Key? key, required this.match, required this.onDelete}) : super(key: key);

  final Match match;
  final Function(Match) onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Color(0xff0000),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(match.local,
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              Text(match.data,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),),
            ],
          ),
        ),
    );


  }
}