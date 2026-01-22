import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:teacher/model/teacher.dart';

class TeacherLoginNotifier extends AsyncNotifier<List<Teacher>>{
  final String baseUrl = "http://127.0.0.1:8000/dusik";

  @override // 함수 수정해서 쓰는게 override
  FutureOr<List<Teacher>> build() async{
    return await fetchTeachers(); // 만들어지자마자 fetch함
  }

  List<Teacher> teachers = [];
  bool isLoading = false;
  String? error;


  Future<List<Teacher>> fetchTeachers() async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/select"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Teacher.fromJson(d)).toList();
  }

   Future<List<Teacher>> loginTeachers(String email) async{ 
  //   isLoading = true;
  //   error = null; try - catch 방법에서 수정
    final res = await http.get(Uri.parse("$baseUrl/student_login"));

    if(res.statusCode != 200){
      throw Exception('불러오기 실패: ${res.statusCode}');
    }

    final data = json.decode(utf8.decode(res.bodyBytes));
    return (data['results'] as List).map((d) => Teacher.fromJson(d)).toList(); // 차이점: list로 return
  }

  Future<String> insertTeachers(Teacher t)async{
    final url = Uri.parse("$baseUrl/insert");
    final response = await http.post(
      url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(t.toJson()),
      );
    final data = json.decode(utf8.decode(response.bodyBytes));
    await refreshTeachers();
    return data['result'];
  }

  Future<String> loginTeacher(String email, String password) async {
    final url = Uri.parse("$baseUrl/teacher_login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'teacher_email': email,
        'teacher_password': password,
      }),
    );
    final data = json.decode(utf8.decode(response.bodyBytes));
    if (data.toString().contains('Fail') || data.toString().contains('Error')) {
    return 'FAIL';
  } 
  if (data is List && data.isNotEmpty) {
    return data[0]['teacher_id'].toString();
    
  }
  return 'FAIL';
}

  Future<void> refreshTeachers() async{
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchTeachers()); // null 데이터 체크
  }

} // StudentNotifier

final teacherLoginNotifierProvider = AsyncNotifierProvider<TeacherLoginNotifier, List<Teacher>>(
  TeacherLoginNotifier.new
);
