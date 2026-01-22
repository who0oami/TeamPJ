import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:teacher/model/teacher.dart';

class TeacherNotifier extends AsyncNotifier<List<Teacher>> {
  final String baseUrl = "http://10.0.2.2:8000";
  final box = GetStorage();

  @override
  FutureOr<List<Teacher>> build() async {
    return await fetchTeacher();
  }

  Future<List<Teacher>> fetchTeacher() async {
    try {
      final teacherId = box.read('teacher_id');

      if (teacherId == null) {
        print('⚠️ 저장된 teacher_id 없음');
        return [];
      }

      final res = await http.get(
        Uri.parse(
          "$baseUrl/minjae/select/teacher?teacher_id=$teacherId",
        ),
      );

      if (res.statusCode != 200) {
        throw Exception("불러오기 실패: ${res.statusCode}");
      }

      final data = json.decode(utf8.decode(res.bodyBytes));
      final results = data['results'];

      if (results == null || results is! List) {
        return [];
      }

      return results.map((e) => Teacher.fromJson(e)).toList();
    } catch (e) {
      print("에러 발생: $e");
      return [];
    }
  }

  Future<void> refreshTeacher() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await fetchTeacher());
  }
}

final teacherNotifierProvider =
    AsyncNotifierProvider<TeacherNotifier, List<Teacher>>(
  TeacherNotifier.new,
);
