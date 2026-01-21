/* 
Description : Firebase ScheduleNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/schedule.dart';


// Firestore Collection Provider
final scheduleCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('schedule'),
);

// StreamProvider
final scheduleListProvider = StreamProvider<List<Schedule>>(
  (ref) {
    final col = ref.watch(scheduleCollectionProvider);
    return col.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Schedule.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
    });
  },
);

// ScheduleActionProvider
class ScheduleActionProvider extends Notifier<void>{

  @override
  void build() {}

  CollectionReference get _schedule => ref.read(scheduleCollectionProvider);

  Future<void> addSchedule() async{
    await _schedule.add({});
  }

  Future<void> updateSchedule() async{
    await _schedule.doc().update({});
  }

  Future<void> deleteSchedule() async{
    await _schedule.doc().delete();
  }
} // ScheduleActionProvider

final scheduleActionProvider = NotifierProvider<ScheduleActionProvider, void>(
  ScheduleActionProvider.new
);