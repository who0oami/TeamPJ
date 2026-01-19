import 'package:flutter/material.dart';
import 'package:student/util/acolor.dart';

/* 
Description : 학생 긴급 호출 화면
  - 1) 긴급 호출 이미지
  - 2) 길게 누르면 이미지 변경, 하단 텍스트 변경
      - 기본 이미지 , 기본 텍스트 설정
      - 변경하면서 현재 위치 전달 하기 
  - 3) notification
      - 틀린 경우 snackBar로 알림 띄워주기
Date : 2026-01-17
Author : 지현
*/

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  late String emergencyText; // 버튼 이미지
  late String buttonImage; // 버튼 이미지
  late Color appBarColor; // 앱바 컬러
  late Color bodyColor; // 바디 컬러

@override
  void initState() {
    super.initState();
    emergencyText = "위급한 상황에 꾸욱- 눌러주세요";
    buttonImage = "images/emergency.png";
    appBarColor = Acolor.baseBackgroundColor;
    bodyColor = Acolor.baseBackgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text(
              "긴급 호출",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold
              ),
              ),
            SizedBox(height: 20),
            GestureDetector(
              onLongPress: () {
                buttonChange();
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(buttonImage),
              ),
            ),
            SizedBox(height: 20),
            Text(
              emergencyText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 40),
            Text(
              "위급한 상황에만 눌러주세요",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue
              ),
            ),
          ],
        ),
      ),
    );
  } // build
  // ------ Functions -----
  buttonChange(){
    if(emergencyText == "위급한 상황에 꾸욱- 눌러주세요"){
      emergencyText = "현재 위치가 전달 되었습니다";
      appBarColor = Colors.green;
      bodyColor =Colors.yellow;
      buttonImage = "images/emergency_push.png";
    }else{
      emergencyText = "위급한 상황에 꾸욱- 눌러주세요";
      appBarColor = Colors.red;
      bodyColor = Colors.blue;
      buttonImage = "images/emergency.png";
    }  
    setState(() {});
  }
} // class