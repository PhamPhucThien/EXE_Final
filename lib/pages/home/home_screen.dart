import 'package:flutter/material.dart';

import 'components/course_card.dart';
import 'components/secondary_course_card.dart';
import 'model/course.dart';

class home_screen extends StatelessWidget {
  const home_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Trang Chủ",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Color(0xFF3E4D4B), fontWeight: FontWeight.bold),
                ),
              ),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: courses
              //         .map(
              //           (course) => Padding(
              //             padding: const EdgeInsets.only(left: 20),
              //             child: CourseCard(
              //               title: course.title,
              //               iconSrc: course.iconSrc,
              //               color: course.color,
              //             ),
              //           ),
              //         )
              //         .toList(),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Menu:",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Color(0xFF3E4D4B), fontWeight: FontWeight.bold),
                ),
              ),
              ...recentCourses
                  .map((course) => Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: SecondaryCourseCard(
                          title: course.title,
                          iconsSrc: course.iconSrc,
                          colorl: course.color,
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}
