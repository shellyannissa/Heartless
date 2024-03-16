import 'package:flutter/material.dart';
import 'package:heartless/shared/constants.dart';
import 'package:heartless/widgets/miscellaneous/tag_tile.dart';

class FileTile extends StatelessWidget {
  final String title;
  final String dateString;
  final String imageUrl;
  const FileTile({
    super.key,
    required this.title,
    required this.dateString,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Constants.cardColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Row(
          children: [
            Image.asset(
              imageUrl,
              height: 50,
              width: 50,
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    dateString,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        // color: Colors.black,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      TagWidget(
                        tag: 'blood pressure',
                        tagColor: Colors.red,
                      ),
                      TagWidget(
                        tag: 'test report',
                        tagColor: Colors.blue,
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ));
  }
}