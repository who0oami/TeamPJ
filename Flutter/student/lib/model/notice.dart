/* 
Description : Notice Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String noticeId;      // Firestore doc.id
  final String homeworkId;    // FK
  final String timetableId;   // FK
  final DateTime noticeDate;

  Notice({
    required this.noticeId,
    required this.homeworkId,
    required this.timetableId,
    required this.noticeDate
  });

  factory Notice.fromMap(Map<String, dynamic> map, String id){
    return Notice(
      noticeId: id,
      homeworkId: map['homework_id'] ?? "",
      timetableId: map['timetable_id'] ?? "",
      noticeDate: (map['notice_date'] as Timestamp).toDate()
    );
  }
}