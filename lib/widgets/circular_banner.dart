import 'dart:async';
import 'package:flutter/widgets.dart';

class CircularBanner extends StatefulWidget {
  const CircularBanner({required this.children, Key? key}) : super(key: key);

  final List<Widget> children;

  @override
  _CircularBannerState createState() => _CircularBannerState();
}

class _CircularBannerState extends State<CircularBanner> {
  late PageController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 9999);
    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    if (widget.children.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) => _stopTimer(),
      onPointerCancel: (event) => _startTimer(),
      onPointerUp: (event) => _startTimer(),
      child: PageView.builder(
        // key: const PageStorageKey('aitsuki_circular_banner'),
        itemBuilder: (context, index) =>
            widget.children[index % widget.children.length],
        controller: _controller,
        allowImplicitScrolling: true,
        itemCount: widget.children.isEmpty ? 0 : null,
      ),
    );
  }
}
