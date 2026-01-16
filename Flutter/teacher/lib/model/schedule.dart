/* 
Description : Schedule 테이블 구성
Date : 2026-1-16
Author : 시온
*/


import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule{
  final String schedule_id;
  final DateTime schedule_date;
  final String schedule_contents;

  Schedule(
    {
      required this.schedule_id,
      required this.schedule_date,
      required this.schedule_contents,
    }
  );
  factory Schedule.fromMap(Map<String, dynamic> map, String id){
    return Schedule(
      schedule_id: id, 
      schedule_date: (map['schedule_date']as Timestamp).toDate(),
      schedule_contents: map['schedule_contents'] ?? "");
      
  }
}