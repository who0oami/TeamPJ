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
          19/01/2026 15:27, 'Point 2, Widget's width default set to MediaQuery.of(context).size.width', Creator: Chansol, Park
  Version: 1.0
  Dependency: 
*/

class AnimatedColorButton extends ConsumerStatefulWidget {
  final double? width;
  final double? height;
  const AnimatedColorButton({super.key, this.width, this.height});

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
    //  Point 2
    final w = widget.width ?? MediaQuery.sizeOf(context).width;
    final weatherAsync = ref.watch(
      weatherProvider,
    ); //  When the weather changes, setstate
    final colors = ref.watch(
      colorProvider,
    ); //  When weather changes, color will changed in Provider that will return List<color>

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        final colorSets =
            Color.lerp(
              //  Set color lerps for gradient
              colors[0],
              colors[1],
              Curves.easeInOut.transform(_animationController.value),
            ) ??
            colors[0];
        return weatherAsync.when(
          data: (data) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                //  Point 1
                onTap: () {
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    enableDrag: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
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
                  width: w,
                  height: widget.height ?? 72,
                  decoration: BoxDecoration(
                    color: colorSets,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, animY.value),
                        child: image(data, h: 100, w: 100),
                      ),
                      Text(data),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (error, stackTrace) {
            return Center(child: Text('Error: $error'));
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  } //  build

  //  Widget
  Widget image(String resultdata, {double? w = 50, double? h = 50}) {
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
    return Image.asset(assetPath, width: w, height: h, fit: BoxFit.contain);
  }

  //  Point 1
  Widget forecastBottomSheet(AsyncValue<List<String>> notifier) {
    final forecolor = ref.watch(forecastColorProvider); //  when forecast Changed
    return notifier.when(
      data: (data) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              color: Colors.transparent,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final foreColorsets =
                      Color.lerp(
                        //  Set color lerps for gradient
                        forecolor[index][0],
                        forecolor[index][1],
                        Curves.easeInOut.transform(_animationController.value),
                      ) ??
                      forecolor[index][0];
                  return Material(
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      tileColor: foreColorsets,
                      leading: Transform.translate(
                        offset: Offset(0, (animY.value)),
                        child: image(data[index]),
                      ),
                      title: Text('${index + 1}시간 후: ${data[index]}'),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
} //  class
