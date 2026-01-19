/* 
Description : Schedule 테이블 구성 / 수정
Date : 2026-1-19
Author : 시온
*/


import 'package:cloud_firestore/cloud_firestore.dart';

class Schedule{
  final String schedule_id;
  final String teacher_id;
  final DateTime schedule_startdate;
  final DateTime schedule_enddate;
  final DateTime schedule_insertdate;
  final DateTime schedule_updatedate;
  final String schedule_title;
  final String schedule_contents;

  Schedule(
    {
      required this.schedule_id,
      required this.teacher_id,
      required this.schedule_startdate,
      required this.schedule_enddate,
      required this.schedule_insertdate,
      required this.schedule_updatedate,
      required this.schedule_title,
      required this.schedule_contents,
    }
  );
  factory Schedule.fromMap(Map<String, dynamic> map, String id){
    return Schedule(
      schedule_id: id, 
      teacher_id: map['teacher_id'] ?? "",
      schedule_startdate: (map['schedule_startdate']as Timestamp).toDate(),
      schedule_enddate: (map['schedule_enddate']as Timestamp).toDate(),
      schedule_insertdate: (map['schedule_insertdate']as Timestamp).toDate(),
      schedule_updatedate: (map['schedule_updatedate']as Timestamp).toDate(),
      schedule_title: map['schedule_title'] ?? "",
      schedule_contents: map['schedule_contents'] ?? "",
      );
  }
}