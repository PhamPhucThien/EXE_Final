import 'package:flutter/material.dart' show Color;

class Course {
  final String title, description, iconSrc;
  final Color color;
  final String? routeName; // Add this property

  Course({
    required this.title,
    this.description = 'Build and animate an iOS app from scratch',
    this.iconSrc = "assets/icons/ios.svg",
    this.color = const Color.fromRGBO(115, 195, 184, 1),
    this.routeName, // Assign routeName
  });
}

final List<Course> courses = [
  Course(
    title: "Animations in SwiftUI",
  ),
  Course(
    title: "Animations in Flutter",
    iconSrc: "assets/icons/code.svg",
    color: Color.fromRGBO(115, 195, 184, 1),
  ),
];

final List<Course> recentCourses = [
  Course(
    title: "Nhắn tin",
    routeName: '/home', // Assign the routeName for 'Nhắn tin'
  ),
  Course(
    title: "Đặt lịch với chuyên viên tư vấn",
    color: const Color.fromRGBO(115, 195, 184, 1),
    iconSrc: "assets/icons/code.svg",
  ),
  Course(
    title: "Đăng ký Gói",
    color: const Color.fromRGBO(115, 195, 184, 1),
    iconSrc: "assets/icons/code.svg",
  ),
  Course(title: ""),
];
