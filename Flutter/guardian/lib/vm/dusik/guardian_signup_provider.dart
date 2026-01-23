import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guardian/model/guardian.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class GuardianSignUpNotifier extends AsyncNotifier<List<Guardian>> {
  final String baseUrl = "http://10.0.2.2:8000/dusik";
  final box = GetStorage();

  @override
  FutureOr<List<Guardian>> build() async {
    return [];
  }

  Future<String> signUpGuardi({
    required String name,
    required String email,
    required String pw,
    required String phone,
    required int studentId,
  }) async {
    final url = Uri.parse("$baseUrl/guardian_signup");
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      final bodyData = {
        "guardian_name": name,
        "guardian_email": email,
        "guardian_password": pw,
        "guardian_phone": phone,
        "student_id": studentId,
        "fcm_token": fcmToken ?? "", 
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bodyData),
      );
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['result'] == 'OK') {
          await box.write('student_id', studentId);
          return 'OK';
        } else {
          return data['message'] ?? data['result'] ?? 'Fail';
        }
      } else {
        return '서버 에러 (${response.statusCode})';
      }
    } catch (e) {
      print("SignUp 에러 발생: $e");
      return '네트워크 연결 오류';
    }
  }
}

final guardianSignUpNotifierProvider =
    AsyncNotifierProvider<GuardianSignUpNotifier, List<Guardian>>(
        GuardianSignUpNotifier.new);