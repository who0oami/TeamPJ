/* 
Description : Timetable Model for Firebase
Date : 2026-1-16
Author : 황민욱
*/

class Timetable {
  final String timetableId;       // Firestore doc.id
  final int timetableSemester;
  final String timetableSubject;
  final int timetableTime;
  final String timetableDay;

  Timetable({
    required this.timetableId,
    required this.timetableSemester,
    required this.timetableSubject,
    required this.timetableTime,
    required this.timetableDay,
  });

  factory Timetable.fromMap(Map<String, dynamic> map, String id){
    return Timetable(
      timetableId: id,
      timetableSemester: map['timetable_semester'] ?? 0,
      timetableSubject: map['timetable_subject'] ?? "",
      timetableTime: map['timetable_time'] ?? 0,
      timetableDay: map['timetable_day'] ?? ""
    );
  }
}