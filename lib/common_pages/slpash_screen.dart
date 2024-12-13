import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final List<Map<String, String>> content = [
    {
      'animation': 'assets/1.json', // Replace with valid Lottie asset paths
      'title': 'Hello, I’m Judica your Legal Assistant.',
      'paragraph': 'My mission is to make sure everyone gets the support they need in the legal system. Whether you’re seeking advice, looking for guidance on bail, or need a quick understanding of legal terms, I’m here to help.'
    },
    {
      'animation': 'assets/2.json',
      'title': 'Making Legal Support Legal Support Clear and Accessible. ',
      'paragraph': 'I simplify complex legal terms and processes, helping regular users understand their rights and options. Whether facing a legal issue or navigating the bail process, I provide clear, straightforward guidance. My goal is to ensure everyone has access to reliable legal support, regardless of who they are.',
    },
    {
      'animation': 'assets/4.json',
      'title': 'Empowering Advocates with Quick, Reliable Legal Resources.',
      'paragraph':  'I provide advocates with fast and dependable access to essential legal resources, from case references and legal precedents to procedural guidelines. My goal is to streamline your work, allowing you to focus more on effectively supporting your clients.',
    },
    {
      'animation': 'assets/3.json',
      'title': 'Streamlining FIR Filing with Accurate Legal Language.',
      'paragraph': 'I assist police officers by transforming individual complaints into accurate legal language using NLP, identifying relevant laws and sections to simplify and expedite FIR filing. This ensures the FIR aligns with legal standards, enabling officers to respond to complaints more efficiently, even without immediate access to a legal expert.',
    },
  ];

  int _currentPage = 0;
  late PageController _pageController;
  late Timer _timer;

  get onTap => null;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);

    // Auto-slide timer
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < content.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // Reset to the first page after the last page
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Common background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Background.jpg'), // Replace with your background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // PageView with content
          FractionallySizedBox(
            heightFactor: 0.8,
            child: PageView.builder(
              controller: _pageController,
              itemCount: content.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                return FractionallySizedBox(
                  widthFactor: 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lottie animation
                      Lottie.asset(
                        content[index]['animation']!,
                        fit: BoxFit.contain,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      // Title
                      Text(
                        content[index]['title']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Paragraph
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          content[index]['paragraph']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // "Get Started" Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Dots Indicator
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                content.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
