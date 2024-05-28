import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HighScoreTile extends StatelessWidget {
  final String docId;

   HighScoreTile({super.key, required this.docId});
  CollectionReference highScores =
  FirebaseFirestore.instance.collection('highscores');
  @override
  Widget build(BuildContext context) {
    // CollectionReference highScores =
    //     FirebaseFirestore.instance.collection('highscores');
    return FutureBuilder(
        future: highScores.doc(docId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;

            return Row(
              children: [
                Text(data['score'].toString()),
                SizedBox(width: 10,),
                Text(data['name']),
              ],
            );
          } else {
            return Text('loading..');
          }
        });
  }
}
