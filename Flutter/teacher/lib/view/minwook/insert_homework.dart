/* 
Description : Homework 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';

class InsertHomework extends StatefulWidget {
  const InsertHomework({super.key});

  @override
  State<InsertHomework> createState() => _InsertHomeworkState();
}

class _InsertHomeworkState extends State<InsertHomework> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('숙제 입력'), centerTitle: true),
    );
  } // build
} // class