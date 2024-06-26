import 'package:flutter/material.dart';
import 'package:heartless/pages/profile/extended_timeline_page.dart';
import 'package:heartless/services/utils/timeline_service.dart';
import 'package:heartless/shared/models/app_user.dart';
import 'package:heartless/widgets/patient_management/timeline_entry_widget.dart';

class TimelineWidget extends StatelessWidget {
  final AppUser patient;
  const TimelineWidget({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            // height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).secondaryHeaderColor,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Timeline',
                      textAlign: TextAlign.start,
                      // style: Theme.of(context).textTheme.headlineMedium
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).shadowColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FutureBuilder(
                    future: TimeLineService.getTimeLine(patient.uid, 4),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.connectionState ==
                          ConnectionState.done) {
                        return Column(
                          children: snapshot.data!
                              .map((e) => TimeLineEntryWidget(
                                  patient: patient,
                                  title: e.title,
                                  time: e.date,
                                  tag: e.tag))
                              .toList(),
                        );
                      } else {
                        return Text("Failed");
                      }
                    }),
              ],
            )),
        Positioned(
          top: 10,
          right: 30,
          child: IconButton(
            color: Colors.black,
            onPressed: () {
              // todo: navigate to timeline page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExtendedTimelinePage(patient: patient),
                ),
              );
            },
            icon: Icon(Icons.keyboard_arrow_right),
          ),
        ),
      ],
    );
  }
}
