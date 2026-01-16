/* 
Description : Homework Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String homework_id;        // Firestore doc.id
  final String homework_contents; 
  final String homework_subject;
  final DateTime homework_date;

  Homework({
    required this.homework_id,
    required this.homework_contents,
    required this.homework_subject,
    required this.homework_date,
  });

  factory Homework.fromMap(Map<String, dynamic> map, String id){
    return Homework(
      homework_id: id,
      homework_contents: map['homework_contents'] ?? "",
      homework_subject: map['homework_subject'] ?? "",
      homework_date: (map['homework_date'] as Timestamp).toDate()
    );
  }
}