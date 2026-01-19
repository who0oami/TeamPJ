import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:student/model/student.dart';

/*
Description : 학생 정보 서버에서 가져오는 기능 적용

Date : 2026-01-19
Author : 이상현
*/

// 학생 정보를 서버에서 가져오는 Provider
final studentFutureProvider = FutureProvider<Student>((ref) async {
  final url = 'http://127.0.0.1:8000/sanghyun/student/1';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);

    // String 이미지를 Uint8List로 변환
    if (data['student_image'] != null && data['student_image'] is String) {
      data['student_image'] = base64Decode(data['student_image']);
    }

    return Student.fromJson(data);
  } else {
    throw Exception('데이터 로드 실패: ${response.statusCode}');
  }
});
