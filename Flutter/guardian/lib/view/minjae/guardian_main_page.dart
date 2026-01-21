import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/vm/minjae/guardian_riverpod.dart';
import 'package:guardian/vm/minjae/meal_riverpod.dart';
import 'package:guardian/vm/minjae/schedule_riverpod.dart';
import 'package:guardian/vm/timetable_riverpod.dart';
import 'package:guardian/model/schedule.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:guardian/model/timetable.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class GuardianMainPage extends ConsumerStatefulWidget {
  GuardianMainPage({super.key});

  @override
  ConsumerState<GuardianMainPage> createState() => _GuardianMainPageState();
}

class _GuardianMainPageState extends ConsumerState<GuardianMainPage> {
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    String formattedDate = DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(selectedDay ?? DateTime.now());

    final guardianAsync = ref.watch(guardianNotifierProvider);
    final timetableAsync = ref.watch(timetableListProvider);
    final lunchmenuAsync = ref.watch(lunchmenuListProvider);

    return guardianAsync.when(
      data: (guardians) {
        final g = guardians.first;
        return Scaffold(
          backgroundColor: Acolor.baseBackgroundColor,
          appBar: AppBar(
            title: const Text('ATTI'),
            centerTitle: true,
            backgroundColor: Acolor.primaryColor,
            foregroundColor: Acolor.onPrimaryColor,
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(g.guardian_name),
                  accountEmail: Text(g.guardian_email ?? ""),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40),
                  ),
                  decoration: BoxDecoration(color: Acolor.primaryColor),
                ),
                _drawerItem(Icons.person, "비밀번호 수정"),
                _drawerItem(Icons.calendar_today, "시간표 조회"),
                _drawerItem(Icons.notifications, "학생 출계조회"),
                _drawerItem(Icons.question_answer, "선생님한테 문의하기"),
                _drawerItem(Icons.announcement, "공지조회"),
                const Divider(),
                _drawerItem(Icons.logout, "로그아웃", color: Colors.red),
              ],
            ),
          ),
          body: timetableAsync.when(
            data: (timetables) {
              return lunchmenuAsync.when(
                data: (menus) {
                  final timetable = timetables.firstWhere(
                    (t) => t.timetable_grade == 1 && t.timetable_class == 1,
                    orElse: () => Timetable(
                      timetable_id: '',
                      timetable_table: {},
                      timetable_semester: '2026-1',
                      timetable_period: 6,
                      timetable_grade: 1,
                      timetable_class: 1,
                    ),
                  );

                  return ListView(
                    children: [
                      _guardianCard(g.guardian_name),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("오늘일정 $formattedDate", textAlign: TextAlign.center),
                      ),
                      _buildCalendar(ref, selectedDay, focusedDay),
                      _buildScheduleList(ref),
                      _buildLocationButton(),
                      _buildTimeTable(timetable),
                      _buildMealGrid(menus),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("급식 데이터 오류: $e")),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text("시간표 로드 오류: $e")),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("오류: $e")),
    );
  }

  Widget _drawerItem(IconData icon, String title, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(title, style: TextStyle(color: color ?? Colors.black87)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _guardianCard(String name) {
    return Center(
      child: Container(
        width: 300,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Acolor.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 50),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("두식초등학교"),
                      const Text("1학년 1번 OOO학생 보호자"),
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(WidgetRef ref, DateTime? selectedDay, DateTime focusedDay) {
    final scheduleMap = ref.watch(scheduleMapProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1)],
      ),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          ref.read(selectedDayProvider.notifier).state = newSelectedDay;
          ref.read(focusedDayProvider.notifier).state = newFocusedDay;
        },
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return scheduleMap[key] ?? [];
        },
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: Acolor.primaryColor, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Acolor.successBackColor, shape: BoxShape.circle),
          markerDecoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildScheduleList(WidgetRef ref) {
    final schedules = ref.watch(scheduleMapProvider);
    final selectedDate = ref.watch(selectedDayProvider);
    final key = DateTime(selectedDate!.year, selectedDate.month, selectedDate.day);
    final todaySchedules = schedules[key] ?? [];

    if (todaySchedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("오늘은 등록된 일정이 없습니다", textAlign: TextAlign.center),
      );
    }

    return Column(
      children: todaySchedules.map((s) {
        final timeStr = DateFormat('HH:mm').format(s.schedule_startdate);
        return ListTile(
          leading: const Icon(Icons.event),
          title: Text(s.schedule_title),
          subtitle: Text("$timeStr - ${s.schedule_contents}"),
        );
      }).toList(),
    );
  }

  Widget _buildLocationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Acolor.errorBackgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emergency_share_rounded),
            SizedBox(width: 8),
            Text("학생 위치 찾기"),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTable(Timetable timetable) {
    final Map<String, List<String>> table = timetable.timetable_table;
    List<String> days = ['월', '화', '수', '목', '금'];
    final int maxPeriod = timetable.timetable_period;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {0: FixedColumnWidth(60)},
        children: [
          TableRow(
            children: [
              _cell(''),
              ...days.map((d) => _cell(d)).toList(),
            ],
          ),
          for (int i = 0; i < maxPeriod; i++)
            TableRow(
              children: [
                _cell('${i + 1}교시', isHeader: true),
                ...days.map((day) {
                  final subjects = table[day] ?? [];
                  return _cell(i < subjects.length ? subjects[i] : '');
                }).toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cell(String text, {bool isHeader = false}) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      color: isHeader ? Colors.blue.shade50 : null,
      child: Text(
        text,
        style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
      ),
    );
  }

  Widget _buildMealGrid(List menus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menus.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 130,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return Container(
            decoration: BoxDecoration(
              color: Acolor.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    menu.lunch_menu_image,
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  menu.lunch_menu_name,
                  style: TextStyle(
                    color: Acolor.onPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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