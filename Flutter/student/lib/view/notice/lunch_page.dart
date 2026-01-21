/* 
Description : homework page - firebase에 데이터 추출
Date : 2026-1-21
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/vm/sion/lunch_provider.dart';
import 'package:student/vm/sion/lunch_time_provider.dart';

class LunchPage extends ConsumerStatefulWidget {
  const LunchPage({super.key});

  @override
  ConsumerState<LunchPage> createState() => _LunchState();
}

class _LunchState extends ConsumerState<LunchPage> {
  @override
  Widget build(BuildContext context) {
    final lunchAsync = ref.watch(lunchmenuListProvider);
    final lunchtimeAsync = ref.watch(lunchListProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: Row(
              children: [
                const Text(
                  "이번주 급식",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 15),
                Text(
                  "1월 21일 (수)", // 나중에 실제 날짜 데이터로 연결 가능
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          
          // 급식 리스트 (Grid 형태)
          Expanded(
            child: lunchAsync.when(
              data: (lunchList) {
                if (lunchList.isEmpty) {
                  return const Center(child: Text('등록된 식단이 없습니다.'));
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,          // 한 줄에 2개씩
                    mainAxisSpacing: 20,       // 세로 간격
                    crossAxisSpacing: 20,      // 가로 간격
                    childAspectRatio: 0.85,    // 카드 가로세로 비율
                  ),
                  itemCount: lunchList.length,
                  itemBuilder: (context, index) {
                    final menu = lunchList[index];
                    return _buildLunchItem(menu.lunch_menu_name, menu.lunch_menu_image);
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

  // 개별 급식 아이템 위젯 (시안 디자인 구현)
  Widget _buildLunchItem(String name, String imageUrl) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F), // 시안의 노란색 배경
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.contain, errorBuilder: (context, error, stack) => const Icon(Icons.restaurant, size: 50, color: Colors.white))
                  : const Icon(Icons.restaurant, size: 50, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF5D4037), // 시안의 갈색 텍스트 컬러 느낌
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}