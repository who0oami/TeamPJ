/* 
Description : Timetable Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

class Timetable {
  final String timetable_id;       // Firestore doc.id
  final int timetable_semester;
  final String timetable_subject;
  final int timetable_time;
  final String timetable_day;

  Timetable({
    required this.timetable_id,
    required this.timetable_semester,
    required this.timetable_subject,
    required this.timetable_time,
    required this.timetable_day,
  });

  factory Timetable.fromMap(Map<String, dynamic> map, String id){
    return Timetable(
      timetable_id: id,
      timetable_semester: map['timetable_semester'] ?? 0,
      timetable_subject: map['timetable_subject'] ?? "",
      timetable_time: map['timetable_time'] ?? 0,
      timetable_day: map['timetable_day'] ?? ""
    );
  }
}