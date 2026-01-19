import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/view/weather/weather.dart';
import 'package:student/vm/calendar_provider.dart';
import 'package:table_calendar/table_calendar.dart';

//  Calendar page
/*
  Created in: 18/01/2026 16:10
  Author: Chansol, Park
  Description:Calendar page
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          19/01/2026 14:15, 'Point 1, bottomNavigationBar', Creator: Chansol, Park
          19/01/2026 15:58, 'Point 2, Weather widget merged', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  ConsumerState<Calendar> createState() => _CalendarState();
}

class _CalendarState extends ConsumerState<Calendar> {
  int? tabIndex;
  String _calendarLocale(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return (lang == 'ko') ? 'ko_KR' : 'en_US';
  }

  List<DateTime> chosenWeek(DateTime cDate) {
    final DateTime monday = DateTime(
      cDate.year,
      cDate.month,
      cDate.day,
    ).subtract(Duration(days: cDate.weekday - 1));
    final DateTime sunday = monday.add(const Duration(days: 6));
    return [monday, sunday];
  }

  @override
  Widget build(BuildContext context) {
    final chosenDate = ref.watch(calendarDateProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //  Point 2
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: AnimatedColorButton(
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            child: Container(
              width: double.infinity,
              height: 420,
              decoration: BoxDecoration(
                color: Color(0xFFF3FAFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TableCalendar(
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: _calendarLocale(context),
                focusedDay: chosenDate,
                firstDay: DateTime(chosenDate.year, chosenDate.month, 1),
                lastDay: DateTime(chosenDate.year, chosenDate.month + 1, 0),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'month'},

                headerStyle: const HeaderStyle(
                  //  Title to center
                  titleCentered: true,
                  //  Block changing months
                  leftChevronVisible: false,
                  rightChevronVisible: false,
                  formatButtonVisible: false,
                ),

                calendarStyle: CalendarStyle(
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFDCD6FF),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(color: Colors.black),
                  todayDecoration: BoxDecoration(
                    color: Color(0xFFBFE9FF),
                    shape: BoxShape.circle,
                  ),
                ),

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(fontSize: 12),
                  weekendStyle: TextStyle(fontSize: 12, color: Colors.black),
                ),

                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final aDate = DateTime(day.year, day.month, day.day);

                    final List<DateTime> isWeek = chosenWeek(chosenDate);

                    final inWeek =
                        !aDate.isBefore(isWeek[0]) && !aDate.isAfter(isWeek[1]);

                    if (inWeek) {
                      return Container(
                        margin: const EdgeInsets.all(4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${day.day}'),
                      );
                    }
                  },
                  dowBuilder: (context, day) {
                    final text = [
                      '월',
                      '화',
                      '수',
                      '목',
                      '금',
                      '토',
                      '일',
                    ][day.weekday - 1];
                    final isSunday = day.weekday == DateTime.sunday;

                    return Center(
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSunday ? Colors.red : Colors.black,
                        ),
                      ),
                    );
                  },
                ),

                selectedDayPredicate: (day) => isSameDay(day, chosenDate),
                onDaySelected: (day, focusedDay) {
                  ref.read(calendarDateProvider.notifier).setSelectedDay(day);
                },
              ),
            ),
          ),
        ],
      ),

      //  Point 1
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
              (states) => const IconThemeData(color: Colors.blue),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) => const TextStyle(color: Colors.blue, fontSize: 12),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: NavigationBar(
              backgroundColor: Colors.white,
              animationDuration: Duration(seconds: 1),
              //  Point 2
              selectedIndex: tabIndex ?? 0,
              indicatorColor: Colors.transparent,
              onDestinationSelected: (i) => setState(() => tabIndex = i),
              destinations: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tabIndex == 0 ? Colors.amberAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: NavigationDestination(
                      icon: Icon(Icons.check_circle_outline),
                      label: '출석 확인',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tabIndex == 1 ? Colors.amberAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: NavigationDestination(
                      icon: Icon(Icons.north_east),
                      label: '조퇴 확인',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tabIndex == 2 ? Colors.amberAccent : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: NavigationDestination(
                      icon: Icon(Icons.location_on_outlined),
                      label: '외출 확인',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } //  build
} //  class
