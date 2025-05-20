import 'package:debate/src/models/debate.dart';
import 'package:debate/src/services/debate_services.dart';
import 'package:debate/src/views/screens/all_debates_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:debate/src/views/utils/global.dart' as glb;

class UpdateDebate extends StatefulWidget {
  final int topicId;
  final int debateId;

  const UpdateDebate({
    super.key,
    required this.topicId,
    required this.debateId,
  });

  @override
  State<UpdateDebate> createState() => _UpdateDebateState();
}

class _UpdateDebateState extends State<UpdateDebate> {
  final updateDebateFormKey = GlobalKey<FormState>();
  bool isUpdateSuccess = false;

  TextEditingController debateTitleController = TextEditingController();
  TextEditingController venueController = TextEditingController();

/* start time variables */
  TextEditingController startDateTimeController = TextEditingController();
  DateTime? _selectedStartDateTime; // Marking as nullable
  late int startEpoch;
  String startErrorText = '';
  bool startHasError = false; // Added boolean to track error state.
  late DateTime
      scheduledDate; // Variable to store the converted start date-time (from epoch format to DateTime format)

  /* end time variables */
  TextEditingController endDateTimeController = TextEditingController();
  DateTime? _selectedEndDateTime;
  late int endEpoch;
  String endErrorText = '';
  bool endHasError = false; // Added boolean to track error state.

