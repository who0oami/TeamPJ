/* 
Description : Notice 목록 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/notice.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';

class ViewNotice extends ConsumerStatefulWidget {
  const ViewNotice({super.key});

  @override
  ConsumerState<ViewNotice> createState() => _ViewNoticeState();
}

class _ViewNoticeState extends ConsumerState<ViewNotice> {
  
  @override
  Widget build(BuildContext context) {

    final noticeAsync = ref.watch(noticeListProvider);
    final noticeAction = ref.read(noticeActionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text('공지 목록'), centerTitle: true),
      body: noticeAsync.when(
        data: (noticeList) => noticeList.isEmpty
          ? Center(child: Text('공지가 없습니다.'))
          : ListView.builder(
            itemCount: noticeList.length,
            itemBuilder: (context, index) {
              Notice notice = noticeList[index];
              return ListTile(
                title: Text(''),
              );
            },
          ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  } // build
} // class