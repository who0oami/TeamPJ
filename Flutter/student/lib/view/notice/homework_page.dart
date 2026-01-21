/* 
Description : homework page - firebase에 데이터 추출
Date : 2026-1-19
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:student/util/acolor.dart';
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
          // 2. 과목과 제목
         Row(
           children: [
            _buildSubjectTag(homework.homework_subject),
            const SizedBox(width: 12), 
            Text(
            homework.homework_title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ],
            ),
          const SizedBox(height: 12),
          // 3. 내용
          Text(
            homework.homework_contents,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 20),
          // 4. 사진
          ImageSlider(images:homework.homework_images),
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

// 과목 버튼 위젯
Widget _buildSubjectTag(String subject) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 안쪽 여백
    decoration: BoxDecoration(
      color: Acolor.primaryColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      subject,
      style: const TextStyle(
        color: Colors.white, // 글자색 흰색
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    ),
  );
}


class ImageSlider extends StatefulWidget {
  final List<String> images;

  const ImageSlider({super.key, required this.images});

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentPage = 0; // 현재 보고 있는 페이지 번호

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 이미지 슬라이더
          PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page; // 페이지 바뀔 때마다 상태 업데이트
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              );
            },
          ),
            
          // 2. 동적 인디케이터 (색상 변경 적용)
          Positioned(
            bottom: 15, // 위치를 살짝 위로 올림
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300), // 부드러운 전환 효과
                  width: _currentPage == index ? 12 : 8, // 선택된 점은 더 크게
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    // 선택된 점은 진한 색, 나머지는 반투명한 회색
                    color: _currentPage == index 
                        ? Acolor.successBackColor
                        : Colors.black26, 
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}


