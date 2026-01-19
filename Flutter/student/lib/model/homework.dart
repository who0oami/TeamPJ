/* 
Description : Homework Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Homework {
  final String homework_id;        // Firestore doc.id
  final String homework_title;
  final String homework_contents;
  final String homework_subject;
  final DateTime homework_duedate;
  final DateTime homework_insertdate;
  final DateTime homework_updatedate;
  final List<String> homework_images;
  final int teacher_id;

  Homework({
    required this.homework_id,
    required this.homework_title,
    required this.homework_contents,
    required this.homework_subject,
    required this.homework_duedate,
    required this.homework_insertdate,
    required this.homework_updatedate,
    required this.homework_images,
    required this.teacher_id,
  });

  factory Homework.fromMap(Map<String, dynamic> map, String id){
    return Homework(
      homework_id: id,
      homework_title: map['homework_title'] ?? "",
      homework_contents: map['homework_contents'] ?? "",
      homework_subject: map['homework_subject'] ?? "",
      homework_duedate: (map['homework_duedate'] as Timestamp).toDate(),
      homework_insertdate: (map['homework_insertdate'] as Timestamp).toDate(),
      homework_updatedate: (map['homework_updatedate'] as Timestamp).toDate(),
      homework_images: List<String>.from(map['homework_images'] ?? []),
      teacher_id: map['teacher_id'] ?? 0,
    );
  }
}