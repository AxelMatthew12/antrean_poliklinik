import 'package:flutter/material.dart';

class SlideGestureWrapper extends StatefulWidget {
  final Widget child;
  final bool slideToLeft;

  const SlideGestureWrapper({
    super.key,
    required this.child,
    required this.slideToLeft,
  });

  @override
  State<SlideGestureWrapper> createState() => _SlideGestureWrapperState();
}

class _SlideGestureWrapperState extends State<SlideGestureWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180), // lebih cepat, lebih halus
    );

    _animation =
        Tween<Offset>(
          begin: Offset(widget.slideToLeft ? 0.15 : -0.15, 0), // cuma 15% geser
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic, // animasi sangat halus
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}
