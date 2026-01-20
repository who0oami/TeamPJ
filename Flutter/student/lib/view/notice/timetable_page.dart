/* 
Description : schedule page - 일단 페이지만 구성!
Date : 2026-1-20
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/model/timetable.dart';
import 'package:student/vm/sion/timetable_provider.dart';

class TimetablePage extends ConsumerStatefulWidget {
  const TimetablePage({super.key});

  @override
  ConsumerState<TimetablePage> createState() => _TimetableState();
}

class _TimetableState extends ConsumerState<TimetablePage> {
 
  final List<String> _days = ['월', '화', '수', '목', '금'];

  @override
  Widget build(BuildContext context) {
    final timetableAsync = ref.watch(timetableListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: timetableAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로드 에러: $err')),
        data: (timetables) {
          if (timetables.isEmpty) {
            return const Center(child: Text('등록된 시간표가 없습니다.'));
          }

          // 첫 번째 시간표 데이터 사용
          final timetable = timetables.first;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 5, blurRadius: 7),
                ],
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade200),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                // 💡 첫 번째 열(교시) 너비를 살짝 좁게 조절
                columnWidths: const {0: FixedColumnWidth(55)}, 
                children: _buildTableRows(timetable),
              ),
            ),
          );
        },
      ),
    );
  }

  // Table Row 생성 로직
  List<TableRow> _buildTableRows(Timetable tt) {
    final periodCount = (tt.timetable_period > 0) ? tt.timetable_period : 6;
    final rows = <TableRow>[];

    // 헤더 추가
    rows.add(_buildTableRow(['교시', ..._days], isHeader: true));

    // 교시별 데이터 행 추가
    for (int p = 0; p < periodCount; p++) {
      final cells = <String>[
        '${p + 1}', // '교시' 글자를 빼서 숫지만 깔끔하게 넣어도 좋아요
        ..._days.map((day) {
          final list = tt.timetable_table[day] ?? const <String>[];
          return (p < list.length) ? list[p] : '';
        }),
      ];
      rows.add(_buildTableRow(cells));
    }
    return rows;
  }

  // 개별 행 디자인
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
          child: Center(
            child: Text(
              cell,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                fontSize: isHeader ? 14 : 13,
                color: isHeader ? Colors.black87 : Colors.black54,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


  