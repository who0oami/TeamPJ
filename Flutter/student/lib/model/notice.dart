/* 
Description : Notice Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String notice_id;      // Firestore doc.id
  final String homework_id;    // FK
  final String timetable_id;   // FK
  final DateTime notice_date;

  Notice({
    required this.notice_id,
    required this.homework_id,
    required this.timetable_id,
    required this.notice_date
  });

  factory Notice.fromMap(Map<String, dynamic> map, String id){
    return Notice(
      notice_id: id,
      homework_id: map['homework_id'] ?? "",
      timetable_id: map['timetable_id'] ?? "",
      notice_date: (map['notice_date'] as Timestamp).toDate()
    );
  }
}