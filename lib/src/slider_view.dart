// Description: A customizable carousel slider widget with drag gestures, custom image widgets,
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A customizable carousel slider widget with drag gestures, custom image widgets,
/// and optional questions and answer buttons.
class SliderView extends StatefulWidget {
  /// List of custom image widgets to display in the carousel.
  final List<Widget> imageWidgets;

  /// Optional title displayed at the top of the center image.
  final String? titleOne;

  /// Optional title displayed at the bottom of the center image.
  final String? titleTwo;

  /// Optional list of questions to display below the center image.
  final List? questions;

  /// Optional list of answer options for each question.
  final List? answerOptions;

  /// Optional function to build custom answer buttons for each question.
  final List<Widget> Function(int index)? answerButtonBuilder;

  /// Animation curve for transitions.
  final Curve animationCurve;

  /// Duration of animations.
  final Duration animationDuration;

  /// Primary color for the slider (replaces AppColors.primary2).
  final Color primaryColor;

  /// Secondary color for borders and accents (replaces AppColors.secondaryColor).
  final Color secondaryColor;

  /// Padding scale for the slider.
  final double? paddingScale;

  /// Font scale for text elements.
  final double? fontScale;

  /// Width scale for side images.
  final double? imageWidthScale;

  /// Width scale for the center image.
  final double? centerImageWidthScale;

  /// Height scale for the center image.
  final double? centerImageHeightScale;

  /// Padding scale for buttons.
  final double? buttonPaddingScale;

  /// Border radius scale for images and containers.
  final double? borderRadiusScale;

  /// Offset scale for next-to-center images.
  final double? nextImageOffsetScale;

  /// Width scale for next-to-center images.
  final double? nextImageWidthScale;

  /// Positioning parameters for image placement.
  final double? nextToLeftTop;
  final double? nextToLeftBottom;
  final double? nextToLeftOffset;
  final double? leftTop;
  final double? leftBottom;
  final double? leftOffset;
  final double? centerTop;
  final double? centerBottom;
  final double? rightTop;
  final double? rightBottom;
  final double? rightOffset;
  final double? nextToRightTop;
  final double? nextToRightBottom;
  final double? nextToRightOffset;

  /// Whether to show navigation arrows.
  final bool arrowShow;

  /// Callback when the current index changes.
  final Function(int)? onIndexChanged;

  const SliderView({
    required this.imageWidgets,
    this.titleOne,
    this.titleTwo,
    this.questions,
    this.answerOptions,
    this.answerButtonBuilder,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.blueAccent,
    this.paddingScale,
    this.fontScale,
    this.imageWidthScale,
    this.centerImageWidthScale,
    this.centerImageHeightScale,
    this.buttonPaddingScale,
    this.borderRadiusScale,
    this.nextImageOffsetScale,
    this.nextImageWidthScale,
    this.nextToLeftTop,
    this.nextToLeftBottom,
    this.nextToLeftOffset,
    this.leftTop,
    this.leftBottom,
    this.leftOffset,
    this.centerTop,
    this.centerBottom,
    this.rightTop,
    this.rightBottom,
    this.rightOffset,
    this.nextToRightTop,
    this.nextToRightBottom,
    this.nextToRightOffset,
    this.arrowShow = true,
    this.onIndexChanged,
    Key? key,
  }) : super(key: key);

  @override
  _SliderViewState createState() => _SliderViewState();
}

