import 'package:cloud_firestore/cloud_firestore.dart';

class Ledger {
  
  Ledger({required this.id, 
          required this.reference, 
          required this.owner, 
          required this.date, 
          required this.type,
          required this.desc, 
          required this.amount, 
        });

    String id;
    String reference;
    String owner;
    String date;
    String type;
    String desc;
    int amount;

  Map<String, dynamic> toFirestore() {
    return {
      'reference': reference,
      'owner': owner,
      'date': date,
      'type': type,
      'desc': desc,
      'amount': amount,
    };
  }

  // character from firestore
  factory Ledger.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    
    Ledger ledger = Ledger(
      id: snapshot.id,
      reference: data['reference'],
      owner: data['owner'],
      date: data['date'],
      type: data['type'],
      desc: data['desc'],
      amount: data['amount'],
    );

    return ledger;
  } 
  
  
}