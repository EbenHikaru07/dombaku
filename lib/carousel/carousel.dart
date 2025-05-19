import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AutoScrollPageView extends StatefulWidget {
  const AutoScrollPageView({super.key});

  @override
  _AutoScrollPageViewState createState() => _AutoScrollPageViewState();
}

class _AutoScrollPageViewState extends State<AutoScrollPageView> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  final List<String> imagePaths = [
    'assets/slide/slidesheep1.png',
    'assets/slide/slidesheep2.jpg',
    'assets/slide/slide3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final actualIndex = index % imagePaths.length;
              return buildSlideImage(imagePaths[actualIndex]);
            },
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        SmoothPageIndicator(
          controller: _pageController,
          count: imagePaths.length,
          effect: ScrollingDotsEffect(
            activeDotColor: const Color(0xff042E22),
            dotColor: Colors.grey.shade300,
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
            maxVisibleDots: 5,
            fixedCenter: false,
          ),
          onDotClicked: (index) {
            _pageController.animateToPage(
              _currentPage + (index - (_currentPage % imagePaths.length)),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ],
    );
  }

  Widget buildSlideImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
