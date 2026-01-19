import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/util/message.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  // Property
  late TextEditingController phoneController; // Phone
  late TextEditingController pwController; // Password

  @override
  void initState() {
    super.initState();
    phoneController = TextEditingController();
    pwController = TextEditingController();
  }

  @override
  void dispose() {
    phoneController.dispose();
    pwController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text("로고 이미지")
            ),
            Text("로그인"),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '전화번호를 입력하세요'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: pwController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'PW를 입력하세요'
                      ),
                    ),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => checkLogin(), 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Acolor.primaryColor,
                    foregroundColor: Acolor.appBarBackgroundColor, 
                    fixedSize: Size(150, 20)
                    ),
                  child: Text(
                    '로그인 하기',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } // build
  // ---- Functions ----
   checkLogin(){
    if(phoneController.text.trim().isEmpty || pwController.text.trim().isEmpty){ // 둘 다 비어있는 경우
      // SnackBar 처리
      Message.snackBar(
      context,
      '전화번호와 비밀번호를 입력하세요',
      2,
      Colors.red,
    );
    }else{
      if(phoneController.text.trim() == 'root' && pwController.text.trim() == '1234'){// 조건이 다르니까 else로 써줘야 함
      // 정상적인 경우 Alert 출력
      Message.dialog(
      context,
      '환영합니다!',
      '오늘도 즐겁게 공부해보아요',
      Colors.white
      );

    }else{
      // SnackBar 처리
       Message.snackBar(
      context,
      '전화번호와 비밀번호를 확인해주세요',
      2,
      Colors.red,
    );
    }
  }
  }
} // class
