import 'package:flutter/widgets.dart';

import 'screenshot_controller.dart';

/// WidgetShot is a custom Widget for taking screenshots
class ScreenShot extends StatefulWidget {
  final Widget? child;
  final ScreenShotController controller;

  const ScreenShot({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  @override
  State<ScreenShot> createState() {
    return ScreenshotState();
  }
}

class ScreenshotState extends State<ScreenShot> with TickerProviderStateMixin {
  late ScreenShotController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _controller.containerKey,
      child: widget.child,
    );
  }
}
