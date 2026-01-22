import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io' show File, Platform;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:teacher/app_keys.dart';
import 'package:teacher/vm/sanghyun/chatting_provider.dart';

// --- [Providers] ---

String _readableText(dynamic value, String fallback) {
  final String s = (value ?? '').toString().trim();
  return s.isEmpty ? fallback : s;
}

// 1. MySQL 가디언/학생/카테고리 목록 로더
final chatTargetProvider = FutureProvider<List<dynamic>>((ref) async {
  final String host = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  final String url = 'http://$host:8000/sanghyun/chat_list';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('MySQL 서버 연결 확인 필요: $e');
  }
});

// 1-1. 카테고리 목록 로더 (MySQL)
final categoryProvider = FutureProvider<Map<int, String>>((ref) async {
  final String host = Platform.isAndroid ? "10.0.2.2" : "127.0.0.1";
  final String url = 'http://$host:8000/sanghyun/categories';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
    final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
    final Map<int, String> map = {};
    for (final item in data) {
      final id = item['category_id'];
      final title = item['category_title'];
      if (id is int && title is String) {
        map[id] = title;
      } else if (id != null && title != null) {
        map[int.parse(id.toString())] = title.toString();
      }
    }
    return map;
  } catch (e) {
    throw Exception('카테고리 로드 실패: $e');
  }
});

// 2-1. guardian_id 기준 최신 채팅의 category_id 로더 (Firebase)
final latestCategoryIdProvider = StreamProvider.family<int?, int>((ref, guardianId) {
  final col = ref.watch(chattingCollectionProvider);
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: true)
      .limit(1)
      .snapshots()
      .map((snap) {
        if (snap.docs.isEmpty) return null;
        final data = snap.docs.first.data() as Map<String, dynamic>;
        final id = data['category_id'];
        if (id is int) return id;
        if (id == null) return null;
        return int.tryParse(id.toString());
      });
});

// 3. 현재 선택된 문의 대상 정보
final selectedInquiryProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// 4. 실시간 채팅 스트림 (Firebase)
final chatStreamProvider = StreamProvider.autoDispose((ref) {
  final inquiry = ref.watch(selectedInquiryProvider);
  if (inquiry == null) return Stream.value([]);
  
  final col = ref.watch(chattingCollectionProvider);
  final int? guardianId = int.tryParse(inquiry['guardian_id'].toString());
  if (guardianId == null) return Stream.value([]);
  
  return col
      .where('guardian_id', isEqualTo: guardianId)
      .orderBy('chatting_date', descending: false)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            DateTime date = (d['chatting_date'] is Timestamp) 
                ? (d['chatting_date'] as Timestamp).toDate() 
                : DateTime.now();
            final String contents =
                (d['chatting_contents'] ?? d['chatting_content'] ?? '').toString();
            final String imageUrl = (d['chatting_image'] ?? '').toString();
            return {
              'contents': contents,
              'imageUrl': imageUrl,
              'isTeacher': d['teacher_id'] != null,
              'date': date,
            };
          }).toList());
});

// --- [Main View] ---

