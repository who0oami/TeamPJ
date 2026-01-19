import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherChatting extends ConsumerStatefulWidget {
  const TeacherChatting({super.key});

  @override
  ConsumerState<TeacherChatting> createState() => _TeacherChattingState();
}

class _TeacherChattingState extends ConsumerState<TeacherChatting> {

  late final TextEditingController chattingController;
  
  @override
  void initState() {
    super.initState();
    chattingController = TextEditingController();
  }

  @override
  void dispose() {
    chattingController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATTI'),
      ),
      body: Center(
        child: Row(
          children: [
            
          ],
        ),
      ),
    );
  }
}