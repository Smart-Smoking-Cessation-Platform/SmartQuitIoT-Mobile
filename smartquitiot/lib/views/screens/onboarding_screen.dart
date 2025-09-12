import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: Column(
        children: [
          // Header
          Container(
            height: 90,
            width: double.infinity,
            color: const Color(0xFF00D09E),
            alignment: Alignment.center,
            child: Text(
              _currentIndex == 0
                  ? 'Welcome To SmartQuit'
                  : _currentIndex == 1
                  ? "Let’s Talk About Your Smoking Status"
                  : "Questions",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Nội dung PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                // PAGE 1: Welcome
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/Group.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Are You Ready To Save Your Life?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // PAGE 2: Let’s Talk
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/health.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tell us about your smoking habits so we can help you better.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // PAGE 3: Questions 1
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ListView(
                    children: [
                      questionInput('How Long Have You Smoked?'),
                      questionInput(
                        'How Much Does It Cost To Buy A Pack Of Cigarettes?',
                      ),
                      questionInput('How Many Cigarettes In A Pack?'),
                      questionOptions(
                        'How Soon After Waking Do You Smoke Your First Cigarette?',
                        ['5 minutes', '5–10 minutes', '31–60 minutes', 'Other'],
                      ),
                    ],
                  ),
                ),

                // PAGE 4: Questions 2
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ListView(
                    children: [
                      questionOptions(
                        'How Many Cigarettes Do You Smoke Per Day On Average?',
                        ['1–10', '11–20', '21–30', '30+'],
                      ),
                      questionOptions(
                        'Do You Find It Difficult To Refrain From Smoking In Places Where It Is Forbidden?',
                        ['Yes', 'No'],
                      ),
                      questionOptions(
                        'Which Cigarette Would You Hate To Give Up?',
                        ['First in the morning', 'Any other'],
                      ),
                      questionOptions(
                        'Do You Smoke More Frequently In The Morning?',
                        ['Yes', 'No'],
                      ),
                      questionOptions(
                        'Do You Smoke Even If You Are Sick In Bed Most Of The Day?',
                        ['Yes', 'No'],
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          // Navigate sang màn hình chính
                          Navigator.pushNamed(context, '/relaunch');
                        },
                        child: const Text(
                          'Finish',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? const Color(0xFF00D09E)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget questionInput(String text) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: 'Nhập thông tin...',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey, // viền khi chưa focus
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.black87, // viền khi focus
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget questionInputBox(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.grey, // viền khi chưa focus
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.black87, // viền khi focus
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget questionOptions(String text, List<String> options) {
    // bạn có thể dùng state riêng để lưu lựa chọn
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Column(
              children: options.map((o) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Radio(
                    value: o,
                    groupValue: null, // bạn tự quản lý state ở đây
                    onChanged: (val) {},
                    activeColor: const Color(0xFF00D09E),
                  ),
                  title: Text(o),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
