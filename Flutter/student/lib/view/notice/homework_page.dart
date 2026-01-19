import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:student/vm/sion/homework_provider.dart';

class HomeworkPage extends ConsumerStatefulWidget {
  const HomeworkPage({super.key});

   @override
  ConsumerState<HomeworkPage> createState() => _HomeworkState();
}

class _HomeworkState extends ConsumerState<HomeworkPage>{

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(homeworkListProvider);

    return Scaffold(

      
      body: Column(
        
        children: [

          Expanded(
          child: homeworkAsync.when(
            data: (noticeList) {
              if (noticeList.isEmpty) {
                return const Center(child: Text('숙제가 없습니다.'));
              }
          
              return ListView.builder(
                itemCount: noticeList.length + 1, // 하단 안내문구를 위해 +1
                itemBuilder: (context, index) {
                  // 마지막 아이템은 "모두 조회했습니다" 문구 표시
                  if (index == noticeList.length) {
                    return _buildFooter();
                  }
          
                  final notice = noticeList[index];
                  return _buildNoticeCard(notice);
                },
              );
            },
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
        ],
        
      ),
    );
  }

  // 숙제 카드 디자인 위젯
  Widget _buildNoticeCard(homework) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // 카드 사이의 간격
      color: Colors.white, // 카드 배경색
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE0E0E0),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "정시온 선생님", // 나중에 데이터 연결 가능
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    DateFormat('yy.MM.dd E요일', 'ko_KR').format(homework.homework_insertdate),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 2. 제목
          Text(
            homework.homework_title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // 3. 내용
          Text(
            homework.homework_contents,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          // 4. 사진
         Image.network(
                homework.homework_images[0], // 리스트의 첫 번째 이미지 표시
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 하단 안내 문구 위젯
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.check_circle_outline, color: Colors.grey, size: 30),
          SizedBox(height: 8),
          Text(
            "최근 공지사항을 모두 조회했습니다.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}


