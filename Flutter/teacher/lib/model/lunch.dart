/* 
Description : Lunch 테이블 구성
Date : 2026-1-16
Author : 시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Lunch{
  final String lunch_id;
  final String lunch_category_id;
  final DateTime lunch_date;
  final String lunch_menu_id;

  Lunch(
    {
      required this.lunch_id,
      required this.lunch_category_id,
      required this.lunch_date,
      required this.lunch_menu_id,
    }

  );
  factory Lunch.fromMap(Map<String, dynamic> map, String id){
    return Lunch(
      lunch_id: id,
      lunch_category_id: map['lunch_category_id'] ?? "",
      lunch_date: (map['lunch_date']as Timestamp).toDate(),
      lunch_menu_id: map['lunch_menu_id'] ?? ""
    );
  }

}