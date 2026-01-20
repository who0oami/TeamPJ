/* 
Description : Notice 상세 페이지
Date : 2026-1-20
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/view/minwook/update_notice.dart';
import 'package:teacher/vm/minwook/notice_provider.dart';
import 'package:teacher/vm/minwook/teacher_provider.dart';

class DetailNotice extends ConsumerWidget {
  final String id;
  const DetailNotice({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final noticeDetailAsync = ref.watch(noticeDetailProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(''), centerTitle: true),
      body: noticeDetailAsync.when(
        data: (noticeDetail) {
          final teacherNameAsync = ref.watch(teacherNameByIdProvider(noticeDetail!.teacher_id));
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(noticeDetail.notice_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        teacherNameAsync.when(
                          data: (data) => Text('작성자: $data', style: TextStyle(fontSize: 15)),
                          error: (error, stackTrace) => Text('$error'),
                          loading: () => CircularProgressIndicator(),
                        ),
                        Column(
                          children: [
                            Text(noticeDetail.notice_insertdate.toString().substring(0, 19), style: TextStyle(fontSize: 15)),
                            Visibility(
                              visible: noticeDetail.notice_updatedate == null ? false : true,
                              child: Text(noticeDetail.notice_updatedate == null ? '' : '(수정: ${noticeDetail.notice_updatedate.toString()})', style: TextStyle(fontSize: 15))
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Divider(thickness: 10),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          noticeDetail.notice_content
                        )
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateNotice(

                                  ),
                                )
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Acolor.successBackColor,
                              foregroundColor: Acolor.successTextColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(5)
                              )
                            ),
                            child: Text('수정')
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                //
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Acolor.errorBackgroundColor,
                                foregroundColor: Acolor.errorTextColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(5)
                                )
                              ),
                              child: Text('삭제')
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          loading: () => Center(child: CircularProgressIndicator()),
        )
      
    );
  }
}