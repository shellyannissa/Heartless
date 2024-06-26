import 'package:flutter/material.dart';
import 'package:heartless/services/date/date_service.dart';
import 'package:heartless/services/enums/activity_type.dart';
import 'package:heartless/services/enums/medical_reading_type.dart';
import 'package:heartless/shared/provider/analytics_provider.dart';
import 'package:heartless/shared/provider/widget_provider.dart';
import 'package:heartless/widgets/analytics/blood_pressure_chart.dart';
import 'package:heartless/widgets/analytics/general_reading_chart.dart';
import 'package:heartless/widgets/analytics/line_default_chart.dart';
import 'package:heartless/widgets/analytics/radial_bar_chart.dart';
import 'package:heartless/widgets/analytics/year_month_week_selector.dart';
import 'package:heartless/widgets/auth/custom_two_button_toggle.dart';
import 'package:provider/provider.dart';

class AnalyticsPage extends StatefulWidget {
  final String patientId;
  const AnalyticsPage({super.key, required this.patientId});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    AnalyticsNotifier analyticsNotifier =
        Provider.of<AnalyticsNotifier>(context, listen: false);

    analyticsNotifier.setSelectedDateWithoutNotifying(
      DateService.getStartOfWeek(DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetNotifier widgetNotifier =
        Provider.of<WidgetNotifier>(context, listen: false);
    AnalyticsNotifier analyticsNotifier =
        Provider.of<AnalyticsNotifier>(context, listen: false);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              centerTitle: true,
              title: const Text(
                'Analytics',
                textAlign: TextAlign.center,
              ),
              surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: YearMonthWeekSelector(),
            ),
            const SizedBox(height: 20),
            TwoButtonToggle(
              emailPhoneToggle: false,
              leftButtonText: 'Activites',
              rightButtonText: 'Readings',
            ),
            // const SizedBox(height: 20),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
          child: Consumer<AnalyticsNotifier>(builder: (context, value, child) {
            // widgetNotifier.setIsGraphEmptyWithoutNotifying(true);
            var activityGraphs = [
              RadialBarChart(
                patientId: widget.patientId,
                date: analyticsNotifier.chosenDate,
              ),
              LineDefaultChart(
                activityType: ActivityType.exercise,
                patientId: widget.patientId,
                date: analyticsNotifier.chosenDate,
              ),
              LineDefaultChart(
                activityType: ActivityType.medicine,
                patientId: widget.patientId,
                date: analyticsNotifier.chosenDate,
              ),
              LineDefaultChart(
                activityType: ActivityType.diet,
                patientId: widget.patientId,
                date: analyticsNotifier.chosenDate,
              ),
            ];

            List<Widget> readingGraphs = [
              BloodPressureChart(
                patientId: widget.patientId,
                date: analyticsNotifier.chosenDate,
              ),
              for (var readingType in MedicalReadingType.values)
                if (readingType != MedicalReadingType.bloodPressure)
                  GeneralReadingChart(
                    patientId: widget.patientId,
                    readingType: readingType,
                    date: analyticsNotifier.chosenDate,
                  ),
              SizedBox(
                height: 100,
                child: Center(child: Text('End of available data')),
              ),
            ];

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widgetNotifier.emailPhoneToggle
                  ? activityGraphs
                  : readingGraphs,
            );
          }),
        ),
      ),
    );
  }
}
