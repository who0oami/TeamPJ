/* 
Description : Homework Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String homeworkId;        // Firestore doc.id
  final String homeworkContents; 
  final String homeworkSubject;
  final DateTime homeworkDate;

  Homework({
    required this.homeworkId,
    required this.homeworkContents,
    required this.homeworkSubject,
    required this.homeworkDate,
  });

  factory Homework.fromMap(Map<String, dynamic> map, String id){
    return Homework(
      homeworkId: id,
      homeworkContents: map['homework_contents'] ?? "",
      homeworkSubject: map['homework_subject'] ?? "",
      homeworkDate: (map['homework_date'] as Timestamp).toDate()
    );
  }
}