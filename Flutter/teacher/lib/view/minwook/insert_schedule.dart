/* 
Description : Schedule 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:teacher/vm/minwook/drawer.dart';

class InsertSchedule extends StatefulWidget {
  const InsertSchedule({super.key});

  @override
  State<InsertSchedule> createState() => _InsertScheduleState();
}

class _InsertScheduleState extends State<InsertSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('학사일정'), centerTitle: true),
      drawer: AppDrawer(currentPage: widget),
    );
  } // build
} // class