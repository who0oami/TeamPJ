/* 
Description : Lunchcategory 테이블 구성
Date : 2026-1-16
Author : 시온
*/


class Lunchcategory{
    final String lunch_category_id;
    final String lunch_category_name;

    Lunchcategory(
      {
        required this.lunch_category_id,
        required this.lunch_category_name,
      }
    );
  factory Lunchcategory.fromMap(Map<String, dynamic> map, String id){
    return Lunchcategory(
      lunch_category_id: id, 
      lunch_category_name: map['lunch_category_name'] ?? ""
      );
  }
}