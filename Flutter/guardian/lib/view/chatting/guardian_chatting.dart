import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guardian/vm/minjae/guardian_riverpod.dart';
import 'package:intl/intl.dart';

final guardianChatCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instance.collection('chatting'),
);

final guardianChatStreamProvider =
    StreamProvider.autoDispose.family<List<Map<String, dynamic>>, int>((ref, guardianId) {
  final col = ref.watch(guardianChatCollectionProvider);
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            DateTime date;
            if (d['chatting_date'] is Timestamp) {
              date = (d['chatting_date'] as Timestamp).toDate();
            } else if (d['chatting_date'] is String) {
              date = DateTime.tryParse(d['chatting_date']) ?? DateTime.now();
            } else {
              date = DateTime.now();
            }

            final String contents =
                (d['chatting_contents'] ?? d['chatting_content'] ?? '').toString();
            return {
              'contents': contents,
              'isMe': d['teacher_id'] == null,
              'date': date,
            };
          }).toList());
});

class GuardianChatting extends ConsumerStatefulWidget {
  const GuardianChatting({
    super.key,
    this.guardianId,
    this.studentId,
    this.categoryId = 1,
  });

  final int? guardianId;
  final int? studentId;
  final int categoryId;

  @override
  ConsumerState<GuardianChatting> createState() => _GuardianChattingState();
}

class _GuardianChattingState extends ConsumerState<GuardianChatting> {
  final TextEditingController _textController = TextEditingController();

  int? _resolveGuardianId(List<dynamic> guardians) {
    if (widget.guardianId != null) return widget.guardianId;
    if (guardians.isEmpty) return null;
    final g = guardians.first;
    return g.guardian_id;
  }

  int? _resolveStudentId(List<dynamic> guardians) {
    if (widget.studentId != null) return widget.studentId;
    if (guardians.isEmpty) return null;
    final g = guardians.first;
    return g.student_id;
  }

  Future<void> _send(int guardianId, int studentId) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    debugPrint(
      '📨 send called: guardianId=$guardianId studentId=$studentId text="$text"',
    );

    _textController.clear();
    final col = ref.read(guardianChatCollectionProvider);
    debugPrint(
      '📡 Firestore project: ${FirebaseFirestore.instance.app.options.projectId}',
    );
    try {
      debugPrint('⏳ Firebase 저장 시도');
      final doc = await col
          .add({
        'category_id': widget.categoryId,
        'chatting_contents': text,
        'chatting_content': text,
        'chatting_date': FieldValue.serverTimestamp(),
        'guardian_id': guardianId,
        'student_id': studentId,
        'teacher_id': null,
        'chatting_image': "",
        'chatting_read_date': null,
      })
          .timeout(const Duration(seconds: 10));
      debugPrint("✅ Firebase 저장 성공: ${doc.id}");
    } catch (e) {
      debugPrint("❌ Firebase 저장 에러: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전송 실패: $e')),
        );
      }
    } finally {
      debugPrint('✅ 전송 처리 완료');
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardianAsync = ref.watch(guardianNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('선생님과의 채팅'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: guardianAsync.when(
        data: (guardians) {
          final guardianId = _resolveGuardianId(guardians);
          final studentId = _resolveStudentId(guardians);
          if (guardianId == null || studentId == null) {
            return const Center(child: Text('학부모 정보가 없습니다.'));
          }

          final chatData = ref.watch(guardianChatStreamProvider(guardianId));
          final guardian = guardians.isEmpty ? null : guardians.first;

          return LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth >= 900;
              final double maxWidth = isTablet ? 720 : double.infinity;

              final content = Column(
                children: [
                  const Divider(height: 1),
                  Expanded(
                    child: chatData.when(
                      data: (msgs) => ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: msgs.length,
                        itemBuilder: (ctx, idx) {
                          final m = msgs[idx];
                          return _buildBubble(m['contents'], m['date'], m['isMe']);
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text('에러: $e')),
                    ),
                  ),
                  _buildInputBar(guardianId, studentId),
                ],
              );

              if (!isTablet) return content;
              return Row(
                children: [
                  SizedBox(
                    width: 320,
                    child: _buildSidebar(context, guardian, guardianId, studentId),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: content,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('학부모 정보 로드 실패: $e')),
      ),
    );
  }

  Widget _buildSidebar(
    BuildContext context,
    dynamic guardian,
    int guardianId,
    int studentId,
  ) {
    final String guardianName = guardian?.guardian_name?.toString() ?? '이름 없음';
    final String now = DateFormat('yyyy.MM.dd EEE', 'ko_KR').format(DateTime.now());

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            '선생님에게 문의',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guardianName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'guardian_id: $guardianId / student_id: $studentId',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                now,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '채팅 안내',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '문의 내용을 남기면 선생님과 실시간으로 대화할 수 있어요.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String contents, DateTime date, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Text(
              DateFormat('a h:mm').format(date),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFF7D060) : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              contents,
              style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe)
            Text(
              DateFormat('a h:mm').format(date),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(int guardianId, int studentId) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _send(guardianId, studentId),
            ),
          ),
          IconButton(
            onPressed: () => _send(guardianId, studentId),
            icon: const Icon(Icons.send, color: Color(0xFFF7D060), size: 30),
          ),
        ],
      ),
    );
  }
}
