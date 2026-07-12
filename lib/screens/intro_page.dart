import 'package:flutter/material.dart';
import 'package:money/dictionary/titles.dart';
import 'package:money/screens/home_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<StatefulWidget> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final PageController _controller = PageController();
  bool _isLastPage = false;

  int _currentPage = 0;

  final List<List<Color>> _pageGradients = [
    [
      const Color(0xFF1E3A8A),
      const Color(0xFF2563EB),
      const Color.fromARGB(255, 72, 127, 245),
    ],
    [
      const Color(0xFF4C1D95),
      const Color(0xFF7C3AED),
      const Color.fromARGB(255, 166, 116, 253),
    ],
    [
      const Color.fromARGB(255, 1, 124, 104),
      const Color.fromARGB(255, 8, 197, 166),
      const Color.fromARGB(255, 71, 233, 206),
    ],
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500), // سرعت تغییر رنگ بک‌گراند
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _pageGradients[_currentPage], // استفاده از رنگ صفحه فعلی
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // تغییر ایندکس رنگ با تغییر صفحه
                    _isLastPage = (index == 2);
                  });
                },
                children: [
                  _buildPage(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "مدیریت طلب و بدهی",
                    subtitle:
                        "تمام بدهی‌ها و طلب‌های خود را در یک جا ثبت و پیگیری کنید.",
                  ),
                  _buildPage(
                    icon: Icons.notifications_active_outlined,
                    title: "یادآور هوشمند",
                    subtitle:
                        "دیگر سررسید پرداخت‌ها و دریافت‌های خود را فراموش نخواهید کرد.",
                  ),
                  _buildPage(
                    icon: Icons.analytics_outlined,
                    title: "گزارش‌های دقیق",
                    subtitle:
                        "تحلیل و بررسی آسان رفتارهای مالی در بازه‌های زمانی مختلف.",
                  ),
                ],
              ),
              Positioned(
                top: 16,
                left: 16,
                child: TextButton(
                  onPressed: () {
                    _controller.animateToPage(
                      2,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "رد کردن",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'sans',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: 3,
                      onDotClicked: (index) {
                        _controller.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      },
                      effect: const ExpandingDotsEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white38,
                        dotHeight: 8,
                        dotWidth: 8,
                        expansionFactor: 4,
                        spacing: 8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          if (_isLastPage) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MyHomePage(title: Titles.mainTitle),
                              ),
                            );
                          } else {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLastPage ? "شروع برنامه" : "بعدی",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Vazir',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Vazir',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.6,
              fontFamily: 'Vazir',
            ),
          ),
        ],
      ),
    );
  }
}
