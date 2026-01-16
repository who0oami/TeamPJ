import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/util/acolor.dart';

/* 
Description : 학생 메인페이지 구성
  1) 플로팅 버튼 구성
  2) 메인페이지 윤곽 구성
Date : 2026-1-15
Author : 상현
*/

class MainPage extends ConsumerStatefulWidget {// <<<<<<<<<<<<<<<<<<<
  MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 앱바 구성
        title: Text('ATTI'),
        centerTitle: true,
        backgroundColor: Acolor.primaryColor,
        foregroundColor: Acolor.onPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsetsGeometry.fromLTRB(10, 10, 10, 0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // 날씨 및 그날의 공지를 확인 할 수 있는 창
                decoration: BoxDecoration(
                  color: Acolor.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        // 날씨 페이지로 이동
                      },
                      icon: Icon(CupertinoIcons.sun_max),
                    ),
                    Text(
                      '오늘의 숙제가 있어요', // 나중에 데이터로 대체될 예정
                      style: TextStyle(color: Acolor.onPrimaryColor),
                    ), // 임시로 우선 디자인용
                  ],
                ),
              ), //날씨 및 그날의 공지를 확인 할 수 있는 컨테이너
              SizedBox(height: 15),
              Container(
                // 학생 정보를 파악 할 수 있는 곳
                decoration: BoxDecoration(
                  color: Acolor.baseBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200,
                width: 300,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.people, size: 120,color: Acolor.successBackColor,), // 사진으로 대체될 예정
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              // 학년 반 나타내는 텍스트
                              '두식초등학교',
                              style: TextStyle(
                                color: Acolor.onPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              // 학년 반 나타내는 텍스트
                              '2학년 3반 19번',
                              style: TextStyle(
                                color: Acolor.onPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              // 이름 나타내는 텍스트
                              '이상현',
                              style: TextStyle(
                                color: Acolor.onPrimaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 250,
                      child: ElevatedButton(// 출결 체크용 버튼
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Acolor.successBackColor,
                          foregroundColor: Acolor.successTextColor,
                        ),
                        onPressed: () {
                          // 출결처리 프로세스 진행
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.school),
                            Text('학교에 왔어요'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ), // 학생 정보파악용
            ],
          ),
        ),
      ),
      floatingActionButton: // 긴급호출 버튼 생성
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: FloatingActionButton(
              elevation: 5,
              backgroundColor: Acolor.errorBackgroundColor,
              foregroundColor: Acolor.errorTextColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Acolor.errorTextColor, width: 5),
              ),
              onPressed: () {
                // 긴급호출 페이지로 이동 예정
              },
              child: Text(
                '긴급호출',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  } // build
} // class
