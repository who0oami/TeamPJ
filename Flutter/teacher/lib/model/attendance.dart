/* 
Description : attendance 테이블 구성
Date : 2026-1-16
Author : 상현
*/

class Attendance {
  final int? attendance_id;
  final String attendance_start_time;
  final String attendance_end_time;
  final String attendance_status;
  final int attendance_grade;
  final int attendance_class;
  final int student_id;

  Attendance(
    {
      this.attendance_id,
      required this.attendance_start_time,
      required this.attendance_end_time,
      required this.attendance_status,
      required this.attendance_grade,
      required this.attendance_class,
      required this.student_id
    }
  );

  factory Attendance.fromJson(Map<String, dynamic> json){
    return Attendance(
      attendance_start_time: json['attendance_start_time'],
      attendance_end_time: json['attendance_end_time'],
      attendance_status: json['attendance_status'],
      attendance_grade: json['attendance_grade'],
      attendance_class: json['attendance_class'],
      student_id: json['student_id']
      );
  }

  Map<String, dynamic> toJson(){
    return{
      'attendance_start_time' : attendance_start_time,
      'attendance_end_time' : attendance_end_time,
      'attendance_status' : attendance_status,
      'attendance_grade' : attendance_grade,
      'attendance_class' : attendance_class,
      'student_id' : student_id
    };
  }
}