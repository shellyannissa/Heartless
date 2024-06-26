import 'package:flutter/material.dart';
import 'package:heartless/backend/controllers/activity_controller.dart';
import 'package:heartless/pages/log/file_upload_preview_page.dart';
import 'package:heartless/services/enums/activity_status.dart';
import 'package:heartless/services/enums/activity_type.dart';
import 'package:heartless/services/utils/toast_message.dart';
import 'package:heartless/shared/constants.dart';
import 'package:heartless/shared/models/activity.dart';
import 'package:heartless/shared/models/app_user.dart';
import 'package:heartless/shared/provider/widget_provider.dart';
import 'package:heartless/widgets/auth/text_input.dart';
import 'package:heartless/widgets/schedule/date_picker_button.dart';
import 'package:heartless/widgets/schedule/discret_date_picker.dart';
import 'package:heartless/widgets/schedule/time_picker_button.dart';
import 'package:provider/provider.dart';

class TaskFormPage extends StatefulWidget {
  final AppUser patient;
  final bool isEdit;
  final Activity? activity;
  TaskFormPage({
    super.key,
    required this.patient,
    this.isEdit = false,
    this.activity,
  });

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ActivityController _activityController = ActivityController();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final List<DateTime> _selectedDates = [];

  bool clicked = false;

  TimeOfDay _selectedTime = TimeOfDay.now();
  String dateDropDownValue = 'Specify a Period';
  ActivityType typeDropDownValue = ActivityType.medicine;
  // for date selector (date range selector)
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  // for date selector (date picker)

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    if (widget.isEdit && widget.activity != null) {
      _titleController.text = widget.activity!.name;
      _descriptionController.text = widget.activity!.description;
      typeDropDownValue = widget.activity!.type;
      _selectedTime = TimeOfDay.fromDateTime(widget.activity!.time);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetNotifier widgetNotifier =
        Provider.of<WidgetNotifier>(context, listen: false);
    final List<String> listOfDropdownItems = [];
    for (ActivityType type in ActivityType.values) {
      listOfDropdownItems.add(type.value);
    }
    Future<void> _addActivityStartToEnd(Activity activity) async {
      // add activity from start date to end date
      while (
          startDate.isBefore(endDate) || startDate.isAtSameMomentAs(endDate)) {
        activity.time = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        await _activityController.addActivity(activity);
        startDate = startDate.add(const Duration(days: 1));
      }
    }

    Future<void> _addActivityForSelectedDates(Activity activity) async {
      // add activity for selected dates
      for (DateTime date in _selectedDates) {
        activity.time = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        await _activityController.addActivity(activity);
      }
    }

    void _editForm(activity) async {
      if (!_formKey.currentState!.validate()) {
        return;
      }
      // handling multiple clicks
      if (clicked) {
        ToastMessage()
            .showError('Please wait for the previous task to complete');
        return;
      }
      clicked = true;
      activity.name = _titleController.text;
      activity.description = _descriptionController.text;
      activity.type = typeDropDownValue;

      activity.time = DateTime(
        activity.time.year,
        activity.time.month,
        activity.time.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _activityController.editActivity(activity);

      clicked = false;

      // clear form
      _titleController.clear();
      _descriptionController.clear();

      ToastMessage().showSuccess('Task edited successfully');
      // go back to previous page
      Navigator.pop(context);
    }

    void _submitForm(WidgetNotifier widgetNotifer) async {
      if (!_formKey.currentState!.validate()) {
        return;
      }

      if (startDate.isAfter(endDate)) {
        ToastMessage().showError('Start date cannot be after end date');
        return;
      }

      if (dateDropDownValue == 'Selective Days' && _selectedDates.isEmpty) {
        ToastMessage().showError('Please select at least one date');
        return;
      }
      // handling multiple clicks
      if (clicked) {
        ToastMessage()
            .showError('Please wait for the previous task to complete');
        return;
      }
      clicked = true;

      // create activity
      Activity activity = Activity();
      activity.name = _titleController.text;
      activity.description = _descriptionController.text;
      activity.type = typeDropDownValue;
      activity.status = ActivityStatus.upcoming;
      activity.patientId = widget.patient.uid;

      if (dateDropDownValue == 'Specify a Period') {
        await _addActivityStartToEnd(activity);
      } else {
        await _addActivityForSelectedDates(activity);
      }

      clicked = false;

      // clear form
      _titleController.clear();
      _descriptionController.clear();

      ToastMessage().showSuccess('Task added successfully');
      // go back to previous page
      widgetNotifier.setLoading(false);
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          widget.isEdit ? 'Edit Task' : 'Create Task',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SelectorWidgetRow(
                    text: 'Category',
                    childWidget: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          border: Border.all(
                            color: Theme.of(context).shadowColor,
                            width: 0.6,
                          ),
                          boxShadow: [
                            BoxShadow(
                              // color: Constants.customGray,
                              color: Theme.of(context).highlightColor,
                              blurRadius: 0.5,
                              spreadRadius: 0.5,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: DropDownWidget(
                          dropdownItems: listOfDropdownItems,
                          dropdownValue: typeDropDownValue.value,
                          onChanged: (newValue) {
                            setState(() {
                              // todo: dont use setstate, user widgetNotifier
                              typeDropDownValue = activityFromString(newValue);
                            });
                          },
                        ))),
                const SizedBox(height: 10),
                TextFieldInput(
                  textEditingController: _titleController,
                  hintText: 'Enter title of task',
                  labelText: 'Title',
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                TextFieldInput(
                  textEditingController: _descriptionController,
                  hintText: 'Instructions or Description',
                  labelText: 'Description',
                  maxLines: 2,
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 10),
                SelectorWidgetRow(
                  text: 'Time',
                  childWidget: TimePickerButton(
                    selectedTime: _selectedTime,
                    onTimeChanged: (newTime) {
                      setState(() {
                        _selectedTime = newTime;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                widget.isEdit
                    ? Container()
                    : Column(
                        children: [
                          SelectorWidgetRow(
                              text: 'Date',
                              childWidget: Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 10, 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).cardColor,
                                    border: Border.all(
                                      color: Theme.of(context).shadowColor,
                                      width: 0.6,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Constants.customGray,
                                        // color: Theme.of(context).shadowColor.withOpacity(0.5),
                                        blurRadius: 0.5,
                                        spreadRadius: 0.5,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                  child: DropDownWidget(
                                    dropdownItems: const [
                                      'Specify a Period',
                                      'Selective Days'
                                    ],
                                    dropdownValue: dateDropDownValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        dateDropDownValue = newValue;
                                      });
                                    },
                                  ))),
                          const SizedBox(height: 20),
                          dateDropDownValue == 'Specify a Period'
                              ? DateRangeSelector(
                                  startDate: startDate,
                                  endDate: endDate,
                                  onStartDateChanged: (newDate) {
                                    startDate = newDate;
                                  },
                                  onEndDateChanged: (newDate) {
                                    endDate = newDate;
                                  })
                              : DiscreteDateSelector(
                                  selectedDates: _selectedDates),
                        ],
                      ),
                const SizedBox(height: 60),
                CustomFormSubmitButton(
                  onTap: () {
                    widgetNotifier.setLoading(true);
                    if (widget.isEdit) {
                      _editForm(widget.activity!);
                    } else {
                      _submitForm(widgetNotifier);
                    }
                    widgetNotifier.setLoading(false);
                  },
                  text: widget.isEdit ? 'Edit Task' : 'Add Task',
                  padding: 30,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DropDownWidget extends StatelessWidget {
  final String dropdownValue;
  final ValueChanged<String> onChanged;
  final List<String> dropdownItems;

  const DropDownWidget({
    super.key,
    required this.dropdownValue,
    required this.onChanged,
    required this.dropdownItems,
  });

  // String dropdownValue = 'Selective Days';
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      underline: Container(height: 0),
      value: dropdownValue,
      iconSize: 24,
      onChanged: (String? newValue) {
        onChanged(newValue!);
      },
      items: dropdownItems.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).shadowColor,
                ),
              )),
        );
      }).toList(),
    );
  }
}

