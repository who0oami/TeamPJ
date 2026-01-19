/* 
Description : Homework 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';

class UpdateHomework extends StatefulWidget {
  const UpdateHomework({super.key});

  @override
  State<UpdateHomework> createState() => _UpdateHomeworkState();
}

class _UpdateHomeworkState extends State<UpdateHomework> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('숙제 수정'), centerTitle: true),
      body: Center(),
    );
  }
}