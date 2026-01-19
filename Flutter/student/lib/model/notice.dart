/* 
Description : Notice Model for Firebase / 수정
Date : 2026-1-19
Author : 정시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Notice {
  final String notice_id;      // Firestore doc.id
  final String teacher_id;    // FK
  final String notice_title; 
  final String notice_content;   
  final DateTime notice_updatedate;
  final DateTime notice_insertdate;
  final String notice_images;   

  Notice({
    required this.notice_id,
    required this.teacher_id,
    required this.notice_title,
    required this.notice_content,
    required this.notice_updatedate,
    required this.notice_insertdate,
    required this.notice_images,
  });

  factory Notice.fromMap(Map<String, dynamic> map, String id){
    return Notice(
      notice_id: id,
      teacher_id: map['teacher_id']?.toString() ?? "",
      notice_title: map['notice_title'] ?? "",
      notice_content: map['notice_content'] ?? "",
      notice_updatedate: (map['notice_updatedate'] as Timestamp).toDate(),
      notice_insertdate: (map['notice_insertdate'] as Timestamp).toDate(),
      notice_images: map['notice_images']?.toString() ?? "",
    );
  }
}