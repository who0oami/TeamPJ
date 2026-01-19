/*
Description : guardian 메인페이지구성 
Date : 2026-1-18
Author : 민재
*/



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:guardian/model/guardian.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/vm/minjae/guardian_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';


final selectedDayProvider = StateProvider<DateTime?>((ref) => DateTime.now());
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());

class GuardianMainPage extends ConsumerStatefulWidget {// <<<<<<<<<<<<<<<<<<<
  GuardianMainPage({super.key});

  @override
  ConsumerState<GuardianMainPage> createState() => _GuardianMainPageState();
}

class _GuardianMainPageState extends ConsumerState<GuardianMainPage> {
    
  
  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    // 날짜 포맷 (예: 2026.01.18 일요일)
   String formattedDate = DateFormat('yyyy.MM.dd EEEE', 'ko_KR').format(selectedDay ?? DateTime.now());
    final guardianAsync=ref.watch(guardianNotifierProvider);
    return Scaffold(
        drawer: Drawer(
  child: ListView(
    padding: EdgeInsets.zero,
    children: [
     
      UserAccountsDrawerHeader(
        accountName: const Text("pikachu"),
        accountEmail: const Text("pikachu@naver.com"),
        currentAccountPicture: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 40),
        ),
        decoration: const BoxDecoration(
          color: Colors.deepPurple,
        ),
      ),

      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("비밀번호 수정"),
        onTap: () {
          Navigator.pop(context); // Drawer 닫기
      
        },
      ),

      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text("시간표 조회"),
        onTap: () {
          Navigator.pop(context);
        },
      ),

      ListTile(
        leading: const Icon(Icons.notifications),
        title: const Text("학생 출결조회"),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.question_answer),
        title: const Text("선생님한테 문의하기"),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      ListTile(
        leading: const Icon(Icons.question_mark),
        title: const Text("공지조회"),
        onTap: () {
          Navigator.pop(context);
        },
      ),

      const Divider(),

      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          "로그아웃",
          style: TextStyle(color: Colors.red),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    ],
  ),
),

      backgroundColor: Acolor.baseBackgroundColor,
      appBar: AppBar(
        // 앱바 구성
        title: Text('ATTI'),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
        
      ),
    
      body: guardianAsync.when(
        data: (guardian) {
          return guardian.isEmpty
          ? const Center(child: Text("학생 정보가 없습니다"),)
          :ListView.builder(
            itemCount: guardian.length,
            itemBuilder: (context, index) {
              final g =guardian[index];
              return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
              
                width: 300,
                height: 200,
                decoration: BoxDecoration(border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
                boxShadow:[
                  BoxShadow(
                    color: Colors.white,//그림자 색상
                    spreadRadius: 2,// 그림자 퍼짐 정도
                    blurRadius: 5,// 그림자 흐림 정도
                    offset: Offset(0, 3)// 그림자 위치 (x, y) - 아래쪽으로 3
                  )
                ] ),
                
                
                 child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person,
                      size: 50,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("두식초등학교"),//나중에
                            Text("1학년 1반 1번 OOO학생 부모님"),//데이터
                            Text(g.guardian_name,//채워넣을거에여
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold
                            ),),
                          ],
                        ),
                      ),
                    ],
                  ),
                 ],),
              ),
              
                  Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(0, 20, 0, 0),
                    child: Text("오늘일정 $formattedDate"),
                  ),
                 _buildCalendar(ref, selectedDay, focusedDay),

                 Padding(
                   padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                   child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white
                    ),
                    onPressed: () {
                      
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.emergency_share_rounded),Text("학생위치 찾기")],)),
                 )
            ],
          ),
        
        ),
      );
            },);
        },
        error: (error, stackTrace) => Center(child: Text("Error: $error"),),
        loading: () => Center(child: CircularProgressIndicator(),),),
      // body: 
    );
  } // build

  Widget _buildCalendar(WidgetRef ref, DateTime? selectedDay, DateTime focusedDay) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Acolor.appBarBackgroundColor, blurRadius: 1)]),
      child: TableCalendar(
        locale: 'ko_KR',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (newSelectedDay, newFocusedDay) {
          ref.read(selectedDayProvider.notifier).state = newSelectedDay;
          ref.read(focusedDayProvider.notifier).state = newFocusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(color: Acolor.primaryColor, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Acolor.successBackColor, shape: BoxShape.circle),
        ),
      ),
      
    );
  }
} // class