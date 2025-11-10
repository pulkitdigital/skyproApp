// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import '../pages/intake_form_page.dart';

// class SplashVideoPage extends StatefulWidget {
//   const SplashVideoPage({super.key});
//   @override
//   State<SplashVideoPage> createState() => _SplashVideoPageState();
// }

// class _SplashVideoPageState extends State<SplashVideoPage> {
//   VideoPlayerController? _controller;
//   bool _readyToGo = false;

//   @override
//   void initState() {
//     super.initState();

//     // Fallback if video is slow/missing.
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted && !_readyToGo) _goNext();
//     });

//     try {
//       _controller = VideoPlayerController.asset('assets/intro.mp4')
//         ..setLooping(false)
//         ..setVolume(0.0)
//         ..initialize().then((_) async {
//           if (!mounted) return;
//           setState(() {});
//           try {
//             await _controller?.play();
//           } catch (_) {}
//           _controller?.addListener(() {
//             final v = _controller?.value;
//             if (v != null &&
//                 v.isInitialized &&
//                 !v.isPlaying &&
//                 v.position >= v.duration &&
//                 mounted) {
//               _goNext();
//             }
//           });
//         });
//     } catch (_) {/* ignore */}
//   }

//   void _goNext() {
//     if (_readyToGo) return;
//     _readyToGo = true;
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => const IntakeFormPage()),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isInit = _controller?.value.isInitialized == true;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: isInit
//             ? FittedBox(
//                 fit: BoxFit.cover,
//                 child: SizedBox(
//                   width: _controller!.value.size.width,
//                   height: _controller!.value.size.height,
//                   child: VideoPlayer(_controller!),
//                 ),
//               )
//             : const CircularProgressIndicator(color: Colors.white),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays assets/intro.mp4 full-screen and then routes to [nextPage].
class SplashVideoPage extends StatefulWidget {
  final Widget nextPage; // where to go after video
  final Duration? minShowTime; // optional: ensure min display time

  const SplashVideoPage({
    super.key,
    required this.nextPage,
    this.minShowTime,
  });

  @override
  State<SplashVideoPage> createState() => _SplashVideoPageState();
}

class _SplashVideoPageState extends State<SplashVideoPage> {
  late final VideoPlayerController _controller;
  bool _navigated = false;
  late final DateTime _start;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
    _controller = VideoPlayerController.asset('assets/intro.mp4')
      ..initialize().then((_) async {
        if (!mounted) return;
        // Mute by default (optional)
        await _controller.setVolume(0.0);
        await _controller.play();

        // When video ends, navigate
        _controller.addListener(_handleVideoProgress);
        setState(() {});
      }).catchError((e) {
        // If video fails, go ahead to app
        _goNext();
      });
  }

  void _handleVideoProgress() {
    if (!_controller.value.isInitialized) return;
    final v = _controller.value;
    if (v.position >= (v.duration - const Duration(milliseconds: 200))) {
      _goNext();
    }
  }

  Future<void> _goNext() async {
    if (_navigated) return;
    _navigated = true;

    // optional: respect minShowTime if provided
    if (widget.minShowTime != null) {
      final elapsed = DateTime.now().difference(_start);
      final left = widget.minShowTime! - elapsed;
      if (left > Duration.zero) await Future.delayed(left);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => widget.nextPage),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // video
          if (_controller.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          // Skip button (optional)
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 12,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
              ),
              onPressed: _goNext,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}