  bool isButtonEnabled = false;
  Debate? specificDebateObjects;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSpecificDebate();
  }

  Future<void> fetchSpecificDebate() async {
    try {
      final fetchedSpecificDebate = await DebateServices()
          .displaySpecificDebate(widget.topicId, widget.debateId);
      setState(() {
        specificDebateObjects = fetchedSpecificDebate;
        // print('debate information: $specificDebateObjects');
        // print(specificDebateObjects!.scheduledTime);

        /* Assign scheduledTime(int) fetched from DB to startEpoch(int) */
        startEpoch = specificDebateObjects!.scheduledTime;

        /* Converting from epoch(int) format to DateTime format */
        scheduledDate = DateTime.fromMillisecondsSinceEpoch(
            specificDebateObjects!.scheduledTime);

        /* Formating DateTime into readable format */
        String formattedScheduleDT =
            DateFormat('dd-MM-yyyy, h:mm a').format(scheduledDate);

        /* Assigning the formatted readable format date to startDateTimeController to show in textfield */
        startDateTimeController.text = formattedScheduleDT;

        /* Assign endTime(int) fetched from DB to endEpoch(int) */
        endEpoch = specificDebateObjects!.endTime;

        /* Converting from epoch(int) format to DateTime format */
        DateTime endDate =
            DateTime.fromMillisecondsSinceEpoch(specificDebateObjects!.endTime);

        /* Formating DateTime into readable format */
        String formattedEndDT =
            DateFormat('dd-MM-yyyy, h:mm a').format(endDate);

        /* Assigning the formatted readable format date to endDateTimeController to display in textfield */
        endDateTimeController.text = formattedEndDT;

        /* Assigning debateTitle fetched from DB to debateTitleController to display in textfield */
        debateTitleController.text = specificDebateObjects!.debateTitle;

        /* Assigning venue fetched from DB to venueController to display in textfield */
        venueController.text = specificDebateObjects!.venue;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error in fetchSpecificDebate: $e');
    }
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
            startDateTimeController.text = formattedStartDateTime;
            /* converting DateTime format to epoch */
            startEpoch = _selectedStartDateTime!.millisecondsSinceEpoch;
            print('Start epoch: ${startEpoch}');
            startErrorText = '';
            startHasError = false; // Reset the error state.
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
      startDateTimeController.clear(); // Clear the controller here
    }
  }

/* selecting end date, time */
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

        if (
            /* To check whether the selected end time is greater than start time (if start date, time is also selected while updating) */
            (_selectedStartDateTime != null &&
                    (selectedDateTime.isAfter(_selectedStartDateTime!) ||
                        (selectedDateTime
                                .isAtSameMomentAs(_selectedStartDateTime!) &&
                            pickedTime.hour > _selectedStartDateTime!.hour) ||
                        (selectedDateTime
                                .isAtSameMomentAs(_selectedStartDateTime!) &&
                            pickedTime.hour == _selectedStartDateTime!.hour &&
                            pickedTime.minute >
                                _selectedStartDateTime!.minute))) ||
                /* To check whether the selected end time is greater than start time (if start date, time is not selected now
             and using previously selected start date, time) */
                (_selectedStartDateTime == null &&
                    (selectedDateTime.isAfter(scheduledDate) ||
                        (selectedDateTime.isAtSameMomentAs(scheduledDate) &&
                            pickedTime.hour > scheduledDate.hour) ||
                        (selectedDateTime.isAtSameMomentAs(scheduledDate) &&
                            pickedTime.hour == scheduledDate.hour &&
                            pickedTime.minute > scheduledDate.minute)))) {
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
            endDateTimeController.text = formattedEndDateTime;
            /* converting DateTime format to epoch */
            endEpoch = _selectedEndDateTime!.millisecondsSinceEpoch;
            // print('End epoch: ${endEpoch}');
            // print('selected end time>>>>> $selectedDateTime');

            endErrorText = '';
            endHasError = false;
          });
        } else {
          setState(() {
            // endErrorText = 'Please select a time in the future.';
            endErrorText = 'End time should be greater than start time';
            endHasError = true; // Set the error state.
          });
        }
      }
    } else {
      setState(() {
        _selectedEndDateTime = null;
      });
      endDateTimeController.clear(); // Clear the controller here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Debate"),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Form(
                      key: updateDebateFormKey,
                      /* onChanged callback is set on the Form widget, 
                      that gets called whenever any form field within the Form changes its value. */
                      onChanged: () {
                        setState(() {
                          /* validate method is called on the FormState to check the validity of the entire form.
                          It internally triggers the validation of each form field based on the validation logic
                           specified in the TextFormField's validator property. validate() returns either true(if no error for any field)
                           or false(if any field has error)  */
                          /* isButtonEnabled is set based on the current validity of the form. 
                           If the form is valid, isButtonEnabled is set to true; otherwise, it is set to false */
                          isButtonEnabled =
                              updateDebateFormKey.currentState?.validate() ??
                                  false;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: [
                            /* Debate title */
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: TextFormField(
                                controller: debateTitleController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: 'Debate title',
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Debate title';
                                  }
                                },
                              ),
                            ),

                            /* Start date, time */
                            Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: TextFormField(
                                controller: startDateTimeController,
                                readOnly: true,
                                onTap: _selectStartDateTime,
                                decoration: InputDecoration(
                                  labelText: 'Start Date and Time',
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
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
                                controller: endDateTimeController,
                                readOnly: true,
                                onTap: _selectEndDateTime,
                                decoration: InputDecoration(
                                  labelText: 'End Date and Time',
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
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
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelText: 'Venue',
                                  labelStyle:
                                      TextStyle(fontWeight: FontWeight.bold),
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
                                      if (updateDebateFormKey.currentState!
                                          .validate()) {
                                        if (endEpoch > startEpoch) {
                                          Map<String, dynamic> formData = {
                                            'debate_title':
                                                debateTitleController.text,
                                            'scheduled_time': startEpoch,
                                            'end_time': endEpoch,
                                            'venue': venueController.text,
                                          };

                                          // print('scheduled_time: $startEpoch');
                                          // print('end_time: $endEpoch');
                                          // print(
                                          //     'start date time>>>>> $scheduledDate');
                                          isUpdateSuccess =
                                              await DebateServices()
                                                  .updateDebate(
                                                      widget.topicId,
                                                      widget.debateId,
                                                      formData);
                                          if (isUpdateSuccess) {
                                            glb.showSnackBar(
                                                context,
                                                'The debate has been successfully updated',
                                                Colors.green);
                                            debateTitleController.clear();
                                            startDateTimeController.clear();
                                            endDateTimeController.clear();
                                            venueController.clear();

                                            FocusScope.of(context).unfocus();

                                            Navigator.of(context).pop();
                                            // Navigator.pushReplacement(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) =>
                                            //         AllDebatesList(),
                                            //   ),
                                            // );
                                          } else {
                                            glb.showSnackBar(context,
                                                'Update failed', Colors.red);
                                          }
                                        } else {
                                          glb.showSnackBar(
                                              context,
                                              'Start time is greater than end time',
                                              Colors.red);
                                        }
                                      }
                                    }
                                  : null,
                              child: Text('Update Debate'),
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
