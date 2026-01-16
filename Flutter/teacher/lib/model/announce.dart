/* 
Description : Announce 테이블 구성
Date : 2026-1-16
Author : 시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Announce{
  final String announce_id;
  final String teacher_id;
  final String lunch_id;
  final String schedule_id;
  final DateTime announce_date;

  Announce(
    {
      required this.announce_id,
      required this.teacher_id,
      required this.lunch_id,
      required this.schedule_id,
      required this.announce_date,
    }
  );

  factory Announce.fromMap(Map<String, dynamic> map, String id){
    return Announce(
      announce_id: id,
      teacher_id: map['teacher_id'] ?? "",
      lunch_id: map['lunch_id'] ?? "",
      schedule_id: map['schedule_id'] ?? "",
      announce_date: (map['announce_date']as Timestamp).toDate(),
    );
  }
}