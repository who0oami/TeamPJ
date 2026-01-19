/* 
Description : Notice 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/notice.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';

class InsertNotice extends ConsumerStatefulWidget {
  const InsertNotice({super.key});

  @override
  ConsumerState<InsertNotice> createState() => _InsertNoticeState();
}

class _InsertNoticeState extends ConsumerState<InsertNotice> {

  @override
  Widget build(BuildContext context) {

    final noticeAsync = ref.watch(noticeListProvider);
    final noticeAction = ref.read(noticeActionProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(title: Text('공지 입력'), centerTitle: true),
      body: Center(),
    );
  } // build
} // class