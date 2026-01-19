/*
Description : 화면구성 작업
1. 학생 데이터만 연결해서 로그인 한 학생 데이터 임시로 1번으로 지정 해서 작업
2. 모든 파일 위젯으로 작업진행

Date : 2026-01-19
Author : 이상현
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:student/vm/sanghyun/student_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../util/acolor.dart';
import '../model/student.dart';

// 캘린더 관리 위해서 필요한 프로바이더
final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final studentAsync = ref.watch(studentFutureProvider);

    String formattedDate = DateFormat(
      'yyyy.MM.dd EEEE',
      'ko_KR',
    ).format(selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('ATTI'),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
      ),
      backgroundColor: Acolor.onPrimaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDateHeader(formattedDate),
            _buildProfileCard(studentAsync),
            _buildSectionTitle("오늘 일정"),
            _buildCalendar(ref, selectedDay, focusedDay),
            _buildSectionTitle("시간표"),
            _buildTimetable(),
            _buildSectionTitle("오늘 급식"),
            _buildMealGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildEmergencyButton(),
    );
  }

  // --- UI 구성 위젯들 ---

  Widget _buildDateHeader(String date) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Acolor.onPrimaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, color: Acolor.primaryColor, size: 40),
          const SizedBox(width: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(color: Colors.grey)),
              const Text(
                "오늘 숙제가 있어요!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AsyncValue<Student> studentAsync) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1),
          ],
        ),
        child: studentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('에러 발생: $err')),
          data: (student) => Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Acolor.successTextColor,
                    backgroundImage: MemoryImage(student.student_image),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "학생 정보",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      Text(
                        student.student_name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // 출석체크
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Acolor.successBackColor,
                    shape: const StadiumBorder(),
                  ),
                  child: Text("학교왔어요 😊",
                    style: TextStyle(
                      color: Acolor.successTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Acolor.appBarBackgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar(
    WidgetRef ref,
    DateTime? selectedDay,
    DateTime focusedDay,
  ) {
    // 캘린더 만들기
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 2),
        ],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          ref.read(selectedDayProvider.notifier).state = newSelectedDay;
          ref.read(focusedDayProvider.notifier).state = newFocusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Acolor.primaryColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Acolor.successBackColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildTimetable() {// 시간표 줄 추가
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey.shade200),
        children: [
          _buildTableRow(['','월','화','수','목','금',], isHeader: true), // 제일 상단
          _buildTableRow(['1교시', '국어', '사회', '과학', '국어', '도덕']),
          _buildTableRow(['2교시', '체육', '미술', '국어', '창체', '국어']),
          _buildTableRow(['3교시', '과학', '미술', '영어', '사회', '국어']),
          _buildTableRow(['4교시', '수학', '영어', '수학', '체육', '수학']),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    // 시간표
    return TableRow(
      children: cells
          .map(
            (cell) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  cell,
                  style: TextStyle(
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMealGrid() { // 급식표
    final List<String> meals = ['잡곡밥','미역국','미트볼','김치','미역줄기','요구르트']; // 임시로 더미 데이터 넣기
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: meals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Acolor.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              meals[index],
              style: TextStyle(
                color: Acolor.onPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmergencyButton() { // 긴급호출 버튼 위젯
    return SizedBox(
      width: 100,
      height: 100,
      child: FloatingActionButton(
        elevation: 8,
        backgroundColor: Acolor.errorBackgroundColor,
        foregroundColor: Acolor.onPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
        onPressed: () {
          // 긴급호출 페이지로 이동
        },
        child: const Text(
          '긴급\n호출',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
