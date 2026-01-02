import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Simple 360 spinner using a sequence of asset images.
///
/// Usage:
/// - Export frames named `frame_000.png`, `frame_001.png`, ... into
///   `assets/images/spins/<machineId>/` and include `assets/images/spins/` in `pubspec.yaml`.
/// - Create: `Spin360(folder: 'assets/images/spins/machine_001', frameCount: 36)`
class Spin360 extends StatefulWidget {
  final String folder; // e.g. 'assets/images/spins/machine_001'
  final int frameCount;
  final bool autoRotate;
  final Duration autoRotateDuration;
  final double sensitivity; // pixels per frame

  const Spin360({
    Key? key,
    required this.folder,
    required this.frameCount,
    this.autoRotate = false,
    this.autoRotateDuration = const Duration(milliseconds: 100),
    this.sensitivity = 8.0,
  }) : super(key: key);

  @override
  State<Spin360> createState() => _Spin360State();
}

class _Spin360State extends State<Spin360> {
  late int _index;
  double _startDx = 0.0;
  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _index = 0;
    _precacheFrames();
    if (widget.autoRotate) _startAutoRotate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _precacheFrames() async {
    // Precache a limited number of frames to avoid OOM; preload every nth frame.
    final int step = (widget.frameCount / 8).ceil().clamp(1, widget.frameCount);
    for (int i = 0; i < widget.frameCount; i += step) {
      final path = '${widget.folder}/frame_${i.toString().padLeft(3, '0')}.png';
      try {
        await precacheImage(AssetImage(path), context);
      } catch (_) {
        // ignore missing frames during precache
      }
    }
    setState(() => _precached = true);
  }

  void _startAutoRotate() {
    _timer = Timer.periodic(widget.autoRotateDuration, (_) {
      setState(() {
        _index = (_index + 1) % widget.frameCount;
      });
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _timer?.cancel();
    final dx = details.delta.dx;
    if (dx.abs() < 0.5) return;
    final int deltaFrames = (dx / widget.sensitivity).round();
    if (deltaFrames == 0) return;
    setState(() {
      _index = (_index - deltaFrames) % widget.frameCount;
      if (_index < 0) _index += widget.frameCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final path =
        '${widget.folder}/frame_${_index.toString().padLeft(3, '0')}.png';
    return GestureDetector(
      onHorizontalDragUpdate: _onDragUpdate,
      onTapDown: (_) => _timer?.cancel(),
      child: Semantics(
        label: '360 viewer',
        child: _precached
            ? Image.asset(path, gaplessPlayback: true, fit: BoxFit.contain)
            : FutureBuilder<ByteData?>(
                future: rootBundle
                    .load(path)
                    .then((bd) => bd)
                    .catchError((_) => null),
                builder: (context, snap) {
                  if (snap.hasData && snap.data != null) {
                    return Image.memory(snap.data!.buffer.asUint8List(),
                        fit: BoxFit.contain);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
      ),
    );
  }
}