class _SliderViewState extends State<SliderView> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  late double dragOffset;
  late AnimationController _controller;
  late Animation<double> _animation;

  Widget get leftImage =>
      currentIndex == 0 ? widget.imageWidgets.last : widget.imageWidgets[currentIndex - 1];
  Widget get centerImage => widget.imageWidgets[currentIndex];
  Widget get rightImage => currentIndex == widget.imageWidgets.length - 1
      ? widget.imageWidgets.first
      : widget.imageWidgets[currentIndex + 1];

  Widget get nextToRightImage {
    if (widget.imageWidgets.isEmpty) return const SizedBox.shrink();
    if (currentIndex == widget.imageWidgets.length - 2) {
      return widget.imageWidgets.first;
    }
    if (currentIndex == widget.imageWidgets.length - 1) {
      return widget.imageWidgets[1];
    }
    return widget.imageWidgets[currentIndex + 2];
  }

  Widget get nextToLeftImage {
    if (widget.imageWidgets.isEmpty) return const SizedBox.shrink();
    if (currentIndex == 0) {
      return widget.imageWidgets[widget.imageWidgets.length - 2];
    }
    if (currentIndex == 1) return widget.imageWidgets.last;
    return widget.imageWidgets[currentIndex - 2];
  }

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    dragOffset = 0.0;

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..addListener(() {
        setState(() {
          dragOffset = _animation.value;
        });
      });
  }

  void _onDragEnd(DragEndDetails details) {
    double threshold = 100;
    if (dragOffset.abs() > threshold) {
      int previousIndex = currentIndex;
      if (dragOffset < 0 && currentIndex < widget.imageWidgets.length - 1) {
        currentIndex++;
      } else if (dragOffset > 0 && currentIndex > 0) {
        currentIndex--;
      }
      if (previousIndex != currentIndex) {
        widget.onIndexChanged?.call(currentIndex);
      }
    }

    _animation = Tween<double>(begin: dragOffset, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: widget.animationCurve));
    _controller.forward(from: 0.0);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      dragOffset += details.delta.dx;
    });
  }

  void _goToPrevious() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.imageWidgets.length) % widget.imageWidgets.length;
      widget.onIndexChanged?.call(currentIndex);
    });
  }

  void _goToNext() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.imageWidgets.length;
      widget.onIndexChanged?.call(currentIndex);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageWidgets.isEmpty) {
      return const Center(child: Text('No images provided'));
    }

    if (widget.questions != null && widget.questions!.length != widget.imageWidgets.length) {
    throw ArgumentError('Questions length must match imageWidgets length');
  }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final paddingScale = widget.paddingScale ?? screenWidth * 0.04;
    final fontScale = widget.fontScale ?? screenWidth * 0.04;
    final imageWidthScale = widget.imageWidthScale ?? screenWidth * 0.3;
    final centerImageWidthScale = widget.centerImageWidthScale ?? screenWidth * 0.55;
    final centerImageHeightScale = widget.centerImageHeightScale ?? screenHeight * 0.4;
    final buttonPaddingScale = widget.buttonPaddingScale ?? screenWidth * 0.04;
    final borderRadiusScale = widget.borderRadiusScale ?? screenWidth * 0.03;
    final nextImageOffsetScale = widget.nextImageOffsetScale ?? screenWidth * 0.0450;
    final nextImageWidthScale = widget.nextImageWidthScale ?? screenWidth * 0.3 * 0.8;

    final nextToLeftTop = widget.nextToLeftTop ?? screenHeight * 0.11;
    final nextToLeftBottom = widget.nextToLeftBottom ?? screenHeight * 0.020;
    final nextToLeftOffset = widget.nextToLeftOffset ?? nextImageOffsetScale * 0.11;
    final leftTop = widget.leftTop ?? screenHeight * 0.022;
    final leftBottom = widget.leftBottom ?? screenHeight * 0.040;
    final leftOffset = widget.leftOffset ?? paddingScale;
    final centerTop = widget.centerTop ?? screenHeight * 0.1;
    final centerBottom = widget.centerBottom ?? screenHeight * 0.08;
    final rightTop = widget.rightTop ?? screenHeight * 0.022;
    final rightBottom = widget.rightBottom ?? screenHeight * 0.040;
    final rightOffset = widget.rightOffset ?? paddingScale;
    final nextToRightTop = widget.nextToRightTop ?? screenHeight * 0.11;
    final nextToRightBottom = widget.nextToRightBottom ?? screenHeight * 0.020;
    final nextToRightOffset = widget.nextToRightOffset ?? nextImageOffsetScale * 0.14;

    return Scaffold(
      body: SafeArea(
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft && currentIndex > 0) {
                _goToPrevious();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
                  currentIndex < widget.imageWidgets.length - 1) {
                _goToNext();
              }
            }
          },
          child: GestureDetector(
            onHorizontalDragEnd: (DragEndDetails details) {
              if (details.primaryVelocity! > 0) {
                _goToPrevious();
              } else if (details.primaryVelocity! < 0) {
                _goToNext();
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadiusScale * 1.5),
                    child: _buildCarouselView(
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      paddingScale: paddingScale,
                      fontScale: fontScale,
                      imageWidthScale: imageWidthScale,
                      centerImageWidthScale: centerImageWidthScale,
                      centerImageHeightScale: centerImageHeightScale,
                      borderRadiusScale: borderRadiusScale,
                      buttonPaddingScale: buttonPaddingScale,
                      nextImageOffsetScale: nextImageOffsetScale,
                      nextImageWidthScale: nextImageWidthScale,
                      nextToLeftTop: nextToLeftTop,
                      nextToLeftBottom: nextToLeftBottom,
                      nextToLeftOffset: nextToLeftOffset,
                      leftTop: leftTop,
                      leftBottom: leftBottom,
                      leftOffset: leftOffset,
                      centerTop: centerTop,
                      centerBottom: centerBottom,
                      rightTop: rightTop,
                      rightBottom: rightBottom,
                      rightOffset: rightOffset,
                      nextToRightTop: nextToRightTop,
                      nextToRightBottom: nextToRightBottom,
                      nextToRightOffset: nextToRightOffset,
                    ),
                  ),
                ),
                if (widget.questions != null && widget.questions!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: paddingScale),
                    child: Text("The Question number is ${currentIndex + 1}"),
                  ),
                if (widget.answerButtonBuilder != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.answerButtonBuilder!(currentIndex),
                  )
                else if (widget.answerOptions != null && widget.answerOptions!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (widget.answerOptions![currentIndex] as List<dynamic>).map((option) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: paddingScale * 0.12),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Selected: $option');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadiusScale * 0.8),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: buttonPaddingScale,
                              vertical: buttonPaddingScale * 0.5,
                            ),
                          ),
                          child: Text(
                            option.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontScale * 0.9,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: paddingScale),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselView({
    required double screenWidth,
    required double screenHeight,
    required double paddingScale,
    required double fontScale,
    required double imageWidthScale,
    required double centerImageWidthScale,
    required double centerImageHeightScale,
    required double borderRadiusScale,
    required double buttonPaddingScale,
    required double nextImageOffsetScale,
    required double nextImageWidthScale,
    required double nextToLeftTop,
    required double nextToLeftBottom,
    required double nextToLeftOffset,
    required double leftTop,
    required double leftBottom,
    required double leftOffset,
    required double centerTop,
    required double centerBottom,
    required double rightTop,
    required double rightBottom,
    required double rightOffset,
    required double nextToRightTop,
    required double nextToRightBottom,
    required double nextToRightOffset,
  }) {
    return AnimatedSwitcher(
      duration: widget.animationDuration,
      switchInCurve: widget.animationCurve,
      switchOutCurve: widget.animationCurve,
      child: Container(
        key: ValueKey(currentIndex),
        padding: EdgeInsets.all(paddingScale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Next-to-left image
                  if (currentIndex > 1)
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      left: nextToLeftOffset,
                      top: nextToLeftTop,
                      bottom: nextToLeftBottom,
                      child: GestureDetector(
                        onTap: _goToPrevious,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: currentIndex == 0 ? 0.8 : 1.0,
                            end: currentIndex == 0 ? 1.0 : 0.8,
                          ),
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          builder: (context, scale, child) {
                            double maxDrag = 150.0;
                            double defaultOpacity = 0.65;
                            double targetOpacity = 0.0;
                            double dragFactor =
                                (dragOffset > 0 ? dragOffset.abs() / maxDrag : 0.0).clamp(0.0, 1.0);
                            double eased = widget.animationCurve.transform(dragFactor);
                            final opacity =
                                defaultOpacity + (targetOpacity - defaultOpacity) * eased;

                            return AnimatedOpacity(
                              opacity: opacity.clamp(0.0, 0.65),
                              duration: widget.animationDuration,
                              child: Transform.rotate(
                                angle: -0.55 * scale,
                                child: Transform.scale(
                                  scale: scale,
                                  child: SizedBox(
                                    width: nextImageWidthScale,
                                    child: _buildImageBox(
                                      nextToLeftImage,
                                      fontScale,
                                      borderRadiusScale * 0.8,
                                      paddingScale,
                                      5.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Next-to-right image
                  if (currentIndex < widget.imageWidgets.length - 2)
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      right: nextToRightOffset,
                      top: nextToRightTop,
                      bottom: nextToRightBottom,
                      child: GestureDetector(
                        onTap: _goToNext,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: currentIndex == (widget.imageWidgets.length - 1) ? 0.8 : 1.0,
                            end: currentIndex == (widget.imageWidgets.length - 1) ? 1.0 : 0.8,
                          ),
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          builder: (context, scale, child) {
                            double maxDrag = 150.0;
                            double defaultOpacity = 0.65;
                            double targetOpacity = 0.0;
                            double dragFactor =
                                (dragOffset < 0 ? dragOffset.abs() / maxDrag : 0.0).clamp(0.0, 1.0);
                            double eased = widget.animationCurve.transform(dragFactor);
                            final opacity =
                                defaultOpacity + (targetOpacity - defaultOpacity) * eased;

                            return AnimatedOpacity(
                              opacity: opacity.clamp(0.0, 0.65),
                              duration: widget.animationDuration,
                              child: Transform.rotate(
                                angle: 0.55 * scale,
                                child: Transform.scale(
                                  scale: scale,
                                  child: SizedBox(
                                    width: nextImageWidthScale,
                                    child: _buildImageBox(
                                      nextToRightImage,
                                      fontScale,
                                      borderRadiusScale * 0.8,
                                      paddingScale,
                                      5.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                  ),
                    ),
                    ),
  
                    
                  // Left image
                  if (currentIndex > 0)
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      left: leftOffset,
                      top: leftTop + 30.0,
                      bottom: leftBottom,
                      child: GestureDetector(
                        onTap: _goToPrevious,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.9, end: 1.0),
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          builder: (context, tweenScale, child) {
                            double maxDrag = 150.0;
                            double defaultOpacity = 0.65;
                            double defaultBlur = 5.0;
                            double targetOpacity = 1.0;
                            double targetBlur = 0.0;
                            double dragFactor =
                                (dragOffset > 0 ? dragOffset.abs() / maxDrag : 0.0).clamp(0.0, 1.0);
                            double eased = widget.animationCurve.transform(dragFactor);
                            double translateX = dragOffset > 0 && currentIndex > 0
                                ? ((screenWidth / 2 - centerImageWidthScale / 2) - leftOffset) *
                                    eased
                                : 0.0;
                            double width = dragOffset > 0 && currentIndex > 0
                                ? imageWidthScale +
                                    (centerImageWidthScale - imageWidthScale) * eased * 0.7
                                : imageWidthScale;
                            double opacity =
                                defaultOpacity + (targetOpacity - defaultOpacity) * eased;
                            double blurSigma = defaultBlur - (defaultBlur - targetBlur) * eased;
                            double angle = dragOffset > 0 ? -0.20 * (1 - eased) : -0.20;

                            return Opacity(
                              opacity: opacity.clamp(0.65, 1.0),
                              child: Transform.translate(
                                offset: Offset(translateX, 0),
                                child: Transform.rotate(
                                  angle: angle,
                                  child: Transform.scale(
                                    scale: tweenScale,
                                    child: SizedBox(
                                      width: width,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(borderRadiusScale * 1.5),
                                        child: _buildImageBox(
                                          leftImage,
                                          fontScale,
                                          borderRadiusScale * 0.8,
                                          paddingScale,
                                          blurSigma.clamp(0.0, 5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Right image
                  if (currentIndex < widget.imageWidgets.length - 1)
                    AnimatedPositioned(
                      duration: widget.animationDuration,
                      curve: widget.animationCurve,
                      right: rightOffset,
                      top: rightTop + 30.0,
                      bottom: rightBottom,
                      child: GestureDetector(
                        onTap: _goToNext,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.9, end: 1.0),
                          duration: widget.animationDuration,
                          curve: widget.animationCurve,
                          builder: (context, tweenScale, child) {
                            double maxDrag = 150.0;
                            double defaultOpacity = 0.65;
                            double defaultBlur = 5.0;
                            double targetOpacity = 1.0;
                            double targetBlur = 0.0;
                            double dragFactor =
                                (dragOffset < 0 ? dragOffset.abs() / maxDrag : 0.0).clamp(0.0, 1.0);
                            double eased = widget.animationCurve.transform(dragFactor);
                            double translateX = dragOffset < 0 &&
                                    currentIndex < widget.imageWidgets.length - 1
                                ? ((screenWidth / 2 - centerImageWidthScale / 2) - rightOffset) *
                                    eased
                                : 0.0;
                            double width =
                                dragOffset < 0 && currentIndex < widget.imageWidgets.length - 1
                                    ? imageWidthScale +
                                        (centerImageWidthScale - imageWidthScale) * eased * 0.7
                                    : imageWidthScale;
                            double opacity =
                                defaultOpacity + (targetOpacity - defaultOpacity) * eased;
                            double blurSigma = defaultBlur - (defaultBlur - targetBlur) * eased;
                            double angle = dragOffset < 0 ? 0.25 * (1 - eased) : 0.25;

                            return Opacity(
                              opacity: opacity.clamp(0.65, 1.0),
                              child: Transform.translate(
                                offset: Offset(-translateX, 0),
                                child: Transform.rotate(
                                  angle: angle,
                                  child: Transform.scale(
                                    scale: tweenScale,
                                    child: SizedBox(
                                      width: width,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(borderRadiusScale * 1.5),
                                        child: _buildImageBox(
                                          rightImage,
                                          fontScale,
                                          borderRadiusScale * 0.8,
                                          paddingScale,
                                          blurSigma.clamp(0.0, 5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                  // Center image
                  GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Center(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.9, end: 1.0),
                        duration: widget.animationDuration,
                        curve: widget.animationCurve,
                        key: ValueKey(currentIndex),
                        builder: (context, value, child) {
                          double maxDrag = 200.0;
                          double dragFactor = (dragOffset.abs() / maxDrag).clamp(0.0, 1.0);
                          double scale = 1.0 - (0.5 * dragFactor);
                          double opacity = 1.0 - (0.8 * dragFactor);

                          return Opacity(
                            opacity: opacity.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: scale.clamp(0.5, 1.0),
                              child: Transform.translate(
                                offset: Offset(dragOffset, 0),
                                child: Transform.rotate(
                                  angle: (dragOffset / maxDrag).clamp(-1.0, 1.0) * 0.15,
                                  child: child,
                                ),
                              ),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () {},
                          child: SizedBox(
                            width: centerImageWidthScale,
                            height: centerImageHeightScale,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(borderRadiusScale * 1.5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.primaryColor.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(borderRadiusScale * 1.5),
                                  border: Border.all(
                                    color: widget.secondaryColor,
                                    width: screenWidth * 0.005,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: paddingScale,
                                      offset: Offset(0, paddingScale * 0.5),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Semantics(
                                      label: 'Image ${currentIndex + 1} of ${widget.imageWidgets.length}',
                                      child: centerImage,
                                    ),
                                    if (widget.titleOne == null)
                                      if (widget.questions != null && widget.questions!.isNotEmpty)
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            padding: EdgeInsets.all(paddingScale * 0.5),
                                            decoration: BoxDecoration(
                                              color: widget.primaryColor.withOpacity(0.8),
                                              borderRadius:
                                                  BorderRadius.circular(borderRadiusScale * 0.5),
                                            ),
                                            child: Text(
                                              widget.questions![currentIndex].toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: fontScale * 0.9,
                                                fontWeight: FontWeight.w500,
                                                shadows: [
                                                  Shadow(
                                                    blurRadius: paddingScale * 0.5,
                                                    color: Colors.black.withOpacity(0.5),
                                                    offset: Offset(2.0, 2.0),
                                                  ),
                                                ],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    if (widget.titleTwo != null)
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(paddingScale * 0.8),
                                          decoration: BoxDecoration(
                                            color: widget.primaryColor.withOpacity(0.8),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(borderRadiusScale * 1.5),
                                              bottomRight: Radius.circular(borderRadiusScale * 1.5),
                                            ),
                                          ),
                                          child: Text(
                                            widget.titleTwo!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontScale * 0.9,
                                              fontWeight: FontWeight.w500,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: paddingScale * 0.5,
                                                  color: Colors.black.withOpacity(0.5),
                                                  offset: Offset(2.0, 2.0),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    if (widget.titleOne != null)
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(paddingScale * 0.8),
                                          decoration: BoxDecoration(
                                            color: widget.primaryColor.withOpacity(0.8),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(borderRadiusScale * 1.5),
                                              topRight: Radius.circular(borderRadiusScale * 1.5),
                                            ),
                                          ),
                                          child: Text(
                                            widget.titleOne!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: fontScale * 0.9,
                                              fontWeight: FontWeight.w600,
                                              shadows: [
                                                Shadow(
                                                  blurRadius: paddingScale * 0.5,
                                                  color: Colors.black.withOpacity(0.5),
                                                  offset: Offset(2.0, 2.0),
                                                ),
                                              ],
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Back arrow
                  if (widget.arrowShow && currentIndex > 0)
                    Positioned(
                      left: screenWidth * 0.018,
                      top: screenHeight * 0.15,
                      child: GestureDetector(
                        onTap: _goToPrevious,
                        child: Icon(
                          Icons.arrow_left,
                          size: screenWidth * 0.09,
                          color: widget.secondaryColor,
                        ),
                      ),
                    ),

                  // Forward arrow
                  if (widget.arrowShow && currentIndex < widget.imageWidgets.length - 1)
                    Positioned(
                      right: screenWidth * 0.018,
                      top: screenHeight * 0.15,
                      child: GestureDetector(
                        onTap: _goToNext,
                        child: Icon(
                          Icons.arrow_right,
                          size: screenWidth * 0.09,
                          color: widget.secondaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageBox(
      Widget image, double fontScale, double borderRadius, double padding, double blurSigma) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: padding * 0.5,
              offset: Offset(0, padding * 0.25),
            ),
          ],
        ),
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: image,
        ),
      ),
    );
  }
}
