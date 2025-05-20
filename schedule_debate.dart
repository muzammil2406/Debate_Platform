import 'package:debate/src/services/debate_services.dart';
import 'package:debate/src/views/screens/all_debates_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class ScheduleDebate extends StatefulWidget {
  final String topicName;
  final String selectedTopic;
  const ScheduleDebate({
    super.key,
    required this.topicName,
    required this.selectedTopic,
  });

  @override
  State<ScheduleDebate> createState() => _ScheduleDebateState();
}

class _ScheduleDebateState extends State<ScheduleDebate> {
  final scheduleDebateFormKey = GlobalKey<FormState>();
  bool isScheduleSuccess = false;

  TextEditingController debateTitleController = TextEditingController();
  TextEditingController venueController = TextEditingController();

/* start time variables */
  TextEditingController _StartDateTimeController = TextEditingController();
  DateTime? _selectedStartDateTime; // Marking as nullable
  late int startEpoch;
  String startErrorText = '';
  bool startHasError = false; // Added boolean to track error state.

  /* end time variables */
  TextEditingController _EndDateTimeController = TextEditingController();
  DateTime? _selectedEndDateTime;
  late int endEpoch;
  String endErrorText = '';
  bool endHasError = false; // Added boolean to track error state.

  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    debateTitleController.addListener(validateInput);
    _StartDateTimeController.addListener(validateInput);
    _EndDateTimeController.addListener(validateInput);
    venueController.addListener(validateInput);
  }

  void validateInput() {
    setState(() {
      isButtonEnabled = (debateTitleController.text.isNotEmpty) &&
          (_StartDateTimeController.text.isNotEmpty && !startHasError) &&
          (_EndDateTimeController.text.isNotEmpty && !endHasError) &&
          (venueController.text.isNotEmpty);
    });
  }

  /* To check if the selected time is greater than current time (to prevent past time selection) */
  /* bool isTimeAfter(TimeOfDay currentTime, TimeOfDay selectedTime) {
      final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;
      final selectedTimeInMinutes = selectedTime.hour * 60 + selectedTime.minute;
      return selectedTimeInMinutes > currentTimeInMinutes;
    } */

  /* Selecting start date and time */
  Future<void> _selectStartDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedStartDateTime != null
            ? TimeOfDay.fromDateTime(_selectedStartDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        /* Obtaining the current Date and Time */
        final DateTime currentDateTime = DateTime.now();

        /* To ensure that the user can only select a date and time in the future or 
        the same day but later than the current time */
        if (selectedDateTime.isAfter(currentDateTime) ||
            (selectedDateTime.isAtSameMomentAs(currentDateTime) &&
                pickedTime.hour >= currentDateTime.hour &&
                pickedTime.minute >= currentDateTime.minute)) {
          setState(() {
            _selectedStartDateTime = selectedDateTime;

            /* Converting from DateTime? type to String type */
            String selectedStartDateTime = _selectedStartDateTime.toString();
            /* Converting from String type to DateTime type */
            DateTime startDateTime = DateTime.parse(selectedStartDateTime);
            /* Formating DateTime type into readable string type */
            String formattedStartDateTime =
                DateFormat('dd-MM-yyyy h:mm a').format(startDateTime);
            /* Assigning the formatted readable string type to textediting controller
              to display in textfield */
            _StartDateTimeController.text = formattedStartDateTime;
            /* converting DateTime format to epoch */
            startEpoch = _selectedStartDateTime!.millisecondsSinceEpoch;
            print('Start epoch: ${startEpoch}');
            startErrorText = '';
            startHasError = false; // Reset the error state.
            // _StartDateTimeController.text =
            //     _selectedStartDateTime.toString(); //to display in textfield
          });
        } else {
          setState(() {
            startErrorText = 'Please select a time in the future.';
            startHasError = true; // Set the error state.
          });
        }
      }
    } else {
      setState(() {
        _selectedStartDateTime = null;
      });
      _StartDateTimeController.clear(); // Clear the controller here
    }
  }

  /* Selecting End date and time */
  Future<void> _selectEndDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedEndDateTime != null
            ? TimeOfDay.fromDateTime(_selectedEndDateTime!)
            : TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // final DateTime currentDateTime = DateTime.now();

        if (_selectedStartDateTime != null &&
            (selectedDateTime.isAfter(_selectedStartDateTime!) ||
                (selectedDateTime.isAtSameMomentAs(_selectedStartDateTime!) &&
                    pickedTime.hour > _selectedStartDateTime!.hour) ||
                (selectedDateTime.isAtSameMomentAs(_selectedStartDateTime!) &&
                    pickedTime.hour == _selectedStartDateTime!.hour &&
                    pickedTime.minute > _selectedStartDateTime!.minute))) {
          setState(() {
            _selectedEndDateTime = selectedDateTime;
            /* Converting from DateTime? type to String type */
            String selectedEndDateTime = _selectedEndDateTime.toString();
            /* Converting from String type to DateTime type */
            DateTime endDateTime = DateTime.parse(selectedEndDateTime);
            /* Formating DateTime type into readable string type */
            String formattedEndDateTime =
                DateFormat('dd-MM-yyyy h:mm a').format(endDateTime);
            /* Assigning the formatted readable string type to textediting controller
              to display in textfield */
            _EndDateTimeController.text = formattedEndDateTime;
            /* converting DateTime format to epoch */
            endEpoch = _selectedEndDateTime!.millisecondsSinceEpoch;
            print('End epoch: ${endEpoch}');

            endErrorText = '';
            endHasError = false;
          });
        } else {
          setState(() {
            endErrorText = 'End time should be greater than start time';
            endHasError = true; // Set the error state.
          });
        }
      }
    } else {
      setState(() {
        _selectedEndDateTime = null;
      });
      _EndDateTimeController.clear(); // Clear the controller here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text("Schedule Debate, ${widget.selectedTopic}"),
        title: Text("Schedule Debate"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: [
              Form(
                key: scheduleDebateFormKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      /* Debate title */
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextFormField(
                          controller: debateTitleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Debate title',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Debate title';
                            }
                            return null;
                          },
                        ),
                      ),

                      /* Start date, time */
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextFormField(
                          controller: _StartDateTimeController,
                          readOnly: true,
                          onTap: _selectStartDateTime,
                          decoration: InputDecoration(
                            labelText: 'Start Date and Time',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter start date & time';
                            }
                            return null;
                          },
                        ),
                      ),
                      Visibility(
                        visible: startHasError,
                        child: Text(
                          startErrorText,
                          style: TextStyle(
                            // backgroundColor: Colors.blue,
                            color: Colors.red,
                          ),
                        ),
                      ),

                      /* End date, time */
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextFormField(
                          controller: _EndDateTimeController,
                          readOnly: true,
                          onTap: _selectEndDateTime,
                          decoration: InputDecoration(
                            labelText: 'End Date and Time',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter end date & time';
                            }
                            return null;
                          },
                        ),
                      ),
                      Visibility(
                        visible: endHasError,
                        child: Text(
                          endErrorText,
                          style: TextStyle(
                            // backgroundColor: Colors.blue,
                            color: Colors.red,
                          ),
                        ),
                      ),

                      /* venue */
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: TextFormField(
                          controller: venueController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'Venue',
                            labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter venue';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () async {
                                if (scheduleDebateFormKey.currentState!
                                    .validate()) {
                                  Map<String, dynamic> formData = {
                                    'debate_title': debateTitleController.text,
                                    'scheduled_time': startEpoch,
                                    'end_time': endEpoch,
                                    'venue': venueController.text,
                                  };

                                  print('scheduled_time: $startEpoch');
                                  print('end_time: $endEpoch');
                                  isScheduleSuccess = await DebateServices()
                                      .scheduleDebate(
                                          formData, widget.selectedTopic);
                                  if (isScheduleSuccess) {
                                    glb.showSnackBar(
                                        context,
                                        'The debate has been successfully scheduled',
                                        Colors.green);
                                    debateTitleController.clear();
                                    _StartDateTimeController.clear();
                                    _EndDateTimeController.clear();
                                    venueController.clear();

                                    FocusScope.of(context).unfocus();
                                    Navigator.of(context).pop();

                                    // Navigator.pushReplacement(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => AllDebatesList(),
                                    //   ),
                                    // );
                                  } else {
                                    glb.showSnackBar(
                                        context, 'Schedule failed', Colors.red);
                                  }
                                }
                              }
                            : null,
                        child: Text('Schedule Debate'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(45),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
