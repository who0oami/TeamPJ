/* 
Description : Lunch 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:teacher/vm/minwook/drawer.dart';

class InsertLunch extends StatelessWidget {
  const InsertLunch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('급식표'), centerTitle: true),
      drawer: AppDrawer(currentPage: this),
    );
  } // build
} // class