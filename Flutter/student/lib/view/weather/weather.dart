import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student/vm/color_provider.dart';
import 'package:student/vm/forecast.dart';
import 'package:student/vm/weather_provider.dart';

//  Weather widget
/*
  Created in: 18/01/2026 13:50
  Author: Chansol, Park
  Description: Weather widget
  Update log: 
    DUMMY 00/00/0000 00:00, 'Point X, Description', Creator: Chansol, Park
          18/01/2026 15:35, 'Point 1, Forecast added', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

class AnimatedColorButton extends ConsumerStatefulWidget {
  final double width;
  final double height;
  const AnimatedColorButton({super.key, this.width = 160, this.height = 72});

  @override
  ConsumerState<AnimatedColorButton> createState() =>
      _AnimatedColorButtonState();
}

class _AnimatedColorButtonState extends ConsumerState<AnimatedColorButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> animY;

  @override
  void initState() {
    super.initState();
    //  Animation for color breathing
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    //  Animation for floating images
    animY = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
      default:
        return ref.read(sunnyColorsProvider);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(
      weatherProvider,
    ); //  When the weather changes, setstate
    final colors = ref.watch(
      colorProvider,
    ); //  When weather changes, color will changed in Provider that will return List<color>

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final colorSets = Color.lerp(
          //  Set color lerps for gradient
          colors[0],
          colors[1],
          Curves.easeInOut.transform(_animationController.value),
        ) ?? colors[0];
        return weatherAsync.when(
          data: (data) {
            return Transform.translate(
              offset: Offset(0, animY.value),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  //  Point 1
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      useSafeArea: true,
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      builder: (_) => Consumer(
                        builder: (context, ref, _) {
                          final forecastAsync = ref.watch(forecastProvider);
                          return forecastBottomSheet(forecastAsync);
                        },
                      ),
                    );
                  },
                  child: Container(
                    width: widget.width,
                    height: widget.height,
                    decoration: BoxDecoration(
                      color: colorSets,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [image(data), Text(data)],
                    ),
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(child:Text('Error: $error'));
          },
          loading: () {
            return const Center(child:CircularProgressIndicator());
          },
        );
      },
    );
  } //  build

  //  Widget
  Widget image(String resultdata) {
    String assetPath;
    switch (resultdata) {
      case '맑음':
        assetPath = 'images/sunny.png';
        break;
      case '흐림':
        assetPath = 'images/cloud.png';
        break;
      case '비':
        assetPath = 'images/rain.png';
        break;
      case '눈':
        assetPath = 'images/snow.png';
        break;
      default:
        assetPath = 'images/error.png';
    }
    return Image.asset(assetPath, width: 50, height: 50, fit: BoxFit.contain);
  }

  //  Point 1
  Widget forecastBottomSheet(AsyncValue<List<String>> notifier) {
    return notifier.when(
      data: (data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              child: Column(
                children: [
                  Row(children: [image(data[index]), Text(data[index])]),
                ],
              ),
            );
          },
        );
      },
      error: (error, stackTrace) => Center(child:Text('Error: $error'),),
      loading: () => const Center(child:CircularProgressIndicator(),)
    );
  }
} //  class
