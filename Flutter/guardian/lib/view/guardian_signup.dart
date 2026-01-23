import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/util/acolor.dart';
import 'package:guardian/util/message.dart';
import 'package:guardian/view/guardian_login.dart';
import 'package:guardian/vm/dusik/guardian_signup_provider.dart';

/* Description : 학부모 회원가입 페이지
  - 1) 입력값 검증 및 학생 번호 존재 확인
  - 2) 가입 성공 시 알림창 띄운 후 로그인 페이지로 이동
Date : 2026-01-23
Author : 지현
*/

class GuardianSignUpPage extends ConsumerStatefulWidget {
  const GuardianSignUpPage({super.key});

  @override
  ConsumerState<GuardianSignUpPage> createState() => _GuardianSignUpPageState();
}

class _GuardianSignUpPageState extends ConsumerState<GuardianSignUpPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController pwController;
  late TextEditingController phoneController;
  late TextEditingController studentIdController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    pwController = TextEditingController();
    phoneController = TextEditingController();
    studentIdController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    phoneController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  // ---- Functions ----
  void checkSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pw = pwController.text.trim();
    final phone = phoneController.text.trim();
    final studentIdStr = studentIdController.text.trim();

    // 1. 빈값 체크
    if ([name, email, pw, phone, studentIdStr].contains('')) {
      Message.snackBar(context, '모든 항목을 입력해주세요', 2, Colors.red);
      return;
    }

    // 2. 서버 통신
    final signUpNotifier = ref.read(guardianSignUpNotifierProvider.notifier);
    final result = await signUpNotifier.signUpGuardi(
      name: name,
      email: email,
      pw: pw,
      phone: phone,
      studentId: int.tryParse(studentIdStr) ?? 0,
    );

    // 3. 결과 처리
    if (result == 'OK') {
      if (!mounted) return;
      
      // Message.dialog에 함수인자(m)가 없으므로 직접 showDialog 호출
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('환영합니다!'),
            content: const Text('보호자 가입이 완료되었습니다.\n로그인 후 이용해주세요.'),
            backgroundColor: Colors.white,
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx); // 다이얼로그 닫기
                    // 로그인 페이지로 이동 (스택 제거)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const GuardianLogin()),
                      (route) => false,
                    );
                  },
                  child: const Text('확인'),
                ),
              ),
            ],
          );
        },
      );
    } else {
      if (!mounted) return;
      // 실패 시 서버에서 온 메시지(학생번호 없음 등) 출력
      Message.snackBar(context, result, 2, Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Acolor.appBarForegroundColor,
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: Acolor.appBarForegroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("images/head.png", width: 150),
              ),
              const Text("보호자 회원가입 정보 입력", style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInputField("이름", nameController, "이름을 입력하세요"),
                    _buildInputField("이메일", emailController, "이메일을 입력하세요"),
                    _buildInputField("비밀번호", pwController, "비밀번호를 입력하세요", isObscure: true),
                    _buildInputField("전화번호", phoneController, "전화번호를 입력하세요", 
                        isNum: true, 
                        formatters: [FilteringTextInputFormatter.digitsOnly, PhoneNumberFormatter()]),
                    _buildInputField("학생 번호", studentIdController, "학생 고유 번호를 입력하세요", isNum: true),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: checkSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Acolor.primaryColor,
                        foregroundColor: Acolor.onPrimaryColor,
                        fixedSize: const Size(200, 50),
                      ),
                      child: const Text('회원가입', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String hint, 
      {bool isObscure = false, bool isNum = false, List<TextInputFormatter>? formatters}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          TextField(
            controller: controller,
            obscureText: isObscure,
            keyboardType: isNum ? TextInputType.number : TextInputType.text,
            inputFormatters: formatters,
            decoration: InputDecoration(
              border: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
              labelText: hint,
              labelStyle: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    if (digits.length <= 3) formatted = digits;
    else if (digits.length <= 7) formatted = '${digits.substring(0, 3)}-${digits.substring(3)}';
    else if (digits.length <= 11) formatted = '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}