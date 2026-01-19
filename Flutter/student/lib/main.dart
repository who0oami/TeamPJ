import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:student/view/calendar.dart';
import 'package:student/view/main_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('STEP 1');

  await initializeDateFormatting('ko_KR', null);
  debugPrint('STEP 2');

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
      
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: Calendar(),
    );
  }
}