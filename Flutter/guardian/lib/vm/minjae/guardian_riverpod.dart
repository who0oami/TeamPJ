




import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/model/guardian.dart';
import 'package:http/http.dart' as http;
class GuardianNotifier extends AsyncNotifier<List<Guardian>>{
  final String baseUrl = "http://10.0.2.2:8000";

  
  @override
  FutureOr<List<Guardian>> build() async{
    return await fetchGuardian();
  }

  Future<List<Guardian>>fetchGuardian() async{
    final res =await http.get(Uri.parse("$baseUrl/minjae/select?guardian_id=1"));
      if(res.statusCode!=200){
        throw Exception("불러오기 실패: ${res.statusCode}");

      }
      final data=json.decode(utf8.decode(res.bodyBytes));
      return(data['results'] as List).map((d)=>Guardian.fromJson(d)).toList();

  }
   Future<void> refreshGuardian()async{
      state =const AsyncLoading();
      state =await AsyncValue.guard(() async=> await fetchGuardian());
  }

}
final guardianNotifierProvider =AsyncNotifierProvider(
  ()=> GuardianNotifier(),
);