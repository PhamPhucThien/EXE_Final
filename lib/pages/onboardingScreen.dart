import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'auth/login_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<String> imagePaths = [
    'assets/onboardingScreen/page1.png',
    'assets/onboardingScreen/page2.png',
    'assets/onboardingScreen/page3.png',
  ];
  final List<String> pageTitles = [
    "Tăng Cường Sức Khỏe Tinh Thần",
    "Quyền Riêng Tư Của Ứng Dụng Đáng Tin Cậy",
    "Thân Thiện Với Người Dùng",
  ];
  final List<String> pageDescriptions = [
    "Thúc đẩy và nâng cao sức khỏe tâm lý của bạn thông qua trao quyền, tự chăm sóc và phát triển cá nhân.",
    "Đảm bảo rằng thông tin cá nhân của bạn vẫn an toàn và được bảo vệ trong khi sử dụng ứng dụng.",
    "Dễ sử dụng và điều hướng cho người dùng ở mọi cấp độ.",
  ];
  int currentIndex = 0;
  bool animateForward = false;

  void navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(250, 250, 255, 1),
            Color.fromRGBO(115, 195, 184, 0.5),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  if (currentIndex < imagePaths.length - 1) {
                    setState(() {
                      currentIndex++;
                      animateForward = true;
                    });
                  }
                },
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    imagePaths[currentIndex],
                    key: ValueKey<String>(imagePaths[currentIndex]),
                    fit: BoxFit.cover,
                  ),
                  reverseDuration: Duration(milliseconds: 200),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70.0,
                width: 302.0,
                alignment: Alignment.center,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    pageTitles[currentIndex],
                    style: TextStyle(
                      color: Color(0xFF3E4E4B),
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 80.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                children: [
                  Text(
                    pageDescriptions[currentIndex],
                    style: TextStyle(
                      color: Color(0xFF3E4E4B),
                      fontSize: 15.0,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16.0,
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 180.0,
                        height: 47.0,
                        child: TextButton(
                          onPressed: () {
                            if (currentIndex < imagePaths.length - 1) {
                              setState(() {
                                currentIndex++;
                                animateForward = true;
                              });
                            } else {
                              navigateToLogin(); // Navigate to Login screen
                            }
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(4.0),
                            backgroundColor: MaterialStateProperty.all<Color>(
                              Color(0xFF3E4D4B),
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          child: Text(
                            currentIndex == imagePaths.length - 1
                                ? 'Bắt Đầu'
                                : 'Tiếp Theo',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Center(
                      child: SizedBox(
                        width: 180.0,
                        height: 47.0,
                        child: TextButton(
                          onPressed: () {
                            if (currentIndex > 0) {
                              setState(() {
                                currentIndex--;
                              });
                            }
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all<double>(4.0),
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          child: Text(
                            'Quay Lại',
                            style: TextStyle(
                              color: Color(0xFF3E4D4B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
