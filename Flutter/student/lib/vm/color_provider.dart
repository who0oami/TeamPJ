import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/vm/weather_provider.dart';

//  ColorProvider
/*
  Created in: 18/01/2026 13:19
  Author: Chansol, Park
  Description: ColorProvider for colorgradient effects
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

final sunnyColorsProvider = Provider<List<Color>>((ref) => const [
  Color(0xFFBFE9FF),
  Color(0xFF87CEEB),
]);

final cloudyColorsProvider = Provider<List<Color>>((ref) => const [
  Color(0xFFE0E6ED),
  Color(0xFFB0BEC5),
]);

final rainyColorsProvider = Provider<List<Color>>((ref) => const [
  Color(0xFF90A4AE),
  Color(0xFF607D8B),
]);

final snowyColorsProvider = Provider<List<Color>>((ref) => const [
  Color(0xFFF5F7FA),
  Color(0xFFE3F2FD),
]);

final errorColorsProvider = Provider<List<Color>>((ref) => const [
  Color.fromARGB(255, 225, 29, 29),
  Color.fromARGB(255, 255, 115, 8),
]);

final colorProvider = NotifierProvider<ColorProvider, List<Color>>(
  ColorProvider.new,
);

class ColorProvider extends Notifier<List<Color>> {
  @override
  List<Color> build() {
    final weatherAsync = ref.watch(weatherProvider);
    final wResult = weatherAsync.asData?.value;
    if (wResult == null) {
      return getColors('에러');
    }
    return getColors(wResult);
  }

  List<Color> getColors(String input) {
    switch (input) {
      case '맑음':
        return ref.read(sunnyColorsProvider);
      case '흐림':
        return ref.read(cloudyColorsProvider);
      case '비':
        return ref.read(rainyColorsProvider);
      case '눈':
        return ref.read(snowyColorsProvider);
      case '에러':
        return ref.read(errorColorsProvider);
      default:
        return ref.read(sunnyColorsProvider);
    }
  }
}
