/* 
Description : Firebase LunchNotifier
Date : 2026-1-19
Author : 황민욱
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teacher/model/lunch.dart';
import 'package:teacher/model/lunch_category.dart';
import 'package:teacher/model/lunch_menu.dart';


// Firestore Collection Provider
final lunchCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('lunch'),
);

final lunchMenuCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('lunch_menu'),
);

final lunchCategoryCollectionProvider = Provider<CollectionReference>(
  (ref) => FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'atti')
  .collection('lunch_category'),
);

// StreamProvider
final lunchListProvider = StreamProvider<List<Lunch>>((ref) {
  final col = ref.watch(lunchCollectionProvider);
  return col.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => Lunch.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList(),
  );
});

final lunchMenuListProvider = StreamProvider<List<LunchMenu>>((ref) {
  final col = ref.watch(lunchMenuCollectionProvider);
  return col.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => LunchMenu.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList(),
  );
});

final lunchCategoryListProvider = StreamProvider<List<LunchCategory>>((ref) {
  final col = ref.watch(lunchCategoryCollectionProvider);
  return col.snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => LunchCategory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList(),
  );
});

// LunchActionProvider
class LunchActionProvider extends Notifier<void> {

  @override
  void build() {}

  CollectionReference get _lunch => ref.read(lunchCollectionProvider);
  CollectionReference get _menu => ref.read(lunchMenuCollectionProvider);
  CollectionReference get _category => ref.read(lunchCategoryCollectionProvider);

// Lunch
  Future<void> addLunch() async {
    await _lunch.add({});
  }

  Future<void> updateLunch() async {
    await _lunch.doc().update({});
  }

  Future<void> deleteLunch() async {
    await _lunch.doc().delete();
  }

// Menu
  Future<void> addMenu() async {
    await _menu.add({});
  }

  Future<void> updateMenu() async {
    await _menu.doc().update({});
  }

  Future<void> deleteMenu() async {
    await _menu.doc().delete();
  }

// Category
  Future<void> addCategory() async {
    await _category.add({});
  }

  Future<void> updateCategory() async {
    await _category.doc().update({});
  }

  Future<void> deleteCategory() async {
    await _category.doc().delete();
  }
} // LunchActionProvider

final lunchActionProvider = NotifierProvider<LunchActionProvider, void>(
  LunchActionProvider.new,
);
