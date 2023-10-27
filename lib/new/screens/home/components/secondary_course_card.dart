import 'package:flutter/material.dart';

import '../../../models/course.dart';

class SecondaryCourseCard extends StatelessWidget {
  const SecondaryCourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        course.ontap(context);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: course.bgColor,
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 30, offset: Offset(0, 10))
          ],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Color(0xFFEEF1F8),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    course.description,
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 40,
              child: VerticalDivider(
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 8),
            Image.asset(
              course.iconSrc,
              height: 45,
              width: 45,
            )
          ],
        ),
      ),
    );
  }
}
