/* 
Description : lunch page 아직 페이지만 나오게 함!
Date : 2026-1-19
Author : 정시온
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/vm/sion/lunch_provider.dart';

class LunchPage extends ConsumerStatefulWidget {
  const LunchPage({super.key});

  @override
  ConsumerState<LunchPage> createState() => _LunchState();
}

class _LunchState extends ConsumerState<LunchPage>{

  @override
  Widget build(BuildContext context) {
  final lunchAsync = ref.watch(lunchmenuListProvider);


  return Scaffold(
    
    );
}
}