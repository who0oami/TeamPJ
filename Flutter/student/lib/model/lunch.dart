/* 
Description : Lunch 테이블 구성
Date : 2026-1-16
Author : 시온
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class Lunch{
  final String lunch_id;
  final String lunchcategory_id;
  final DateTime lunch_date;
  final String lunch_menu;
  final String lunch_image;

  Lunch(
    {
      required this.lunch_id,
      required this.lunchcategory_id,
      required this.lunch_date,
      required this.lunch_menu,
      required this.lunch_image,
    }

  );
  factory Lunch.fromMap(Map<String, dynamic> map, String id){
    return Lunch(
      lunch_id: id, 
      lunchcategory_id: map['lunchcategory_id'] ?? "",
      lunch_date: (map['lunch_date']as Timestamp).toDate(),
      lunch_menu: map['lunch_menu'] ?? "", 
      lunch_image: map['lunch_image'] ?? "");
  }

}