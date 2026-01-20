import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/firebase_options.dart';
import 'package:teacher/view/chatting/teacher_chatting.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // 💡 앱 리스트를 먼저 확인하고, 비어있을 때만 초기화합니다.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // 💡 만약 여기서 [core/duplicate-app] 에러가 난다면, 
    // 이미 초기화된 것이므로 에러를 무시하고 진행합니다.
    debugPrint("Firebase initialization warning: $e");
  }

  runApp(
    ProviderScope(child: const MyApp())
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TeacherChatting(),
    );
  }
}