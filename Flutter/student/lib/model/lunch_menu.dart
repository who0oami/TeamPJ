/* 
Description : LunchMenu Model for Firebase
Date : 2026-1-19
Author : 황민욱
*/

class LunchMenu {
  String lunch_menu_id;
  String lunch_category_id;
  String lunch_menu_name;
  String lunch_menu_image;

  LunchMenu({
    required this.lunch_menu_id,
    required this.lunch_category_id,
    required this.lunch_menu_name,
    required this.lunch_menu_image
  });

  factory LunchMenu.fromMap(Map<String, dynamic> map, String id){
    return LunchMenu(
      lunch_menu_id: id,
      lunch_category_id: map['lunch_category_id'] ?? "",
      lunch_menu_name: map['lunch_menu_name'] ?? "",
      lunch_menu_image: (map['lunch_menu_image']) ?? ""
    );
  }

}