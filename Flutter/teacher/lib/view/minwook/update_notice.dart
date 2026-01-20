/* 
Description : Notice 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateNotice extends ConsumerStatefulWidget {
  const UpdateNotice({super.key});

  @override
  ConsumerState<UpdateNotice> createState() => _UpdateNoticeState();
}

class _UpdateNoticeState extends ConsumerState<UpdateNotice> {




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('공지 수정'), centerTitle: true),
      body: Center(),
    );
  }
}