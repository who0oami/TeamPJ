/* 
Description : Firebase TimetableNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/timetable.dart';


// Firestore Collection Provider
final timetableCollectionProvider = Provider<CollectionReference<Map<String, dynamic>>>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('timetable'),
);

// StreamProvider
final timetableListProvider = StreamProvider<List<Timetable>>(
  (ref) {
    final col = ref.watch(timetableCollectionProvider);
    return col.orderBy('homework_insertdate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Timetable.fromMap(doc.data(), doc.id)).toList();
    });
  },
);

// 시간표 필터 Provider => 학기, 학년, 반에 따라
final timetableByFilterProvider = StreamProvider.family<Timetable?, ({String semester, int grade, int classNum})>(
  (ref, f) {
    return ref
        .watch(timetableCollectionProvider)
        .where('timetable_semester', isEqualTo: f.semester)
        .where('timetable_grade', isEqualTo: f.grade)
        .where('timetable_class', isEqualTo: f.classNum)
        .limit(1)
        .snapshots()
        .map((s) =>
            s.docs.isEmpty ? null : Timetable.fromMap(s.docs.first.data(), s.docs.first.id));
  },
);

// TimetableActionProvider
class TimetableActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _timetable => ref.read(timetableCollectionProvider);

  Future<void> addTimetable(Timetable timetable) async{
    await _timetable.add(timetable.toMap());
  }

  Future<void> updateTimetable(String id, Map<String, dynamic> data) async{
    await _timetable.doc(id).update(data);
  }

  Future<void> deleteTimetable(String id) async{
    await _timetable.doc(id).delete();
  }
} // TimetableActionProvider

final timetableActionProvider = NotifierProvider<TimetableActionProvider, void>(
  TimetableActionProvider.new
);