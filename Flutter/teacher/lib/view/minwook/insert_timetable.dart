/* 
Description : Timetable 입력 & 수정 페이지
Date : 2026-1-19
Author : 황민욱
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/model/timetable.dart';
import 'package:teacher/vm/minwook/drawer.dart';
import 'package:teacher/vm/minwook/timetable_provider.dart';

// 초기 상태 설정 (Stateless, 나중에 교체 예정)
final semesterProvider = StateProvider<String>((ref) => '2026-1');
final gradeProvider = StateProvider<int>((ref) => 1);
final classProvider = StateProvider<int>((ref) => 1);

class InsertTimetable extends ConsumerWidget {
  const InsertTimetable({super.key});

  // 임시 데이터 (교체 예정, 학기 제외하고 그냥 써도 됨)
  static const List<String> _days = ['월', '화', '수', '목', '금'];
  static const List<String> _semesters = ['2026-1', '2026-2'];
  static const List<int> _grades = [1, 2, 3, 4, 5, 6];
  static const List<int> _classes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semester = ref.watch(semesterProvider);
    final grade = ref.watch(gradeProvider);
    final classNum = ref.watch(classProvider);
    final ttAsync = ref.watch(
      timetableByFilterProvider((semester: semester, grade: grade, classNum: classNum)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('시간표'), centerTitle: true),
      drawer: AppDrawer(currentPage: this),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildFilterBar(ref),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ttAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (tt) {
                    if (tt == null) {
                      return const Center(child: Text('시간표 데이터가 없음'));
                    }
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Table(
                        border: TableBorder.all(color: Colors.grey.shade200),
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        children: _buildTableRows(tt),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  } // build

  // Widget ====================================

  // Dropdown 필터
  Widget _buildFilterBar(WidgetRef ref) {
    final semester = ref.watch(semesterProvider);
    final grade = ref.watch(gradeProvider);
    final classNum = ref.watch(classProvider);

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonFormField<String>(
              value: semester,
              decoration: const InputDecoration(
                labelText: '학기',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _semesters
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                ref.read(semesterProvider.notifier).state = v;
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonFormField<int>(
              value: grade,
              decoration: const InputDecoration(
                labelText: '학년',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: _grades
                  .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                ref.read(gradeProvider.notifier).state = v;
              },
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: DropdownButtonFormField<int>(
            value: classNum,
            decoration: const InputDecoration(
              labelText: '반',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: _classes
                .map((c) => DropdownMenuItem(value: c, child: Text('$c')))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              ref.read(classProvider.notifier).state = v;
            },
          ),
        ),
      ],
    );
  }

  // Table Row
  List<TableRow> _buildTableRows(Timetable tt) {
    final periodCount = (tt.timetable_period > 0) ? tt.timetable_period : 6;

    final rows = <TableRow>[];
    rows.add(_buildTableRow(['교시', ..._days], isHeader: true));

    // 교시 계산 (6교시)
    for (int p = 0; p < periodCount; p++) {
      final cells = <String>[
        '${p + 1}교시',
        ..._days.map((day) {
          final list = tt.timetable_table[day] ?? const <String>[];
          return (p < list.length) ? list[p] : '';
        }),
      ];
      rows.add(_buildTableRow(cells));
    }
    return rows;
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Center(
            child: Text(
              cell,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
} // class