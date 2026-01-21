/*
Description : teacher 메인페이지구성 (Decorated UI + Drawer DB 연동)
Date : 2026-1-18
Author : 민재
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:teacher/util/acolor.dart';
import 'package:teacher/vm/minjae/teacher_riverpod.dart';
import 'package:teacher/vm/minjae/meal_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:teacher/model/timetable.dart';
import 'package:teacher/vm/minjae/timetable_riverpod.dart';

final selectedDayProvider =
    StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

class TeacherMainPage extends ConsumerStatefulWidget {
  const TeacherMainPage({super.key});

  @override
  ConsumerState<TeacherMainPage> createState() =>
      _TeacherMainPageState();
}

class _TeacherMainPageState
    extends ConsumerState<TeacherMainPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    final formattedDate = DateFormat(
      'yyyy.MM.dd EEEE',
      'ko_KR',
    ).format(selectedDay ?? DateTime.now());

    final teacherAsync = ref.watch(teacherNotifierProvider);
    final timetableAsync = ref.watch(timetableListProvider);
    final lunchmenuAsync = ref.watch(lunchmenuListProvider);

    return Scaffold(
      /// ================= Drawer =================
      drawer: Drawer(
        child: Consumer(
          builder: (context, ref, _) {
            final teacherAsync =
                ref.watch(teacherNotifierProvider);

            return teacherAsync.when(
              data: (teachers) {
                if (teachers.isEmpty) {
                  return const SizedBox();
                }
                final t = teachers.first;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    UserAccountsDrawerHeader(
                      accountName: Text(t.teacher_name),
                      accountEmail: Text(t.teacher_email),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          "http://10.0.2.2:8000/minjae/view/${t.teacher_id}",
                        ),
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.deepPurple,
                      ),
                    ),

                    _drawerItems(context),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) =>
                  Center(child: Text("오류: $e")),
            );
          },
        ),
      ),

      backgroundColor: Acolor.baseBackgroundColor,

      appBar: AppBar(
        title: const Text('ATTI'),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
        elevation: 0,
      ),

      /// ================= Body =================
      body: teacherAsync.when(
        data: (teachers) {
          return timetableAsync.when(
            data: (timetables) {
              return lunchmenuAsync.when(
                data: (menus) {
                  final t = teachers.first;
                  final timetable = timetables.first;

                  return ListView(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 40),
                    children: [
                      /// ===== 상단 웰컴 카드 =====
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Acolor.primaryColor,
                                Acolor.primaryColor
                                    .withOpacity(0.8),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage:
                                    NetworkImage(
                                  "http://10.0.2.2:8000/minjae/view/${t.teacher_id}",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    const Text(
                                      "두식초등학교 · 1학년 1반",
                                      style: TextStyle(
                                          color:
                                              Colors.white70),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${t.teacher_name} 선생님",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle("오늘 일정"),
                      Center(child: Text(formattedDate)),

                      const SizedBox(height: 12),

                      _buildCalendar(
                          ref, selectedDay, focusedDay),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.redAccent,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        30),
                              ),
                            ),
                            onPressed: () {},
                            icon: const Icon(
                                Icons.location_on),
                            label: const Text(
                              "학생 위치 찾기",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      _sectionTitle("오늘의 시간표"),
                      _buildTimeTable(timetable),

                      const SizedBox(height: 24),

                      _sectionTitle("오늘의 급식"),
                      _buildMealGrid(menus),
                    ],
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text("급식 오류: $e")),
              );
            },
            loading: () => const Center(
                child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text("시간표 오류: $e")),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("오류: $e")),
      ),
    );
  }

  /// ================= Drawer Items =================
  Widget _drawerItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text("비밀번호 수정"),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.how_to_reg),
          title: const Text("학생 출결 조회"),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.edit_calendar),
          title: const Text("학생 출결 수정"),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text("시간표 조회"),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.edit_note),
          title: const Text("시간표 수정"),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.restaurant_menu),
          title: const Text("급식표 조회"),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text("급식표 수정"),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.campaign),
          title: const Text("공지 조회"),
          onTap: () => Navigator.pop(context),
        ),
        ListTile(
          leading:
              const Icon(Icons.edit_notifications),
          title: const Text("공지 작성 / 수정"),
          onTap: () => Navigator.pop(context),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout,
              color: Colors.red),
          title: const Text(
            "로그아웃",
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  /// ================= Section Title =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ================= Calendar =================
  Widget _buildCalendar(
      WidgetRef ref, DateTime? selectedDay, DateTime focusedDay) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: focusedDay,
          headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true),
          selectedDayPredicate: (day) =>
              isSameDay(selectedDay, day),
          onDaySelected:
              (newSelectedDay, newFocusedDay) {
            ref.read(selectedDayProvider.notifier)
                .state = newSelectedDay;
            ref.read(focusedDayProvider.notifier)
                .state = newFocusedDay;
          },
        ),
      ),
    );
  }

  // ================= TimeTable =================
  Widget _buildTimeTable(Timetable timetable) {
    final table = timetable.timetable_table;
    final days = ['월', '화', '수', '목', '금'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Table(
        border: TableBorder.all(
            color: Colors.black),
        children: [
          TableRow(
            children: [
              _cell(''),
              ...days.map(_cell).toList(),
            ],
          ),
          for (int i = 0;
              i < timetable.timetable_period;
              i++)
            TableRow(
              children: [
                _cell('${i + 1}교시',
                    isHeader: true),
                ...days.map((day) {
                  final list = table[day] ?? [];
                  return _cell(
                      i < list.length
                          ? list[i]
                          : '');
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(String text,
      {bool isHeader = false}) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  // ================= Meal =================
  Widget _buildMealGrid(List menus) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: menus.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 140,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (_, index) {
          final menu = menus[index];
          return Container(
            decoration: BoxDecoration(
              color: Acolor.primaryColor,
              borderRadius:
                  BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Image.network(
                  menu.lunch_menu_image,
                  height: 60,
                ),
                const SizedBox(height: 8),
                Text(
                  menu.lunch_menu_name,
                  style: TextStyle(
                    color:
                        Acolor.onPrimaryColor,
                    fontWeight:
                        FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