class TeacherChatting extends ConsumerWidget {
  const TeacherChatting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // 왼쪽 목록 (MySQL 데이터)
          SizedBox(width: 400, child: _buildSidebar(ref)),
          const VerticalDivider(width: 1, color: Color(0xFFEEEEEE)),
          // 오른쪽 채팅 (Firebase 데이터)
          const Expanded(child: _ChatDetailView()),
        ],
      ),
    );
  }

  Widget _buildSidebar(WidgetRef ref) {
    final listAsync = ref.watch(chatTargetProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final selectedInquiry = ref.watch(selectedInquiryProvider);

    return Column(
      children: [
        const SizedBox(height: 60),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('문의 내역', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                ref.invalidate(chatTargetProvider);
                ref.invalidate(categoryProvider);
                ref.invalidate(selectedInquiryProvider);
                ref.invalidate(chatStreamProvider);
              },
              icon: const Icon(Icons.refresh),
              tooltip: '새로고침',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: listAsync.when(
            data: (items) => categoriesAsync.when(
              data: (categoryMap) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, idx) {
                final item = items[idx];
                final bool isSelected = selectedInquiry?['guardian_id'] == item['guardian_id'];
                final int? guardianId = int.tryParse(item['guardian_id'].toString());
                final String studentName = _readableText(
                  item['student_name'] ?? item['guardian_name'],
                  '이름 없음',
                );
                final categoryIdAsync = guardianId == null
                    ? const AsyncValue<int?>.data(null)
                    : ref.watch(latestCategoryIdProvider(guardianId));
                Uint8List? img;
                if (item['student_image'] != null) img = base64Decode(item['student_image']);

                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: const Color(0xFFFFF9E6),
                    onTap: () => ref.read(selectedInquiryProvider.notifier).state = item,
                    leading: CircleAvatar(
                      backgroundImage: img != null ? MemoryImage(img) : null,
                      child: img == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(
                      '$studentName 학부모님',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    // Firebase category_id -> MySQL category_title 매핑
                    subtitle: categoryIdAsync.when(
                      data: (categoryId) {
                        final String categoryTitle = _readableText(
                          categoryId == null ? null : categoryMap[categoryId],
                          '제목 없음',
                        );
                        return Text('문의 : $categoryTitle');
                      },
                      loading: () => const Text('문의 : 불러오는 중...'),
                      error: (e, s) => Text('문의 : 제목 없음'),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('카테고리 로드 실패: $e')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('데이터 로드 실패: $e')),
          ),
        ),
      ],
    );
  }
}

class _ChatDetailView extends ConsumerStatefulWidget {
  const _ChatDetailView();
  @override
  ConsumerState<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends ConsumerState<_ChatDetailView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  static const int _maxSendAttempts = 3;
  int? _lastGuardianId;
  bool _didInitialScroll = false;
  bool _wasCurrentRoute = true;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _showSnack(String message) {
    // [Codex] Use global messenger to avoid missing context issues.
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }


  void _send() async {
    final inquiry = ref.read(selectedInquiryProvider);
    final text = _textController.text.trim();
    if (inquiry == null) {
      debugPrint("⚠️ 전송 실패: 문의 대상이 선택되지 않았습니다.");
      _showSnack('전송 실패: 문의 대상을 선택해주세요.');
      return;
    }
    if (text.isEmpty) {
      debugPrint("⚠️ 전송 실패: 메시지가 비어 있습니다.");
      _showSnack('전송 실패: 메시지를 입력해주세요.');
      return;
    }

    // 1. 전송 누르면 즉시 텍스트 필드 비우기
    _textController.clear();
    final col = ref.read(chattingCollectionProvider);

    try {
      debugPrint("➡️ 전송 시도: guardian_id=${inquiry['guardian_id']}, student_id=${inquiry['student_id']}");
      _showSnack('전송 중...');
      await _retrySend(col: col, inquiry: inquiry, text: text);
      _scrollToBottom();
    } catch (e) {
      debugPrint("❌ Firebase 저장 에러: $e");
      _showSnack('전송 실패: $e');
    }
  }

  Future<void> _pickAndSendImage() async {
    final inquiry = ref.read(selectedInquiryProvider);
    if (inquiry == null) {
      _showSnack('전송 실패: 문의 대상을 선택해주세요.');
      return;
    }

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;

    try {
      _showSnack('이미지 업로드 중...');
      final file = File(picked.path);
      final storage = FirebaseStorage.instanceFor(app: Firebase.app());
      final String fileName =
          '${inquiry['guardian_id']}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = storage.ref().child('chatting_images').child(fileName);
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      await _retrySend(
        col: ref.read(chattingCollectionProvider),
        inquiry: inquiry,
        imageUrl: url,
      );
      _scrollToBottom();
      _showSnack('이미지 전송 완료');
    } catch (e) {
      debugPrint('❌ 이미지 업로드/전송 실패: $e');
      _showSnack('이미지 전송 실패: $e');
    }
  }

  Future<void> _retrySend(
    {
    required CollectionReference col,
    required Map<String, dynamic> inquiry,
    String? text,
    String? imageUrl,
  }
  ) async {
    final String safeText = (text ?? '').trim();
    final String safeImageUrl = (imageUrl ?? '').trim();
    for (int attempt = 1; attempt <= _maxSendAttempts; attempt++) {
      try {
        // [Codex] Quick connectivity check before write.
        await col.limit(1).get(const GetOptions(source: Source.server)).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint("❌ Firebase 읽기 타임아웃(5초)");
            throw TimeoutException("Firebase read timed out");
          },
        );
        debugPrint("✅ Firebase 읽기 성공");
        // 2. Firebase 'atti' 인스턴스에 직접 저장
        final value = await col.add({
          'category_id': inquiry['category_id'] ?? 1,
          'chatting_contents': safeText,
          'chatting_content': safeText,
          'chatting_date': FieldValue.serverTimestamp(), // 서버 시간 고정 저장
          'guardian_id': int.tryParse(inquiry['guardian_id'].toString()) ??
              inquiry['guardian_id'],
          'student_id': inquiry['student_id'] ?? 1,
          'teacher_id': 1,
          'chatting_image': safeImageUrl,
          'chatting_read_date': null,
        }).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint("❌ Firebase 저장 타임아웃(5초)");
            throw TimeoutException("Firebase write timed out");
          },
        );
        debugPrint("✅ Firebase 저장 성공: ${value.id}");
        _showSnack('전송 성공');
        return;
      } on FirebaseException catch (e) {
        final bool shouldRetry =
            e.code == 'unavailable' || e.code == 'deadline-exceeded';
        if (!shouldRetry || attempt == _maxSendAttempts) rethrow;
        final delay = Duration(seconds: 1 << (attempt - 1));
        debugPrint("⏳ 재시도 대기 ${delay.inSeconds}s (attempt $attempt)");
        await Future.delayed(delay);
      } on TimeoutException {
        if (attempt == _maxSendAttempts) rethrow;
        final delay = Duration(seconds: 1 << (attempt - 1));
        debugPrint("⏳ 타임아웃 재시도 대기 ${delay.inSeconds}s (attempt $attempt)");
        await Future.delayed(delay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inquiry = ref.watch(selectedInquiryProvider);
    final chatData = ref.watch(chatStreamProvider);

    if (inquiry == null) return const Center(child: Text('문의를 선택해주세요.'));
    final int? guardianId = int.tryParse(inquiry['guardian_id'].toString());
    if (guardianId != null && guardianId != _lastGuardianId) {
      _lastGuardianId = guardianId;
      _didInitialScroll = false;
      _scrollToBottom();
    }
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    if (isCurrentRoute && !_wasCurrentRoute) {
      _wasCurrentRoute = true;
      _didInitialScroll = false;
      _scrollToBottom();
    } else if (!isCurrentRoute && _wasCurrentRoute) {
      _wasCurrentRoute = false;
    }

    return Column(
      children: [
        AppBar(
          title: Text('${inquiry['student_name']} 학부모님'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        const Divider(height: 1),
        Expanded(
          child: chatData.when(
            data: (msgs) {
              if (!_didInitialScroll && msgs.isNotEmpty) {
                _didInitialScroll = true;
                _scrollToBottom();
              }
              final reversedMsgs = msgs.reversed.toList();
              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.all(20),
                itemCount: reversedMsgs.length,
                itemBuilder: (ctx, idx) {
                  final m = reversedMsgs[idx];
                  return _buildBubble(
                    m['contents'],
                    m['imageUrl'],
                    m['date'],
                    m['isTeacher'],
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('에러: $e')),
          ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildBubble(
    String contents,
    String? imageUrl,
    DateTime date,
    bool isMe,
  ) {
    final String? url = (imageUrl ?? '').trim().isEmpty ? null : imageUrl;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) Text(DateFormat('a h:mm').format(date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? const Color(0xFFF7D060) : const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (url != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return const Icon(Icons.broken_image, size: 40);
                      },
                    ),
                  ),
                if (contents.trim().isNotEmpty) ...[
                  if (url != null) const SizedBox(height: 8),
                  Text(
                    contents,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe) Text(DateFormat('a h:mm').format(date), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: _pickAndSendImage,
            icon: const Icon(Icons.add, color: Color(0xFFF7D060), size: 30),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '메시지를 입력하세요',
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          IconButton(onPressed: _send, icon: const Icon(Icons.send, color: Color(0xFFF7D060), size: 30)),
        ],
      ),
    );
  }
}