class SelectorWidgetRow extends StatelessWidget {
  final Widget childWidget;
  final String text;

  const SelectorWidgetRow({
    super.key,
    required this.childWidget,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 30,
        ),
        Container(
            padding: const EdgeInsets.all(10),
            // width: 120,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // color: Theme.of(context).cardColor,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 22,
                  color: Theme.of(context).shadowColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )),
        const SizedBox(width: 10),
        childWidget,
      ],
    );
  }
}

class DateRangeSelector extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;

  const DateRangeSelector({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  });

  @override
  _DateRangeSelectorState createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorWidgetRow(
          childWidget: Flexible(
            // Wrap DatePickerButton in Flexible
            child: DatePickerButton(
              selectedDate: _startDate,
              startDate: DateTime.now(),
              onChanged: (newDate) {
                setState(() {
                  // todo: implement using widgetNotifier
                  _startDate = newDate;
                });
                widget.onStartDateChanged(newDate);
              },
            ),
          ),
          text: 'Start Date',
        ),
        const SizedBox(height: 20),
        SelectorWidgetRow(
          childWidget: Flexible(
            // Wrap DatePickerButton in Flexible
            child: DatePickerButton(
              selectedDate: _endDate,
              startDate: _startDate,
              onChanged: (newDate) {
                setState(() {
                  // todo: implement using widgetNotifier
                  _endDate = newDate;
                });
                widget.onEndDateChanged(newDate);
              },
            ),
          ),
          text: 'End Date  ',
        ),
      ],
    );
  }
}
