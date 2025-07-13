import 'package:dombaku/bottombar/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:dombaku/starting/cover.dart';
import 'package:dombaku/session/user_session.dart';
import 'package:dombaku/dashboard/notification_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shineAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateAfterSplash();
      }
    });

    _controller.forward();
  }

  Future<void> _navigateAfterSplash() async {
    try {
      await NotificationService().start();

      bool loggedIn = await UserSession.isLoggedIn();

      if (!mounted) return;

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('User login status: $loggedIn'),
      //     duration: Duration(seconds: 2),
      //   ),
      // );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => loggedIn ? const MainScreen() : const CoverPage(),

        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CoverPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildShinyImage(Widget child) {
    return AnimatedBuilder(
      animation: _shineAnimation,
      builder: (context, _) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0, -0.3),
              end: Alignment(1.0, 0.3),
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.8),
                Colors.white.withOpacity(0.1),
              ],
              stops: [
                (_shineAnimation.value - 0.3).clamp(0.0, 1.0),
                _shineAnimation.value.clamp(0.0, 1.0),
                (_shineAnimation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: buildShinyImage(child!),
            );
          },
          child: Image.asset(
            'assets/images/dombaku.png',
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
